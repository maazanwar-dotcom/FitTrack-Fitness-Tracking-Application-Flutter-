import 'package:fittrack/screens/auth/onboarding_screen.dart';
import 'package:fittrack/screens/home/home_screen.dart';
import 'package:fittrack/widgets/custom_form_fields.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginScreen extends StatefulWidget {
  final String? email;
  final String? password;
  final String? username;
  const LoginScreen({super.key, this.email, this.password, this.username});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formkey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void login() {
    if (_formkey.currentState!.validate()) {
      if (passwordController.text == widget.password &&
          emailController.text == widget.email) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(username: widget.username),
          ),
        );
      } else {
        print('Validation failed');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email or Password Incorrect'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print(widget.username);
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: Form(
        key: _formkey,
        child: Column(
          children: [
            CustomFormFields(
              hintText: 'example@gmail.com',
              label: 'Email',
              controller: emailController,
              validator: (value) {
                print('Validating email: $value'); // Debug print
                if (value == null || value.isEmpty) {
                  return "Email is required";
                }
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value)) {
                  return "Enter a valid email";
                }
                return null;
              },
            ),
            SizedBox(height: 10),
            CustomFormFields(
              hintText: 'minimum 6 characters',
              label: 'Password',
              obsecure: true,
              controller: passwordController,
              validator: (value) {
                print('Validating password: $value'); // Debug print
                if (value == null || value.isEmpty) {
                  return "Password is required";
                }
                if (value.length < 6) {
                  return "Password must be at least 6 characters";
                }
                return null;
              },
            ),
            SizedBox(height: 10),
            TextButton(onPressed: () {}, child: Text('Forgot Password?')),
            SizedBox(height: 10),
            ElevatedButton(onPressed: login, child: Text('Login')),
            SizedBox(height: 10),
            Text(
              '--------------------------------------------or------------------------------------------',
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(FontAwesomeIcons.google, size: 30),
                  SizedBox(width: 20),
                  Text('Sign in with google'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
