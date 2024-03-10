import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:untitled/model/admin.dart';
import 'dart:convert';
import 'package:untitled/model/doctor.dart';
import 'package:untitled/servicies/api.dart';
import 'package:untitled/model/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:untitled/image_viewer.dart';
import 'dart:io' as io;
import 'package:cached_network_image/cached_network_image.dart';
// import 'package:file_picker/file_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';

final _firestore = FirebaseFirestore.instance;
late User signedInUser;

class MessagesHomeScreen extends StatefulWidget {
  const MessagesHomeScreen({super.key});

  @override
  State<MessagesHomeScreen> createState() => _MessagesHomeScreen();
}

//  Color customColor2 = Color.fromARGB(255, 216, 243, 248);
// Color customColor = const Color(0xFFBBF1FA);
// Color mainColor = const Color(0xFF389AAB);
Color myColor = Color(0xFF144C74);

Color customColor2 = Color.fromARGB(255, 216, 243, 248);
Color customColor = const Color(0xFFBBF1FA);
Color mainColor = const Color(0xFF389AAB);
bool isDoctor = false;
String isAdmin = "user";
String formattedTime = "";

String selectedUserEmail = '';
String receiverUser = "";
String receivername = "";
String image = "";

class _MessagesHomeScreen extends State<MessagesHomeScreen> {
  List doctors = [];
  List filteredDoctors = [];

  TextEditingController searchController = TextEditingController();
  final messageTextController = TextEditingController();
  String? messageTxt;
  /***************fireBase *********/
  final _auth = FirebaseAuth.instance;
  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        signedInUser = user;
        print(signedInUser.email); //email for the current user
      }
    } catch (e) {
      print("from chat :- ${e}");
    }
  }

  @override
  void initState() {
    super.initState();

    // Use Future.delayed to schedule an asynchronous operation
    Future.delayed(Duration.zero, () {
      // Retrieve the isDoctor value from the arguments
      // bool? isDoctorArg = ModalRoute.of(context)!.settings.arguments as bool?;

      // if (isDoctorArg != null) {
      //   setState(() {
      //     isDoctor = isDoctorArg;
      //   });
      // }

      // Retrieve the role value from the arguments
      final Map<String, dynamic> args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      String role = args['role'];
      // Use the 'role' variable to determine the type of user
      if (role == 'user') {
        isAdmin = "user"; //false
        isDoctor = false;
        // User-specific logic
      } else if (role == 'doctor') {
        isAdmin = "doctor";
        isDoctor = true;
        // Doctor-specific logic
      } else if (role == 'admin') {
        // Admin-specific logic
        isAdmin = "admin";
        isDoctor = false;
      }

      getCurrentUser();
      getinfo();
      filteredDoctors = List.from(doctors);
    });
  }

  void filterUsers(String query) {
    setState(() {
      filteredDoctors = doctors
          .where((doctors) =>
              doctors['name'].toLowerCase().contains(query.toLowerCase()) ||
              doctors['email']
                  .toLowerCase()
                  .contains(query.toLowerCase())) //email
          .toList();
    });
  }

/////////////////////////////////////////////////////////////////////////////////////////
  List<Doctor> doctorinfo = [];
  List<Userr> userinfo = [];
  List<Admin> admininfo = [];
  void getinfo() async {
    if (isAdmin == "user" || isAdmin == "admin") {
      //false
      final response = await Api.getdoctors();
      Map<String, dynamic> parsedJson = json.decode(response.body);
      if (parsedJson.containsKey("doctor") && parsedJson["doctor"] is List) {
        List<dynamic> parsedJsonList = parsedJson["doctor"];
        List<Doctor> doctors2 = [];
        for (var parsedJson2 in parsedJsonList) {
          String temp = parsedJson2['category'];
          String category = await Api.getcategory(temp ?? '');
          Doctor doctor = Doctor(
            id: parsedJson2['_id'],
            name: parsedJson2['name'],
            email: parsedJson2['email'],
            password: parsedJson2['password'],
            phoneNumber: parsedJson2['phoneNumber'],
            city: parsedJson2['city'],
            workingDays: List<String>.from(parsedJson2['WorkingDays']),
            locationMap: List<double>.from(parsedJson2['locationMap']),
            rating: parsedJson2['Rating'] as int? ?? 0,
            startTime: parsedJson2['StartTime'],
            endTime: parsedJson2['EndTime'],
            profileImg:"http://localhost:8081/profileimg/" + parsedJson2['ProfileImg'],
            category: category,
          );

          doctors2.add(doctor);
        }

        // Now, the 'doctors' list contains all doctor objects
        doctorinfo = doctors2;
        for (Doctor doctor in doctors2) {
          print("Doctor Name: ${doctor.name}");
          Map<String, dynamic> doctorMap = {
            "email": doctor.email,
            "id": doctor.id,
            "name": doctor.name,
            "specialty": doctor
                .category, // Assuming 'category' in 'Doctor' corresponds to 'specialty' in your target list
            "City": doctor.city,
            "image": doctor.profileImg,
            "rate": doctor.rating,
          };
          doctors.add(doctorMap);
        }
        for (var doctor in doctors) {
          print("Doctorss Name: ${doctor['name']}");
        }
        setState(() {
          filteredDoctors = List.from(doctors);
          // loadUserData();
        });
      }
    } else {
      final response = await Api.getUsers();
      dynamic parsedJson = json.decode(response.body);
      // print("parssssssssssss useeeeeeerrrrrrrrrrr: $parsedJson");
      final responseAdmin = await Api.getAdmins();
      dynamic parsedJsonAdmin = json.decode(responseAdmin.body);
      // print("parssssssssssssssss :    $parsedJsonAdmin");
      if (parsedJson is List) {
        List<Userr> usersList = [];
        for (var parsedJson2 in parsedJson) {
          // Process each user in the list
          Userr user = Userr(
            id: parsedJson2['_id'],
            name: parsedJson2['name'],
            email: parsedJson2['email'],
            password: parsedJson2['password'],
            phoneNumber: parsedJson2['phoneNumber'],
            city: parsedJson2['city'],
            profileImg: "http://localhost:8081/profileimg/" +parsedJson2['ProfileImg'],
          );
          usersList.add(user);
        }
        // Now, the 'usersList' contains all user objects
        userinfo = usersList;
        for (Userr user in usersList) {
          print("user Name: ${user.name}");
          Map<String, dynamic> userMap = {
            "email": user.email,
            "id": user.id,
            "name": user.name,
            "City": user.city,
            "image": user.profileImg,
          };
          doctors.add(userMap);
        }
        // setState(() {
        //   filteredDoctors = List.from(doctors);
        // });
      }
      // else {
      //   // Handle the case where the response is not a list (Map, error, etc.)
      //   print("Unexpected response format: $parsedJson");
      // }
////////////////////////////////////////get admins////////////////////////////////

      if (parsedJsonAdmin is List) {
        List<Admin> adminList = [];
        for (var parsedJson2Admin in parsedJsonAdmin) {
          // Process each user in the list
          Admin admin = Admin(
            id: parsedJson2Admin['_id'],
            name: parsedJson2Admin['name'],
            email: parsedJson2Admin['email'],
            password: parsedJson2Admin['password'],
            image :parsedJson2Admin['image'],
          );
          adminList.add(admin);
        }
        // Now, the 'usersList' contains all user objects
        admininfo = adminList;
        for (Admin admin in adminList) {
          print("admin Name: ${admin.email}");
          Map<String, dynamic> adminMap = {
            "email": admin.email,
            "id": admin.id,
            "name": admin.name,
            "image": admin.image,
          };
          doctors.add(adminMap);
        }
        setState(() {
          filteredDoctors.addAll(doctors);
        });
      }
    }

    // You can perform any further processing or setState as needed
  }
  //////////////////////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: SafeArea(
              child: Container(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: mainColor,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: Icon(
                              Icons.arrow_back_sharp,
                              color: mainColor,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.only(top: 10, bottom: 20),
                              height: 60,
                              child: TextField(
                                onChanged: (value) {
                                  filterUsers(value);
                                },
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 20,
                                  ),
                                  hintText: 'Search by name ...',
                                  hintStyle: TextStyle(color: mainColor),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Icon(
                              Icons.search,
                              color: mainColor,
                              size: 35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredDoctors.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              Container(
                                color: const Color.fromARGB(255, 241, 240, 240),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      receiverUser =
                                          filteredDoctors[index]['email'];
                                      receivername =
                                          filteredDoctors[index]['name'];
                                      image = filteredDoctors[index]['image'];
                                    });
                                    // Navigator.pushNamed(context, "Messages",
                                    //     arguments: {
                                    //       "email": filteredDoctors[index]
                                    //           ['email'],
                                    //       "name": filteredDoctors[index]
                                    //           ['name'],
                                    //       "image": filteredDoctors[index]
                                    //           ['image']
                                    //     });
                                    print("${filteredDoctors[index]['email']}");
                                  },
                                  child: ListTile(
                                    title: Text(
                                        "${filteredDoctors[index]['name']}"),
                                    subtitle: isDoctor
                                        ? Text(
                                            "${filteredDoctors[index]['email']}")
                                        : Text(
                                            "${filteredDoctors[index]['specialty']}"),
                                    // Add other user details as needed
                                    leading: filteredDoctors[index]['image'] ==
                                            ""
                                        ? CircleAvatar(
                                            backgroundColor: customColor,
                                            backgroundImage:
                                                AssetImage("images/logo2.png"),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color:
                                                      mainColor, // Specify the border color here
                                                  width:
                                                      2.0, // Specify the border width here
                                                ),
                                              ),
                                            ),
                                          )
                                        : CircleAvatar(
                                            backgroundColor: customColor,
                                            backgroundImage: NetworkImage(
                                                "${filteredDoctors[index]['image']}"),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color:
                                                      mainColor, // Specify the border color here
                                                  width:
                                                      2.0, // Specify the border width here
                                                ),
                                              ),
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                              Divider(
                                // Add a Divider after each ListTile
                                color: mainColor, // You can customize the color
                                thickness:
                                    0.1, // You can customize the thickness
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // MessagesUserList(),
          ),
          if (receiverUser == "" && receivername == "" && image == "")
            Expanded(
              flex: 3,
              child: Container(
                color: mainColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 250,
                      // color: mainColor,
                      child: Image(
                        image: AssetImage("images/logo2.png"),
                        color: customColor,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Start your conversation with the most famous dentists through our application",
                          style: GoogleFonts.lora(
                            textStyle: TextStyle(
                              fontSize: 15,
                              fontStyle: FontStyle.italic,
                              // fontWeight: FontWeight.bold,
                              color: customColor,
                              // shadows: [
                              //   Shadow(
                              //     blurRadius: 8.0,
                              //     color: mainColor,
                              //     offset: Offset(
                              //         MediaQuery.of(context).size.width *
                              //             0.002, //0.1
                              //         MediaQuery.of(context).size.width *
                              //             0.002), //0.1
                              //   ),
                              // ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Icon(
                          Icons.chat_rounded,
                          color: customColor,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Communication, speed, knowledge....",
                      style: GoogleFonts.lora(
                        textStyle: TextStyle(
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          // fontWeight: FontWeight.bold,
                          color: customColor,
                          // shadows: [
                          //   Shadow(
                          //     blurRadius: 8.0,
                          //     color: mainColor,
                          //     offset: Offset(
                          //         MediaQuery.of(context).size.width *
                          //             0.002, //0.1
                          //         MediaQuery.of(context).size.width *
                          //             0.002), //0.1
                          //   ),
                          // ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          else
            Expanded(
                flex: 3,
                // child: Container(
                //   child: Column( children: [Text("$receivername"),Text("$receiverUser"),Text("$image")],mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment: CrossAxisAlignment.center,),),

                child: Scaffold(
                  appBar: AppBar(
                    // leading: IconButton(
                    //   icon: Icon(Icons.arrow_back, color: Colors.white),
                    //   onPressed: () => Navigator.of(context).pop(),
                    // ),
                    backgroundColor: mainColor,
                    title: Row(
                      children: [
                        image == ""
                            ? CircleAvatar(
                                backgroundColor: customColor,
                                backgroundImage: AssetImage("images/logo2.png"),
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: mainColor,
                                      width: 2.0,
                                    ),
                                  ),
                                ),
                              )
                            : CircleAvatar(
                                backgroundColor: customColor,
                                backgroundImage: NetworkImage(image),
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: mainColor,
                                      width: 2.0,
                                    ),
                                  ),
                                ),
                              ),
                        SizedBox(width: 10),
                        Text(
                          "${receivername}",
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(width: 10),
                      ],
                    ),
                    actions: [
                      IconButton(
                        onPressed: () {
                          // navigator.pop();
                          // Navigator.of(context).pop();
                          setState(() {
                            receiverUser = "";
                            receivername = "";
                            image = "";
                          });
                        },
                        icon: Icon(
                          Icons.close_sharp,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  body: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("images/chat2opacity.jpg"),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          MessageStreamBuilder(),
                          Container(
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: mainColor,
                                  width: 3,
                                ),
                              ),
                            ),
                            child: Container(
                              color: Colors.white,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 6),
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.add_a_photo,
                                        size: 25,
                                        color: mainColor,
                                      ),
                                      onPressed: () async {
                                        String? imageUrl = await _pickImage();
                                        if (imageUrl != "") {
                                          DateTime currentTime = DateTime.now();
                                          formattedTime = DateFormat.jm()
                                              .format(currentTime);
                                          messageTextController.clear();
                                          _firestore
                                              .collection('messages')
                                              .add({
                                            'receiver': receiverUser,
                                            'text': "",
                                            'imageUrl': imageUrl,
                                            'sender': signedInUser.email,
                                            'time':
                                                FieldValue.serverTimestamp(),
                                            'timeSendMsg': formattedTime,
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    child: TextField(
                                      controller: messageTextController,
                                      onChanged: (value) {
                                        messageTxt = value;
                                      },
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: 10,
                                          horizontal: 20,
                                        ),
                                        hintText: 'Write your message here...',
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      DateTime currentTime = DateTime.now();
                                      formattedTime =
                                          DateFormat.jm().format(currentTime);
                                      messageTextController.clear();
                                      _firestore.collection('messages').add({
                                        'receiver': receiverUser,
                                        'text': messageTxt,
                                        'imageUrl': "",
                                        'sender': signedInUser.email,
                                        'time': FieldValue.serverTimestamp(),
                                        'timeSendMsg': formattedTime,
                                      });
                                    },
                                    child: Icon(
                                      Icons.send_sharp,
                                      color: mainColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ))
        ],
      ),
    );
  }
}

Set<String> userPairs = Set<String>();

class MessageStreamBuilder extends StatelessWidget {
  const MessageStreamBuilder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('messages').orderBy('time').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
          return Text('Send the first message');
        }

        final messages = snapshot.data!.docs.reversed;

        List<MessageLine> messageWidgets = [];

        for (var message in messages) {
          final messageText = message.get('text');
          final messageSender = message.get('sender');
          final messageReceiver = message.get('receiver');
          final imageUrl = message.get('imageUrl');
          final timeSendMsg = message.get("timeSendMsg");
          final currentUser = signedInUser.email;

          final messageWidget = MessageLine(
            sender: messageSender,
            text: messageText,
            receiver: messageReceiver,
            imageUrl: imageUrl,
            isMe: currentUser == messageSender,
            timeSendMsg: timeSendMsg,
          );

          if ((currentUser == messageSender &&
                  receiverUser == messageReceiver) ||
              (currentUser == messageReceiver &&
                  receiverUser == messageSender)) {
            userPairs.add('$messageSender-$messageReceiver');
            messageWidgets.add(messageWidget);
          }
        }

        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            children: messageWidgets,
          ),
        );
      },
    );
  }
}

class MessageLine extends StatelessWidget {
  const MessageLine({
    this.sender,
    this.text,
    this.imageUrl,
    required this.isMe,
    this.timeSendMsg,
    this.receiver,
    Key? key,
  }) : super(key: key);

  final String? sender;
  final String? text;
  final String? imageUrl;
  final bool isMe;
  final String? timeSendMsg;
  final String? receiver;

  @override
  Widget build(BuildContext context) {
    Color customColor = const Color(0xFFBBF1FA);
    Color mainColor = const Color(0xFF389AAB);

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (imageUrl != "" && imageUrl != null)
            GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImageViewer(imageUrl: imageUrl!),
                    ),
                  );
                },
                child:
                    // Image.network(
                    //   "$imageUrl",
                    //   width: 200,
                    //   height: 200,
                    //   fit: BoxFit.cover,
                    // ),
                    CachedNetworkImage(
                  imageUrl: imageUrl ??
                      "https://static.vecteezy.com/system/resources/previews/021/548/095/non_2x/default-profile-picture-avatar-user-avatar-icon-person-icon-head-icon-profile-picture-icons-default-anonymous-user-male-and-female-businessman-photo-placeholder-social-network-avatar-portrait-free-vector.jpg",
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ))
          else
            Material(
              borderRadius: isMe
                  ? BorderRadius.only(
                      topLeft: Radius.circular(30),
                      bottomLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    )
                  : BorderRadius.only(
                      topRight: Radius.circular(30),
                      topLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
              elevation: 6,
              color: isMe ? mainColor : customColor,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Text(
                  '$text',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: isMe ? Colors.white : mainColor,
                  ),
                ),
              ),
            ),
          Text(
            "${timeSendMsg}",
            style: TextStyle(
              fontSize: 12,
              color: isMe
                  ? Color.fromARGB(255, 54, 148, 164)
                  : Color.fromARGB(255, 136, 134, 134),
            ),
          ),
        ],
      ),
    );
  }
}

// Future<String?> _pickImage() async {
//   final picker = ImagePicker();
//   final pickedFile = await picker.pickImage(source: ImageSource.gallery);

//   if (pickedFile != null) {
//     final imageUrl = await _uploadImage(pickedFile.path);
//     return imageUrl;
//   } else {
//     return "";
//   }
// }

Future<String?> _pickImage() async {
  try {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null && result.files.isNotEmpty) {
      final bytes = result.files.first.bytes;
      final imageUrl = await _uploadImageBytes(bytes!);
      return imageUrl;
    } else {
      return "";
    }
  } catch (e) {
    print("Error picking image: $e");
    return "";
  }
}

Future<String> _uploadImageBytes(List<int> bytes) async {
  String fileName = DateTime.now().millisecondsSinceEpoch.toString();
  try {
    final ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('images/$fileName.png');

    final uploadTask = ref.putData(Uint8List.fromList(bytes));

    await uploadTask.whenComplete(() => null);

    return await ref.getDownloadURL();
  } catch (e) {
    print("Error uploading image: $e");
    return "";
  }
}

// Future<String> _uploadImage(String imagePath) async {
//   String fileName = DateTime.now().millisecondsSinceEpoch.toString();
//   try {
//     final ref = firebase_storage.FirebaseStorage.instance
//         .ref()
//         .child('images/$fileName.png');
//     final uploadTask = ref.putFile(io.File(imagePath));

//     await uploadTask.whenComplete(() => null);

//     return await ref.getDownloadURL();
//   } catch (e) {
//     return "";
//   }
// }
Future<String> _uploadImage(String imagePath) async {
  String fileName = DateTime.now().millisecondsSinceEpoch.toString();
  try {
    final ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('images/$fileName.png');

    final metadata = firebase_storage.SettableMetadata(
      contentType: 'image/png',
    );

    final uploadTask = ref.putFile(io.File(imagePath), metadata);

    final taskSnapshot = await uploadTask;

    if (taskSnapshot.state == firebase_storage.TaskState.success) {
      return await ref.getDownloadURL();
    } else {
      return "";
    }
  } catch (e) {
    print("Error uploading image: $e");
    return "";
  }
}
