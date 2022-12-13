import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_5.dart';

import 'package:uchat365/colors.dart';

import 'reuse_ables/fireBaseFireStore Utils.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen({
    Key? key,
    required this.name,
    required this.receiverEmail,
    required this.currentStatus,
    required this.imagePath,
    required this.internetConnectionStatus,
  }) : super(key: key);
  String name;
  String imagePath;
  String receiverEmail;
  String currentStatus;
  bool internetConnectionStatus;
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  var chatBubbleId;
  var selectedChatBubbleId = '';

  List<String> chatBubbleIdsList = [];

  Color selectedChatBubbleColor = Colors.blue;

  bool _isChatBubbleSelected = false;

  final TextEditingController _massageController = TextEditingController();
  final TextEditingController textEditionController = TextEditingController();
  ScrollController scrollController = ScrollController();
  String _message = 'default';

  final IconData _messageStatus = Icons.access_time_sharp;

  bool isTextFieldEmpty = true;
  Offset _tapPosition = const Offset(0, 0);

  saveMassages(String time, String message, int messageStatus) async {
    await FirebaseFirestore.instance.collection('$currentUserEmail').add({
      'Message': message,
      'Reaction': '',
      'Sender Email': currentUserEmail.toString(),
      'Receiver Email': widget.receiverEmail,
      'Message Status': messageStatus,
      'Created At': DateTime.now(),
      'Time': time,
    });
    await FirebaseFirestore.instance.collection(widget.receiverEmail).add({
      'Message': message,
      'Reaction': '',
      'Sender Email': currentUserEmail.toString(),
      'Receiver Email': widget.receiverEmail,
      'Message Status': messageStatus,
      'Created At': DateTime.now(),
      'Time': time,
    });
    print('-------------------------');
    print('Massage Send Successfully');
    print('-------------------------');
  }

  //--------------------------------------------------------------//
  CollectionReference event =
      FirebaseFirestore.instance.collection('$currentUserEmail');

  Future<void> deleteChatBubble(id) {
    return event
        .doc(id)
        .delete()
        .then((value) => log('Event deleted '))
        .catchError((error) => log('Failed to delete Chat $error'));
  }

  updateChatBubble(String id, String userReaction) async {
    print(currentUserEmail);
    print(widget.receiverEmail);

    await FirebaseFirestore.instance
        .collection('$currentUserEmail')
        .doc(id)
        .update({
          'isCompleted': 1,
          'Reaction': userReaction,
        })
        .then((value) => print('Sender Message Status Updated'))
        .catchError((error) => print('Failed to Update $error'));

    await FirebaseFirestore.instance
        .collection(widget.receiverEmail)
        .doc(id)
        .update({
          'isCompleted': 1,
          'Reaction': userReaction,
        })
        .then((value) => print('Receiver Message Status Updated'))
        .catchError((error) => print('Failed to Update $error'));
  }

  void resetToRest() {
    setState(() {
      _isChatBubbleSelected = false;
      selectedChatBubbleId = '';
      chatBubbleIdsList.clear();
    });
  }
  //--------------------------------------------------------------//

  @override
  Widget build(BuildContext context) {
    log('-------------------------------------------------------------');
    log('Chat Screen Build is Called ${widget.internetConnectionStatus}');

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text.rich(
            TextSpan(
              text: '', // default text style
              children: <TextSpan>[
                TextSpan(
                    text: 'U', style: TextStyle(fontStyle: FontStyle.italic)),
                TextSpan(
                    text: 'Chat',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        body: Stack(
          children: [
            _isChatBubbleSelected
                ? Hero(
                    tag: 'animate1',
                    child: Container(
                        color: blueColor,
                        width: double.infinity,
                        height: 100,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 3.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                icon: Icon(Icons.arrow_back, color: whiteColor),
                                onPressed: () {
                                  resetToRest();
                                },
                              ),
                              // Text(
                              //   '${chatBubbleIdsList.length}',
                              //   style: TextStyle(
                              //     color: whiteColor,
                              //   ),
                              // ),
                              IconButton(
                                icon: Icon(Icons.replay, color: whiteColor),
                                onPressed: () {},
                              ),
                              IconButton(
                                icon: Icon(Icons.star, color: whiteColor),
                                onPressed: () {},
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: whiteColor),
                                onPressed: () {
                                  deleteChatBubble(chatBubbleId);
                                  setState(() {
                                    _isChatBubbleSelected = false;
                                    selectedChatBubbleColor =
                                        Colors.transparent;
                                  });
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.copy, color: whiteColor),
                                onPressed: () {},
                              ),
                              IconButton(
                                icon: Icon(Icons.share, color: whiteColor),
                                onPressed: () {},
                              ),
                              IconButton(
                                icon: Icon(Icons.more_vert, color: whiteColor),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        )),
                  )
                : Hero(
                    tag: 'animate1',
                    child: Container(
                        color: blueColor,
                        width: double.infinity,
                        height: 100,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 0.0),
                          child: GestureDetector(
                            child: ListTile(
                              leading: widget.imagePath != ''
                                  ? CircleAvatar(
                                      radius: 30.0,
                                      backgroundImage:
                                          NetworkImage(widget.imagePath),
                                      backgroundColor:
                                          blueColor.withOpacity(0.4),
                                    )
                                  : CircleAvatar(
                                      radius: 30.0,
                                      foregroundImage: const AssetImage(
                                          'assets/default profile.jpg'),
                                      backgroundColor:
                                          blueColor.withOpacity(0.4),
                                    ),
                              title: Text(widget.name,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: whiteColor)),
                              dense: true,
                              subtitle: StreamBuilder<QuerySnapshot>(
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
                                      ));
                                    }

                                    final List storedMassages = [];

                                    snapshot.data!.docs
                                        .map((DocumentSnapshot document) {
                                      Map id = document.data()
                                          as Map<String, dynamic>;
                                      if (widget.receiverEmail == document.id) {
                                        storedMassages.add(id);
                                        id['id'] = document.id;
                                      }
                                    }).toList();

                                    return Text(
                                        storedMassages[0]
                                            ['User Current Status'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: whiteColor));
                                  }),
                              trailing: SizedBox(
                                width: 160,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                        icon: Icon(Icons.video_call,
                                            color: whiteColor),
                                        onPressed: () {}),
                                    IconButton(
                                        icon:
                                            Icon(Icons.call, color: whiteColor),
                                        onPressed: () {}),
                                    IconButton(
                                        icon: Icon(Icons.more_vert,
                                            color: whiteColor),
                                        onPressed: () {}),
                                  ],
                                ),
                              ),
                            ),
                            onTap: () {
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //       builder: (context) => FreelancerProfileScreen(
                              //         userName: widget.name,
                              //         userEmail: widget.receiverEmail,
                              //         userProfileUrl: widget.imagePath,
                              //         requestCategory: 'Special Category',
                              //       ),
                              //     ));
                            },
                          ),
                        )),
                  ),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(top: 70.0, bottom: 63.0),
                child: GestureDetector(
                  onTap: () {
                    chatBubbleIdsList.clear();
                    if (selectedChatBubbleId != '') {
                      resetToRest();
                    }
                  },
                  child: Container(
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: whiteColor,
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15.0),
                          topRight: Radius.circular(15.0)),
                    ),
                    child: Scrollbar(
                      radius: const Radius.circular(30.0),
                      controller: scrollController,
                      child: ListView(
                        shrinkWrap: true,
                        reverse: true,
                        children: [
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('$currentUserEmail')
                                .orderBy('Created At', descending: false)
                                .snapshots(),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.hasError) {
                                log('Something went wrong');
                              }
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                      bottom:
                                          MediaQuery.of(context).size.height *
                                              0.3),
                                  child: Center(
                                    child: SizedBox(
                                      height: 15,
                                      width: 15,
                                      child: CircularProgressIndicator(
                                        color: blueColor,
                                        strokeWidth: 2.0,
                                      ),
                                    ),
                                  ),
                                );
                              }

                              final List storedMassages = [];

                              snapshot.data!.docs
                                  .map((DocumentSnapshot document) {
                                Map id =
                                    document.data() as Map<String, dynamic>;
                                storedMassages.add(id);
                                id['id'] = document.id;
                              }).toList();

                              return Column(
//                            crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // storedMassages.isEmpty
                                  //     ? Padding(
                                  //         padding: const EdgeInsets.only(
                                  //             bottom: 50.0),
                                  //         child: Center(
                                  //           child: Text(
                                  //             'Say Hi to ${widget.name}',
                                  //             style: const TextStyle(
                                  //                 fontWeight: FontWeight.bold),
                                  //           ),
                                  //         ),
                                  //       )
                                  //     : Container(),
                                  for (int i = 0;
                                      i < storedMassages.length;
                                      i++) ...[
                                    storedMassages[i]['Sender Email'] ==
                                                currentUserEmail &&
                                            storedMassages[i]
                                                    ['Receiver Email'] ==
                                                widget.receiverEmail
                                        ?
                                        //Sender ChatBubble

                                        Stack(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  chatBubbleIdsList.add(
                                                      storedMassages[i]['id']);
                                                },
                                                onTapDown: (details) {
                                                  _tapPosition =
                                                      details.globalPosition;
                                                  print(_tapPosition);
                                                },
                                                onLongPress: () async {
                                                  setState(() {
                                                    _isChatBubbleSelected =
                                                        true;
                                                    chatBubbleId =
                                                        storedMassages[i]['id'];
                                                    selectedChatBubbleId =
                                                        storedMassages[i]['id'];
                                                    chatBubbleIdsList.add(
                                                        selectedChatBubbleId);
                                                  });
                                                  showReactionMenu(
                                                    context,
                                                    _tapPosition,
                                                    chatBubbleId,
                                                  );
                                                  print(
                                                      'selectedChatBubbleId : $selectedChatBubbleId');
                                                },
                                                child: Container(
                                                  width: double.infinity,
                                                  color: storedMassages[i]
                                                              ['id'] ==
                                                          selectedChatBubbleId
                                                      ? Colors.blue[100]
                                                      : transparentColor,
                                                  child: ChatBubble(
                                                    clipper: ChatBubbleClipper5(
                                                        type: BubbleType
                                                            .sendBubble),
                                                    shadowColor: Colors.black,
                                                    elevation: 1.5,
                                                    alignment:
                                                        Alignment.topRight,
                                                    margin:
                                                        const EdgeInsets.only(
                                                            top: 10,
                                                            right: 10,
                                                            bottom: 8.0),
                                                    backGroundColor: blueColor,
                                                    child: Container(
                                                      constraints:
                                                          BoxConstraints(
                                                        maxWidth: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.7,
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        children: [
                                                          Text(
                                                            storedMassages[i]
                                                                ['Message'],
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .white),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    top: 5.0),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Text(
                                                                  storedMassages[
                                                                          i]
                                                                      ['Time'],
                                                                  style: TextStyle(
                                                                      fontStyle:
                                                                          FontStyle
                                                                              .italic,
                                                                      textBaseline:
                                                                          TextBaseline
                                                                              .ideographic,
                                                                      color: Colors
                                                                              .grey[
                                                                          400],
                                                                      fontSize:
                                                                          11),
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                          .symmetric(
                                                                      horizontal:
                                                                          4.0),
                                                                  child: Icon(
                                                                      storedMassages[i]['Message Status'] == 0
                                                                          ? Icons
                                                                              .check
                                                                          : Icons
                                                                              .access_time_sharp,
                                                                      size: 15,
                                                                      color: Colors
                                                                              .grey[
                                                                          400]),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Visibility(
                                                visible: storedMassages[i]
                                                        ['Reaction']
                                                    .isNotEmpty,
                                                child: Positioned.fill(
                                                  left: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.8,
                                                  child: Align(
                                                    alignment:
                                                        Alignment.bottomRight,
                                                    child: GestureDetector(
                                                      onTapDown: (details) {
                                                        _tapPosition = details
                                                            .globalPosition;
                                                        showReactionMenu(
                                                          context,
                                                          _tapPosition,
                                                          storedMassages[i]
                                                              ['id'],
                                                        );
                                                        print(_tapPosition);
                                                      },
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(4.5),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(50),
                                                        ),
                                                        child: Text(
                                                            storedMassages[i]
                                                                ['Reaction']),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        : storedMassages[i]['Sender Email'] ==
                                                    widget.receiverEmail &&
                                                storedMassages[i]
                                                        ['Receiver Email'] ==
                                                    currentUserEmail
                                            ? Stack(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 8.0),
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        chatBubbleIdsList.add(
                                                            storedMassages[i]
                                                                ['id']);
                                                      },
                                                      onTapDown: (details) {
                                                        _tapPosition = details
                                                            .globalPosition;
                                                        print(_tapPosition);
                                                      },
                                                      onLongPress: () async {
                                                        setState(() {
                                                          _isChatBubbleSelected =
                                                              true;
                                                          chatBubbleId =
                                                              storedMassages[i]
                                                                  ['id'];
                                                          selectedChatBubbleId =
                                                              storedMassages[i]
                                                                  ['id'];
                                                          chatBubbleIdsList.add(
                                                              selectedChatBubbleId);
                                                        });
                                                        showReactionMenu(
                                                          context,
                                                          _tapPosition,
                                                          chatBubbleId,
                                                        );
                                                        print(
                                                            'selectedChatBubbleId : $selectedChatBubbleId');
                                                      },
                                                      child: Container(
                                                        width: double.infinity,
                                                        color: storedMassages[i]
                                                                    ['id'] ==
                                                                selectedChatBubbleId
                                                            ? Colors.blue[100]
                                                            : transparentColor,
                                                        child: ChatBubble(
                                                          clipper: ChatBubbleClipper5(
                                                              type: BubbleType
                                                                  .receiverBubble),
                                                          backGroundColor:
                                                              Colors.grey[100],
                                                          shadowColor:
                                                              Colors.black,
                                                          elevation: 1.5,
                                                          margin:
                                                              const EdgeInsets
                                                                      .only(
                                                                  top: 10,
                                                                  left: 10,
                                                                  bottom: 8.0),
                                                          child: Container(
                                                            constraints:
                                                                BoxConstraints(
                                                              maxWidth: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.7,
                                                            ),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  storedMassages[
                                                                          i][
                                                                      'Message'],
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .black),
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      top: 5.0),
                                                                  child: Text(
                                                                    storedMassages[
                                                                            i][
                                                                        'Time'],
                                                                    style: TextStyle(
                                                                        fontStyle:
                                                                            FontStyle
                                                                                .italic,
                                                                        textBaseline:
                                                                            TextBaseline
                                                                                .ideographic,
                                                                        color: Colors.grey[
                                                                            500],
                                                                        fontSize:
                                                                            11),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Visibility(
                                                    visible: storedMassages[i]
                                                            ['Reaction']
                                                        .isNotEmpty,
                                                    child: Positioned.fill(
                                                      left: 10,
                                                      child: Align(
                                                        alignment: Alignment
                                                            .bottomLeft,
                                                        child: GestureDetector(
                                                          onTapDown: (details) {
                                                            _tapPosition = details
                                                                .globalPosition;
                                                            showReactionMenu(
                                                              context,
                                                              _tapPosition,
                                                              storedMassages[i]
                                                                  ['id'],
                                                            );
                                                            print(_tapPosition);
                                                          },
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(4.5),
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          50),
                                                            ),
                                                            child: Text(
                                                                storedMassages[
                                                                        i][
                                                                    'Reaction']),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : Container(),
                                  ],
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding:
                    const EdgeInsets.only(left: 3.0, right: 60.0, bottom: 4.0),
                child: TextField(
                  // keyboardType: TextInputType.text,
                  // style: const TextStyle(color: Colors.white),
                  cursorColor: blackColor,

//              autofocus: true,

                  onChanged: (value) {
                    if (value.isEmpty) {
                      setState(() {
                        if (isTextFieldEmpty == false) {
                          isTextFieldEmpty = true;
                        }
                      });
                    } else {
                      if (isTextFieldEmpty == true) {
                        setState(() {
                          isTextFieldEmpty = false;
                        });
                      }
                    }
                  },
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    // fillColor: purpleColor,
                    // filled: true,
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(color: whiteColor, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(color: whiteColor, width: 1.5),
                    ),
                    hintText: 'Type Massage',
                    hintStyle: TextStyle(color: blackColor),
                    labelStyle: TextStyle(color: blackColor),
                    prefixIcon: IconButton(
                      icon: IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.emoji_emotions_outlined,
                          color: blackColor,
                          size: 20.0,
                        ),
                      ),
                      splashColor: blueColor.withOpacity(0.3),
                      splashRadius: 10,
                      onPressed: () async {
                        print(chatBubbleIdsList.length);
                        for (int i = 0; i < chatBubbleIdsList.length; i++) {
                          print(chatBubbleIdsList[i]);
                        }
                      },
                    ),
                    prefixText: '  ',
                  ),
                  controller: _massageController,
                ),
              ),
            ),
            Positioned.fill(
              right: 2.0,
              bottom: 4.0,
              child: Align(
                alignment: Alignment.bottomRight,
                child: MaterialButton(
                  shape: const CircleBorder(),
                  height: 50.0,
                  minWidth: 50.0,
                  onPressed: () async {
                    if (_massageController.text.isNotEmpty) {
                      String time =
                          formatDate(DateTime.now(), [hh, ':', nn, ' ', am]);
                      _message = _massageController.text;
                      _massageController.clear();
                      await saveMassages(time, _message, 0);
                    }
                  },
                  color: blueColor,
                  child: Icon(
                    isTextFieldEmpty ? Icons.mic : Icons.send,
                    color: whiteColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> showReactionMenu(
    BuildContext context,
    Offset position,
    String bubbleId,
  ) async {
    final RenderBox overlay =
        Overlay.of(context)?.context.findRenderObject() as RenderBox;

    await showMenu(
      context: context,
      position: RelativeRect.fromRect(
        position & const Size(40, 40),
        Offset.zero & overlay.size,
      ),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width,
        minWidth: 300,
      ),
      items: [
        PopupMenuItem(
          padding: EdgeInsets.zero,
          value: 'value',
          height: 35,
          textStyle: const TextStyle(color: Colors.white),
          onTap: () {},
          child: Row(
            children: [
              IconButton(
                onPressed: () async {
                  await updateChatBubble(bubbleId, '👍');
                  resetToRest();
                  Navigator.pop(context);
                },
                icon: const Text(
                  '👍',
                  style: TextStyle(fontSize: 22),
                ),
              ),
              IconButton(
                onPressed: () async {
                  await updateChatBubble(bubbleId, '❤');
                  resetToRest();
                  Navigator.pop(context);
                },
                padding: EdgeInsets.zero,
                icon: const Text(
                  '❤',
                  style: TextStyle(fontSize: 22),
                ),
              ),
              IconButton(
                onPressed: () async {
                  await updateChatBubble(bubbleId, '😂');
                  resetToRest();
                  Navigator.pop(context);
                },
                padding: EdgeInsets.zero,
                icon: const Text(
                  '😂',
                  style: TextStyle(fontSize: 22),
                ),
              ),
              IconButton(
                onPressed: () async {
                  await updateChatBubble(bubbleId, '😮');
                  resetToRest();
                  Navigator.pop(context);
                },
                icon: const Text(
                  '😮',
                  style: TextStyle(fontSize: 22),
                ),
              ),
              IconButton(
                onPressed: () async {
                  await updateChatBubble(bubbleId, '😥');
                  resetToRest();
                  Navigator.pop(context);
                },
                icon: const Text(
                  '😥',
                  style: TextStyle(fontSize: 22),
                ),
              ),
              IconButton(
                onPressed: () async {
                  await updateChatBubble(bubbleId, '🙏');
                  resetToRest();
                  Navigator.pop(context);
                },
                icon: const Text(
                  '🙏',
                  style: TextStyle(fontSize: 22),
                ),
              ),
              IconButton(
                onPressed: () {
                  resetToRest();
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.add,
                  color: customGreyColor,
                  size: 30,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
