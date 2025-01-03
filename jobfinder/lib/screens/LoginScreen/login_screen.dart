import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      // Thực hiện đăng nhập với Firebase
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String userId = userCredential.user!.uid; // Lấy userId từ Firebase

      // Truy vấn role từ Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không tìm thấy thông tin người dùng!')),
        );
        return;
      }

      String role = userDoc['role'] ?? 'employee';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đăng nhập thành công!')),
      );

      // Điều hướng dựa trên role
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => role == "Job"
              ? RecruiterMainScreen(userId: userId)
              : MainScreen(userId: userId),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;

      if (e.code == 'user-not-found') {
        errorMessage = 'Không tìm thấy người dùng với email này!';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Mật khẩu không đúng!';
      } else {
        errorMessage = 'Đã xảy ra lỗi: ${e.message}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xảy ra lỗi không xác định: ${e.toString()}'),
        ),
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
                    onPressed: () => print("Quên mật khẩu"),
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
                      onTap: _isChecked ? () => print("Google") : null,
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor:
                            _isChecked ? Colors.redAccent : Colors.grey,
                        child: Icon(Icons.g_mobiledata, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: _isChecked ? () => print("Facebook") : null,
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor:
                            _isChecked ? Colors.blueAccent : Colors.grey,
                        child: Icon(Icons.facebook, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: _isChecked ? () => print("Apple") : null,
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor:
                            _isChecked ? Colors.black : Colors.grey,
                        child: Icon(Icons.apple, color: Colors.white),
                      ),
                    ),
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
                  onPressed: () => print("Trải nghiệm không cần đăng nhập"),
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
