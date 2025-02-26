import 'package:app_dat_xe/src/resources/dialog/msg_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';

import 'home_page.dart';

class PhoneNumberPage extends StatefulWidget {
  final User user;

  const PhoneNumberPage({Key? key, required this.user}) : super(key: key);

  @override
  _PhoneNumberPageState createState() => _PhoneNumberPageState();
}

class _PhoneNumberPageState extends State<PhoneNumberPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  late String verificationId;
  bool _isVerifying = false;
  bool otpSent = false;
  bool isPressed3 = false;
  bool isPressed4 = false;

  // Danh sách mã vùng quốc gia
  final List<String> countryCodes = [
    '+1', // USA, Canada
    '+7', // Russia, Kazakhstan
    '+20', // Egypt
    '+27', // South Africa
    '+30', // Greece
    '+31', // Netherlands
    '+32', // Belgium
    '+33', // France
    '+34', // Spain
    '+36', // Hungary
    '+39', // Italy
    '+40', // Romania
    '+41', // Switzerland
    '+43', // Austria
    '+44', // UK
    '+45', // Denmark
    '+46', // Sweden
    '+47', // Norway
    '+48', // Poland
    '+49', // Germany
    '+51', // Peru
    '+52', // Mexico
    '+53', // Cuba
    '+54', // Argentina
    '+55', // Brazil
    '+56', // Chile
    '+57', // Colombia
    '+58', // Venezuela
    '+60', // Malaysia
    '+61', // Australia
    '+62', // Indonesia
    '+63', // Philippines
    '+64', // New Zealand
    '+65', // Singapore
    '+66', // Thailand
    '+81', // Japan
    '+82', // South Korea
    '+84', // Vietnam
    '+86', // China
    '+90', // Turkey
    '+91', // India
    '+92', // Pakistan
    '+93', // Afghanistan
    '+94', // Sri Lanka
    '+95', // Myanmar
    '+98', // Iran
    '+211', // South Sudan
    '+212', // Morocco
    '+213', // Algeria
    '+216', // Tunisia
    '+218', // Libya
    '+220', // Gambia
    '+221', // Senegal
    '+222', // Mauritania
    '+223', // Mali
    '+224', // Guinea
    '+225', // Ivory Coast
    '+226', // Burkina Faso
    '+227', // Niger
    '+228', // Togo
    '+229', // Benin
    '+230', // Mauritius
    '+231', // Liberia
    '+232', // Sierra Leone
    '+233', // Ghana
    '+234', // Nigeria
    '+235', // Chad
    '+236', // Central African Republic
    '+237', // Cameroon
    '+238', // Cape Verde
    '+239', // São Tomé and Príncipe
    '+240', // Equatorial Guinea
    '+241', // Gabon
    '+242', // Republic of the Congo
    '+243', // Democratic Republic of the Congo
    '+244', // Angola
    '+245', // Guinea-Bissau
    '+246', // British Indian Ocean Territory
    '+247', // Ascension Island
    '+248', // Seychelles
    '+249', // Sudan
    '+250', // Rwanda
    '+251', // Ethiopia
    '+252', // Somalia
    '+253', // Djibouti
    '+254', // Kenya
    '+255', // Tanzania
    '+256', // Uganda
    '+257', // Burundi
    '+258', // Mozambique
    '+260', // Zambia
    '+261', // Madagascar
    '+262', // Réunion
    '+263', // Zimbabwe
    '+264', // Namibia
    '+265', // Malawi
    '+266', // Lesotho
    '+267', // Botswana
    '+268', // Eswatini (Swaziland)
    '+269', // Comoros
    '+290', // Saint Helena
    '+291', // Eritrea
    '+297', // Aruba
    '+298', // Faroe Islands
    '+299', // Greenland
    '+350', // Gibraltar
    '+351', // Portugal
    '+352', // Luxembourg
    '+353', // Ireland
    '+354', // Iceland
    '+355', // Albania
    '+356', // Malta
    '+357', // Cyprus
    '+358', // Finland
    '+359', // Bulgaria
    '+370', // Lithuania
    '+371', // Latvia
    '+372', // Estonia
    '+373', // Moldova
    '+374', // Armenia
    '+375', // Belarus
    '+376', // Andorra
    '+377', // Monaco
    '+378', // San Marino
    '+379', // Vatican City
    '+380', // Ukraine
    '+381', // Serbia
    '+382', // Montenegro
    '+383', // Kosovo
    '+385', // Croatia
    '+386', // Slovenia
    '+387', // Bosnia and Herzegovina
    '+389', // North Macedonia
    '+420', // Czech Republic
    '+421', // Slovakia
    '+423', // Liechtenstein
    '+500', // Falkland Islands
    '+501', // Belize
    '+502', // Guatemala
    '+503', // El Salvador
    '+504', // Honduras
    '+505', // Nicaragua
    '+506', // Costa Rica
    '+507', // Panama
    '+508', // Saint Pierre and Miquelon
    '+509', // Haiti
    '+590', // Guadeloupe
    '+591', // Bolivia
    '+592', // Guyana
    '+593', // Ecuador
    '+594', // French Guiana
    '+595', // Paraguay
    '+596', // Martinique
    '+597', // Suriname
    '+598', // Uruguay
    '+599', // Caribbean Netherlands
    '+670', // Timor-Leste
    '+672', // Antarctica
    '+673', // Brunei
    '+674', // Nauru
    '+675', // Papua New Guinea
    '+676', // Tonga
    '+677', // Solomon Islands
    '+678', // Vanuatu
    '+679', // Fiji
    '+680', // Palau
    '+681', // Wallis and Futuna
    '+682', // Cook Islands
    '+683', // Niue
    '+685', // Samoa
    '+686', // Kiribati
    '+687', // New Caledonia
    '+688', // Tuvalu
    '+689', // French Polynesia
    '+690', // Tokelau
    '+691', // Micronesia
    '+692', // Marshall Islands
    '+850', // North Korea
    '+852', // Hong Kong
    '+853', // Macau
    '+855', // Cambodia
    '+856', // Laos
    '+880', // Bangladesh
    '+886', // Taiwan
    '+960', // Maldives
    '+961', // Lebanon
    '+962', // Jordan
    '+963', // Syria
    '+964', // Iraq
    '+965', // Kuwait
    '+966', // Saudi Arabia
    '+967', // Yemen
    '+968', // Oman
    '+970', // Palestine
    '+971', // United Arab Emirates
    '+972', // Israel
    '+973', // Bahrain
    '+974', // Qatar
    '+975', // Bhutan
    '+976', // Mongolia
    '+977', // Nepal
    '+992', // Tajikistan
    '+993', // Turkmenistan
    '+994', // Azerbaijan
    '+995', // Georgia
    '+996', // Kyrgyzstan
    '+998', // Uzbekistan
  ];

  String selectedCountryCode = '+84'; // Mặc định Việt Nam

  void _sendOTP() async {
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: "$selectedCountryCode${_phoneController.text.trim()}",
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await widget.user.linkWithCredential(credential);
          print("Tự động xác minh thành công!");
          if (mounted) {
            Navigator.pop(context); // Đóng dialog trước khi chuyển trang
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
                  (route) => false, // Xóa hết các trang trước đó
            );
          }

        },
        verificationFailed: (FirebaseAuthException e) {
          print("Lỗi gửi OTP: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Lỗi gửi OTP: ${e.message}")),
          );
        },
        codeSent: (String verId, int? resendToken) {
          setState(() {
            verificationId = verId; // LƯU verificationId
          });
          _showOTPDialog(); // Hiển thị hộp thoại nhập OTP
        },
        codeAutoRetrievalTimeout: (String verId) {
          setState(() {
            verificationId = verId;
          });
        },
      );
    } catch (e) {
      print("Lỗi gửi OTP: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi gửi OTP: $e")),
      );
    }
  }

  void _showOTPDialog() {
    String otpCode = "";

    showDialog(
      context: context,
      barrierDismissible: false, // Không cho phép đóng hộp thoại khi nhấn ra ngoài
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r), // Bo viền hộp thoại
          ),
          child: Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: Colors.blue, width: 3.w), // 🔹 Viền màu xanh
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.2),
                  blurRadius: 10.r,
                  spreadRadius: 2.r,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Nhập mã OTP",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
                ),
                SizedBox(height: 10.h),
                const Text(
                  "Vui lòng nhập mã OTP gồm 6 chữ số đã gửi đến số điện thoại của bạn.",
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20.h),
                Pinput(
                  length: 6,
                  showCursor: true,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    otpCode = value;
                  },
                  onCompleted: (pin) {
                    otpCode = pin;
                    _verifyOTP(otpCode); // Khi nhập xong, tự động xác thực
                  },
                  defaultPinTheme: PinTheme(
                    width: 50.w,
                    height: 60.h,
                    textStyle: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: Colors.blue, width: 2.w),
                    ),
                  ),
                  focusedPinTheme: PinTheme(
                    width: 50.w,
                    height: 60.h,
                    textStyle: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: Colors.blueAccent, width: 3.w),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.2),
                          blurRadius: 5.r,
                        )
                      ],
                    ),
                  ),
                  submittedPinTheme: PinTheme(
                    width: 50.w,
                    height: 60.h,
                    textStyle: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context), // Đóng hộp thoại
                      child: const Text("Hủy", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _verifyOTP(String otp) async {
    if (verificationId.isEmpty) {
      _showMessageDialog("Error", "Verification ID is not set!");
      return;
    }

    try {
      setState(() => _isVerifying = true);

      linkPhoneNumberWithGoogle(otp); // Chờ liên kết hoàn tất

      if (mounted && context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (e) {
      print("Lỗi khi xác minh OTP: $e");
      setState(() => _isVerifying = false);

      _showMessageDialog("OTP Verification Failed", "Invalid OTP. Please try again.");

    }
  }

  void linkPhoneNumberWithGoogle(String smsCode) async {
    try {
      // Hiển thị Loading Dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      // Tạo credential từ mã OTP
      PhoneAuthCredential phoneCredential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      // Liên kết số điện thoại với tài khoản Google
      await widget.user.linkWithCredential(phoneCredential);
      print("Liên kết số điện thoại thành công!");
      await Future.delayed(Duration(seconds: 2)); // Chờ Firebase cập nhật dữ liệu

// 🔹 Reload user trước khi kiểm tra
      await FirebaseAuth.instance.currentUser?.reload();
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        print("🔹 Danh sách provider của tài khoản: ${user.providerData.map((e) => e.providerId).toList()}");
        print("📧 Email: ${user.email}");
        print("📱 Số điện thoại: ${user.phoneNumber}");
      }

      FirebaseAuth.instance.fetchSignInMethodsForEmail(widget.user.email!).then((methods) {
        print("✅ Phương thức đăng nhập hiện có sau khi liên kết số điện thoại: $methods");
      });


      // Cập nhật số điện thoại vào Firebase Database
      DatabaseReference ref =
          FirebaseDatabase.instance.ref().child('users/${widget.user.uid}');
      await ref.update({
        "name": widget.user.displayName ?? "Unknown",
        "email": widget.user.email ?? "Unknown",
        "phone": "$selectedCountryCode${_phoneController.text.trim()}",
        "signInMethod": "google",
      });

      // Ẩn Loading Dialog sau khi hoàn thành
      if (mounted) {
        Navigator.pop(context); // Đóng dialog trước khi chuyển trang
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
              (route) => false, // Xóa hết các trang trước đó
        );
      }
    } catch (e) {
      // Ẩn Loading Dialog nếu có lỗi
      if (mounted) Navigator.pop(context);

      print("Lỗi khi liên kết số điện thoại: $e");
      MsgDialog.showMsgDialog(context, "Lỗi liên kết số điện thoại", e.toString());

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.all(16.r),
        child: Padding(
          padding: EdgeInsets.all(16.0.r),
          child: Column(
            children: [
              Text(
                'Vui lòng nhập số điện thoại để xác minh',
                style: TextStyle(fontSize: 30.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 20.h,
              ),
              _buildPhoneNumberField(),
              SizedBox(height: 10.h),
              Padding(
                padding: EdgeInsets.fromLTRB(0.w, 15.h, 0.w, 10.h),
                child: GestureDetector(
                  onTap: _sendOTP,
                  onTapDown: (_) => setState(() => isPressed3 = true),
                  // Khi nhấn xuống
                  onTapUp: (_) => setState(() => isPressed3 = false),
                  // Khi thả ra
                  onTapCancel: () => setState(() => isPressed3 = false),
                  // Khi hủy nhấn
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    width: double.infinity,
                    height: 52.h,
                    transform: isPressed3
                        ? Matrix4.translationValues(2, 2, 0)
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
                      boxShadow: isPressed3
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
                        'Gửi mã OTP',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 2.sp,
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
              SizedBox(
                height: 40.h,
              ),
              // if (otpSent) ...[
              //   Padding(
              //     padding: const EdgeInsets.symmetric(horizontal: 20),
              //     child: PinCodeTextField(
              //       length: 6,
              //       // Số ký tự OTP
              //       appContext: context,
              //       keyboardType: TextInputType.number,
              //       autoFocus: true,
              //       // Tự động focus khi mở màn hình
              //       animationType: AnimationType.fade,
              //       cursorColor: Colors.blue,
              //       pinTheme: PinTheme(
              //         shape: PinCodeFieldShape.box,
              //         // Hình dạng ô (box / underline / circle)
              //         borderRadius: BorderRadius.circular(6),
              //         fieldHeight: 50,
              //         fieldWidth: 40,
              //         activeFillColor: Colors.white,
              //         selectedFillColor: Colors.blue.shade100,
              //         // Màu khi đang nhập
              //         inactiveFillColor: Colors.grey.shade200,
              //         // Màu khi chưa nhập
              //         activeColor: Colors.blue,
              //         selectedColor: Colors.blueAccent,
              //         inactiveColor: Colors.grey,
              //       ),
              //       onCompleted: (value) => _verifyOTP(value),
              //       // Gọi hàm kiểm tra khi nhập đủ
              //       onChanged: (value) {
              //         print("OTP nhập: $value");
              //       },
              //     ),
              //   )
              // ],
            ],
          ),
        ),
      ),
    );
  }

  void _showMessageDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneNumberField() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.w, 20.h, 0.w, 20.h),
      child: Row(
        children: <Widget>[
          // Mã vùng với DropdownButton có label giống TextField
          Expanded(
              flex: 4,
              child: Container(
                height: 56.h,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Mã vùng',
                    border: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xffCED0D2), width: 1.w),
                      borderRadius: BorderRadius.all(Radius.circular(6.r)),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedCountryCode,
                      isExpanded: true,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCountryCode = newValue!;
                        });
                      },
                      items: countryCodes
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Row(
                            children: [
                              Icon(Icons.phone,
                                  color: Colors.grey, size: 20.r),
                              SizedBox(width: 10.w),
                              Text(value, style: TextStyle(fontSize: 16.sp)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              )),
          SizedBox(width: 5.w),
          // TextField nhập số điện thoại
          Expanded(
            flex: 7,
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Số điện thoại',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xffCED0D2), width: 1.w),
                  borderRadius: BorderRadius.all(Radius.circular(6.r)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
