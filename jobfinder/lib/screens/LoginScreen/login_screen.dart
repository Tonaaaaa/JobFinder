import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jobfinder/screens/HomeScreen/employee_home_screen.dart';
import 'package:jobfinder/screens/MainScreen/employee_main_screen.dart';
import 'package:jobfinder/screens/MainScreen/recruiter_main_screen.dart';
import 'package:jobfinder/screens/SignUpScreen/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _isChecked = true;
  bool _isTyping = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(_updateLogoState);
    _passwordFocusNode.addListener(_updateLogoState);
  }

  @override
  void dispose() {
    _emailFocusNode.removeListener(_updateLogoState);
    _passwordFocusNode.removeListener(_updateLogoState);
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _generateCandidateCode() {
    final now = DateTime.now();
    final random =
        DateTime.now().millisecondsSinceEpoch.toString().substring(7);
    return "C${now.year}${now.month.toString().padLeft(2, '0')}${random}";
  }

  Future<void> _resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email đặt lại mật khẩu đã được gửi!')),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;

      if (e.code == 'user-not-found') {
        errorMessage = 'Không tìm thấy người dùng với email này!';
      } else {
        errorMessage = 'Đã xảy ra lỗi: ${e.message}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xảy ra lỗi: $e')),
      );
    }
  }

  void _showForgotPasswordDialog() {
    final TextEditingController emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 16,
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Quên mật khẩu?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Nhập email của bạn, chúng tôi sẽ gửi một liên kết để đặt lại mật khẩu.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập email.';
                    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                        .hasMatch(value)) {
                      return 'Vui lòng nhập email hợp lệ.';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Nhập email của bạn',
                    prefixIcon: Icon(Icons.email, color: Colors.blueAccent),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final email = emailController.text.trim();
                      Navigator.pop(context);
                      _resetPassword(email);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  ),
                  child: Text(
                    'Gửi yêu cầu',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Hủy',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> signInWithFacebook(BuildContext context) async {
    try {
      // Bắt đầu đăng nhập với Facebook
      final LoginResult result = await FacebookAuth.instance
          .login(permissions: ['email', 'public_profile']);

      if (result.status == LoginStatus.success) {
        // Lấy AccessToken từ kết quả đăng nhập
        final AccessToken accessToken = result.accessToken!;

        // Tạo Firebase Credential từ Facebook AccessToken
        final facebookCredential =
            FacebookAuthProvider.credential(accessToken.tokenString);

        // Đăng nhập với Firebase
        final UserCredential userCredential = await FirebaseAuth.instance
            .signInWithCredential(facebookCredential);
        final User? user = userCredential.user;

        if (user != null) {
          // Kiểm tra và thêm người dùng vào Firestore
          final userDoc =
              FirebaseFirestore.instance.collection('users').doc(user.uid);
          final userSnapshot = await userDoc.get();

          if (!userSnapshot.exists) {
            await userDoc.set({
              'name': user.displayName ?? 'Người dùng Facebook',
              'email': user.email ?? 'Không có email',
              'avatarUrl': user.photoURL,
              'role': 'employee', // Vai trò mặc định
              'createdAt': FieldValue.serverTimestamp(),
            });
          }

          // Hiển thị thông báo đăng nhập thành công
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Đăng nhập Facebook thành công!")),
          );

          // Điều hướng đến màn hình chính
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainScreen(
                  userId: user.uid), // Thay MainScreen bằng màn hình của bạn
            ),
          );
        }
      } else if (result.status == LoginStatus.cancelled) {
        // Người dùng hủy đăng nhập
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Đăng nhập Facebook bị hủy.")),
        );
      } else {
        // Lỗi đăng nhập
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi đăng nhập Facebook: ${result.message}")),
        );
      }
    } catch (e) {
      // Xử lý lỗi chung
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đã xảy ra lỗi khi đăng nhập Facebook: $e")),
      );
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      // Đăng xuất trước khi hiển thị hộp thoại chọn tài khoản
      await googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // Người dùng hủy đăng nhập
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final User? user = userCredential.user;

      if (user != null) {
        // Kiểm tra và lưu thông tin người dùng vào Firestore
        final userDoc =
            FirebaseFirestore.instance.collection('users').doc(user.uid);
        final userSnapshot = await userDoc.get();

        if (!userSnapshot.exists) {
          await userDoc.set({
            'name': user.displayName ?? 'Người dùng Google',
            'email': user.email,
            'avatarUrl': user.photoURL,
            'role': 'employee', // Vai trò mặc định
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        return user;
      }

      return null;
    } catch (e) {
      print("Lỗi đăng nhập Google: $e");
      return null;
    }
  }

  void _updateLogoState() {
    setState(() {
      _isTyping = _emailFocusNode.hasFocus || _passwordFocusNode.hasFocus;
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng nhập email và mật khẩu!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;

      if (user != null) {
        // Kiểm tra email đã xác thực
        if (!user.emailVerified) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Email của bạn chưa được xác thực. Vui lòng kiểm tra email và xác thực tài khoản.'),
            ),
          );

          // Đăng xuất ngay lập tức
          await FirebaseAuth.instance.signOut();
          return;
        }

        // Truy cập thông tin người dùng từ Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (!userDoc.exists) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Không tìm thấy thông tin người dùng!')),
          );
          return;
        }

        final role = userDoc['role'] ?? 'guest';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đăng nhập thành công!')),
        );

        // Điều hướng dựa trên vai trò
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => role == 'Job'
                ? RecruiterMainScreen(userId: user.uid)
                : MainScreen(userId: user.uid),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Đã xảy ra lỗi!';

      if (e.code == 'user-not-found') {
        errorMessage = 'Không tìm thấy người dùng với email này!';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Mật khẩu không đúng!';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xảy ra lỗi: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: _isTyping ? 100 : 170,
                  child: Image.asset('assets/images/JobSphereLogo.png'),
                ),
                const SizedBox(height: 1),
                Text(
                  "Chào mừng bạn đến với JobSphere",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: _emailFocusNode.hasFocus ? 'Email' : null,
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                    hintText: !_emailFocusNode.hasFocus ? 'Email' : null,
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Icon(Icons.email, color: Colors.blueAccent),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: _passwordFocusNode.hasFocus ? 'Mật khẩu' : null,
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                    hintText: !_passwordFocusNode.hasFocus ? 'Mật khẩu' : null,
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Icon(Icons.lock, color: Colors.blueAccent),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey[600],
                      ),
                      onPressed: _togglePasswordVisibility,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _showForgotPasswordDialog,
                    child: Text(
                      'Quên mật khẩu?',
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'ĐĂNG NHẬP',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        User? user = await signInWithGoogle();
                        if (user != null) {
                          // Lưu thông tin người dùng vào Firestore
                          final userDoc = FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid);

                          await userDoc.set({
                            'name': user.displayName ?? 'Người dùng Google',
                            'email': user.email,
                            'avatarUrl': user.photoURL,
                            'role': 'employee',
                            'createdAt': FieldValue.serverTimestamp(),
                          }, SetOptions(merge: true));

                          // Chuyển đến màn hình chính
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MainScreen(userId: user.uid),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text("Đăng nhập Google không thành công")),
                          );
                        }
                      },
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.redAccent,
                        child: Icon(Icons.g_mobiledata, color: Colors.white),
                      ),
                    ),

                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap:
                          _isChecked ? () => signInWithFacebook(context) : null,
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor:
                            _isChecked ? Colors.blueAccent : Colors.grey,
                        child: Icon(Icons.facebook, color: Colors.white),
                      ),
                    ),

                    const SizedBox(width: 20),
                    // GestureDetector(
                    //   onTap: _isChecked ? () => print("Apple") : null,
                    //   child: CircleAvatar(
                    //     radius: 28,
                    //     backgroundColor:
                    //         _isChecked ? Colors.black : Colors.grey,
                    //     child: Icon(Icons.apple, color: Colors.white),
                    //   ),
                    // ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: _isChecked,
                      activeColor: Colors.blueAccent,
                      checkColor: Colors.white,
                      onChanged: (value) {
                        setState(() {
                          _isChecked = value!;
                        });
                      },
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          text:
                              'Bằng việc đăng nhập, tôi đã đọc và đồng ý với ',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                          children: [
                            TextSpan(
                              text: 'Điều khoản dịch vụ ',
                              style: TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: 'và ',
                            ),
                            TextSpan(
                              text: 'Chính sách bảo mật ',
                              style: TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: 'của JobSphere.',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Bạn chưa có tài khoản? ',
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignUpScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Đăng ký ngay',
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Divider(
                  color: Colors.grey,
                  thickness: 1,
                ),
                const SizedBox(height: 1),
                TextButton(
                  onPressed: () async {
                    try {
                      // Đăng nhập ẩn danh với Firebase
                      final UserCredential userCredential =
                          await FirebaseAuth.instance.signInAnonymously();
                      final User? user = userCredential.user;

                      if (user != null) {
                        // Kiểm tra và thêm thông tin người dùng ẩn danh vào Firestore (nếu cần)
                        final userDoc = FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid);
                        final userSnapshot = await userDoc.get();

                        if (!userSnapshot.exists) {
                          await userDoc.set({
                            'name': 'Người dùng ẩn danh',
                            'role': 'guest', // Vai trò: guest
                            'createdAt': FieldValue.serverTimestamp(),
                          });
                        }

                        // Chuyển sang màn hình chính hoặc màn hình trải nghiệm
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MainScreen(
                                userId:
                                    user.uid), // MainScreen là màn hình chính
                          ),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                "Lỗi khi trải nghiệm không cần đăng nhập: $e")),
                      );
                    }
                  },
                  child: Text(
                    'Trải nghiệm không cần đăng nhập',
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
