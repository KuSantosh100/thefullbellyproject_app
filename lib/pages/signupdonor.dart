import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thefullbellyproject_app/pages/onboarding.dart';

class SignUpDonorPage extends StatefulWidget {
  static const String id = 'signUpDonor';
  @override
  SignUpDonorPageState createState() => SignUpDonorPageState();
}

class SignUpDonorPageState extends State<SignUpDonorPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  void _handleGoogleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User user = userCredential.user!;
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': user.displayName,
        'email': user.email,
        'type': 'donor',
      });
      await FirebaseFirestore.instance.collection('donors').doc(user.uid).set({
        'name': user.displayName,
        'email': user.email,
        'compWorks': [],
      });
      _handleSignUpSuccess();
    } catch (e) {
      print(e);
    }
  }

  void _handleSignUp() async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'name': _nameController.text,
        'username': _usernameController.text,
        'email': _emailController.text,
        'location': _locationController.text,
        'type': 'donor',
      });
      await FirebaseFirestore.instance
          .collection('donors')
          .doc(userCredential.user!.uid)
          .set({
        'name': _nameController.text,
        'username': _usernameController.text,
        'email': _emailController.text,
        'location': _locationController.text,
        'compWorks': [],
      });
      _handleSignUpSuccess();
    } catch (e) {
      print(e);
    }
  }

  void _handleSignUpSuccess() {
    Navigator.pushNamed(context, OnboardingPage.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _handleSignUp,
              child: const Text('Sign Up'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _handleGoogleSignIn,
              child: const Text('Sign Up with Google'),
            ),
          ],
        ),
      ),
    );
  }
}
