// ignore_for_file: avoid_print, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'forgot_password.dart';
import 'package:uchat365/colors.dart';
import 'package:uchat365/my_home_screen.dart';
import 'package:uchat365/reuse_ables/widgets.dart';
import 'package:uchat365/security_section/registeration_screen.dart';

class SignInScreen extends StatefulWidget {
  static const String id = 'SignInScreen';

  SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final bool _obscureText = true;
  bool _isLoading = false;

  var email = "";
  var password = "";

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final storage = const FlutterSecureStorage();

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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> userSignIn() async {
    try {
      _isLoading = true;
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
//      //______________________________________________________________________//
      print('user credential email : ${userCredential.user?.email}');
//      //STORE user id into the Local Database
      await storage.write(key: 'uid', value: userCredential.user?.uid);
      //______________________________________________________________________//

      Fluttertoast.showToast(
        msg: 'User Login Successfully', // message
        toastLength: Toast.LENGTH_SHORT, // length
        gravity: ToastGravity.BOTTOM, // location
        backgroundColor: Colors.green,
      );

      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => MyHomeScreen(internetConnectionStatus: false),
          ),
          (route) => false);
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (e.code == 'user-not-found') {
        _scaffoldKey.currentState!.showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              "No User Found for that Email",
              style: TextStyle(fontSize: 15.0, color: Colors.white),
            ),
          ),
        );
      } else if (e.code == 'wrong-password') {
        setState(() {
          _isLoading = false;
        });
        _scaffoldKey.currentState!.showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              "Wrong Password Provided by User",
              style: TextStyle(fontSize: 15.0, color: Colors.white),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print("SignInScreen Build Run");

    return Scaffold(
      key: _scaffoldKey,
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'LOGIN',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: blueColor,
                    fontSize: 30,
                  ),
                ),
                const SizedBox(height: 20),
                InputField(
                  label: 'Email Id',
                  hint: 'Enter Email Id',
                  textInputType: TextInputType.emailAddress,
                  prefixIcon: Icons.alternate_email,
                  controller: _emailController,
                  isFieldDisable: _isLoading,
                  validate: MultiValidator([
                    RequiredValidator(errorText: 'Please enter email'),
                    EmailValidator(errorText: 'Not a Valid Email'),
                  ]),
                ),
                InputField(
                  label: 'Password',
                  hint: 'Enter Password',
                  textInputType: TextInputType.text,
                  prefixIcon: Icons.vpn_key,
                  controller: _passwordController,
                  isFieldDisable: _isLoading,
                  obscureText: _obscureText,
                  enableSuffixIcon: true,
                  validate: validatePassword,
                ),
                Material(
                  color: blueColor,
                  borderRadius: BorderRadius.circular(30.0),
                  clipBehavior: Clip.antiAlias,
                  child: MaterialButton(
                    minWidth: _isLoading ? 50.0 : 160.0,
                    elevation: 3.0,
                    height: 40.0,
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    onPressed: () {
                      SystemChannels.textInput.invokeMethod('TextInput.hide');

                      if (_isLoading) {
                      } else {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            email = _emailController.text.trim();
                            password = _passwordController.text.trim();
                          });
                          userSignIn();
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
                            'Login',
                            style: TextStyle(
                              color: whiteColor,
                            ),
                          ),
                  ),
                ),
                TextButton(
                  onPressed: () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForgotPassword(),
                      ),
                    )
                  },
                  child: const Text(
                    'Forgot Password ?',
                    style: TextStyle(fontSize: 14.0, color: Colors.blue),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have account? ",
                        style: TextStyle(color: blackColor)),
                    TextButton(
                        onPressed: () => {
                              SystemChannels.textInput
                                  .invokeMethod('TextInput.hide'),
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterScreen(),
                                ),
                              )
                            },
                        child: const Text('Register'))
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
