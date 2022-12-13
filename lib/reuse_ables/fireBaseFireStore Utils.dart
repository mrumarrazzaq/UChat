import 'package:firebase_auth/firebase_auth.dart';

final currentUserId = FirebaseAuth.instance.currentUser!.uid;
var currentUserEmail = FirebaseAuth.instance.currentUser!.email;
