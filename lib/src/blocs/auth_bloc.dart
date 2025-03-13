import 'dart:async';

import 'package:app_dat_xe/src/fire_base/fire_base_auth.dart';

class AuthBloc {
  final _firAuth = FirAuth();

  // Sửa kiểu StreamController thành StreamController<String?>
  final StreamController<String?> _nameController = StreamController<String?>();
  final StreamController<String?> _emailController =
      StreamController<String?>();
  final StreamController<String?> _passController = StreamController<String?>();
  final StreamController<String?> _phoneController =
      StreamController<String?>();

  // Stream trả về kiểu String?
  Stream<String?> get nameStream => _nameController.stream;

  Stream<String?> get emailStream => _emailController.stream;

  Stream<String?> get passStream => _passController.stream;

  Stream<String?> get phoneStream => _phoneController.stream;

  final StreamController<String?> _emailController1 =
      StreamController<String?>();
  final StreamController<String?> _passController1 =
      StreamController<String?>();

  Stream<String?> get emailStream1 => _emailController1.stream;

  Stream<String?> get passStream1 => _passController1.stream;

  bool isValidSignUp(String name, String email, String pass, String phone) {
    if (name.isEmpty) {
      _nameController.sink.addError("Phải nhập tên");
      return false;
    }
    _nameController.sink.add(null);

    final phoneRegex = RegExp(r'^\+[1-9]\d{1,14}$'); // Số từ 10 đến 15 chữ số

    if (phone.isEmpty) {
      _phoneController.sink.addError("Nhập số điện thoại");
      return false;
    }

    if (!phoneRegex.hasMatch(phone)) {
      _phoneController.sink
          .addError("Số điện thoại không hợp lệ (chỉ gồm 10-15 chữ số)");
      return false;
    }

    _phoneController.sink.add(null); // Xóa lỗi nếu kiểm tra thành công

    final emailRegex =
        RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");

    if (email.isEmpty) {
      _emailController.sink.addError("Phải nhập email !");
      return false;
    } else if (!emailRegex.hasMatch(email)) {
      _emailController.sink.addError("Email không hợp lệ !");
      return false;
    } else {
      _emailController.sink.add(""); // Xóa lỗi nếu hợp lệ
    }

    if (pass.isEmpty) {
      _passController.sink.addError("Phải nhập mật khẩu");
      return false;
    } else if (pass.length < 8) {
      _passController.sink.addError("Mật khẩu phải có ít nhất 8 ký tự");
      return false;
    }

    _passController.sink.add(null);
    return true;
  }

  bool isValidSignIn(String email, String pass) {
    final emailRegex1 =
        RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");

    if (email.isEmpty) {
      _emailController1.sink.addError("Phải nhập email !");
      return false;
    } else if (!emailRegex1.hasMatch(email)) {
      _emailController1.sink.addError("Email không hợp lệ !");
      return false;
    } else {
      _emailController1.sink.add(""); // Xóa lỗi nếu hợp lệ
    }

    if (pass.isEmpty) {
      _passController1.sink.addError("Mật khẩu không được để trống !");
      return false;
    } else if (pass.length < 8) {
      _passController1.sink.addError("Mật khẩu phải có ít nhất 8 ký tự");
      return false;
    }
    _passController1.sink.add(""); // Xóa lỗi nếu hợp lệ
    return true;
  }

  void signUp(String email, String pass, String phone, String name,
      Function onSuccess, Function(String) onRegisterError) {
    if (isValidSignUp(name, email, pass, phone)) {
      _firAuth.signUp(email, pass, name, phone, onSuccess, onRegisterError);
    }
  }

  void signIn(String email, String pass, Function onSuccess,
      Function(String) onSignInError) {
    _firAuth.signIn(email, pass, onSuccess, onSignInError);
  }

  void dispose() {
    _nameController.close();
    _emailController.close();
    _passController.close();
    _phoneController.close();
  }
}
