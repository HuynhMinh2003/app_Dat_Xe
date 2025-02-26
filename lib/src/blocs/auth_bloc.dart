import 'dart:async';

import 'package:app_dat_xe/src/fire_base/fire_base_auth.dart';

class AuthBloc {
  final _firAuth = FirAuth();

  // Sửa kiểu StreamController thành StreamController<String?>
  final StreamController<String?> _nameController = StreamController<String?>();
  final StreamController<String?> _emailController = StreamController<String?>();
  final StreamController<String?> _passController = StreamController<String?>();
  final StreamController<String?> _phoneController = StreamController<String?>();

  // Stream trả về kiểu String?
  Stream<String?> get nameStream => _nameController.stream;
  Stream<String?> get emailStream => _emailController.stream;
  Stream<String?> get passStream => _passController.stream;
  Stream<String?> get phoneStream => _phoneController.stream;

  bool isValid(String name, String email, String pass, String phone) {
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
      _phoneController.sink.addError("Số điện thoại không hợp lệ (chỉ gồm 10-15 chữ số)");
      return false;
    }

    _phoneController.sink.add(null); // Xóa lỗi nếu kiểm tra thành công

    if (email.isEmpty) {
      _emailController.sink.addError("Phải nhập email");
      return false;
    }
    _emailController.sink.add(null);

    if (pass.isEmpty) {
      _passController.sink.addError("Phải nhập mật khẩu");
      return false;
    }
    _passController.sink.add(null);

    return true;
  }

  void signUp(String email, String pass, String phone, String name,
      Function onSuccess, Function(String) onRegisterError) {
    _firAuth.signUp(email, pass, name, phone, onSuccess, onRegisterError);
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
