import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gbvapp/components/SignUp.dart';
import 'package:gbvapp/firebase/auth_methods.dart';
import '../minicomponents/snack_bar.dart';

class LoginContainer extends StatelessWidget {
  const LoginContainer({super.key});

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
          Login()
        ],
      ),
    );
  }
}

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // input states
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  void login() async {
    FirebaseAuthMethods(FirebaseAuth.instance).login(email: _emailController.text, password: _passwordController.text, context: context);
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
              // heading text
              Text('LOGIN', style: TextStyle(color: Colors.white, fontSize: 30)),

              SizedBox(height: 70),

              // text field 1
              TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    hintText: 'Email',
                  )),

              SizedBox(height: 30),

              // text field 2
              TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    hintText: 'Password',
                  )),

              SizedBox(height: 30),

              // login button
              ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (_passwordController.text.length <= 5) {
                        showErrSnack(context: context, text: 'Password must be atleast 6 characters!');
                      } else if (!_emailController.text.contains('@') || !_emailController.text.contains('.')) {
                        showErrSnack(context: context, text: "An email must contain characters '@' and '.' ");
                      } else {
                        login();
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF332885), minimumSize: const Size.fromHeight(50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: Text('LOGIN', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
              SizedBox(height: 50),

              // bottom text
              BottomTXTlogin()
            ],
          ),
        ),
      ),
    );
  }
}

// bottom text widget
class BottomTXTlogin extends StatelessWidget {
  const BottomTXTlogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpContainer()));
          },
          child: Text(
            'Create Account',
            style: TextStyle(color: Colors.white, decoration: TextDecoration.underline, fontSize: 19),
          ),
        ),
        GestureDetector(
          onTap: () {
            showModalBottomSheet(context: context, isScrollControlled: true, shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25))), builder: (context) => ForgotPass());
          },
          child: Text(
            'Forgot Password?',
            style: TextStyle(color: Colors.white, decoration: TextDecoration.underline, fontSize: 19),
          ),
        )
      ],
    );
  }
}

// forgot password modal

class ForgotPass extends StatefulWidget {
  const ForgotPass({super.key});

  @override
  State<ForgotPass> createState() => _ForgotPassState();
}

class _ForgotPassState extends State<ForgotPass> {
  // state
  TextEditingController _forgotPasswordController = TextEditingController();
  String validationText = '';

  void resetPass() {
    FirebaseAuthMethods(FirebaseAuth.instance).resetPassword(email: _forgotPasswordController.text, context: context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),

            //
            TextField(
                controller: _forgotPasswordController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  hintText: 'Password',
                )),
            SizedBox(height: 5),
            Text(
              validationText,
              style: TextStyle(color: Colors.red.shade900),
            ),
            //
            SizedBox(height: 20),
            //
            SizedBox(
              height: 40,
              width: MediaQuery.of(context).size.width * 0.7,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF332885)),
                  onPressed: () {
                    if (_forgotPasswordController.text.contains('@') && _forgotPasswordController.text.contains('.')) {
                      resetPass();
                    } else {
                      setState(() {
                        validationText = "An email must contain the : '@' and '.'  Symbols !";
                      });
                    }
                  },
                  child: Text(
                    'Send email',
                    style: TextStyle(fontSize: 17),
                  )),
            )
          ],
        ),
      ),
    );
  }
}
