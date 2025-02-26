import 'package:app_dat_xe/src/app.dart';
import 'package:app_dat_xe/src/resources/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:app_dat_xe/src/blocs/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cấu hình thanh trạng thái
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Làm trong suốt
      statusBarIconBrightness: Brightness.dark, // Icon màu tối (dark mode)
    ),
  );

  // Khởi tạo Firebase
  await Firebase.initializeApp();

  runApp(
    ScreenUtilInit(
      designSize: Size(384, 856.1777777777778), // Điều chỉnh theo màn hình chuẩn của bạn
      minTextAdapt: true,
      builder: (context, child) {
        return MyApp(
          AuthBloc(),
          MaterialApp(
            home: LoginPage(),
            debugShowCheckedModeBanner: false,
          ),
        );
      },
    ),
  );
}
