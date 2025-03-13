import 'package:app_dat_xe/src/app.dart';
import 'package:app_dat_xe/src/resources/dialog/loading_dialog.dart';
import 'package:app_dat_xe/src/resources/dialog/msg_dialog.dart';
import 'package:app_dat_xe/src/resources/home_page.dart';
import 'package:app_dat_xe/src/resources/phone_number_page.dart';
import 'package:app_dat_xe/src/resources/register_page.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/gestures.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("users");

  // final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isPressed1 = false;
  bool isPressed2 = false;
  bool _isPressed1 = false;
  bool _isPressed = false;

  bool _obscureText = true; // Mật khẩu mặc định bị ẩn

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Future<void> signInWithGoogle() async {
      try {
        await GoogleSignIn().signOut(); // Đăng xuất trước khi đăng nhập lại
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) {
          print("Google Sign-In bị hủy");
          return;
        }

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Kiểm tra email trong Firebase Realtime Database
        DatabaseReference dbRef =
            FirebaseDatabase.instance.ref().child('users');
        DataSnapshot snapshot = await dbRef.get();

        String? userUid;
        String? signInMethod;

        if (snapshot.exists) {
          Map<dynamic, dynamic> users = snapshot.value as Map<dynamic, dynamic>;
          users.forEach((uid, userData) {
            if (userData["email"] == googleUser.email) {
              userUid = uid;
              signInMethod = userData["signInMethod"];
            }
          });
        }

        if (userUid != null && signInMethod == "email/pass") {
          print(
              "Tài khoản đã đăng ký bằng email & password. Không thể đăng nhập bằng Google.");
          Future.delayed(const Duration(milliseconds: 200), () {
            _showCustomSnackBar(
              context,
              "Tài khoản này đã đăng ký bằng email & password. Hãy đăng nhập theo cách đó.",
              Colors.red,
              Icons.error,
            );
          });
          return;
        }

        // Nếu không bị chặn, tiến hành đăng nhập Google
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
        User? user = userCredential.user;

        if (user != null) {
          print("Google Sign-In thành công: ${user.email}");

          DatabaseReference ref =
              FirebaseDatabase.instance.ref().child('users/${user.uid}');
          DataSnapshot userSnapshot = await ref.get();

          if (userSnapshot.exists) {
            print("Tài khoản đã tồn tại. Kiểm tra số điện thoại...");

            Map<String, dynamic> userData =
                Map<String, dynamic>.from(userSnapshot.value as Map);
            if (userData.containsKey("phone") &&
                userData["phone"].toString().isNotEmpty) {
              print("Người dùng đã có số điện thoại, chuyển đến HomePage");

              // ✅ Chỉ lưu trạng thái đăng nhập nếu vào thẳng HomePage
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setBool("isLoggedIn", true);
              await prefs.setString("userEmail", user.email ?? "");

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
                (Route<dynamic> route) => false,
              );
            } else {
              print("Người dùng chưa có số điện thoại, yêu cầu nhập");

              if (ModalRoute.of(context)?.settings.name != 'PhoneNumberPage') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PhoneNumberPage(user: user),
                    settings: const RouteSettings(name: 'PhoneNumberPage'),
                  ),
                );
              }
            }
          } else {
            print(
                "Người dùng chưa đăng ký trong database, yêu cầu nhập số điện thoại");

            if (ModalRoute.of(context)?.settings.name != 'PhoneNumberPage') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => PhoneNumberPage(user: user),
                  settings: const RouteSettings(name: 'PhoneNumberPage'),
                ),
              );
            }
          }
        }
      } catch (e) {
        print("Lỗi khi đăng nhập với Google: $e");
      }
    }

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: SafeArea(
            child: Container(
          padding: EdgeInsets.fromLTRB(30.w, 0.h, 30.w, 0.h),
          constraints: const BoxConstraints.expand(),
          color: Colors.white,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 60.h,
                ),
                Transform.scale(
                  scale: 1.01, // Phóng to ảnh
                  child: Image.asset(
                    'assets/ic_car_yellow.png',
                    width: MediaQuery.of(context).size.width * 0.55,
                    height: MediaQuery.of(context).size.height * 0.2,
                    fit: BoxFit.contain,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0.w, 0.h, 0.w, 6.h),
                  child: Text(
                    'Chào mừng trở lại!',
                    style: GoogleFonts.openSans(
                        fontSize: 35.sp,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  'Đăng nhập để tiếp tục sử dụng tApp',
                  style: TextStyle(
                      fontSize: 16.sp,
                      color: Color(0xff606470),
                      fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0.w, 50.h, 0.w, 20.h),
                  child: TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    // Bàn phím nhập email
                    style: TextStyle(
                      fontSize: 18.sp,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(fontSize: 16.sp),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 14.h, horizontal: 14.w),
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(left: 20.w, right: 10.w),
                        child: Icon(Icons.email),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 1.w),
                        borderRadius: BorderRadius.all(Radius.circular(30.r)),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0.w, 3.h, 0.w, 5.h),
                  child: TextField(
                    controller: _passController,
                    style: TextStyle(fontSize: 18.sp, color: Colors.black),
                    obscureText: _obscureText, // Kiểm soát ẩn/hiện mật khẩu
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu',
                      labelStyle: TextStyle(fontSize: 16.sp),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 14.h, horizontal: 14.w),
                      // Tăng độ rộng trên và dưới
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(left: 20.w, right: 10.w),
                        // Đẩy icon vào bên phải một chút
                        child: Icon(Icons.lock),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility
                              : Icons.visibility_off,
                          // Thay đổi icon
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText =
                                !_obscureText; // Đảo trạng thái hiển thị mật khẩu
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xffCED0D2), width: 1.w),
                        borderRadius: BorderRadius.all(Radius.circular(30.r)),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0.w, 10.h, 0.w, 30.h),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: StatefulBuilder(
                        builder: (context, setState) {
                          return GestureDetector(
                            onTapDown: (_) =>
                                setState(() => _isPressed1 = true),
                            onTapCancel: () =>
                                setState(() => _isPressed1 = false),
                            onTapUp: (_) {
                              setState(() => _isPressed1 = false);
                              _onForgotPasswordClick();
                            },
                            child: Text(
                              'Quên mật khẩu?',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0077BE).withOpacity(
                                    _isPressed1 ? 0.6 : 1.0), // Hiệu ứng nhấn
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0.w, 5.h, 0.w, 8.h),
                  child: GestureDetector(
                    onTap: _onLoginClick,
                    onTapDown: (_) => setState(() => isPressed1 = true),
                    // Khi nhấn xuống
                    onTapUp: (_) => setState(() => isPressed1 = false),
                    // Khi thả ra
                    onTapCancel: () => setState(() => isPressed1 = false),
                    // Khi hủy nhấn
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      width: double.infinity,
                      height: 52.h,
                      transform: isPressed1
                          ? Matrix4.translationValues(2.w, 2.h, 0)
                          : Matrix4.identity(),
                      // Hiệu ứng lún xuống
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30.r),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xff4381c9),
                            Color(0xff316ec5)
                          ], // Hiệu ứng ánh sáng
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: isPressed1
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  // Bóng mờ hơn khi nhấn
                                  offset: Offset(2.w, 2.h),
                                  blurRadius: 3.r,
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4),
                                  // Bóng đậm phía dưới
                                  offset: Offset(4.w, 4.h),
                                  blurRadius: 5.r,
                                ),
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.5),
                                  // Ánh sáng phía trên
                                  offset: Offset(-2.w, -2.h),
                                  blurRadius: 5.r,
                                ),
                              ],
                      ),
                      child: Center(
                        child: Text(
                          'Đăng nhập',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                offset: Offset(2.w, 2.h),
                                blurRadius: 3.r,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0.w, 5.h, 0.w, 5.h),
                  child: Container(
                    constraints:
                        BoxConstraints.loose(Size(double.infinity, 45.h)),
                    alignment: AlignmentDirectional.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      // Canh giữa nội dung
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width *
                              0.3, // Giảm độ dài gạch
                          child: Divider(
                            color: Color(0xff606470),
                            thickness: 1.h,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          // Khoảng cách với gạch ngang
                          child: GestureDetector(
                            onTap: _onForgotPasswordClick,
                            child: Text(
                              'hoặc',
                              style: TextStyle(
                                  fontSize: 16.sp, color: Color(0xff606470)),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width *
                              0.3, // Giảm độ dài gạch
                          child: Divider(
                            color: Color(0xff606470),
                            thickness: 1.h,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0.w, 8.h, 0.w, 10.h),
                  child: GestureDetector(
                    onTap: signInWithGoogle,
                    onTapDown: (_) => setState(() => isPressed2 = true),
                    // Khi nhấn xuống
                    onTapUp: (_) => setState(() => isPressed2 = false),
                    // Khi thả ra
                    onTapCancel: () => setState(() => isPressed2 = false),
                    // Khi hủy nhấn
                    child: AnimatedContainer(
                        duration: const Duration(milliseconds: 100),
                        width: double.infinity,
                        height: 52.h,
                        transform: isPressed2
                            ? Matrix4.translationValues(2.w, 2.h, 0)
                            : Matrix4.identity(),
                        // Hiệu ứng lún xuống
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30.r),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xff101010),
                              Color(0xff063c88), // Màu xanh chính
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: isPressed2
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    // Bóng mờ hơn khi nhấn
                                    offset: Offset(2.w, 2.h),
                                    blurRadius: 3.r,
                                  ),
                                ]
                              : [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.4),
                                    // Bóng đậm phía dưới
                                    offset: Offset(4.w, 4.h),
                                    blurRadius: 5.r,
                                  ),
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.5),
                                    // Ánh sáng phía trên
                                    offset: Offset(-2.w, -2.h),
                                    blurRadius: 5.r,
                                  ),
                                ],
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 20.w,
                            ),
                            Image.asset('assets/ic_google.png'),
                            SizedBox(
                              width: 8.w,
                            ),
                            Text(
                              'Tiếp tục với Google',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        )),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0.w, 20.h, 0.w, 40.h),
                  child: RichText(
                      text: TextSpan(
                          text: 'Tài khoản mới?',
                          style: TextStyle(
                              color: Color(0xff606470), fontSize: 16.sp),
                          children: <TextSpan>[
                        TextSpan(
                          recognizer: TapGestureRecognizer()
                            ..onTapDown = (_) {
                              setState(() {
                                _isPressed = true;
                              });
                            }
                            ..onTapUp = (_) {
                              setState(() {
                                _isPressed = false;
                              });
                              Navigator.of(context).push(PageRouteBuilder(
                                transitionDuration:
                                    Duration(milliseconds: 3000),
                                // Thời gian hiệu ứng
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        RegisterPage(),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  var fadeAnimation = Tween<double>(
                                    begin: 0.0,
                                    // Bắt đầu từ trong suốt
                                    end: 1.0, // Hiện ra hoàn toàn
                                  ).animate(animation);

                                  var scaleAnimation = Tween<double>(
                                    begin: 0.8,
                                    // Nhỏ hơn bình thường
                                    end: 1.0, // Phóng to đến kích thước chuẩn
                                  ).animate(animation);

                                  return FadeTransition(
                                    opacity: fadeAnimation,
                                    child: ScaleTransition(
                                      scale: scaleAnimation,
                                      child: child,
                                    ),
                                  );
                                },
                              ));
                            },
                          text: " Hãy đăng kí để trải nghiệm",
                          style: TextStyle(
                            color:
                                Colors.blue.withOpacity(_isPressed ? 0.6 : 1.0),
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ])),
                ),
              ],
            ),
          ),
        )),
      ),
    );
  }

  // void _onForgotPasswordClick() {
  //   TextEditingController emailController = TextEditingController();
  //
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: Text("Forgot Password"),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Text("Please enter your email to reset your password."),
  //             TextField(
  //               controller: emailController,
  //               keyboardType: TextInputType.emailAddress,
  //               decoration: InputDecoration(
  //                 hintText: "Enter your email",
  //               ),
  //             ),
  //           ],
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(context), // Đóng dialog
  //             child: Text("Cancel"),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               String email = emailController.text.trim();
  //               if (email.isEmpty) {
  //                 MsgDialog.showMsgDialog(
  //                     context, "Forgot Password", "Please enter your email.");
  //                 return;
  //               }
  //
  //               LoadingDialog.showLoadingDialog(context, "Sending reset email...");
  //
  //               FirebaseAuth.instance.sendPasswordResetEmail(email: email).then((value) {
  //                 LoadingDialog.hideLoadingDialog(context);
  //                 MsgDialog.showMsgDialog(context, "Forgot Password",
  //                     "A password reset link has been sent to your email.");
  //               }).catchError((error) {
  //                 Navigator.pop(context);
  //                 LoadingDialog.hideLoadingDialog(context);
  //                 MsgDialog.showMsgDialog(context, "Forgot Password", error.toString());
  //               });
  //             },
  //             child: Text("Send"),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  void _onLoginClick() async {
    String email = _emailController.text;
    String pass = _passController.text;

    if (email.isEmpty || pass.isEmpty) {
      MsgDialog.showMsgDialog(
          context, "Lỗi", "Vui lòng điền đầy đủ thông tin !!!");
      return;
    }

    var authBloc = MyApp.of(context).authBloc;
    LoadingDialog.showLoadingDialog(context, "Đang tải...");

    authBloc.signIn(email, pass, () async {
      LoadingDialog.hideLoadingDialog(context);

      // Lưu trạng thái đăng nhập vào SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      if (mounted && context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    }, (msg) {
      LoadingDialog.hideLoadingDialog(context);
      MsgDialog.showMsgDialog(context, "Đăng nhập", msg);
    });
  }

  void _onForgotPasswordClick() {
    TextEditingController emailController = TextEditingController();

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20.w,
            right: 20.w,
            bottom: MediaQuery.of(context).viewInsets.bottom +
                20, // Đẩy nội dung lên khi bàn phím mở
            top: 20.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Quên mật khẩu",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10.h),
              Text("Vui lòng điền email của bạn để đặt lại mật khẩu"),
              SizedBox(height: 10.h),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: "Nhập email của bạn",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    // Đóng bottom sheet
                    child: Text("Hủy"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      String email = emailController.text.trim();

                      if (email.isEmpty) {
                        // Đóng bottom sheet trước khi hiển thị thông báo lỗi
                        Navigator.pop(context);

                        // Hiển thị thông báo lỗi
                        Future.delayed(Duration(milliseconds: 200), () {
                          _showCustomSnackBar(
                              context,
                              "Vui lòng điền email của bạn",
                              Colors.red,
                              Icons.error);
                        });
                        return;
                      }

                      // Hiển thị dialog loading
                      LoadingDialog.showLoadingDialog(
                          context, "Kiểm tra tài khoản...");

                      try {
                        // Kiểm tra email trong Firebase Realtime Database
                        DataSnapshot snapshot = await _dbRef.get();

                        String? userUid;
                        String? signInMethod;

                        if (snapshot.exists) {
                          Map<dynamic, dynamic> users =
                              snapshot.value as Map<dynamic, dynamic>;
                          users.forEach((uid, userData) {
                            if (userData["email"] == email) {
                              userUid = uid;
                              signInMethod = userData["signInMethod"];
                            }
                          });
                        }

                        if (userUid == null) {
                          Navigator.pop(
                              context); // Đóng loading dialog và bottom sheet
                          Navigator.pop(
                              context); // Đóng loading dialog và bottom sheet
                          Future.delayed(Duration(milliseconds: 200), () {
                            _showCustomSnackBar(
                                context,
                                "Email này không tồn tại trong hệ thống",
                                Colors.red,
                                Icons.error);
                          });
                          return;
                        }

                        if (signInMethod == "google") {
                          Navigator.pop(
                              context); // Đóng loading dialog và bottom sheet
                          Navigator.pop(
                              context); // Đóng loading dialog và bottom sheet
                          Future.delayed(Duration(milliseconds: 200), () {
                            _showCustomSnackBar(
                              context,
                              "Bạn đã đăng nhập bằng Google. Hãy đăng nhập lại bằng Google Sign-In.",
                              Colors.orange,
                              Icons.info,
                            );
                          });
                          return;
                        }

                        // Gửi email reset mật khẩu nếu tất cả điều kiện đã thông qua
                        await FirebaseAuth.instance
                            .sendPasswordResetEmail(email: email);
                        Navigator.pop(
                            context); // Đóng loading dialog và bottom sheet
                        Navigator.pop(
                            context); // Đóng loading dialog và bottom sheet
                        Future.delayed(Duration(milliseconds: 200), () {
                          _showCustomSnackBar(
                              context,
                              "Link đặt lại mật khẩu đã được gửi!",
                              Colors.green,
                              Icons.check_circle);
                        });
                      } catch (error) {
                        Navigator.pop(
                            context); // Đóng loading dialog và bottom sheet
                        Navigator.pop(
                            context); // Đóng loading dialog và bottom sheet
                        Future.delayed(Duration(milliseconds: 200), () {
                          _showCustomSnackBar(context, error.toString(),
                              Colors.red, Icons.error);
                        });
                      }
                    },
                    child: Text("Gửi"),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

// Hàm hiển thị SnackBar từ trên
  void _showCustomSnackBar(
      BuildContext context, String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(width: 10.w),
            Expanded(
                child: Text(message, style: TextStyle(color: Colors.white))),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        // Hiển thị nổi lên thay vì dính dưới cùng
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r), // Bo góc SnackBar
        ),
        margin: EdgeInsets.all(20.r),
        // Tạo khoảng cách xung quanh
        duration: Duration(seconds: 3), // Hiển thị trong 3 giây
      ),
    );
  }
}
