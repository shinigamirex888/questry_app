import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:questry/app/data/profileModel.dart';
import 'package:questry/app/modules/chatbox/controller/chatController.dart';
import 'package:questry/app/modules/chatbox/models/messageModel.dart';
import 'package:questry/app/modules/chatbox/views/ownMessageCard.dart';
import 'package:questry/app/modules/chatbox/views/replyCard.dart';
import 'package:questry/app/modules/profile/controller/profile_controller.dart';
import '../models/chatmodel.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatScreen extends StatefulWidget {
  ChatScreen({Key key, this.profile, this.conversationId}) : super(key: key);
  final ProfileModel profile;
  final String conversationId;

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool show = false;
  FocusNode focusNode = FocusNode();
  bool sendButton = false;
  TextEditingController _controller = TextEditingController();
  IO.Socket socket;

  @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  //   connect();
  //   focusNode.addListener(() {
  //     if (focusNode.hasFocus) {
  //       setState(() {
  //         show = false;
  //       });
  //     }
  //   });
  // }

  // void connect() {
  //   socket = IO.io("http://192.168.73.184:5000", <String, dynamic>{
  //     "transports": ["websocket"],
  //     "autoConnect": false,
  //   });
  //   socket.connect();
  //   socket.emit("signin", widget.sourceChat.id);
  //   socket.onConnect((data) {
  //     print("connected");
  //     socket.on("message", (msg) {
  //       print(msg);
  //       setMessage("destination", msg["message"]);
  //     });
  //   });
  //   print(socket.connected);
  // }

  // void sendMessage(String message, int sourceId, int tragetId) {
  //   setMessage("source", message);
  //   socket.emit("message",
  //       {"message": message, "sourceId": sourceId, "targetId": tragetId});
  // }

  // void setMessage(String type, String message) {
  //   MessageModel messageModel = MessageModel(type: type, message: message);
  //   setState(() {
  //     messages.add(messageModel);
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    print("inside chat screen ${widget.conversationId}");
    return GetBuilder<ChatController>(
        builder: (controller) => Scaffold(
            backgroundColor: Colors.blueGrey[200],
            appBar: AppBar(
              titleSpacing: 0,
              leadingWidth: 70,
              leading: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_back,
                      size: 24,
                    ),
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.blueGrey,
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
              title: InkWell(
                onTap: () {},
                child: Container(
                  margin: EdgeInsets.all(6),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.profile.username,
                        style: TextStyle(
                          fontSize: 18.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "last seen today at 12:05",
                        style: TextStyle(
                          fontSize: 13,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.videocam),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {},
                ),
                PopupMenuButton(onSelected: (val) {
                  print(val);
                }, itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem(
                      child: Text("View Contact"),
                      value: "View Contact",
                    ),
                    PopupMenuItem(
                      child: Text("Media, links and docs"),
                      value: "Media, links and docs",
                    ),
                    PopupMenuItem(
                      child: Text("Search"),
                      value: "Search",
                    ),
                    PopupMenuItem(
                      child: Text("Mute Notifications"),
                      value: "Mute Notifications",
                    ),
                    PopupMenuItem(
                      child: Text("Wallpaper"),
                      value: "Wallpaper",
                    ),
                  ];
                })
              ],
            ),
            body: GetBuilder<ProfileController>(
              builder: (profilecontroller) => Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: WillPopScope(
                  child: Stack(
                    children: [
                      Container(
                          height: MediaQuery.of(context).size.height - 140,
                          child: controller.allMessages.length > 0
                              ? ListView.builder(
                                  itemCount: controller.allMessages.length,
                                  itemBuilder: (context, index) {
                                    if (controller.allMessages[index]
                                            ["sender"] ==
                                        profilecontroller.profileModel.id) {
                                      return OwnMessageCard(
                                        message: controller.allMessages[index]
                                            ["text"],
                                      );
                                    } else {
                                      return replyCard(
                                        message: controller.allMessages[index]
                                            ["text"],
                                      );
                                    }
                                  })
                              : Center(
                                  child: CircularProgressIndicator(),
                                )),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                Container(
                                    width:
                                        MediaQuery.of(context).size.width - 55,
                                    child: Card(
                                      margin: EdgeInsets.only(
                                          left: 2, right: 2, bottom: 8),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(25)),
                                      child: TextFormField(
                                        controller: _controller,
                                        focusNode: focusNode,
                                        maxLines: 5,
                                        minLines: 1,
                                        onChanged: (value) {
                                          if (value.length > 0) {
                                            setState(() {
                                              sendButton = true;
                                            });
                                          } else {
                                            setState(() {
                                              sendButton = false;
                                            });
                                          }
                                        },
                                        textAlignVertical:
                                            TextAlignVertical.center,
                                        keyboardType: TextInputType.multiline,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: "Type a Message",
                                          prefixIcon: IconButton(
                                            icon: Icon(
                                                Icons.emoji_emotions_outlined),
                                            onPressed: () {
                                              setState(() {
                                                focusNode.unfocus();
                                                focusNode.canRequestFocus =
                                                    false;
                                                show = !show;
                                              });
                                            },
                                          ),
                                          suffixIcon: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: Icon(Icons.attach_file),
                                                onPressed: () {
                                                  showModalBottomSheet(
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      context: context,
                                                      builder: (builder) =>
                                                          bottomSheet());
                                                },
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.camera_alt),
                                                onPressed: () {},
                                              )
                                            ],
                                          ),
                                          contentPadding: EdgeInsets.all(5),
                                        ),
                                      ),
                                    )),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 8, right: 2),
                                  child: CircleAvatar(
                                    backgroundColor:
                                        Theme.of(context).accentColor,
                                    radius: 25,
                                    child: IconButton(
                                      icon: Icon(
                                        sendButton ? Icons.send : Icons.mic,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        if (sendButton) {
                                          if (_controller.text.length > 0) {
                                            controller.addMessage(
                                                widget.conversationId,
                                                _controller.text);
                                            _controller.clear();
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                )
                              ],
                            ),
                            show ? emojiSelect() : Container(),
                          ],
                        ),
                      )
                    ],
                  ),
                  onWillPop: () {
                    if (show) {
                      setState(() {
                        show = false;
                      });
                    } else {
                      Navigator.pop(context);
                    }
                    return Future.value(false);
                  },
                ),
              ),
            )));
  }

  Widget bottomSheet() {
    return Container(
      height: 278,
      width: MediaQuery.of(context).size.width,
      child: Card(
        margin: EdgeInsets.all(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  iconCreation(
                      Icons.insert_drive_file, Colors.indigo, "Document"),
                  SizedBox(
                    width: 40,
                  ),
                  iconCreation(Icons.camera_alt, Colors.pink, "Camera"),
                  SizedBox(
                    width: 40,
                  ),
                  iconCreation(Icons.insert_photo, Colors.purple, "Gallery"),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  iconCreation(Icons.headset, Colors.orange, "Audio"),
                  SizedBox(
                    width: 40,
                  ),
                  iconCreation(Icons.location_pin, Colors.teal, "Location"),
                  SizedBox(
                    width: 40,
                  ),
                  iconCreation(Icons.person, Colors.blue, "Contact"),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget iconCreation(IconData icon, Color color, String text) {
    return InkWell(
      onTap: () {},
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: color,
            radius: 30,
            child: Icon(
              icon,
              size: 29,
              color: Colors.white,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            text,
            style: TextStyle(fontSize: 12),
          )
        ],
      ),
    );
  }

  Widget emojiSelect() {
//    return EmojiPicker(
//        rows: 4,
//        columns: 7,
//        onEmojiSelected: (emoji, category) {
//          print(emoji);
//          setState(() {
//            _controller.text = _controller.text + emoji.emoji;
//          });
//        });
  }
}
