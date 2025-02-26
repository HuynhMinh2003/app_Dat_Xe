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
        print("User creation failed: user is null");
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
      onRegisterError('Sign up fall, please try again');
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
      onSignInError("Sign in fall, please try again");
    });
  }

  void _onSignUpErr(String code, Function(String) onRegisterError) {
    switch (code) {
      case "email-already-in-use":
        onRegisterError(
            'The email address is already in use by another account.');
        break;
      case "invalid-email":
        onRegisterError('The email address is not valid.');
        break;
      case "weak-password":
        onRegisterError('The password is not strong enough.');
        break;
      case "operation-not-allowed":
        onRegisterError(
            'Email/password accounts are not enabled. Please contact support.');
        break;
      case "too-many-requests":
        onRegisterError('Too many requests. Please wait and try again later.');
        break;
      case "network-request-failed":
        onRegisterError(
            'Network error. Please check your connection and try again.');
        break;
      default:
        onRegisterError('Sign up failed, please try again.');
        break;
    }
  }
}
