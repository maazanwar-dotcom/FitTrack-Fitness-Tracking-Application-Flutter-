import 'package:fittrack/screens/home/WorkoutScreen.dart';
import 'package:fittrack/widgets/custom_form_fields.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (_formkey.currentState!.validate()) {
      try {
        final credential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
              email: emailController.text.trim(),
              password: passwordController.text,
            );
        Navigator.pushReplacement<void, void>(
          context,
          MaterialPageRoute<void>(builder: (context) => WorkoutScreen()),
        );
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message ?? 'Login failed')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
              '-----------------------------or-----------------------------',
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement Google Sign-In if needed
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.account_circle, size: 30),
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
