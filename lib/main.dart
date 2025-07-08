import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'providers/asistencia_provider.dart';
import 'services/api_service.dart';
import 'screens/dashboard_screen.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null); // Inicializa el locale español para fechas
  
  // Cambia este valor a true para usar datos de prueba
  const bool usarMock = true;

  // Inicializar el servicio de API (real o mock)
  final apiService = usarMock ? MockApiService() : ApiService();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AsistenciaProvider(apiService: apiService),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1920, 1080), // Tamaño de diseño para TV 16:9
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Dashboard de Asistencia SENA',
          theme: ThemeData(
            colorScheme: ColorScheme.light(
              primary: Color(AppThemes.primaryColor),
              secondary: Color(AppThemes.secondaryColor),
              background: Color(AppThemes.backgroundColor),
              surface: Colors.white,
              onBackground: Color(AppThemes.textColor),
              onSurface: Color(AppThemes.textColor),
              brightness: Brightness.light,
            ),
            textTheme: GoogleFonts.robotoTextTheme(
              Theme.of(context).textTheme.copyWith(
                    displayLarge: TextStyle(
                      fontSize: 64.sp,
                      fontWeight: FontWeight.bold,
                      color: Color(AppThemes.textColor),
                    ),
                    displayMedium: TextStyle(
                      fontSize: 48.sp,
                      fontWeight: FontWeight.w600,
                      color: Color(AppThemes.textColor),
                    ),
                    displaySmall: TextStyle(
                      fontSize: 36.sp,
                      fontWeight: FontWeight.w500,
                      color: Color(AppThemes.textColor),
                    ),
                    headlineMedium: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w500,
                      color: Color(AppThemes.textColor),
                    ),
                    bodyLarge: TextStyle(
                      fontSize: 18.sp,
                      color: Color(AppThemes.textColor),
                    ),
                    bodyMedium: TextStyle(
                      fontSize: 16.sp,
                      color: Color(AppThemes.textColor),
                    ),
                  ),
            ),
            primaryTextTheme: GoogleFonts.robotoTextTheme(
              Theme.of(context).primaryTextTheme,
            ),
            scaffoldBackgroundColor: Color(AppThemes.backgroundColor),
            appBarTheme: AppBarTheme(
              backgroundColor: Color(AppThemes.primaryColor),
              elevation: 0,
              centerTitle: true,
              titleTextStyle: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            useMaterial3: true,
          ),
          home: const DashboardScreen(),
        );
      },
    );
  }
}
