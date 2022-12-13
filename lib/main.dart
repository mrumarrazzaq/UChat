// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'my_home_screen.dart';
import 'package:uchat365/colors.dart';
import 'package:uchat365/onboading_screen.dart';

// //-------------------Android Channel-------------------//
// const AndroidNotificationChannel channel = AndroidNotificationChannel(
//   'high_importance_channel', //id
//   'High Importance Notification', //name
//   'This channel is used for notification', //description
//   importance: Importance.high,
//   playSound: true,
// );
//
// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();
//
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   print('--------------------------------------------------');
//   print('Handling a background message ${message.messageId}');
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // await flutterLocalNotificationsPlugin
  //     .resolvePlatformSpecificImplementation<
  //         AndroidFlutterLocalNotificationsPlugin>()
  //     ?.createNotificationChannel(channel);
  //
  // await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
  //   alert: true,
  //   sound: true,
  //   badge: true,
  // );

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const MyApp());
}

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'UChat App',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primaryColor: purpleColor,
//         splashColor: purpleColor.withOpacity(0.4),
//         accentColor: purpleColor,
//         appBarTheme: AppBarTheme(
//           backgroundColor: purpleColor,
//           actionsIconTheme: IconThemeData(color: whiteColor),
//           iconTheme: IconThemeData(color: whiteColor),
//           foregroundColor: whiteColor,
//           centerTitle: true,
//           elevation: 0.0,
//         ),
//       ),
//       home: OnBoardingScreen(),
// //       initialRoute: OnBoardingScreen.id,
// //       routes: {
// // //        SigninScreen.id: (context) => SigninScreen(),
// // //        RegisterScreen.id: (context) => const RegisterScreen(),
// // //         ForgotPassword.id: (context) => const ForgotPassword(),
// // //        ChangePassword.id: (context) => const ChangePassword(),
// // //         HomeScreen.id: (context) => HomeScreen(),
// // //        SettingsScreen.id: (context) => SettingsScreen(),
// //       },
//     );
//   }
// }

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  bool _internetConnectionStatus = false;
  final storage = const FlutterSecureStorage();

  Future<bool> checkLoginStatus() async {
    String? value = await storage.read(key: 'uid');
    if (value == null) {
      print('---------------');
      print('User is logOUT');
      return false;
    } else {
      print('---------------');
      print('User is logIN');
      return true;
    }
  }

  @override
  void initState() {
    super.initState();

    //----------------InternetConnectionChecker------------------//
    InternetConnectionChecker().onStatusChange.listen(
      (status) {
        final hasInternet = status == InternetConnectionStatus.connected;
        final text = hasInternet ? 'Internet' : 'No internet connection';
        final color = hasInternet ? Colors.green : Colors.red;
        final icon = hasInternet ? Icons.wifi : Icons.wifi_off;
        setState(
          () {
            _internetConnectionStatus = hasInternet;
            showSimpleNotification(
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
              leading: Icon(icon),
              background: color,
            );
          },
        );
      },
    );
    //----------------------------------------------------------//

    // FirebaseMessaging.onMessage.listen(
    //   (RemoteMessage message) {
    //     RemoteNotification? notification = message.notification;
    //     AndroidNotification? android = message.notification?.android;
    //     if (notification != null && android != null) {
    //       flutterLocalNotificationsPlugin.show(
    //         notification.hashCode,
    //         notification.title,
    //         notification.body,
    //         NotificationDetails(
    //           android: AndroidNotificationDetails(
    //             channel.id,
    //             channel.name,
    //             channel.description,
    //             color: Colors.red,
    //             icon: '@mipmap/ic_launcher',
    //             playSound: true,
    //           ),
    //         ),
    //       );
    //     }
    //   },
    // );
    //
    // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    //   print('A new onMessageOpenedApp event');
    //   RemoteNotification? notification = message.notification;
    //   AndroidNotification? android = message.notification?.android;
    //   if (notification != null && android != null) {
    //     showDialog(
    //         context: context,
    //         builder: (_) {
    //           return AlertDialog(
    //             title: Text('${notification.title}'),
    //             content: SingleChildScrollView(
    //               child: Column(
    //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                 children: [
    //                   Text('${notification.body}'),
    //                 ],
    //               ),
    //             ),
    //           );
    //         });
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'UChat App',
        theme: ThemeData(
          primaryColor: blueColor,
          splashColor: blueColor.withOpacity(0.4),
          // ignore: deprecated_member_use
          accentColor: blueColor,
          appBarTheme: AppBarTheme(
            backgroundColor: blueColor,
            actionsIconTheme: IconThemeData(color: whiteColor),
            iconTheme: IconThemeData(color: whiteColor),
            foregroundColor: whiteColor,
            centerTitle: true,
            elevation: 0.0,
          ),
        ),
        home: FutureBuilder(
          future: checkLoginStatus(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            //Check for errors
            if (snapshot.hasError) {
              print('Something went wrong.');
              return Scaffold(
                body: Center(
                  child: CircularProgressIndicator(
                    color: blueColor,
                    strokeWidth: 2.0,
                  ),
                ),
              );
            }
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.data == false) {
                print('======================');
                print('OnBoarding Screen Called');
                return const OnBoardingScreen();
              }
              print('======================');
              print('MYHome Screen Called');
              return MyHomeScreen(
                internetConnectionStatus: _internetConnectionStatus,
              );
            }
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  color: blueColor,
                  strokeWidth: 2.0,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
