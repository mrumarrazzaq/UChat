// ignore_for_file: avoid_print, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:form_field_validator/form_field_validator.dart';

import 'package:uchat365/colors.dart';
import 'package:uchat365/reuse_ables/widgets.dart';
import 'package:uchat365/security_section/signIn_screen.dart';

final user = FirebaseFirestore.instance;

class RegisterScreen extends StatefulWidget {
  static const String id = 'RegisterScreen';

  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  var fcmToken;

  bool _isLoading = false;
  final bool _obscure = true;

  String _name = '';
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  final String _imageURL = '';

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? validatePassword(value) {
    if (value.isEmpty) {
      return 'Please enter password';
    } else if (value.length < 8) {
      return 'Should be at least 8 characters';
    } else if (value.length > 25) {
      return 'Should not be more than 25 characters';
    } else {
      return null;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> registration() async {
    if (_password == _confirmPassword) {
      try {
        print(_name);
        print(_email);
        print(_password);
        print(_confirmPassword);

        _isLoading = true;

        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: _email, password: _password);
        print(userCredential);

        final json = {
          'User Name': _name,
          'User Email': _email,
          'User Password': _password,
          'User Image Url': _imageURL,
          'User Current Status': '.online.',
        };

        user.collection('User Data').doc(_email).set(json);
        fcmToken = await _fcm.getToken();

        final jsonToken = {
          'token': fcmToken,
          'createdAT': FieldValue.serverTimestamp(),
        };

        print('--------------------------------------------------');
        print('FCM Token : $fcmToken');
        print('--------------------------------------------------');
        user
            .collection('User Data')
            .doc(_email)
            .collection('token')
            .doc(_email)
            .set(jsonToken);

        Fluttertoast.showToast(
          msg: 'Registered Successfully.. Now Login', // message
          toastLength: Toast.LENGTH_SHORT, // length
          gravity: ToastGravity.BOTTOM, // location
          backgroundColor: Colors.green,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignInScreen()),
        );
      } on FirebaseAuthException catch (e) {
        setState(() {
          _isLoading = false;
        });
        if (e.code == 'weak-password') {
          _scaffoldKey.currentState!.showSnackBar(
            const SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                'Password Provided is too Weak!!',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
            ),
          );
        } else if (e.code == 'email-already-in-use') {
          setState(() {
            _isLoading = false;
          });

          _scaffoldKey.currentState!.showSnackBar(
            const SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                'Sorry! Account Already Exist !',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
              duration: Duration(seconds: 1),
            ),
          );
        }
      }
    } else {
      setState(() {
        _isLoading = false;
      });

      _scaffoldKey.currentState!.showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Password and Confirm Password doesn\'t match!!',
            style: TextStyle(fontSize: 15, color: Colors.white),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print("RegisterScreen Build Run");

    return Scaffold(
      key: _scaffoldKey,
      // backgroundColor: purpleColor,
      body: Center(
        child: ListView(
          shrinkWrap: true,
          children: [
            Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Text(
                      'REGISTER',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: blueColor,
                      ),
                    ),
                  ),

                  // Name
                  InputField(
                    label: 'Name',
                    hint: 'Enter Name',
                    textInputType: TextInputType.text,
                    controller: _nameController,
                    prefixIcon: Icons.person,
                    isFieldDisable: _isLoading,
                    validate: (value) {
                      if (value!.isEmpty) {
                        return "Please enter name";
                      } else if (double.tryParse(value) != null) {
                        return 'numbers not allowed';
                      }
                      return null;
                    },
                  ),
                  //Email Address
                  InputField(
                    label: 'Email Id',
                    hint: 'Enter Email Id',
                    textInputType: TextInputType.emailAddress,
                    controller: _emailController,
                    prefixIcon: Icons.alternate_email,
                    isFieldDisable: _isLoading,
                    validate: MultiValidator(
                      [
                        RequiredValidator(errorText: 'Please enter a email'),
                        EmailValidator(errorText: 'Not a Valid Email'),
                      ],
                    ),
                  ),
                  //Password
                  InputField(
                    label: 'Password',
                    hint: 'Enter password',
                    textInputType: TextInputType.text,
                    controller: _passwordController,
                    prefixIcon: Icons.vpn_key,
                    isFieldDisable: _isLoading,
                    enableSuffixIcon: true,
                    obscureText: _obscure,
                    validate: validatePassword,
                  ),
                  //Confirm Password
                  InputField(
                    label: 'Confirm Password',
                    hint: 'Enter Confirm Password',
                    textInputType: TextInputType.text,
                    controller: _confirmPasswordController,
                    prefixIcon: Icons.vpn_key,
                    isFieldDisable: _isLoading,
                    enableSuffixIcon: true,
                    obscureText: _obscure,
                    validate: validatePassword,
                  ),

                  Material(
                    color: blueColor,
                    clipBehavior: Clip.antiAlias,
                    borderRadius: BorderRadius.circular(30.0),
                    child: MaterialButton(
                      minWidth: _isLoading ? 50.0 : 160.0,
                      height: 40.0,
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      onPressed: () {
                        SystemChannels.textInput.invokeMethod('TextInput.hide');
                        if (_isLoading) {
                        } else {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              _name = _nameController.text.trim();
                              _email = _emailController.text.trim();
                              _password = _passwordController.text.trim();
                              _confirmPassword =
                                  _confirmPasswordController.text.trim();
                            });
                            registration();
                          }
                        }
                      },
                      child: _isLoading
                          ? SizedBox(
                              height: 30.0,
                              width: 30.0,
                              child: CircularProgressIndicator(
                                color: whiteColor,
                                strokeWidth: 3.0,
                              ),
                            )
                          : Text(
                              'Register',
                              style: TextStyle(
                                color: whiteColor,
                              ),
                            ),
                    ),
                  ),
                  // TextButton(
                  //     onPressed: () async {
                  //       fcmToken = await _fcm.getToken();
                  //       print('----------------------');
                  //       print('FCM Token : $fcmToken');
                  //       print('----------------------');
                  //     },
                  //     child: Text('abcd')),
                  //Other options
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already have an Account? ",
                          style: TextStyle(color: blackColor)),
                      TextButton(
                          onPressed: () => {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SignInScreen(),
                                  ),
                                )
                              },
                          child: const Text('SignIn'))
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
