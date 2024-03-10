import 'dart:async';
import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:localstorage/localstorage.dart';
import 'package:untitled/Notifications.dart' as notif;
import 'package:untitled/Profile/userprofile.dart';
import 'package:untitled/Profile/usertodoctor.dart';
import 'package:untitled/maps/doctorslocation.dart';
import 'package:untitled/maps/nearest.dart';
import 'package:untitled/model/doctor.dart';
import 'package:untitled/servicies/api.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key});

  @override
  State<HomePage> createState() => _HomePageState();
}

bool isDoctor = false;

class _HomePageState extends State<HomePage> {
  List nearestdoctors = [];
  List top3 = [];
  List doctors = [
/*     {
      "id": "1",
      "name": "Dr Mira",
      "specialty": "Dental neurologist", //اعصاب
      "City": "Nablus",
      "image": "",
      "rate": 3
    },
    {
      "id": "1",
      "name": "Dr Mira",
      "specialty": "Dental neurologist", //اعصاب
      "City": "Nablus",
      "image": "",
      "rate": 4
    },
    {
      "id": "1",
      "name": "Dr Mira",
      "specialty": "Dental neurologist", //اعصاب
      "City": "Nablus",
      "image": "",
      "rate": 5
    },
    {
      "id": "1",
      "name": "Dr Deema",
      "specialty": "Cosmetic dentist", //تجميل
      "City": "Nablus",
      "image": "",
      "rate": 5
    },
    {
      "id": "1",
      "name": "Dr Aseel",
      "specialty": "Pediatric dentist", //اطفال
      "City": "jenin",
      "image": "",
      "rate": 2
    },
    {
      "id": "1",
      "name": "Dr Raghad",
      "specialty": "Pediatric dentist", //اطفال
      "City": "Ramallah",
      "image": "",
      "rate": 2
    },
    {
      "id": "1",
      "name": "Dr Aseel",
      "specialty": "Pediatric dentist", //اطفال
      "City": "Nablus",
      "image": "",
      "rate": 1
    },
    {
      "id": "1",
      "name": "Dr Aseel",
      "specialty": "Dental neurologist", //اطفال
      "City": "Nablus",
      "image": "",
      "rate": 2
    },
    {
      "id": "1",
      "name": "Dr Mira",
      "specialty": "Dental neurologist", //اطفال
      "City": "Nablus",
      "image": "",
      "rate": 1
    },
    {
      "id": "1",
      "name": "Dr Mira",
      "specialty": "Dental Surgeon", //اطفال
      "City": "Nablus",
      "image": "",
      "rate": 2
    },
    {
      "id": "1",
      "name": "Dr razan",
      "specialty": "Orthodontist", //اطفال
      "City": "Hebron",
      "image": "",
      "rate": 2
    }, */
  ];
  List filteredDoctors = [];
  String? selectedCity = null; // Initialize with an empty string
  int displayedItemCount = 4; // Initially display 4 items
  bool showAll = false;

  String nameUser = 'user';
  String emailUser = 'user@gmail.com';
  String userID = '1';
  String userImage = '';

  final LocalStorage storage = new LocalStorage('my_data');

  Map<String, dynamic>? getUserData() {
    // Get the existing data from LocalStorage
    Map<String, dynamic>? existingData = storage.getItem('user_data_new');

    return existingData;
  }

  void loadUserData() {
    // Retrieve user data
    Map<String, dynamic>? userData = getUserData();

    if (userData != null) {
      // Do something with the user data
      setState(() {
        nameUser = userData['name'];
        emailUser = userData['email'];
        userID = userData['id'];
        userImage = "http://localhost:8081/profileimg/" + userData['profileImg'];
      });
      print('User data loaded: name=$nameUser, email=$emailUser, id=$userID');
      print('Name: ${userData['name']}');
      print('Email: ${userData['email']}');
      print('ID: ${userData['id']}');
    } else {
      print('User data not found.');
    }
  }

  List<Doctor> doctorinfo = [];
  late LatLngClass userLocation;
  int notificationVount = 0;
  List<dynamic> allnotification = [];
  List<dynamic> parsedJsonNotList = [];
  void getinfo() async {
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
          profileImg: "http://localhost:8081/profileimg/" + parsedJson2['ProfileImg'],
          category: category,
        );

        doctors2.add(doctor);
      }

      // Now, the 'doctors' list contains all doctor objects
      doctorinfo = doctors2;
      List temp = [];
      for (Doctor doctor in doctors2) {
        print("Doctor Name: ${doctor.name}");
        Map<String, dynamic> doctorMap = {
          "id": doctor.id,
          "name": doctor.name,
          "specialty": doctor
              .category, // Assuming 'category' in 'Doctor' corresponds to 'specialty' in your target list
          "City": doctor.city,
          "image": doctor.profileImg,
          "rate": doctor.rating,
          "locationMap": doctor.locationMap
        };
        doctors.add(doctorMap);
      }
      /*  for (var doctor in doctors) {
        print("Doctorss Name: ${doctor['name']}");
      } */
      setState(() {
        filteredDoctors = List.from(doctors);
        temp = List.from(doctors);
        temp.sort((a, b) => b["rate"].compareTo(a["rate"]));
        // Take the top 3 doctors
        top3 = temp.take(3).toList();
        // loadUserData();
      });
//--------------------Nearby clinics--------------------------
      initializeData();
    }
  }

  late Position currentLocation;
  Future<Position> _getLongLat() async {
    var pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    /*  var lastMsg = await Geolocator.getLastKnownPosition();
    print("getLastKnownPosition $lastMsg"); */

    return pos;
    // return await Geolocator.getCurrentPosition().then((value) => value);
  }

  List<List<double>> doctorLocations = [];
  Future _getLocation() async {
    bool service;
    var per;
    try {
      service = await Geolocator.isLocationServiceEnabled();
      print("Aseel1");
      if (service == false) {
        print("Aseel2.1");
        AwesomeDialog(
           width: MediaQuery.of(context).size.width * 0.45,
            context: context,
            title: 'service',
            body: Text("Service Not Enabled"))
          ..show();
      }
      print("Aseel2.2");
      per = await Geolocator.checkPermission();
      print("Aseel3");
      // LocationPermission permission = await Geolocator.requestPermission();

      if (per == LocationPermission.denied) {
        // throw 'Location permissions are denied.';
        per = await Geolocator.requestPermission();
        print("Aseel4.1");
      }
      if (per == LocationPermission.always) {
        print("Aseel4.2");
      }
      print("Aseel4.3");
      currentLocation = await _getLongLat();
      print("Aseel4.3");
      print("Latitude: ${currentLocation.latitude}");
      print("Longitude: ${currentLocation.longitude}");
      setState(() {
        userLocation =
            LatLngClass(currentLocation.latitude, currentLocation.longitude);
        setState(() {
          for (int i = 0; i < doctors.length; i++) {
            double latitude = doctors[i]['locationMap']?[0]; // 32.22219
            double longitude = doctors[i]['locationMap']?[1];
            doctorLocations.add([latitude, longitude]);
            print("Map");
          }
          double maxDistance =
              32.0; // Set your maximum distance threshold in kilometers

          List<LatLngClass> nearestLocations =
              findNearestLocations(doctorLocations, userLocation, maxDistance);

          print(
              'Nearest doctor locations within $maxDistance km: $nearestLocations');
          for (int i = 0; i < doctors.length; i++) {
            for (int j = 0; j < nearestLocations.length; j++) {
              if (doctors[i]['locationMap']?[0] ==
                      nearestLocations[j].latitude &&
                  doctors[i]['locationMap']?[1] ==
                      nearestLocations[j].longitude) {
                Map<String, dynamic> doctorMap = {
                  "id": doctors[i]['id'],
                  "name": doctors[i]['name'],
                  "specialty": doctors[i]['specialty'],
                  "City": doctors[i]['City'],
                  "image": doctors[i]['image'],
                  "rate": doctors[i]['rate'],
                  "locationMap": doctors[i]['locationMap'],
                };
                nearestdoctors.add(doctorMap);
                // nearestdoctors.add(doctorMap);
              }
            }
          }
        });
      });
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  void initializeData() async {
    await _getLocation();
  }

  // var fbm = FirebaseMessaging.instance;
  // // when the app closed and click to notification
  // initalMessage() async {
  //   var message = await FirebaseMessaging.instance.getInitialMessage();
  //   if (message != null) {
  //     Navigator.of(context).pushNamed("Homepage");
  //   }
  // }
//late List<dynamic> allnotification=[];
  late StreamSubscription<List<Map<String, dynamic>>> subscription;

  void getnotifications() {
    subscription = Api.streamNotifications(emailUser)
        .listen((List<Map<String, dynamic>> notifications) {
      print("=====================Notifications Firebase================");
      print(notifications);
      setState(() {
        allnotification = notifications;
      });
      print("=====================Notifications Firebase================");
    });
  }

  late StreamSubscription<int> unreadCount = 0 as StreamSubscription<int>;
  void getnotificationcount() {
    unreadCount =
        Api.streamUnreadNotificationCount(emailUser).listen((int count) {
      setState(() {
        notificationVount = count;
      });
      print("Number of unread notifications (real-time): $count");

      // Update your UI or perform actions based on the unread count
    });
  }

  void getnot() {
    StreamSubscription<void> updateOnTimeFieldSubscription =
        Api.streamUpdateOnTimeField().listen((_) {
      print("onTime field updated (real-time)");
    });
  }

/* void firebaseOnMessage() {
  FirebaseMessaging.onMessage.listen((message) {
    if (message != null) {
      final title = message.notification?.title;
      final body = message.notification?.body;
      showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            contentPadding: EdgeInsets.all(18),
            children: [
              Text('Title: $title'),
              Text('Body: $body'),
            ],
          ); // SimpleDialog
        },
      );
    }
  });
} */
  void firebaseOnMessage() {
    FirebaseMessaging.onMessage.listen((message) {
      print('onMessage occurred. Message is: ');
      if (message != null) {
        final title = message.notification?.title;
        final body = message.notification?.body;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.notifications_active_sharp,
                      color: Colors.white,
                    ),
                    Text('  New Notification'),
                  ],
                ),
                Row(
                  children: [
                    Text(' $title'),
                  ],
                ),
                Row(
                  children: [
                    Text('$body'),
                  ],
                ),
              ],
            ),
            backgroundColor: mainColor,
            showCloseIcon: true,
            duration: Duration(seconds: 5),

            //width: 20.0,
          ),
        );
      }
    });
  }

  void onFirebaseOpenedApp() {
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      print('onMessageOpenedApp occurred. Message is: ');
      print(event.notification?.title);
      // Additional handling for the notification data or payload can be done here
    });
  }

  Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print("Handling a background message: ${message.notification?.title}");
    // Handle the background message, e.g., show a notification
  }

  @override
  void initState() {
    firebaseOnMessage();
    onFirebaseOpenedApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    /**********************************************notifications ********************************************** */
    // fbm.getToken().then((token) {
    //   print("*******************************token*******************");
    //   print(token);
    // });

    // FirebaseMessaging.onMessage.listen((event) {
    //   //بتعطينا انو وصل اشعار واحنا فاتحين التطبيق
    //   print("*******************************notification*******************");
    //   print("${event.notification!.body}");
    // });

    // //notification in the background on click navigator to message page
    // FirebaseMessaging.onMessageOpenedApp.listen((message) {
    //   Navigator.pushNamed(context, "MessagesUserList", arguments: isDoctor);
    // });
    /******************************************************************************************** */
    super.initState();
    print("Initializing HomePage");
    setState(() {
      loadUserData();
      getinfo();
      getnotifications();
      getnotificationcount();
      getnot();
      // loadUserID();
      // filteredDoctors = List.from(doctors);
    });
  }

  void filterDoctorsByCity(String? city) {
    setState(() {
      selectedCity = city;
      if (city == null || city == "All") {
        // If no city is selected, display all doctors
        filteredDoctors = List.from(doctors);
      } else {
        // Filter doctors based on the selected city
        filteredDoctors = doctors.where((doctor) {
          return doctor['City'] == city;
        }).toList();
      }
    });
  }

  void filterDoctors(String query) {
    setState(() {
      if (query.isEmpty) {
        // If the query is empty, display all doctors
        filteredDoctors = List.from(doctors);
      } else {
        // Filter doctors based on the query
        filteredDoctors = doctors.where((doctor) {
          final name = doctor['name'].toLowerCase();
          return name.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Color customColor = const Color(0xFFBBF1FA);
  Color mainColor = const Color(0xFF389AAB);
  Color footerColor = Color(0xFF2D3E50);

  @override
  Widget build(BuildContext context) {
    setState(() {
      loadUserData();
    });

    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      // drawerScrimColor: Colors.cyan[100],
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          leading: SizedBox(
            width: 20,
          ),
          centerTitle: true,
          backgroundColor: mainColor,
          title: Center(
            child: Image.asset(
              'images/logo4.png',
              width: 100.0, // Adjust the width as needed
              height: 100.0, // Adjust the height as needed
              color: customColor,
            ),
          ),
          actions: [
            Stack(children: [
              IconButton(
                iconSize: 37,
                color: customColor,
                icon: Icon(Icons.notifications_active),
                onPressed: () async {
                  notif.Notifications().showNotificationList(context);
                  print("=====================Notifications================");
                  setState(() {
                    notif.notifications.clear();
                    print(allnotification);

                    for (var notificationItem in allnotification) {
                      if (notificationItem.containsKey('title') &&
                          notificationItem.containsKey('content') &&
                          notificationItem.containsKey('date') &&
                          notificationItem.containsKey('read')) {
                        notif.NotificationItem notf = notif.NotificationItem(
                            title: notificationItem['title'] ?? '',
                            content: notificationItem['content'] ?? '',
                            date: notificationItem['date'] ?? '',
                            read: notificationItem['read'] ?? false,
                            timetosend: notificationItem['dateTime'].toDate() ??
                                DateTime.now());
                        notif.notifications.add(notf);
                      } else {
                        print(
                            "Notification item is missing required properties.");
                      }
                    }
                    notif.notifications
                        .sort((a, b) => a.timetosend.compareTo(b.timetosend));
                  });
                },
              ),
              notificationVount != 0
                  ? Positioned(
                      right: 30,
                      top: 2,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red, // You can customize the color
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Center(
                          child: Text(
                            '$notificationVount',
                            style: TextStyle(
                              color: Colors
                                  .white, // You can customize the text color
                            ),
                          ),
                        ),
                      ),
                    )
                  : Container(),
            ])

            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: SizedBox(
            //     width: 40,
            //   ),
            // ),
          ],
          elevation: 6,
          shadowColor: mainColor,
        ),
      ),
      // drawer: Drawer(
      //   // backgroundColor: customColor,
      //   child: Column(children: [
      //     UserAccountsDrawerHeader(
      //       // decoration: BoxDecoration(
      //       //   color: mainColor,
      //       // ),
      //       accountName: Text(
      //         nameUser,
      //         style: TextStyle(fontSize: 20),
      //       ),
      //       accountEmail: Text(
      //         // "mira@gmail.com",
      //         emailUser,
      //         style: TextStyle(fontSize: 15),
      //       ),
      //       currentAccountPicture: userImage == ""
      //           ? CircleAvatar(
      //               backgroundColor: customColor,
      //               backgroundImage: AssetImage("images/logo2.png"),
      //               child: Container(
      //                 decoration: BoxDecoration(
      //                   shape: BoxShape.circle,
      //                   border: Border.all(
      //                     color: mainColor, // Specify the border color here
      //                     width: 2.0, // Specify the border width here
      //                   ),
      //                 ),
      //               ),
      //             )
      //           : CircleAvatar(
      //               backgroundColor: customColor,
      //               backgroundImage: NetworkImage(userImage),
      //               child: Container(
      //                 decoration: BoxDecoration(
      //                   shape: BoxShape.circle,
      //                   border: Border.all(
      //                     color: mainColor, // Specify the border color here
      //                     width: 2.0, // Specify the border width here
      //                   ),
      //                 ),
      //               ),

      //               //  CircleAvatar(
      //               //   backgroundColor: customColor,
      //               //   backgroundImage: NetworkImage(),
      //               //   child: Container(
      //               //     decoration: BoxDecoration(
      //               //       shape: BoxShape.circle,
      //               //       border: Border.all(
      //               //         color: mainColor, // Specify the border color here
      //               //         width: 2.0, // Specify the border width here
      //               //       ),
      //               //     ),
      //               //   ),

      //               // child: Text(
      //               //   nameUser.isNotEmpty ? nameUser[0] : 'U',
      //               //   style: TextStyle(fontSize: 30, color: mainColor),
      //               // ),
      //             ),
      //       decoration: BoxDecoration(
      //         color: mainColor,
      //         // image: DecorationImage(
      //         //   image: AssetImage('images/logo2.jpg'),
      //         //   fit: BoxFit.cover,
      //         // ),
      //       ),
      //     ),
      //     ListTile(
      //       iconColor: mainColor,
      //       textColor: mainColor,
      //       title: Text(
      //         "My Profile ",
      //         style: TextStyle(fontSize: 18),
      //       ),
      //       leading: Icon(
      //         Icons.home,
      //         size: 35,
      //       ),
      //       splashColor: customColor,
      //       onTap: () async {
      //         // Navigator.pushNamed(context, "UserProfile");
      //         final res = await Api.getuserbyid(userID);
      //         Navigator.push(
      //             context,
      //             MaterialPageRoute(
      //                 builder: (context) => ProfileUser(
      //                       userinfo: res.body,
      //                       visit: false,
      //                     )));
      //       },
      //     ),
      //     Divider(),
      //     ListTile(
      //       iconColor: mainColor,
      //       textColor: mainColor,
      //       title: Text(
      //         "Categories",
      //         style: TextStyle(fontSize: 18),
      //       ),
      //       splashColor: customColor,
      //       leading: Icon(
      //         Icons.edit_square,
      //         size: 35,
      //       ),
      //       onTap: () {
      //         Navigator.pushNamed(context, "Categories");
      //       },
      //     ),
      //     Divider(),
      //     ListTile(
      //       iconColor: mainColor,
      //       textColor: mainColor,
      //       title: Text(
      //         "Booked appointments",
      //         style: TextStyle(fontSize: 18),
      //       ),
      //       splashColor: customColor,
      //       leading: Icon(
      //         Icons.access_time_filled,
      //         size: 35,
      //       ),
      //       onTap: () {
      //         Navigator.pushNamed(context, "BookedAppointments", arguments: {
      //           'userID': userID,
      //         });
      //       },
      //     ),
      //     Divider(),
      //     ListTile(
      //       iconColor: mainColor,
      //       textColor: mainColor,
      //       title: Text(
      //         "Messages",
      //         style: TextStyle(fontSize: 18),
      //       ),
      //       splashColor: customColor,
      //       leading: Icon(
      //         Icons.message,
      //         size: 35,
      //       ),
      //       onTap: () {
      //         Navigator.pushNamed(context, "MessagesHomeScreen",
      //             arguments: isDoctor);
      //       },
      //     ),
      //     Divider(),
      //     ListTile(
      //       iconColor: mainColor,
      //       textColor: mainColor,
      //       title: Text(
      //         "Clinic locations",
      //         style: TextStyle(fontSize: 18),
      //       ),
      //       leading: Icon(
      //         Icons.location_on,
      //         size: 35,
      //       ),
      //       splashColor: customColor,
      //       onTap: () async {
      //         // Navigator.pushNamed(context, "UserProfile");
      //         Map<String, dynamic> res = await Api.getLocations();
      //         print("LOCATIONS $res");
      //         Navigator.push(
      //             context,
      //             MaterialPageRoute(
      //                 builder: (context) => Doc_locations(
      //                       doctor_category: res['doctorDetails'],
      //                     )));
      //       },
      //     ),
      //     Divider(),
      //     ListTile(
      //       iconColor: mainColor,
      //       textColor: mainColor,
      //       title: Text(
      //         "Log out",
      //         style: TextStyle(fontSize: 18),
      //       ),
      //       splashColor: customColor,
      //       leading: Icon(
      //         Icons.exit_to_app,
      //         size: 35,
      //       ),
      //       onTap: () {
      //         Navigator.pushReplacementNamed(context, "LogIn");
      //         // print("my context :$context");
      //       },
      //     ),
      //     // Divider(),
      //   ]),
      // ),

      body: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border(right: BorderSide(width: 0.5, color: mainColor)),

                // boxShadow:[
                //   BoxShadow(
                //   color: mainColor.withOpacity(0.5),
                //   spreadRadius: 5,
                //   blurRadius: 7,
                //   offset: Offset(0, 3),
                // ),
                // ]
              ),
              // color: mainColor,
              child: Column(
                children: [
                  UserAccountsDrawerHeader(
                    // decoration: BoxDecoration(
                    //   color: mainColor,
                    // ),
                    accountName: Text(
                      nameUser,
                      style: TextStyle(fontSize: 20),
                    ),
                    accountEmail: Text(
                      // "mira@gmail.com",
                      emailUser,
                      style: TextStyle(fontSize: 15),
                    ),
                    currentAccountPicture: userImage == ""
                        ? CircleAvatar(
                            backgroundColor: customColor,
                            backgroundImage: AssetImage("images/logo2.png"),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color:
                                      mainColor, // Specify the border color here
                                  width: 2.0, // Specify the border width here
                                ),
                              ),
                            ),
                          )
                        : CircleAvatar(
                            backgroundColor: customColor,
                            backgroundImage: NetworkImage(userImage),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color:
                                      mainColor, // Specify the border color here
                                  width: 2.0, // Specify the border width here
                                ),
                              ),
                            ),
                          ),
                    decoration: BoxDecoration(
                      color: mainColor,
                      // image: DecorationImage(
                      //   image: AssetImage('images/logo2.jpg'),
                      //   fit: BoxFit.cover,
                      // ),
                    ),
                  ),
                  ListTile(
                    iconColor: mainColor,
                    textColor: mainColor,
                    title: Text(
                      "My Profile ",
                      style: TextStyle(fontSize: 18),
                    ),
                    leading: Icon(
                      Icons.home,
                      size: 35,
                    ),
                    splashColor: customColor,
                    onTap: () async {
                      // Navigator.pushNamed(context, "UserProfile");
                      final res = await Api.getuserbyid(userID);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfileUser(
                                    userinfo: res.body,
                                    visit: false,
                                  )));
                    },
                  ),
                  Divider(),
                  ListTile(
                    iconColor: mainColor,
                    textColor: mainColor,
                    title: Text(
                      "Categories",
                      style: TextStyle(fontSize: 18),
                    ),
                    splashColor: customColor,
                    leading: Icon(
                      Icons.edit_square,
                      size: 35,
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, "Categories");
                    },
                  ),
                  Divider(),
                  ListTile(
                    iconColor: mainColor,
                    textColor: mainColor,
                    title: Text(
                      "Booked appointments",
                      style: TextStyle(fontSize: 18),
                    ),
                    splashColor: customColor,
                    leading: Icon(
                      Icons.access_time_filled,
                      size: 35,
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, "BookedAppointments",
                          arguments: {
                            'userID': userID,
                          });
                    },
                  ),
                  Divider(),
                  ListTile(
                    iconColor: mainColor,
                    textColor: mainColor,
                    title: Text(
                      "Messages",
                      style: TextStyle(fontSize: 18),
                    ),
                    splashColor: customColor,
                    leading: Icon(
                      Icons.message,
                      size: 35,
                    ),
                    onTap: () {
                      // Navigator.pushNamed(context, "MessagesHomeScreen",
                      //     arguments: isDoctor);
                      Navigator.pushNamed(
                        context,
                        "MessagesHomeScreen",
                        arguments: {'role': 'user'},
                      );
                    },
                  ),
                  Divider(),
                  ListTile(
                    iconColor: mainColor,
                    textColor: mainColor,
                    title: Text(
                      "Clinic locations",
                      style: TextStyle(fontSize: 18),
                    ),
                    leading: Icon(
                      Icons.location_on,
                      size: 35,
                    ),
                    splashColor: customColor,
                    onTap: () async {
                      // Navigator.pushNamed(context, "UserProfile");
                      Map<String, dynamic> res = await Api.getLocations();
                      print("LOCATIONS $res");
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Doc_locations(
                                    doctor_category: res['doctorDetails'],
                                  )));
                    },
                  ),
                  Divider(),
                  ListTile(
                    iconColor: mainColor,
                    textColor: mainColor,
                    title: Text(
                      "Log out",
                      style: TextStyle(fontSize: 18),
                    ),
                    splashColor: customColor,
                    leading: Icon(
                      Icons.exit_to_app,
                      size: 35,
                    ),
                    onTap: () async {
                      var data = {"token": ""};
                      await Api.changeFCMuser(data, userID);
                      Navigator.pushReplacementNamed(context, "LogIn");
                      // print("my context :$context");
                    },
                  ),

                  // Text("my profile")
                ],
              ),
            ),
            flex: 1,
          ),
          Expanded(
            flex: 5,
            child: NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return [];
              },
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 70),
                      child: Column(
                        children: [
                          Container(
                            child: Container(
                              color: const Color.fromARGB(147, 0, 0, 0),
                              child: Center(
                                  child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.timer_outlined,
                                        color: mainColor,
                                        size: 60,
                                      ),
                                      Text(
                                        "TeethTickTock",
                                        style: TextStyle(
                                          fontSize: 60,
                                          fontWeight: FontWeight.bold,
                                          color: mainColor,
                                          shadows: [
                                            Shadow(
                                              blurRadius: 5.0,
                                              color: mainColor,
                                              offset: Offset(
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.001,
                                                      MediaQuery.of(context)
                                                          .size
                                                          .width) *
                                                  0.001,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.timer_outlined,
                                        color: mainColor,
                                        size: 60,
                                      )
                                    ],
                                  ),
                                  Text(
                                    "Search and book your appointment with the desired dentist",
                                    style: TextStyle(
                                      fontSize: 20,
                                      // fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.white,
                                    ),
                                  )
                                ],
                              )),
                            ),
                            // width: 700,
                            height: 450,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage("images/background2.jpg"),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                            ),
                          ),
                          // ),
                          Padding(
                            padding: EdgeInsets.only(top: 20.0, bottom: 20),
                            child: Text(
                              "Doctors",
                              style: TextStyle(
                                fontSize: 35,
                                fontWeight: FontWeight.bold,
                                color: mainColor,
                                shadows: [
                                  Shadow(
                                    blurRadius: 15.0,
                                    color: mainColor,
                                    offset: Offset(
                                        MediaQuery.of(context).size.width *
                                            0.002,
                                        MediaQuery.of(context).size.width *
                                            0.002),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          //search
                          // ),
                          /////////////////////////////////////////////Top3
                          ///
                          ///
                          ///
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Top Rated Doctors",
                                  style: TextStyle(
                                    // decoration: TextDecoration.underline,

                                    // decorationColor:
                                    //     mainColor, // Optionally set the underline color
                                    // decorationThickness:
                                    //     1.0, // Optionally set the thickness of the underline
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    color: mainColor,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 15.0,
                                        color: mainColor,
                                        offset: Offset(
                                            MediaQuery.of(context).size.width *
                                                0.002,
                                            MediaQuery.of(context).size.width *
                                                0.002),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star_rate_rounded,
                                    color: Colors.yellow,
                                    size: 30,
                                  ),
                                  Icon(
                                    Icons.star_rate_rounded,
                                    color: Colors.yellow,
                                    size: 30,
                                  ),
                                  Icon(
                                    Icons.star_rate_rounded,
                                    color: Colors.yellow,
                                    size: 30,
                                  ),
                                ],
                              )
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            // color: customColor,
                            padding: EdgeInsets.symmetric(
                                horizontal: 150, vertical: 40),
                            margin: EdgeInsets.only(bottom: 15.0, top: 15),

                            decoration: BoxDecoration(
                              color: customColor,
                              borderRadius: BorderRadius.circular(
                                  12), // Adjust the radius as needed
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0,
                                      3), // changes the position of the shadow
                                ),
                              ],
                            ),

                            child:
                                ///////////////////////////////////Top3
                                SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  for (int i = 0; i < top3.length; i++)
                                    Padding(
                                      padding: EdgeInsets.only(
                                          right: screenWidth * 0.05),
                                      child: GestureDetector(
                                        onTap: () async {
                                          print("test");
                                          try {
                                            final response =
                                                await Api.getdoctor(
                                                    top3[i]['id'] ?? '');
                                            String responseBody = response.body;
                                            if (responseBody
                                                .contains("doctor")) {
                                              responseBody = responseBody
                                                  .replaceAll("doctor", "user");
                                            }
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) {
                                              return UserProfiledoc(
                                                doctorinfo: responseBody,
                                                userid: userID,
                                              );
                                            }));
                                          } catch (error) {
                                            print("Error in API call: $error");
                                            // Handle the error, e.g., show a message to the user
                                          }
                                        },
                                        child: MouseRegion(
                                          cursor: SystemMouseCursors.click,
                                          child: Container(
                                            width: screenWidth > 600
                                                ? 200
                                                : 150, // Adjust the width as needed
                                            padding: EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.1),
                                                  blurRadius: 4.0,
                                                  spreadRadius: 0.05,
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Align(
                                                  alignment: Alignment.center,
                                                  child: Container(
                                                    height: 150,
                                                    width: 150,
                                                    child: top3[i]['image'] ==
                                                            ""
                                                        ? Image.asset(
                                                            "images/logo2.png",
                                                            fit: BoxFit.cover,
                                                          )
                                                        : Image.network(
                                                            top3[i]['image'],
                                                            fit: BoxFit.cover,
                                                          ),
                                                  ),
                                                ),
                                                Text(
                                                  "${top3[i]['name']}",
                                                  style: TextStyle(
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  "${top3[i]['specialty']}",
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: const Color.fromARGB(
                                                        255, 144, 141, 141),
                                                  ),
                                                ),
                                                Text(
                                                  "${top3[i]['City']}",
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: const Color.fromARGB(
                                                        255, 144, 141, 141),
                                                  ),
                                                ),
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: List.generate(
                                                    5,
                                                    (index) => Icon(
                                                      Icons.star,
                                                      color: index <
                                                              top3[i]['rate']
                                                          ? Colors.yellow
                                                          : null,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            ///////////////////////////////////Nearby Clinic
                            ///
                          ),
                          //                Divider(
                          //   color: mainColor,
                          //   thickness: 1, // Adjust the thickness as needed
                          // ),

                          SizedBox(
                            // height: 50,
                            height: 20,
                          ),

                          ///
                          ///
                          ///
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Nearby Clinic",
                                  style: TextStyle(
                                    // decoration: TextDecoration.underline,

                                    // decorationColor:
                                    //     mainColor, // Optionally set the underline color
                                    // decorationThickness:
                                    //     1.0, // Optionally set the thickness of the underline

                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    color: mainColor,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 15.0,
                                        color: mainColor,
                                        offset: Offset(
                                            MediaQuery.of(context).size.width *
                                                0.002,
                                            MediaQuery.of(context).size.width *
                                                0.002),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 40),
                            margin: EdgeInsets.only(bottom: 15.0, top: 15),

                            // margin: EdgeInsets.only(bottom: 15.0, top: 15),
                            decoration: BoxDecoration(
                              color: Colors.white70,
                              borderRadius: BorderRadius.circular(
                                  12), // Adjust the radius as needed
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0,
                                      3), // changes the position of the shadow
                                ),
                              ],
                            ),

                            child:
                                ///////////////////////////////////Nearby Clinic
                                SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  for (int i = 0;
                                      i < nearestdoctors.length;
                                      i++)
                                    Padding(
                                      padding: EdgeInsets.only(
                                          right: screenWidth * 0.05),
                                      child: GestureDetector(
                                        onTap: () async {
                                          print("test");
                                          try {
                                            final response =
                                                await Api.getdoctor(
                                                    nearestdoctors[i]['id'] ??
                                                        '');
                                            String responseBody = response.body;
                                            if (responseBody
                                                .contains("doctor")) {
                                              responseBody = responseBody
                                                  .replaceAll("doctor", "user");
                                            }
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) {
                                              return UserProfiledoc(
                                                doctorinfo: responseBody,
                                                userid: userID,
                                              );
                                            }));
                                          } catch (error) {
                                            print("Error in API call: $error");
                                            // Handle the error, e.g., show a message to the user
                                          }
                                        },
                                        child: MouseRegion(
                                          cursor: SystemMouseCursors.click,
                                          child: Container(
                                            width: screenWidth > 600
                                                ? 200
                                                : 150, // Adjust the width as needed
                                            padding: EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.1),
                                                  blurRadius: 4.0,
                                                  spreadRadius: 0.05,
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Align(
                                                  alignment: Alignment.center,
                                                  child: Container(
                                                    height: 150,
                                                    width: 150,
                                                    child: nearestdoctors[i]
                                                                ['image'] ==
                                                            ""
                                                        ? Image.asset(
                                                            "images/logo2.png",
                                                            fit: BoxFit.cover,
                                                          )
                                                        : Image.network(
                                                            nearestdoctors[i]
                                                                ['image'],
                                                            fit: BoxFit.cover,
                                                          ),
                                                  ),
                                                ),
                                                Text(
                                                  "${nearestdoctors[i]['name']}",
                                                  style: TextStyle(
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  "${nearestdoctors[i]['specialty']}",
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: const Color.fromARGB(
                                                        255, 144, 141, 141),
                                                  ),
                                                ),
                                                Text(
                                                  "${nearestdoctors[i]['City']}",
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: const Color.fromARGB(
                                                        255, 144, 141, 141),
                                                  ),
                                                ),
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: List.generate(
                                                    5,
                                                    (index) => Icon(
                                                      Icons.star,
                                                      color: index <
                                                              nearestdoctors[i]
                                                                  ['rate']
                                                          ? Colors.yellow
                                                          : null,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            ///////////////////////////////////Nearby Clinic
                            ///
                          ),
                          SizedBox(
                            height: 40,
                          ),
                          Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  "All Doctors",
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: mainColor,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 15.0,
                                        color: mainColor,
                                        offset: Offset(
                                            MediaQuery.of(context).size.width *
                                                0.002,
                                            MediaQuery.of(context).size.width *
                                                0.002),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              Center(
                                child: Container(
                                  width: 400,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(30.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        blurRadius: 5,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: TextField(
                                      decoration: InputDecoration(
                                        hintText: 'Search...',
                                        border: InputBorder.none,
                                        icon: Icon(
                                          Icons.search,
                                          color: mainColor,
                                        ),
                                      ),
                                      onChanged: (query) {
                                        // Your search function
                                        // filterDoctors(query);
                                        filterDoctors(query);
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          Row(
                            children: [
                              Text(
                                "Sorted by City:",
                                style: TextStyle(
                                    fontSize: 18,
                                    color: mainColor,
                                    fontWeight: FontWeight.bold),
                              ),
                              DropdownButton<String>(
                                // disabledHint: Text("doctor City"),
                                hint: Text("All"),
                                // dropdownColor: mainColor,
                                iconEnabledColor: mainColor,
                                iconSize: 30,
                                iconDisabledColor: mainColor,
                                value: selectedCity,
                                items: [
                                  DropdownMenuItem<String>(
                                    value: "All",
                                    child: Text("All"),
                                  ),
                                  ...doctors
                                      .map((doctor) => doctor['City'])
                                      .toSet()
                                      .map((city) => DropdownMenuItem<String>(
                                            value: city,
                                            child: Text(
                                              city,
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.black,
                                              ),
                                            ),
                                          )),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    filterDoctorsByCity(value!);
                                  });
                                },
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 40,
                          ),

                          GridView.builder(
                            shrinkWrap: true,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: screenWidth > 600 ? 4 : 2,
                              crossAxisSpacing: screenWidth * 0.05,
                              mainAxisSpacing: screenWidth * 0.06,
                              childAspectRatio: 0.8,
                            ),
                            itemCount: filteredDoctors.length,
                            padding: EdgeInsets.symmetric(
                                horizontal: 1, vertical: 8),
                            itemBuilder: (context, i) {
                              return GestureDetector(
                                onTap: () async {
                                  print("test");
                                  try {
                                    final response = await Api.getdoctor(
                                        filteredDoctors[i]['id'] ?? '');
                                    String responseBody = response.body;
                                    if (responseBody.contains("doctor")) {
                                      responseBody = responseBody.replaceAll(
                                          "doctor", "user");
                                    }
                                    Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) {
                                      return UserProfiledoc(
                                        doctorinfo: responseBody,
                                        userid: userID,
                                      );
                                    }));
                                  } catch (error) {
                                    print("Error in API call: $error");
                                    // Handle the error, e.g., show a message to the user
                                  }
                                },
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: Container(
                                    // color: mainColor,
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,

                                      // color: mainColor,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 4.0,
                                          spreadRadius: 0.05,
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Align(
                                          alignment: Alignment.center,
                                          child: Container(
                                            height: 150,
                                            width: 150,
                                            child: filteredDoctors[i]
                                                        ['image'] ==
                                                    ""
                                                ? Image.asset(
                                                    "images/logo2.png",
                                                    fit: BoxFit.cover,
                                                  )
                                                : Image.network(
                                                    filteredDoctors[i]['image'],
                                                    fit: BoxFit.cover,
                                                  ),
                                          ),
                                        ),
                                        // SizedBox(
                                        //   height: 10,
                                        // ),
                                        Text(
                                          "${filteredDoctors[i]['name']}",
                                          style: TextStyle(
                                            // Add other style parameters
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "${filteredDoctors[i]['specialty']}",
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: const Color.fromARGB(
                                                255, 144, 141, 141),
                                          ),
                                        ),
                                        Text(
                                          "${filteredDoctors[i]['City']}",
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: const Color.fromARGB(
                                                255, 144, 141, 141),
                                          ),
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          mainAxisSize: MainAxisSize.min,
                                          children: List.generate(
                                            5,
                                            (index) => Icon(
                                              Icons.star,
                                              color: index <
                                                      filteredDoctors[i]['rate']
                                                  ? Colors.yellow
                                                  : null,
                                            ),
                                          ),
                                        ),
                                        // Spacer to push the footer to the bottom
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    // Spacer to push the footer to the bottom
                    // Spacer(),

// *******************Footer section********************************************************************
                    Container(
                      margin: EdgeInsets.only(top: 30),
                      color: footerColor,
                      padding: EdgeInsets.only(
                          right: 16.0, left: 16.0, bottom: 16.0, top: 40),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ' Who we are ? ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                '© 2023 Teeth Tick Tock is an application that brings together\n specialized dentists in specific fields to facilitate  the booking \n of the first appointment with the selected doctor. It also \n simplifies communication with the doctor through messages \n and provides information about them.',
                                style: TextStyle(
                                    color: const Color.fromARGB(
                                        255, 190, 189, 189),
                                    fontStyle: FontStyle.italic),
                              ), //© 2023 TeethTickTock
                              SizedBox(
                                height: 20,
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.email,
                                    color: const Color.fromARGB(
                                        255, 190, 189, 189),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.of(context).pushNamed(
                                        "SendEmail",
                                        arguments: {'emailUser': emailUser},
                                      );
                                    },
                                    child: Text(
                                      "TeethTictTock@gmail.com",
                                      style: TextStyle(
                                          color: const Color.fromARGB(
                                              255, 190, 189, 189),
                                          decoration: TextDecoration.underline),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.phone,
                                    color: const Color.fromARGB(
                                        255, 190, 189, 189),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    "+970595408588 ",
                                    style: TextStyle(
                                        color: const Color.fromARGB(
                                            255, 190, 189, 189),
                                        decoration: TextDecoration.underline),
                                  ),
                                  Text(
                                    "| +970595048188",
                                    style: TextStyle(
                                        color: const Color.fromARGB(
                                            255, 190, 189, 189),
                                        decoration: TextDecoration.underline),
                                  )
                                ],
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 80,
                          ),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ' Our policy ',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "Reservations",
                                  style: TextStyle(
                                      color: const Color.fromARGB(
                                          255, 190, 189, 189),
                                      fontStyle: FontStyle.italic),
                                ), //© 2023 TeethTickTock
                                SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  "Messages",
                                  style: TextStyle(
                                      color: const Color.fromARGB(
                                          255, 190, 189, 189),
                                      fontStyle: FontStyle.italic),
                                ), //© 2023 TeethTickTock
                                SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  "Maps",
                                  style: TextStyle(
                                      color: const Color.fromARGB(
                                          255, 190, 189, 189),
                                      fontStyle: FontStyle.italic),
                                ), //© 2023 TeethTickTock
                                SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  "Categories",
                                  style: TextStyle(
                                      color: const Color.fromARGB(
                                          255, 190, 189, 189),
                                      fontStyle: FontStyle.italic),
                                ), //© 2023 TeethTickTock
                                SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  "Review",
                                  style: TextStyle(
                                      color: const Color.fromARGB(
                                          255, 190, 189, 189),
                                      fontStyle: FontStyle.italic),
                                ), //© 2023 TeethTickTock
                                SizedBox(
                                  height: 20,
                                ),
                              ]),
                          Expanded(
                            child: Container(
                              alignment: Alignment.centerRight,
                              width: 100,
                              child: Image.asset(
                                'images/logo2.png',
                                width: 250.0, // Adjust the width as needed
                                height: 250.0, // Adjust the height as needed
                                color: const Color.fromARGB(255, 190, 189, 189),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
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
