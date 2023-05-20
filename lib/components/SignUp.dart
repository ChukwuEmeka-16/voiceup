import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gbvapp/firebase/auth_methods.dart';
import 'package:gbvapp/minicomponents/snack_bar.dart';

class SignUpContainer extends StatelessWidget {
  const SignUpContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/authpage.png',
            fit: BoxFit.cover,
            colorBlendMode: BlendMode.darken,
            color: Colors.black.withOpacity(0.2),
          ),
          SignUp()
        ],
      ),
    );
  }
}

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  // states for each of the input fields
  TextEditingController _fullNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  void signUp() async {
    FirebaseAuthMethods(FirebaseAuth.instance).signUpWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
        context: context,
        name: _fullNameController.text);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: EdgeInsets.only(top: 30),
        padding: EdgeInsets.only(left: 30, right: 30),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text('SIGN UP',
                  style: TextStyle(color: Colors.white, fontSize: 30)),

              SizedBox(height: 50),

              // text field 1
              TextField(
                  controller: _fullNameController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.all(10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    hintText: 'Full Name',
                  )),

              SizedBox(height: 30),

              // textfield 2
              TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.all(10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    hintText: 'Email',
                  )),

              SizedBox(height: 30),

              // text field 3
              TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.all(10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    hintText: 'Password',
                  )),

              SizedBox(height: 30),

              // text field 4
              TextField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.all(10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    hintText: 'Confirm Password',
                  )),

              SizedBox(height: 30),
              //
              ////
              // submission button
              ////
              //
              ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (_passwordController.text !=
                          _confirmPasswordController.text) {
                        showErrSnack(
                            context: context, text: 'Passwords do not match!');
                      } else if (_passwordController.text.length <= 5) {
                        showErrSnack(
                            context: context,
                            text: 'Password must be atleast 6 characters!');
                      } else if (!_emailController.text.contains('@') ||
                          !_emailController.text.contains('.')) {
                        showErrSnack(
                            context: context,
                            text:
                                "An email must contain characters '@' and '.' ");
                      } else if (_fullNameController.text.length < 1) {
                        showErrSnack(context: context, text: 'Invalid name');
                      } else {
                        signUp();
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF332885),
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  child: Text('CREATE ACCOUNT',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold))),
              SizedBox(height: 30),
              //
              // bottom text
              //
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      'Login',
                      style: TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.underline),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
