import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';

import 'package:uchat365/colors.dart';
import 'package:uchat365/recent_chats.dart';
import 'reuse_ables/fireBaseFireStore Utils.dart';
import 'security_section/signIn_screen.dart';

class MyHomeScreen extends StatefulWidget {
  static const String id = 'MyHomeScreen';
  MyHomeScreen({Key? key, required this.internetConnectionStatus})
      : super(key: key);
  bool internetConnectionStatus;
  @override
  State<MyHomeScreen> createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<MyHomeScreen>
    with WidgetsBindingObserver {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  GlobalKey<SliderDrawerState> _key = GlobalKey<SliderDrawerState>();
  final storage = FlutterSecureStorage();
  bool _isture = true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setUserStatus(status: 'Online');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      //User Status online
      setUserStatus(status: 'Online');
    } else {
      //User Status offLine
      setUserStatus(status: 'Offline');
    }
  }

  void setUserStatus({required String status}) async {
    await _fireStore.collection('User Data').doc('$currentUserEmail').update({
      'User Current Status': status,
    });
  }

  wait() async {
    await Future.delayed(Duration(milliseconds: 1000), () {
      setState(() {
        _isture != _isture;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    print('-------------------------------------------------------------');
    print('HomeScreen Build is Called ${widget.internetConnectionStatus}');
    return SafeArea(
      child: Scaffold(
        body: SliderDrawer(
          key: _key,
          appBar: SliderAppBar(
            appBarColor: blueColor,
            drawerIconColor: whiteColor,
            title: Text(
              'UChat',
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w700, color: whiteColor),
            ),
            trailing: IconButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                await storage.delete(key: 'uid');

                log('------------');
                log('SignOut called');

                await Fluttertoast.showToast(
                  msg: 'User Logout Successfully', // message
                  toastLength: Toast.LENGTH_SHORT, // length
                  gravity: ToastGravity.BOTTOM, // location
                  backgroundColor: Colors.green,
                );

                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SignInScreen(),
                    ),
                    (route) => false);
              },
              icon: Icon(
                Icons.logout,
                color: whiteColor,
              ),
            ),
          ),
          slider: Container(
            color: blueColor,
            padding: const EdgeInsets.only(top: 50.0),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(backgroundColor: whiteColor, radius: 55),
                    CircleAvatar(backgroundColor: blueColor, radius: 50),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Name',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: whiteColor),
                  ),
                ),
                CustamTile(title: 'Profile', iconData: Icons.account_circle),
                Divider(color: whiteColor, indent: 10, endIndent: 10),
                CustamTile(title: 'Setting', iconData: Icons.settings),
                Divider(color: whiteColor, indent: 10, endIndent: 10),
                CustamTile(
                    title: 'Privacy Policy', iconData: Icons.privacy_tip),
                Divider(color: whiteColor, indent: 10, endIndent: 10),
                CustamTile(title: 'Logout', iconData: Icons.logout),
              ],
            ),
          ),
          child: Scaffold(
            floatingActionButton: _isture
                ? FloatingActionButton.extended(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecentChats(
                              internetConnectionStatus:
                                  widget.internetConnectionStatus),
                        ),
                      );
                    },
                    tooltip: 'Start Chat',
                    label: Row(
                      children: const [
                        Padding(
                          padding: EdgeInsets.only(right: 4.0),
                          child: Icon(Icons.chat),
                        ),
                        Text("Start Chat")
                      ],
                    ),
                  )
                : FloatingActionButton(
                    onPressed: () async {
                      // CheckInternetConnectivity();
                      // await checkAdvanceInternetConnectivity();
                    },
                    tooltip: 'Start Chat',
                    child: const Icon(Icons.chat),
                  ),
          ),
        ),
      ),
    );
  }
}

class CustamTile extends StatelessWidget {
  CustamTile({
    Key? key,
    required this.title,
    required this.iconData,
  }) : super(key: key);
  String title;
  IconData iconData;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {},
      child: ListTile(
        leading: Icon(iconData, color: whiteColor),
        title: Text(
          title,
          style: TextStyle(fontSize: 20, color: whiteColor),
        ),
      ),
    );
  }
}
