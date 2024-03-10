import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:localstorage/localstorage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:untitled/Admin/AllUsers.dart';
import 'package:untitled/Admin/alldoctors.dart';
import 'package:untitled/Profile/doctorprofile.dart';
import 'package:untitled/Profile/userprofile.dart';
import 'package:untitled/maps/doctorslocation.dart';
import 'package:untitled/model/doctor.dart';
import 'package:untitled/servicies/api.dart';
import 'package:http/http.dart' as http;

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({Key? key}) : super(key: key);

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  Color customColor = const Color(0xFFBBF1FA);
  Color mainColor = const Color(0xFF389AAB);
//fire base
  final _auth = FirebaseAuth.instance;
  //send email
  Future<void> _sendEmail(String dremail, bool accept) async {
    String name = "Teeth Tick Tock team";
    String email = dremail;
    String content = "";
    String subject = "";
    if (accept == true) {
      setState(() {
        content =
            "We are happy to inform you that you have been approved to join the Teeth Tik Tok application as a doctor. We wish you a pleasant and comfortable experience in using our application. You can now log in using your email.";
        subject = "Accept to join the application";
      });
    } else {
      setState(() {
        content =
            "We regret that your request to join the application was rejected because the conditions were not met";
        subject = "Reject to join the application";
      });
    }

    final serviceId = 'service_fcoxknn';
    final templateId = 'template_998s89n';
    final userId = 'jNnzsQ_l_16bKhioh';
    print("name :$name");
    print("email :$email");
    print("subject :$subject");
    print("content :$content");
    final url = Uri.parse("https://api.emailjs.com/api/v1.0/email/send");

    final response = await http.post(url,
        headers: {
          'origin': 'http://localhost', // to work on mobile app
          'Content-Type': 'application/json' // to work on website
        },
        body: json.encode({
          "service_id": serviceId,
          "template_id": templateId,
          "user_id": userId,
          "template_params": {
            'user_name': name,
            'user_email': email,
            'user_subject': subject,
            'user_message': content,
          }
        }));
    if (response.statusCode == 200) {
      print('Email sent successfully!');
      print(response.body);
    } else {
      print('Failed to send email. Status code: ${response.statusCode}');
      print(response.body);
    }
  }

  // Function to load user data from local storage
  String nameUser = 'Admin';
  String emailUser = 'admin@gmail.com';
  String userID = '1';
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
      });
      print('User data loaded: name=$nameUser, email=$emailUser, id=$userID');
      print('Name: ${userData['name']}');
      print('Email: ${userData['email']}');
      print('ID: ${userData['id']}');
    } else {
      print('User data not found.');
    }
  }

  List<Map<String, dynamic>> requeststemp = [
    {
      "id": "request_id_1",
      "name": "John Doe",
      "email": "john.doe@example.com",
      "city": "New York",
      "phone": "555-1234",
      "category": "Cardiology",
      "password": "password123",
      "locationMap": {"latitude": 40.7128, "longitude": -74.0060},
      "categoryid": 1,
    },
    {
      "id": "request_id_2",
      "name": "Jane Smith",
      "email": "jane.smith@example.com",
      "city": "San Francisco",
      "phone": "555-5678",
      "category": "Pediatrics",
      "password": "securepass",
      "locationMap": {"latitude": 37.7749, "longitude": -122.4194},
      "categoryid": 2,
    },
    {
      "id": "request_id_3",
      "name": "Bob Johnson",
      "email": "bob.johnson@example.com",
      "city": "Chicago",
      "phone": "555-4321",
      "category": "Orthopedics",
      "password": "secret123",
      "locationMap": {"latitude": 41.8781, "longitude": -87.6298},
      "categoryid": 3,
    },
    // Add more request items as needed
  ];
  late List<Map<String, dynamic>> requests = [];
  late String dategoryid;
  void getinfo() async {
    print("aseel");
    final response = await Api.getdoctorrequests();
    print("aseel");
    print(response.body);

    Map<dynamic, dynamic> parsedJson = json.decode(response.body);

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
          phoneNumber: parsedJson2['phoneNumber'],
          city: parsedJson2['city'],
          locationMap: List<double>.from(parsedJson2['locationMap']),
          category: category,
          password: parsedJson2['password'],
        );

        doctors2.add(doctor);
        print("Doctor Name: ${doctor.name}");
        print("Doctor Name: ${doctor.locationMap}");
        Map<String, dynamic> doctorMap = {
          "id": doctor.id,
          "name": doctor.name,
          "email": doctor.email,
          "city": doctor.city,
          "phone": doctor.phoneNumber,
          "location": doctor.locationMap,
          "category": doctor.category,
          "categoryid": parsedJson2['category'],
          "password": doctor.password,
          "locationMap": doctor.locationMap
        };
        setState(() {
          requests.add(doctorMap);
          filteredRequests.add(doctorMap);
          // loadUserData();
        });
      }
      /*  setState(() {
        requests.addAll(requeststemp);
        filteredRequests.addAll(requeststemp);
        requests.addAll(requeststemp);
        filteredRequests.addAll(requeststemp);
      }); */
    }
    setState(() {
      isgetinfo = List.filled(requests.length, false);
    });
  }

  late List<Map<String, dynamic>> filteredRequests = [];
  late List<bool> isgetinfo = [];
  @override
  void initState() {
    super.initState();
    setState(() {
      getinfo();
    });
  }

  void filterDoctors(String query) {
    setState(() {
      if (query.isEmpty) {
        // If the query is empty, display all doctors
        filteredRequests = List.from(requests);
      } else {
        // Filter doctors based on the query
        filteredRequests = requests.where((doctor) {
          final name = doctor['name'].toLowerCase();
          final category = doctor['category'].toLowerCase();

          return name.contains(query.toLowerCase()) ||
              category.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  late List doctorcategory = [];
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          backgroundColor: mainColor,
          elevation: 12,
          shadowColor: mainColor,
          leading: Image.asset(
            'images/logo2.png',
            width: 140.0,
            height: 140.0,
            color: customColor,
          ),
          title: Text("TeethTickTock",
              style: GoogleFonts.lora(
                textStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  color: customColor,
                ),
              )),
          actions: [
            IconButton(
              icon: Container(
                decoration: BoxDecoration(
                    // border: Border(
                    //     bottom: BorderSide(
                    //         color: customColor,
                    //         width: 0.8)), // Adjust color and width as needed
                    ),
                child: Text(
                  'Requests',
                  style: GoogleFonts.lora(
                    textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      color: customColor,
                    ),
                  ),
                ),
              ),
              onPressed: () async {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AdminHomePage()));
              },
            ),
            SizedBox(
              width: 10,
            ),
            IconButton(
              icon: Container(
                decoration: BoxDecoration(
                    // border: Border(
                    //     bottom: BorderSide(
                    //         color: customColor,
                    //         width: 0.8)), // Adjust color and width as needed
                    ),
                child: Text(
                  'Messages',
                  style: GoogleFonts.lora(
                    textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      color: customColor,
                    ),
                  ),
                ),
              ),
              onPressed: () {
                // Navigator.pushNamed(context, "Messages");
                //  Navigator.pushNamed(context, "MessagesHomeScreen",
                //           arguments: isDoctor);
                Navigator.pushNamed(
                  context,
                  "MessagesHomeScreen",
                  arguments: {'role': 'admin'},
                );
              },
            ),
            SizedBox(
              width: 10,
            ),
            IconButton(
              icon: Container(
                decoration: BoxDecoration(
                    // border: Border(
                    //     bottom: BorderSide(
                    //         color: customColor,
                    //         width: 0.8)), // Adjust color and width as needed
                    ),
                child: Text(
                  'Categories',
                  style: GoogleFonts.lora(
                    textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      color: customColor,
                    ),
                  ),
                ),
              ),
              onPressed: () {
                // Navigator.pushNamed(context, "Messages");
              },
            ),
            SizedBox(
              width: 10,
            ),
            IconButton(
              icon: Container(
                decoration: BoxDecoration(
                    // border: Border(
                    //     bottom: BorderSide(
                    //         color: customColor,
                    //         width: 0.8)), // Adjust color and width as needed
                    ),
                child: Text(
                  'Doctors',
                  style: GoogleFonts.lora(
                    textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      color: customColor,
                    ),
                  ),
                ),
              ),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Doctorss()));
                //  Navigator.pushNamed(context, "Doctors");
              },
            ),
            SizedBox(
              width: 10,
            ),
            IconButton(
              icon: Container(
                decoration: BoxDecoration(
                    // border: Border(
                    //     bottom: BorderSide(
                    //         color: customColor,
                    //         width: 0.8)), // Adjust color and width as needed
                    ),
                child: Text(
                  'Users',
                  style: GoogleFonts.lora(
                    textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      color: customColor,
                    ),
                  ),
                ),
              ),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AllUsers()));
                //  Navigator.pushNamed(context, "Doctors");
              },
            ),
            SizedBox(
              width: 10,
            ),
            IconButton(
              icon: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        // border: Border(
                        //     bottom: BorderSide(
                        //         color: customColor,
                        //         width: 0.8)), // Adjust color and width as needed
                        ),
                    child: Row(
                      children: [
                        Text(
                          'Logout ',
                          style: GoogleFonts.lora(
                            textStyle: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              color: customColor,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.logout,
                          size: 22,
                          color: customColor,
                        )
                      ],
                    ),
                  )
                ],
              ),
              onPressed: () {
                Navigator.pushReplacementNamed(context, "LogIn");
              },
            ),
          ],
        ),
      ),
//********************************************************************************************************************************************************************** */
      body: Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(0.2), // Customize the shadow color
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3), // Adjust the position of the shadow
                  ),
                ],
              ),
              child: Image.asset(
                'images/requests.png'
                // 'images/checklist.png'
                ,
                fit: BoxFit.fitHeight,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: screenWidth * .15, top: 10),
              child: Column(
                children: [
                  Text(
                    "Doctor's Requests",
                    style: GoogleFonts.lora(
                      textStyle: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: mainColor,
                        shadows: [
                          Shadow(
                            blurRadius: 5.0,
                            color: mainColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * .27,
                    // 400, // Set your desired width
                    height: 40, // Set your desired height
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: mainColor,
                            width: 2.0,
                          ),
                        ),
                        icon: Icon(
                          Icons.search,
                          color: mainColor,
                        ),
                      ),
                      onChanged: (query) {
                        filterDoctors(query);
                      },
                    ),
                  ),
                  // ),
                  requests.length == 0
                      ? Padding(
                          padding: const EdgeInsets.all(20),
                          child: Center(
                            child: Text('There are no requests yet.',
                                style: GoogleFonts.lora(
                                  textStyle: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    color: mainColor,
                                  ),
                                )),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(top: 20, bottom: 10),
                          child: Expanded(
                            child: Container(
                              width: MediaQuery.of(context).size.width * .40,
                              height: MediaQuery.of(context).size.height - 183,
                              child: ListView.builder(
                                itemCount: filteredRequests.length,
                                itemBuilder: (context, index) {
                                  return Card(
                                    color: Colors.white,
                                    elevation: 2.3,
                                    shadowColor: mainColor,
                                    //.fromARGB(197, 201, 237, 244),
                                    child: ListTile(
                                      onTap: () {
                                        setState(() {
                                          isgetinfo[index] = !isgetinfo[index];
                                        });
                                      },
                                      title: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                filteredRequests[index]
                                                    ['name']!,
                                                style: GoogleFonts.lora(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.bold,
                                                  color: mainColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                filteredRequests[index]
                                                    ['category']!,
                                                style: GoogleFonts.lora(
                                                    fontSize: 13,
                                                    // fontWeight: FontWeight.bold,
                                                    color: Colors.grey[700]
                                                    //mainColor,
                                                    ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                      subtitle: isgetinfo[index]
                                          ? Column(
                                              children: [
                                                Column(
                                                  children: [
                                                    Divider(),
                                                    Row(
                                                      children: [
                                                        IconButton(
                                                          icon:
                                                              Icon(Icons.email),
                                                          color: Color.fromARGB(
                                                              255, 4, 52, 61),
                                                          iconSize:
                                                              19.0, // Use a double value for size
                                                          onPressed: () {
                                                            // Your onPressed logic goes here
                                                          },
                                                        ),
                                                        SizedBox(
                                                          width: 5,
                                                        ),
                                                        Text(
                                                          filteredRequests[
                                                              index]['email']!,
                                                          style:
                                                              GoogleFonts.lora(
                                                            fontSize: 13,
                                                            color: Colors
                                                                .grey[700],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    IconButton(
                                                      icon: Icon(
                                                          Icons.location_on),
                                                      color: Color.fromARGB(
                                                          213, 4, 52, 61),
                                                      iconSize:
                                                          19.0, // Use a double value for size
                                                      onPressed: () {
                                                        try {
                                                          print(
                                                              "Location Map: ${filteredRequests[index]['locationMap']}");
                                                          var data2;
                                                          setState(() {
                                                            data2 = [
                                                              {
                                                                "name":
                                                                    filteredRequests[
                                                                            index]
                                                                        [
                                                                        'name'],
                                                                "locationMap": [
                                                                  filteredRequests[
                                                                          index]
                                                                      [
                                                                      'locationMap'][0],
                                                                  filteredRequests[
                                                                          index]
                                                                      [
                                                                      'locationMap'][1]
                                                                ]
                                                              },
                                                            ];
                                                          });

                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  Doc_locations(
                                                                      doctor_category:
                                                                          data2),
                                                            ),
                                                          );
                                                        } catch (e) {
                                                          print(
                                                              "Error parsing location values: $e");
                                                        }
                                                      },
                                                    ),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                      filteredRequests[index]
                                                          ['city']!,
                                                      style: GoogleFonts.lora(
                                                        fontSize: 13,
                                                        color: Colors.grey[700],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    IconButton(
                                                      icon: Icon(Icons.phone),
                                                      color: Color.fromARGB(
                                                          172, 4, 52, 61),
                                                      iconSize:
                                                          19.0, // Use a double value for size
                                                      onPressed: () {
                                                        // Your onPressed logic goes here
                                                      },
                                                    ),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                      filteredRequests[index]
                                                          ['phone']!,
                                                      style: GoogleFonts.lora(
                                                        fontSize: 13,
                                                        color: Colors.grey[700],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            )
                                          : Container(),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              Icons.done_outlined,
                                              color: Color.fromARGB(
                                                  255, 4, 52, 61), //CHECK
                                            ),
                                            onPressed: () {
                                              AwesomeDialog(
                                                  context: context,
                                                  dialogType:
                                                      DialogType.question,
                                                  animType: AnimType.scale,
                                                  title: 'Add Doctor',
                                                  desc:
                                                      'Are you sure you want to add this doctor?',
                                                  btnCancelOnPress: () {},
                                                  btnOkOnPress: () async {
                                                    var data = {
                                                      "name": filteredRequests[
                                                          index]['name'],
                                                      "email": filteredRequests[
                                                          index]['email'],
                                                      "password":
                                                          filteredRequests[
                                                                  index]
                                                              ['password'],
                                                      "phoneNumber":
                                                          filteredRequests[
                                                              index]['phone'],
                                                      "city": filteredRequests[
                                                          index]['city'],
                                                      "locationMap":
                                                          filteredRequests[
                                                                  index]
                                                              ['locationMap'],
                                                      "category":
                                                          filteredRequests[
                                                                  index]
                                                              ['categoryid']
                                                    };
                                                    final response =
                                                        await Api.adddoctor(
                                                            data);
                                                    if (response.statusCode ==
                                                        200) {
                                                      _sendEmail(
                                                          filteredRequests[
                                                              index]['email'],
                                                          true);
                                                      //add doctors to firebase
                                                      /*******************firebase ***********************/
                                                      try {
                                                        final newUser = await _auth
                                                            .createUserWithEmailAndPassword(
                                                                email: filteredRequests[
                                                                        index]
                                                                    ['email'],
                                                                password: filteredRequests[
                                                                        index][
                                                                    'password']);
                                                      } catch (e) {
                                                        print(
                                                            "error from fireBase :- ${e}");
                                                      }
                                                      /************************************************ */
                                                      final response2 = await Api
                                                          .deleterequestbyid(
                                                              filteredRequests[
                                                                  index]['id']);
                                                      if (response2
                                                              .statusCode ==
                                                          200) {
                                                        setState(() {
                                                          filteredRequests
                                                              .removeAt(index);
                                                          requests
                                                              .removeAt(index);
                                                        });
                                                      }
                                                    }

                                                    /**************************************************/
                                                  },
                                                  btnCancelColor:
                                                      Color.fromARGB(
                                                          255, 32, 87, 97),
                                                  btnOkColor: Color.fromARGB(
                                                      255, 56, 154, 171),
                                                  descTextStyle: TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 32, 87, 97),
                                                  ),
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.45)
                                                ..show();
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.close,
                                              color: mainColor,
                                            ),
                                            onPressed: () {
                                              AwesomeDialog(
                                                context: context,
                                                dialogType: DialogType.question,
                                                animType: AnimType.scale,
                                                title: 'Delete Doctor',
                                                desc:
                                                    'Are you sure you want to delete this doctor?',
                                                btnCancelOnPress: () {},
                                                btnOkOnPress: () async {
                                                  _sendEmail(
                                                      filteredRequests[index]
                                                          ['email'],
                                                      false);
                                                  final response2 = await Api
                                                      .deleterequestbyid(
                                                          filteredRequests[
                                                              index]['id']);
                                                  if (response2.statusCode ==
                                                      200) {
                                                    setState(() {
                                                      filteredRequests
                                                          .removeAt(index);
                                                      requests.removeAt(index);
                                                    });
                                                  }
                                                },
                                                btnCancelColor: Color.fromARGB(
                                                    255, 32, 87, 97),
                                                btnOkColor: Color.fromARGB(
                                                    255, 56, 154, 171),
                                                descTextStyle: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 32, 87, 97),
                                                ),
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.45,
                                              )..show();
                                            },
                                          ),
                                          IconButton(
                                            icon: isgetinfo[index]
                                                ? Icon(
                                                    Icons
                                                        .keyboard_arrow_up_outlined,
                                                    color: Colors.grey[800],
                                                  )
                                                : Icon(
                                                    Icons
                                                        .keyboard_arrow_down_outlined,
                                                    color: Colors.grey[800],
                                                  ),
                                            onPressed: () {
                                              setState(() {
                                                isgetinfo[index] =
                                                    !isgetinfo[index];
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              //  ),
                            ),
                            //  ),
                            //   ),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
      //   ),
    );
  }
}
