import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:localstorage/localstorage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:untitled/Admin/AdminHomePage.dart';
import 'package:untitled/Admin/AllUsers.dart';
import 'package:untitled/Profile/doctorprofile.dart';
import 'package:untitled/Profile/userprofile.dart';
import 'package:untitled/maps/map.dart';
import 'package:untitled/model/doctor.dart';
import 'package:untitled/servicies/api.dart';

class Doctorss extends StatefulWidget {
  const Doctorss({Key? key}) : super(key: key);

  @override
  State<Doctorss> createState() => _DoctorssState();
}

class _DoctorssState extends State<Doctorss> {
  Color customColor = const Color(0xFFBBF1FA);
  Color mainColor = const Color(0xFF389AAB);
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

  List<Map<String, dynamic>> doctors = [];

  List<Map<String, dynamic>> filteredDoctors = [];
  //late List<bool> getinfo;
  List specialtyList = [
    "Cosmetic dentist",
    "Pediatric dentist",
    "Dental neurologist",
    "Dental Surgeon",
    "Orthodontist",
  ];
  String specialtyChose = "Cosmetic dentist";
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
          profileImg: parsedJson2['ProfileImg'],
          category: category,
        );

        doctors2.add(doctor);
      }
      for (Doctor doctor in doctors2) {
        print("Doctor Name: ${doctor.name}");
        Map<String, dynamic> doctorMap = {
          "id": doctor.id,
          "name": doctor.name,
          "category": doctor.category,
          "email": doctor.email,
          "location": doctor.locationMap,
          "city": doctor.city,
          "phone": doctor.phoneNumber
        };
        setState(() {
          doctors.add(doctorMap);
          filteredDoctors.add(doctorMap);
        });
      }
      for (var doctor in doctors) {
        print("Doctorss Name: ${doctor['name']}");
      }
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      //   filteredDoctors = doctors;
      getinfo();
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
          final category = doctor['category'].toLowerCase();
          final phone = doctor['phone'].toLowerCase();
          final email = doctor['email'].toLowerCase();
          final city = doctor['city'].toLowerCase();
          return name.contains(query.toLowerCase()) ||
              category.contains(query.toLowerCase()) ||
              phone.contains(query.toLowerCase()) ||
              email.contains(query.toLowerCase()) ||
              city.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                Navigator.pushNamed(context, "Messages");
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
                Navigator.pushNamed(context, "Messages");
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
      body: /* SingleChildScrollView(
          child: */
          Container(
        child: Padding(
          padding: const EdgeInsets.only(top: 0),
          child: Row(
            //  mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    //   top: MediaQuery.of(context).size.height * 0.5,
                    ),
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withOpacity(0.2), // Customize the shadow color
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset:
                            Offset(0, 3), // Adjust the position of the shadow
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'images/left2.png',
                    fit: BoxFit.fitHeight,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                      //  top: MediaQuery.of(context).size.height * 0.5,
                      left: 20,
                      top: 10),
                  child: Column(
                    children: [
                      Text(
                        "All Doctors",
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
                        width: 400, // Set your desired width
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
                      /*  SizedBox(
                        height: 20,
                      ), */
                      Expanded(
                        child: Container(
                          child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: doctors.length == 0
                                    ? Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Center(
                                          child: Text(
                                              'There are no doctors yet.',
                                              style: GoogleFonts.lora(
                                                textStyle: TextStyle(
                                                  fontSize: 25,
                                                  fontWeight: FontWeight.bold,
                                                  color: mainColor,
                                                ),
                                              )),
                                        ),
                                      )
                                    : DataTable(
                                        columns: [
                                            DataColumn(
                                                label: Text(
                                              'Name',
                                              style: TextStyle(
                                                color: mainColor,
                                              ),
                                            )),
                                            DataColumn(
                                                label: Text('Category',
                                                    style: TextStyle(
                                                      color: mainColor,
                                                    ))),
                                            DataColumn(
                                                label: Text('Phone',
                                                    style: TextStyle(
                                                      color: mainColor,
                                                    ))),
                                            DataColumn(
                                                label: Text('Email',
                                                    style: TextStyle(
                                                      color: mainColor,
                                                    ))),
                                            DataColumn(
                                                label: Text('City',
                                                    style: TextStyle(
                                                      color: mainColor,
                                                    ))),
                                            DataColumn(
                                                label: Text('Location',
                                                    style: TextStyle(
                                                      color: mainColor,
                                                    ))),
                                            DataColumn(
                                                label: Text('Delete?',
                                                    style: TextStyle(
                                                      color: mainColor,
                                                    ))),
                                          ],
                                        rows: List<DataRow>.generate(
                                          filteredDoctors.length,
                                          (index) => DataRow(
                                            onLongPress: () async {
                                              final response =
                                                  await Api.getdoctor(
                                                      filteredDoctors[index]
                                                          ['id']);
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) {
                                                print(response.body);
                                                return Profile(
                                                    username: response.body);
                                              }));
                                              print(
                                                  'Row tapped for ${filteredDoctors[index]['name']}');
                                            },
                                            cells: [
                                              DataCell(GestureDetector(
                                                onTap: () async {
                                                  final response =
                                                      await Api.getdoctor(
                                                          filteredDoctors[index]
                                                              ['id']);
                                                  Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                          builder: (context) {
                                                    print(response.body);
                                                    return Profile(
                                                        username:
                                                            response.body);
                                                  }));
                                                  print(
                                                      'Row tapped for ${filteredDoctors[index]['name']}');
                                                },
                                                child: Text(
                                                  filteredDoctors[index]
                                                      ['name']!,
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                              )),
                                              DataCell(
                                                Text(
                                                  filteredDoctors[index]
                                                      ['category']!,
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  filteredDoctors[index]
                                                      ['phone']!,
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  filteredDoctors[index]
                                                      ['email']!,
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  filteredDoctors[index]
                                                      ['city']!,
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                              ),
                                              DataCell(
                                                GestureDetector(
                                                  onTap: () async {
                                                    final response =
                                                        await Api.getdoctor(
                                                            filteredDoctors[
                                                                index]['id']);
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              PositionMap(
                                                                  id: response
                                                                      .body,
                                                                  flag:
                                                                      "show")),
                                                    );
                                                  },
                                                  child: Text(
                                                    '${filteredDoctors[index]['location'][0]}, ${filteredDoctors[index]['location'][1]}',
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.delete,
                                                    color: mainColor,
                                                  ),
                                                  onPressed: () {
                                                    // Handle delete action
                                                    AwesomeDialog(
                                                      context: context,
                                                      dialogType:
                                                          DialogType.question,
                                                      animType: AnimType.scale,
                                                      title: 'Delete Doctor',
                                                      desc:
                                                          'Are you sure you want to delete this doctor?',
                                                      btnCancelOnPress: () {},
                                                      btnOkOnPress: () async {
                                                        final response2 = await Api
                                                            .deletedoctorbyid(
                                                                filteredDoctors[
                                                                        index]
                                                                    ['id']);
                                                        if (response2
                                                                .statusCode ==
                                                            200) {
                                                          setState(() {
                                                            filteredDoctors
                                                                .removeAt(
                                                                    index);
                                                            doctors.removeAt(
                                                                index);
                                                          });
                                                        }
                                                      },
                                                      btnCancelColor:
                                                          Color.fromARGB(
                                                              255, 32, 87, 97),
                                                      btnOkColor:
                                                          Color.fromARGB(255,
                                                              56, 154, 171),
                                                      descTextStyle: TextStyle(
                                                        color: Color.fromARGB(
                                                            255, 32, 87, 97),
                                                      ),
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.45,
                                                    )..show();
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        )),
                              )
                              // },
                              ),
                        ),
                      )

                      // ),
                    ],
                  ),
                  //  ],
                  //  ),
                ),
              ),
            ],
          ),
        ),
      ),
      //)
    );
  }
}
