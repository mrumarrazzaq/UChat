import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:uchat365/colors.dart';
import 'package:uchat365/chat_screen.dart';
import 'package:uchat365/reuse_ables/fireBaseFireStore%20Utils.dart';

class RecentChats extends StatefulWidget {
  RecentChats({Key? key, required this.internetConnectionStatus})
      : super(key: key);
  bool internetConnectionStatus;
  @override
  _RecentChatsState createState() => _RecentChatsState();
}

class _RecentChatsState extends State<RecentChats> {
//  String receiverEmail = '';
//  String receiverName = '';
//  String receiverProfileImageUrl = '';
//  Timestamp timestamp = Timestamp.now();
//  fetch() async {
//    final user = FirebaseAuth.instance.currentUser;
//    print(user!.email);
//    print('-------------------------------------');
//    print('Current user data is fetching');
//    try {
//      await FirebaseFirestore.instance
//          .collection('Recent Chats ${currentUserEmail.toString()}')
//          .doc(user.email)
//          .get()
//          .then((ds) {
//        receiverEmail = ds['Receiver Email'];
//        receiverName = ds['Receiver Name'];
//        receiverProfileImageUrl = ds['Receiver profileImageUrl'];
//        timestamp = ds['Created At'];
//      });
//      setState(() {});
//    } catch (e) {
//      print(e.toString());
//    }
//  }

  @override
  Widget build(BuildContext context) {
    print('-------------------------------------------------------------');
    print(
        'Recent Chat Screen Build is Called ${widget.internetConnectionStatus}');
    return Scaffold(
      appBar: AppBar(
        title: const Text.rich(
          TextSpan(
            text: '', // default text style
            children: <TextSpan>[
              TextSpan(
                  text: 'U', style: TextStyle(fontStyle: FontStyle.italic)),
              TextSpan(
                  text: 'Chat', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            color: blueColor,
            width: double.infinity,
            height: 100,
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Text(
                'Users',
                textAlign: TextAlign.center,
                style: TextStyle(color: whiteColor, fontSize: 20),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(top: 50.0),
              child: Container(
                height: double.infinity,
                decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15.0),
                      topRight: Radius.circular(15.0)),
                ),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('User Data')
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            print('Something went wrong');
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(
                                color: blueColor,
                                strokeWidth: 2.0,
                              ),
                            );
                          }
                          final List recentMassages = [];

                          snapshot.data!.docs.map((DocumentSnapshot document) {
                            Map id = document.data() as Map<String, dynamic>;
                            recentMassages.add(id);
//                  print('==============================================');
//                  print(storeRequests);
//                  print('Document id : ${document.id}');
                            id['id'] = document.id;
//                            storedMassages.sort((a, b) => b.value["Created At"]
//                                .compareTo(a.value["Created At"]));
                          }).toList();
                          return Column(
//                            shrinkWrap: true,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              recentMassages.isEmpty
                                  ? const Padding(
                                      padding: EdgeInsets.only(top: 30.0),
                                      child: Center(
                                        child: Text(
                                          'No Recent Chats',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    )
                                  : Container(),
                              for (int i = 0;
                                  i < recentMassages.length;
                                  i++) ...[
                                recentMassages[i]['User Email'] ==
                                        currentUserEmail
                                    ? Container()
                                    : CustomRecentChatsTile(
                                        name: recentMassages[i]['User Name'],
                                        email: recentMassages[i]['User Email'],
                                        massage: recentMassages[i]
                                            ['User Email'],
                                        imagePath: recentMassages[i]
                                            ['User Image Url'],
                                        currentStatus: recentMassages[i]
                                            ['User Current Status'],
                                        noOfMassages: 0,
                                        internetConnectionStatus:
                                            widget.internetConnectionStatus,
                                      ),
                              ],
                            ],
                          );
                        }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomRecentChatsTile extends StatelessWidget {
  CustomRecentChatsTile({
    Key? key,
    required this.name,
    required this.email,
    required this.massage,
    required this.imagePath,
    required this.noOfMassages,
    required this.currentStatus,
    required this.internetConnectionStatus,
  }) : super(key: key);

  String name;
  String email;
  String massage;
  String imagePath;
  int noOfMassages;
  String currentStatus;
  bool internetConnectionStatus;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                name: name,
                currentStatus: currentStatus,
                imagePath: imagePath,
                receiverEmail: email,
                internetConnectionStatus: internetConnectionStatus,
              ),
            ));
      },
      child: Column(
        children: [
          ListTile(
            leading: imagePath != ''
                ? Stack(
                    children: [
                      CircleAvatar(
                        radius: 30.0,
                        backgroundImage: NetworkImage(imagePath),
                      ),
                      Positioned(
                        top: 40,
                        left: 40,
                        child: CircleAvatar(
                          backgroundColor: currentStatus == 'Online'
                              ? Colors.green
                              : Colors.grey[600],
                          radius: 6.5,
                        ),
                      ),
                    ],
                  )
                : Stack(
                    children: [
                      CircleAvatar(
                        radius: 30.0,
                        backgroundImage:
                            const AssetImage('assets/default profile.jpg'),
                        backgroundColor: blueColor.withOpacity(0.4),
                      ),
                      Positioned(
                        top: 40,
                        left: 40,
                        child: CircleAvatar(
                          backgroundColor: currentStatus == 'Online'
                              ? Colors.green
                              : Colors.grey[600],
                          radius: 6.5,
                        ),
                      ),
                    ],
                  ),
            title:
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  massage,
                  overflow: TextOverflow.fade,
//                  style: const TextStyle(fontSize: 11),
                ),
//                Text(time),
              ],
            ),
            trailing: Container(
              height: 20,
              width: 20,
              decoration: BoxDecoration(
                color: noOfMassages == 0
                    ? Colors.white
                    : Colors.purpleAccent.withOpacity(0.7),
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: Center(
                  child: Text(noOfMassages.toString(),
                      style: TextStyle(color: whiteColor))),
            ),
          ),
          const Divider(
            indent: 70,
            endIndent: 10,
          ),
        ],
      ),
    );
  }
}
