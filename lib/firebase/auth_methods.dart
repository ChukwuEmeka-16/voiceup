import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gbvapp/minicomponents/snack_bar.dart';
import '../components/App.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/Login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthMethods {
  // GET the auth and firestore instance
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
   
  FirebaseAuthMethods(this._auth);

  // create an account function
  Future<void> signUpWithEmail({required String email, required String password, required BuildContext context, required String name}) async {
    //
    // get the local storage object, so we can CRUD stuff
    //
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password).then((value) async {
        // after creating the user , we want to create a document for them in the firestore
        CollectionReference users = _firestore.collection('users');
        //
        // create the users document and populate with fields
        //
        await users.doc(value.user!.uid).set({'name': name, 'email': value.user!.email, 'pin': 1234, 'contacts': [], 'incidents': [], 'settings': [], 'securityMode': false});
        showSuccSnack(context: context, text: 'Account created ');
        //
        // store their details in storage, to proove theyve been authenticated
        //
        await prefs.setString('user', value.user!.uid);
        //
        // store the security mode setting to false by default
        await prefs.setBool('active', false);
        //
        // redirect to home screen
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => App(), fullscreenDialog: true));
      });
    } on FirebaseAuthException catch (e) {
      showErrSnack(context: context, text: e.message ?? 'An unexpected error occured');
    } catch (e) {
      showErrSnack(context: context, text: 'An unexpected error occured, please try again');
    }
  }

  // log in function

  Future<void> login({required String email, required String password, required BuildContext context}) async {
    // get the local storage object, so we can CRUD stuff
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password).then((value) async {
        await prefs.setString('user', value.user!.uid);
        // alert logged in
        showSuccSnack(context: context, text: 'Logged in');

        // go to the home page
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => App(), fullscreenDialog: true));
      });
    } on FirebaseAuthException catch (e) {
      showErrSnack(context: context, text: e.message ?? 'An unexpected error occured!');
    } catch (e) {
      showErrSnack(context: context, text: 'An unexpected error occured!');
    }
  }

  // log out

  Future<void> appSignOut({required BuildContext context}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      await _auth.signOut().then((value) async {
        // delete user string from storage
        await prefs.remove('user');
        // go back to login screen
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginContainer(), fullscreenDialog: true));
      });
    } catch (e) {
      showErrSnack(context: context, text: 'error logging out');
    }
  }

  // reset password
  Future<void> resetPassword({required String email, required BuildContext context}) async {
    await _auth.sendPasswordResetEmail(email: email).then((value) => showErrSnack(context: context, text: 'Email sent')).catchError((error) => showErrSnack(context: context, text: 'Failed to send password reset email'));
  }
}
