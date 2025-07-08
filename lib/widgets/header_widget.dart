import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../utils/constants.dart';

class HeaderWidget extends StatefulWidget {
  const HeaderWidget({super.key});

  @override
  State<HeaderWidget> createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  late String _fechaHora;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _actualizarHora();
    // Actualizar la hora cada minuto
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      setState(_actualizarHora);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _actualizarHora() {
    final now = DateTime.now();
    final formatter = DateFormat("EEEE, d 'de' MMMM 'de' y - hh:mm a", 'es_ES');
    setState(() {
      _fechaHora = formatter.format(now);
      // Capitalizar la primera letra
      _fechaHora = _fechaHora[0].toUpperCase() + _fechaHora.substring(1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Logo y título
        Row(
          children: [
            // Logo del SENA
            Image.asset(
              'assets/images/logo_sena.png',
              width: 80.w,
              height: 80.h,
              fit: BoxFit.contain,
            ),
            SizedBox(width: 16.w),
            // Título
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SISTEMA DE CONTROL DE ASISTENCIA',
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                    color: Color(AppThemes.primaryColor),
                  ),
                ),
                Text(
                  'CENTRO INDUSTRIAL Y DE AVIACIÓN',
                  style: TextStyle(
                    fontSize: 24.sp,
                    color: Color(AppThemes.textColor),
                  ),
                ),
              ],
            ),
          ],
        ),
        
        // Fecha y hora
        Container(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            _fechaHora,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w500,
              color: Color(AppThemes.textColor),
            ),
          ),
        ),
      ],
    );
  }
}
