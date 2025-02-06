import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:homepage/assets.dart';
import 'package:homepage/color.dart';
import 'package:homepage/forgotpassword.dart';
import 'package:homepage/homecontent.dart';
import 'package:homepage/signup.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Import the http package

class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _DoorHubSignInPageState();
}

class _DoorHubSignInPageState extends State<Loginpage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  final _shakeKey = GlobalKey<ShakeWidgetState>(); 

 Future<String> login(String emailOrPhone, String password) async {
  final String url = 'http://192.168.1.150:8080/api/parlour/ParlourLogin'; // Replace with your backend API URL
  
  final Map<String, dynamic> requestBody = {
    'email': emailOrPhone,
    'password': password,
  };
  
  final response = await http.post(
    Uri.parse(url),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(requestBody),
  );

  if (response.statusCode == 200) {
    final responseData = json.decode(response.body);
    final token = responseData['token'];  // Extract token
    final int parlourId = responseData['parlour']['id']; // Extract parlour ID

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token); // Store token
    await prefs.setInt('parlourId', parlourId); // Store parlour ID

    print('Parlour ID: $parlourId'); 

    return 'Login successful';
  } else {
    return 'Login failed: ${response.body}';
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 100),
            Center(child: Image.asset(loginAssets.kLogoBlue)),
            const SizedBox(height: 62),
            const Text('Sign in',
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: Colors.black)),
            const SizedBox(height: 10),
            SizedBox(height: 24),

            // Form widget
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Phone Number Field
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                        color: loginColors.kInput,
                        borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      children: [
                        Container(
                          height: 20,
                          width: 2,
                          decoration: BoxDecoration(
                            color: AppColors.kPrimary,
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: AuthField(
                              controller: _phoneController,
                              hintText: 'Email or Phone Number',
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email or phone number';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Password Field
                  Container(
                    decoration: BoxDecoration(
                        color: loginColors.kInput,
                        borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      children: [
                        Container(
                          height: 20,
                          width: 2,
                          decoration: BoxDecoration(
                            color: AppColors.kPrimary,
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: TextFormField(
                              controller: _passwordController,
                              obscureText: !_isPasswordVisible,
                              decoration: InputDecoration(
                                hintText: 'Password',
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.black,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                                hintStyle: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.kHint),
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Inside your ShakeWidget, shake the button when form is invalid
            ShakeWidget(
              key: _shakeKey,
              shakeOffset: 10.0,
              shakeDuration: const Duration(milliseconds: 500),
              child: PrimaryButton(
                onTap: () async {
                  if (_formKey.currentState!.validate()) {
                    String emailOrPhone = _phoneController.text;
                    String password = _passwordController.text;
                    
                    // Call the backend login function
                    String result = await login(emailOrPhone, password);
                    
                    if (result == 'Login successful') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Homecontent()),
                      );
                    } else {
                      // Show an error message if login fails
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(result)),
                      );
                    }
                  } else {
                    _shakeKey.currentState?.shake();
                  }
                },
                text: 'Login',
                color: AppColors.kPrimary,
              ),
            ),

            const SizedBox(height: 63),
            const Center(
                child: Text('Sign in with',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomSocialButton(onTap: () {}, icon: loginAssets.kGoogle),
                const SizedBox(width: 35),
                CustomSocialButton(onTap: () {}, icon: loginAssets.kFacebook),
                const SizedBox(width: 35),
                CustomSocialButton(onTap: () {}, icon: loginAssets.kApple),
              ],
            ),
            const SizedBox(height: 65),
            Center(
              child: PrimaryButton(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Homecontent()),
                  );
                },
                text: 'Continue as a Guest',
                color: loginColors.kInput,
                textColor: Colors.black,
                width: 240,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Create a New Account?',
                    style: TextStyle(fontSize: 13, color: Color(0xFF9A9FA5))),
                CustomTextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Signup()),
                    );
                  },
                  text: 'Sign Up',
                ),
                CustomTextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
                    );
                  },
                  text: 'forgot password',
                )
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

abstract class ShakeAnimation<T extends StatefulWidget> extends State<T>
    with SingleTickerProviderStateMixin {
  ShakeAnimation(this.animationDuration);
  final Duration animationDuration;
  late final animationController =
      AnimationController(vsync: this, duration: animationDuration);

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}

class ShakeWidget extends StatefulWidget {
  const ShakeWidget({
    required this.child,
    required this.shakeOffset,
    Key? key,
    this.shakeCount = 3,
    this.shakeDuration = const Duration(milliseconds: 400),
  }) : super(key: key);
  final Widget child;
  final double shakeOffset;
  final int shakeCount;
  final Duration shakeDuration;

  @override
  ShakeWidgetState createState() => ShakeWidgetState(shakeDuration);
}

class ShakeWidgetState extends ShakeAnimation<ShakeWidget> {
  ShakeWidgetState(Duration duration) : super(duration);

  @override
  void initState() {
    super.initState();
    animationController.addStatusListener(_updateStatus);
  }

  void _updateStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      animationController.reset();
    }
  }

  void shake() {
    animationController.forward();
  }

  @override
  void dispose() {
    animationController.removeStatusListener(_updateStatus);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      child: widget.child,
      builder: (context, child) {
        final sineValue =
            sin(widget.shakeCount * 2 * pi * animationController.value);
        return Transform.translate(
          offset: Offset(sineValue * widget.shakeOffset, 0),
          child: child,
        );
      },
    );
  }
}

class CustomSocialButton extends StatelessWidget {
  final VoidCallback onTap;
  final String icon;
  const CustomSocialButton(
      {super.key, required this.onTap, required this.icon});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 55,
        width: 55,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: loginColors.kNeutral01,
          border: Border.all(color: loginColors.kNeutral03, width: 2),
        ),
        child: SvgPicture.asset(icon),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  final double? width;
  final double? height;
  final double? borderRadius;
  final double? fontSize;
  final Color? color;
  final Color? textColor; // Add this line for text color
  final bool isBorder;

  const PrimaryButton({
    required this.onTap,
    required this.text,
    this.height,
    this.width,
    this.borderRadius,
    this.isBorder = false,
    this.fontSize,
    this.color,
    this.textColor, // Add this line for text color
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? AppColors.kPrimary,
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 10),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor ?? Colors.white, // Use the textColor parameter
          fontSize: fontSize ?? 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class CustomTextButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Color? color;
  final double? fontSize;
  const CustomTextButton({
    required this.onPressed,
    required this.text,
    this.fontSize,
    this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(color: AppColors.kPrimary, fontSize: 12),
      ),
    );
  }
}

class AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator; // Validator function here
  final String? Function(String?)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final EdgeInsets? padding;

  const AuthField(
      {super.key,
      required this.controller,
      required this.hintText,
      this.keyboardType,
      this.validator,
      this.onChanged,
      this.padding,
      this.inputFormatters});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator, // Pass the validator here
      onChanged: onChanged,
      style: const TextStyle(
          fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black),
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
          filled: false,
          hintText: hintText,
          hintStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.kHint),
          contentPadding: padding),
      keyboardType: keyboardType,
    );
  }
}