import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DashboardHeader extends StatelessWidget {
  final String fecha;
  final String hora;
  final String jornada;

  const DashboardHeader({
    Key? key,
    required this.fecha,
    required this.hora,
    required this.jornada,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              padding: EdgeInsets.all(8.w),
              child: Icon(
                Icons.dashboard_rounded,
                color: const Color(0xFF3B82F6),
                size: 28.w,
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              'Panel de Control',
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
                letterSpacing: -1,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today_rounded, size: 16.w, color: const Color(0xFF64748B)),
                SizedBox(width: 6.w),
                Text(
                  fecha,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: const Color(0xFFBAE6FD)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.access_time_rounded, size: 16.w, color: const Color(0xFF0EA5E9)),
                  SizedBox(width: 6.w),
                  Text(
                    jornada,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0369A1),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    hora,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF0369A1),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
} 