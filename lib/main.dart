import 'package:app_dat_xe/src/app.dart';
import 'package:app_dat_xe/src/resources/home_page.dart';
import 'package:app_dat_xe/src/resources/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:app_dat_xe/src/blocs/auth_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cấu hình thanh trạng thái
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Làm trong suốt
      statusBarIconBrightness: Brightness.dark, // Icon màu tối
    ),
  );

  // Khởi tạo Firebase
  await Firebase.initializeApp();

  runApp(
    ScreenUtilInit(
      designSize: const Size(384, 856.1777777777778),
      minTextAdapt: true,
      builder: (context, child) {
        return FutureBuilder<bool>(
          future: checkLoginState(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const MaterialApp(
                home: Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                ),
              );
            } else {
              bool isLoggedIn = snapshot.data ?? false;
              return MyApp(
                AuthBloc(),
                MaterialApp(
                  home: isLoggedIn ? HomePage() : LoginPage(),
                  debugShowCheckedModeBanner: false,
                ),
              );
            }
          },
        );
      },
    ),
  );
}

Future<bool> checkLoginState() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  if (isLoggedIn && FirebaseAuth.instance.currentUser != null) {
    return true;
  }
  return false;
}
