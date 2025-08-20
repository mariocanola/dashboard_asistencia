import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Sistema de gestión de foco para navegación con control remoto en TV
class TVFocusSystem {
  static final Map<String, FocusNode> _focusNodes = {};
  static FocusNode? _currentFocus;
  
  /// Registra un nodo de foco con un identificador único
  static FocusNode registerFocusNode(String id) {
    if (!_focusNodes.containsKey(id)) {
      _focusNodes[id] = FocusNode();
    }
    return _focusNodes[id]!;
  }
  
  /// Obtiene un nodo de foco por su ID
  static FocusNode? getFocusNode(String id) {
    return _focusNodes[id];
  }
  
  /// Mueve el foco en la dirección especificada
  static void moveFocus(BuildContext context, TraversalDirection direction) {
    FocusScope.of(context).focusInDirection(direction);
  }
  
  /// Limpia todos los nodos de foco
  static void dispose() {
    for (var node in _focusNodes.values) {
      node.dispose();
    }
    _focusNodes.clear();
  }
}

/// Widget envolvente que hace cualquier widget enfocable para TV
class TVFocusableWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onSelect;
  final VoidCallback? onFocus;
  final VoidCallback? onUnfocus;
  final String? focusId;
  final EdgeInsets padding;
  final Color focusColor;
  final double focusWidth;
  final BorderRadius? borderRadius;
  
  const TVFocusableWidget({
    Key? key,
    required this.child,
    this.onSelect,
    this.onFocus,
    this.onUnfocus,
    this.focusId,
    this.padding = const EdgeInsets.all(4),
    this.focusColor = Colors.blue,
    this.focusWidth = 3.0,
    this.borderRadius,
  }) : super(key: key);
  
  @override
  State<TVFocusableWidget> createState() => _TVFocusableWidgetState();
}

class _TVFocusableWidgetState extends State<TVFocusableWidget> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  
  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusId != null 
        ? TVFocusSystem.registerFocusNode(widget.focusId!)
        : FocusNode();
    
    _focusNode.addListener(_handleFocusChange);
  }
  
  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
    
    if (_isFocused) {
      widget.onFocus?.call();
    } else {
      widget.onUnfocus?.call();
    }
  }
  
  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    if (widget.focusId == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.select ||
              event.logicalKey == LogicalKeyboardKey.enter) {
            widget.onSelect?.call();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: widget.padding,
        decoration: BoxDecoration(
          border: _isFocused
              ? Border.all(
                  color: widget.focusColor,
                  width: widget.focusWidth,
                )
              : null,
          borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
        ),
        child: widget.child,
      ),
    );
  }
}

/// Maneja la navegación del control remoto a nivel de aplicación
class TVNavigationHandler extends StatelessWidget {
  final Widget child;
  
  const TVNavigationHandler({
    Key? key,
    required this.child,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        LogicalKeySet(LogicalKeyboardKey.arrowUp): 
            const DirectionalFocusIntent(TraversalDirection.up),
        LogicalKeySet(LogicalKeyboardKey.arrowDown): 
            const DirectionalFocusIntent(TraversalDirection.down),
        LogicalKeySet(LogicalKeyboardKey.arrowLeft): 
            const DirectionalFocusIntent(TraversalDirection.left),
        LogicalKeySet(LogicalKeyboardKey.arrowRight): 
            const DirectionalFocusIntent(TraversalDirection.right),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          DirectionalFocusIntent: DirectionalFocusAction(),
        },
        child: child,
      ),
    );
  }
}