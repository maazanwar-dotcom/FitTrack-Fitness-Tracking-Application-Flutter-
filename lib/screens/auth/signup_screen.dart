import 'package:fittrack/screens/auth/login_screen.dart';
import 'package:fittrack/widgets/custom_form_fields.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formkey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  void signUp() {
    if (_formkey.currentState!.validate()) {
      // Print values for debugging
      print('Email: ${emailController.text}');
      print('Password: ${passwordController.text}');
      print('Username: ${usernameController.text}');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(
            email: emailController.text,
            password: passwordController.text,
            username: usernameController.text,
          ),
        ),
      );
    } else {
      // This will show if validation fails
      print('Validation failed');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all fields correctly'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0), // Add some padding
        child: Form(
          key: _formkey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
              SizedBox(height: 16),
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
              SizedBox(height: 16),
              CustomFormFields(
                hintText: 'username',
                label: 'Username',
                controller: usernameController,
                validator: (value) {
                  print('Validating username: $value'); // Debug print
                  if (value == null || value.isEmpty) {
                    return "Username is required";
                  }
                  if (value.length < 3) {
                    return "Username must be at least 3 characters";
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(onPressed: signUp, child: Text('Continue')),
            ],
          ),
        ),
      ),
    );
  }
}
