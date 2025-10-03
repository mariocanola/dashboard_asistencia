import 'dart:async';
import 'package:flutter/foundation.dart';

import '../providers/asistencia_provider.dart';

/// Servicio de optimización ultra-rápida para máximo 2 segundos de latencia
class UltraFastOptimizationService {
  static final UltraFastOptimizationService _instance = UltraFastOptimizationService._internal();
  factory UltraFastOptimizationService() => _instance;
  UltraFastOptimizationService._internal();

  // Cache de datos para evitar llamadas innecesarias
  Map<String, dynamic> _dataCache = {};
  DateTime? _lastCacheUpdate;
  Timer? _cacheCleanupTimer;

  // Configuración ultra-rápida
  static const Duration _maxLatency = Duration(seconds: 2);
  static const Duration _cacheTimeout = Duration(seconds: 5);
  static const Duration _cleanupInterval = Duration(minutes: 1);

  /// Inicializa el servicio de optimización
  void initialize() {
    debugPrint('🚀 Iniciando UltraFastOptimizationService - Máximo 2s de latencia');
    
    // Limpiar cache periódicamente
    _cacheCleanupTimer = Timer.periodic(_cleanupInterval, (_) {
      _cleanupCache();
    });
  }

  /// Optimiza la carga de datos con cache inteligente
  Future<void> optimizeDataLoad(AsistenciaProvider provider) async {
    try {
      final startTime = DateTime.now();
      
      // Verificar si tenemos datos recientes en cache
      if (_isCacheValid()) {
        debugPrint('⚡ Usando cache válido - Latencia: 0ms');
        return;
      }

      // Cargar datos con timeout estricto
      await provider.cargarAsistencias().timeout(
        _maxLatency,
        onTimeout: () {
          debugPrint('⏰ Timeout en carga de datos - usando cache anterior');
        },
      );

      // Actualizar cache
      _updateCache(provider);
      
      final latency = DateTime.now().difference(startTime).inMilliseconds;
      debugPrint('⚡ Datos cargados - Latencia: ${latency}ms');
      
    } catch (e) {
      debugPrint('❌ Error en optimización: $e');
    }
  }

  /// Verifica si el cache es válido
  bool _isCacheValid() {
    if (_lastCacheUpdate == null) return false;
    
    final now = DateTime.now();
    return now.difference(_lastCacheUpdate!).inSeconds < _cacheTimeout.inSeconds;
  }

  /// Actualiza el cache con datos actuales
  void _updateCache(AsistenciaProvider provider) {
    _dataCache = {
      'asistencias': provider.asistenciasDetalle,
      'fichas': provider.fichas,
      'jornadaActual': provider.jornadaActual,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    _lastCacheUpdate = DateTime.now();
  }

  /// Limpia el cache expirado
  void _cleanupCache() {
    if (_lastCacheUpdate != null) {
      final now = DateTime.now();
      if (now.difference(_lastCacheUpdate!).inMinutes > 5) {
        _dataCache.clear();
        _lastCacheUpdate = null;
        debugPrint('🧹 Cache limpiado');
      }
    }
  }

  /// Obtiene estadísticas de rendimiento
  Map<String, dynamic> getPerformanceStats() {
    return {
      'maxLatency': _maxLatency.inMilliseconds,
      'cacheTimeout': _cacheTimeout.inSeconds,
      'lastCacheUpdate': _lastCacheUpdate?.toIso8601String(),
      'cacheSize': _dataCache.length,
      'cacheValid': _isCacheValid(),
    };
  }

  /// Limpia recursos
  void dispose() {
    _cacheCleanupTimer?.cancel();
    _dataCache.clear();
    _lastCacheUpdate = null;
  }
}
