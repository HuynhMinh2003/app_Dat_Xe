import 'dart:async';
import 'package:app_dat_xe/src/resources/dialog/msg_dialog.dart';
import 'package:app_dat_xe/src/resources/home_page.dart';
import 'package:app_dat_xe/src/resources/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  String selectedCountryCode = '+84'; // Mã vùng mặc định là Việt Nam
  final TextEditingController _phoneController = TextEditingController();

  bool _isVerifying = false;

  // Danh sách mã vùng (có thể mở rộng)
  final List<String> countryCodes = [
    '+1',   // USA, Canada
    '+7',   // Russia, Kazakhstan
    '+20',  // Egypt
    '+27',  // South Africa
    '+30',  // Greece
    '+31',  // Netherlands
    '+32',  // Belgium
    '+33',  // France
    '+34',  // Spain
    '+36',  // Hungary
    '+39',  // Italy
    '+40',  // Romania
    '+41',  // Switzerland
    '+43',  // Austria
    '+44',  // UK
    '+45',  // Denmark
    '+46',  // Sweden
    '+47',  // Norway
    '+48',  // Poland
    '+49',  // Germany
    '+51',  // Peru
    '+52',  // Mexico
    '+53',  // Cuba
    '+54',  // Argentina
    '+55',  // Brazil
    '+56',  // Chile
    '+57',  // Colombia
    '+58',  // Venezuela
    '+60',  // Malaysia
    '+61',  // Australia
    '+62',  // Indonesia
    '+63',  // Philippines
    '+64',  // New Zealand
    '+65',  // Singapore
    '+66',  // Thailand
    '+81',  // Japan
    '+82',  // South Korea
    '+84',  // Vietnam
    '+86',  // China
    '+90',  // Turkey
    '+91',  // India
    '+92',  // Pakistan
    '+93',  // Afghanistan
    '+94',  // Sri Lanka
    '+95',  // Myanmar
    '+98',  // Iran
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
  // Thêm các mã vùng khác nếu cần

  String formatPhoneNumber(String countryCode, String phoneNumber) {
    phoneNumber = phoneNumber.trim(); // Xóa khoảng trắng
    if (phoneNumber.startsWith('0')) {
      phoneNumber = phoneNumber.substring(1); // Loại bỏ số 0 đầu tiên
    }
    return countryCode + phoneNumber; // Kết hợp với mã quốc gia
  }

  bool isPressed3 = false;
  bool _isPressed = false;
  String _verificationId = "";
  String _email = "";
  String _password = "";
  String _phoneNumber = "";
  String _name = "";

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    _phoneController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xff3277D8)),
        elevation: 0,
      ),
      body: GestureDetector(
        onTap: (){
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Container(
          padding: EdgeInsets.fromLTRB(30.w, 0.h, 30.w, 0.h),
          constraints: const BoxConstraints.expand(),
          color: Colors.white,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Transform.scale(
                  scale: 1.01, // Phóng to ảnh
                  child: Image.asset(
                    'assets/ic_car_red.png',
                    width: MediaQuery.of(context).size.width * 0.55,
                    height: MediaQuery.of(context).size.height * 0.2,
                    fit: BoxFit.contain,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0.w, 0.h, 0.w, 6.h),
                  child: Text(
                    'Đăng kí',
                    style: GoogleFonts.openSans(fontSize: 35.sp, color: Color(0xff333333), fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                  ),
                ),
                Text(
                  'Đăng kí tài khoản? Chỉ với vài bước',
                  style: TextStyle(fontSize: 16.sp, color: Color(0xff606470), fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10.h,),
                _buildTextField(_nameController, 'Họ và tên', Icons.person),
                _buildPhoneNumberField(),
                _buildTextField(_emailController, 'Email', Icons.email),
                _buildTextField(_passController, 'Mật khẩu', Icons.lock),
                Padding(
                  padding: EdgeInsets.fromLTRB(0.w, 15.h, 0.w, 10.h),
                  child: GestureDetector(
                    onTap: _verifyPhoneNumber,
                    onTapDown: (_) => setState(() => isPressed3 = true), // Khi nhấn xuống
                    onTapUp: (_) => setState(() => isPressed3 = false),  // Khi thả ra
                    onTapCancel: () => setState(() => isPressed3 = false), // Khi hủy nhấn
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      width: double.infinity,
                      height: 52.h,
                      transform: isPressed3 ? Matrix4.translationValues(2.w, 2.h, 0) : Matrix4.identity(), // Hiệu ứng lún xuống
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30.r),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xff4381c9),
                            Color(0xff316ec5)], // Hiệu ứng ánh sáng
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: isPressed3
                            ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2), // Bóng mờ hơn khi nhấn
                            offset: Offset(2.w, 2.h),
                            blurRadius: 3.r,
                          ),
                        ]
                            : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4), // Bóng đậm phía dưới
                            offset: Offset(4.w, 4.h),
                            blurRadius: 5.r,
                          ),
                          BoxShadow(
                            color: Colors.white.withOpacity(0.5), // Ánh sáng phía trên
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
                  padding: EdgeInsets.fromLTRB(0.w, 15.h, 0.w, 20.h),
                  child: RichText(
                    text: TextSpan(
                      text: 'Đã có tài khoản? ',
                      style: TextStyle(color: Color(0xff606470), fontSize: 16.sp),
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
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    transitionDuration:
                                    const Duration(milliseconds: 3000),
                                    pageBuilder:
                                        (context, animation, secondaryAnimation) =>
                                        LoginPage(),
                                    transitionsBuilder: (context, animation,
                                        secondaryAnimation, child) {
                                      const begin =
                                      Offset(0.0, 1.0); // Bắt đầu từ bên phải
                                      const end = Offset
                                          .zero; // Kết thúc tại vị trí bình thường
                                      const curve =
                                          Curves.easeInOut; // Hiệu ứng mượt mà
                                      var tween = Tween(begin: begin, end: end)
                                          .chain(CurveTween(curve: curve));
                                      var offsetAnimation = animation.drive(tween);

                                      // Đảm bảo child được sử dụng để áp dụng hiệu ứng SlideTransition
                                      return SlideTransition(
                                        position: offsetAnimation,
                                        child: child,
                                      );
                                    },
                                  ),
                                );
                              },
                            text: "Đăng nhập ngay",
                            style: TextStyle(
                              color:
                              Colors.blue.withOpacity(_isPressed ? 0.6 : 1.0),
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      )
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon,
      ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.w, 15.h, 0.w, 15.h),
      child: TextField(
        controller: controller,
        style: TextStyle(fontSize: 18.sp, color: Colors.black),
        decoration: InputDecoration(
          labelText: label,
          contentPadding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 14.w),
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 18.w, right: 10.w),
            child: Icon(icon, size: 24.r, color: Colors.black),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xffCED0D2), width: 1.w),
            borderRadius: BorderRadius.all(Radius.circular(30.r)),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label, IconData icon) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool _obscureText = true;

        return Padding(
          padding: EdgeInsets.fromLTRB(0.w, 15.h, 0.w, 15.h),
          child: TextField(
            controller: controller,
            obscureText: _obscureText,
            style: TextStyle(fontSize: 18.sp, color: Colors.black),
            decoration: InputDecoration(
              labelText: label,
              contentPadding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 14.w),
              prefixIcon: Padding(
                padding: EdgeInsets.only(left: 18.w, right: 10.w),
                child: Icon(icon, size: 24.r, color: Colors.black),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.black,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xffCED0D2), width: 1.w),
                borderRadius: BorderRadius.all(Radius.circular(30.r)),
              ),
            ),
          ),
        );
      },
    );
  }


  // Hàm xây dựng TextField cho số điện thoại với DropdownButton
  Widget _buildPhoneNumberField() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.w, 20.h, 0.w, 20.h),
      child: Row(
        children: <Widget>[
          // Mã vùng với DropdownButton có kích thước cố định
          Expanded(
            flex: 4, // Chia tỷ lệ độ rộng hợp lý
            child: Container(
              height: 56.h,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Mã vùng',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xffCED0D2), width: 1.w),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.r),  // Bo góc bên trái
                      bottomLeft: Radius.circular(30.r), // Bo góc bên trái
                      topRight: Radius.circular(6.r),   // Góc bên phải vuông
                      bottomRight: Radius.circular(6.r), // Góc bên phải vuông
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
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
                    items: countryCodes.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Row(
                          children: [
                            SizedBox(width: 10.w),
                            Icon(Icons.phone, color: Colors.black, size: 20.r),
                            SizedBox(width: 10.w),
                            Text(value, style: TextStyle(fontSize: 16.sp)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 5.w),
          // TextField nhập số điện thoại
          Expanded(
            flex: 7, // Tăng tỷ lệ độ rộng để phù hợp
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Số điện thoại',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xffCED0D2), width: 1.w),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(6.r),   // Góc bên trái vuông
                    bottomLeft: Radius.circular(6.r), // Góc bên trái vuông
                    topRight: Radius.circular(30.r),  // Bo góc bên phải
                    bottomRight: Radius.circular(30.r), // Bo góc bên phải
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _verifyPhoneNumber() async {
    _phoneNumber = formatPhoneNumber(selectedCountryCode, _phoneController.text.trim());
    _email = _emailController.text.trim();
    _password = _passController.text.trim();
    _name = _nameController.text.trim();

    // Kiểm tra nếu bất kỳ trường nào bị bỏ trống
    if (_phoneNumber.isEmpty || _email.isEmpty || _password.isEmpty || _name.isEmpty) {
      MsgDialog.showMsgDialog(context, "Lỗi", "Vui lòng điền đầy đủ thông tin !!!");
      return;
    }

// Kiểm tra định dạng email
    bool isValidEmail(String email) {
      final RegExp emailRegex = RegExp(r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$");
      return emailRegex.hasMatch(email);
    }

    if (!isValidEmail(_email)) {
      MsgDialog.showMsgDialog(context, "Lỗi", "Email không hợp lệ. Vui lòng nhập đúng định dạng (ví dụ: example@email.com).");
      return;
    }

// Kiểm tra độ dài mật khẩu
    if (_password.length < 8) {
      MsgDialog.showMsgDialog(context, "Lỗi", "Mật khẩu phải có ít nhất 8 ký tự.");
      return;
    }

// Nếu tất cả hợp lệ, tiếp tục xử lý đăng ký
    try{
      await _auth.verifyPhoneNumber(
        phoneNumber: _phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          _linkEmailWithPhone(); // Liên kết email sau khi xác thực số điện thoại
        },
        verificationFailed: (FirebaseAuthException e) {
          MsgDialog.showMsgDialog(context, "Xác thực thất bại", e.message!);
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
          });
          _showOTPDialog();
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    }
    catch(e){
    }
  }

  void _showOTPDialog() {
    String otpCode = "";

    showDialog(
      context: context,
      barrierDismissible: false,
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
                  textAlign: TextAlign.right,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
                ),
                SizedBox(height: 10.h,),
                const Text(
                  "Vui lòng nhập mã OTP gồm 6 chữ số đã gửi đến số điện thoại của bạn.",
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30.h),
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
      }
    );
  }

  // Xác minh OTP
  void _verifyOTP(String otp) async {
    if (_verificationId.isEmpty) {
      _showMessageDialog("Lỗi", "ID xác minh chưa được thiết lập!");
      return;
    }

    try {
      setState(() => _isVerifying = true);

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: otp,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        // Lưu trạng thái đăng nhập vào SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool("isLoggedIn", true);
        await prefs.setString("userPhone", userCredential.user!.phoneNumber ?? "");

        Navigator.pop(context); // Đóng OTP dialog
        _linkEmailWithPhone(); // Liên kết email sau khi xác thực số điện thoại thành công
      }
    } catch (e) {
      setState(() => _isVerifying = false);
      _showMessageDialog("Xác thực OTP thất bại", "OTP không hợp lệ. Vui lòng thử lại.");
    }
  }


// 🔹 Hàm liên kết email với số điện thoại
  Future<void> _linkEmailWithPhone() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        // 🔹 Hiển thị Loading Dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return const Center(child: CircularProgressIndicator());
          },
        );

        AuthCredential emailCredential = EmailAuthProvider.credential(
          email: _email,
          password: _password,
        );

        await user.linkWithCredential(emailCredential);
        print("Email và số điện thoại đã được liên kết thành công.");

        // 🔹 Sau khi liên kết, lưu thông tin vào Realtime Database
        await _saveUserDataToDatabase(user);

        // 🔹 Ẩn Loading Dialog trước khi chuyển trang
        if (mounted && context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
      } catch (e) {
        // 🔹 Ẩn Loading Dialog nếu có lỗi
        if (mounted) Navigator.pop(context);

        print("Lỗi khi liên kết email: $e");
        MsgDialog.showMsgDialog(context, "Lỗi", "Liên kết email với số điện thoại thất bại");
      }
    }
  }

// 🔹 Hàm lưu thông tin vào Realtime Database
  Future<void> _saveUserDataToDatabase(User user) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref().child("users").child(user.uid);

    await ref.set({
      "name": _name,
      "email": _email,
      "phone": _phoneNumber,
      "signInMethod": "email/pass",
    });

    print("Dữ liệu người dùng đã được lưu vào Firebase Realtime Database.");
  }

  // 🔹 Hiển thị thông báo
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

}

