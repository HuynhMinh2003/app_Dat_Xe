import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class FirAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void signUp(String email, String pass, String name, String phone,
      Function onSuccess, Function(String) onRegisterError) {
    _firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: pass)
        .then((userCredential) {
      // Lấy đối tượng User từ UserCredential
      var user = userCredential.user;
      if (user != null) {
        _createUser(user.uid, name, phone, onSuccess,
            onRegisterError); // Lấy UID từ user
        print(user);
      } else {
        print("Tạo người dùng không thành công: người dùng trống");
      }
    }).catchError((err) {
      _onSignUpErr(err.code, onRegisterError);
    });
  }

  _createUser(String userId, String name, String phone, Function onSuccess,
      Function(String) onRegisterError) {
    var user = {
      "name": name,
      "phone": phone,
    };
    var ref = FirebaseDatabase.instance.ref().child("users");
    ref.child(userId).set(user).then((user) {
      onSuccess();
    }).catchError((err) {
      onRegisterError('Đăng ký thất bại, vui lòng thử lại');
    });
  }

  void signIn(String email, String pass, Function onSuccess,
      Function(String) onSignInError) {
    _firebaseAuth
        .signInWithEmailAndPassword(email: email, password: pass)
        .then((user) {
      print("On sign in success");
      onSuccess();
    }).catchError((err) {
      onSignInError("Đăng nhập thất bại, vui lòng thử lại");
    });
  }

  void _onSignUpErr(String code, Function(String) onRegisterError) {
    switch (code) {
      case "email-already-in-use":
        onRegisterError(
            'Địa chỉ email này đã được một tài khoản khác sử dụng.');
        break;
      case "invalid-email":
        onRegisterError('Địa chỉ email không hợp lệ.');
        break;
      case "weak-password":
        onRegisterError('Mật khẩu không đủ mạnh.');
        break;
      case "operation-not-allowed":
        onRegisterError(
            'Tài khoản email/mật khẩu không được kích hoạt. Vui lòng liên hệ bộ phận hỗ trợ.');
        break;
      case "too-many-requests":
        onRegisterError('Quá nhiều yêu cầu. Vui lòng đợi và thử lại sau.');
        break;
      case "network-request-failed":
        onRegisterError(
            'Lỗi mạng. Vui lòng kiểm tra kết nối của bạn và thử lại.');
        break;
      default:
        onRegisterError('Đăng ký không thành công, vui lòng thử lại.');
        break;
    }
  }
}
