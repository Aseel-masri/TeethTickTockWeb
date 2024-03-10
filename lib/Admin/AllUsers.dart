import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localstorage/localstorage.dart';
import 'package:untitled/Admin/AdminHomePage.dart';
import 'package:untitled/Admin/alldoctors.dart';
import 'package:http/http.dart' as http;
import 'package:untitled/Profile/userprofile.dart';
import 'package:untitled/servicies/api.dart';

class AllUsers extends StatefulWidget {
  const AllUsers({super.key});

  @override
  State<AllUsers> createState() => _AllUsersState();
}

class _AllUsersState extends State<AllUsers> {
  Color customColor = const Color(0xFFBBF1FA);
  Color mainColor = const Color(0xFF389AAB);
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

/************************************************************** */
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> filteredusers = [];
  Future<void> getUsers() async {
    try {
      final http.Response response = await Api.getUsers();

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        setState(() {
          users = List<Map<String, dynamic>>.from(jsonData);
          filteredusers = List<Map<String, dynamic>>.from(jsonData);
          print(users);
        });
      } else {
        // Handle the error or throw an exception
        print('Failed to load users. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network or other errors
      print('Error fetching users: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      loadUserData();
      getUsers();
      //   filteredDoctors = doctors;
      // getinfo();
    });
  }

  void filterusers(String query) {
    setState(() {
      if (query.isEmpty) {
        // If the query is empty, display all doctors
        filteredusers = List.from(users);
      } else {
        // Filter doctors based on the query
        filteredusers = users.where((user) {
          final name = user['name'].toLowerCase();
          // final category = user['category'].toLowerCase();
          final phone = user['phoneNumber'].toLowerCase();
          final email = user['email'].toLowerCase();
          final city = user['city'].toLowerCase();
          return name.contains(query.toLowerCase()) ||
              // category.contains(query.toLowerCase()) ||
              phone.contains(query.toLowerCase()) ||
              email.contains(query.toLowerCase()) ||
              city.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

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
      body: Container(
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
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "All Users",
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
                            filterusers(query);
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
                                child: users.length == 0
                                    ? Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Center(
                                          child: Text('There are no users yet.',
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
                                            // DataColumn(
                                            //     label: Text('Category',
                                            //         style: TextStyle(
                                            //           color: mainColor,
                                            //         ))),
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
                                            // DataColumn(
                                            //     label: Text('Location',
                                            //         style: TextStyle(
                                            //           color: mainColor,
                                            //         ))),
                                            DataColumn(
                                                label: Text('Delete?',
                                                    style: TextStyle(
                                                      color: mainColor,
                                                    ))),
                                          ],
                                        rows: List<DataRow>.generate(
                                          filteredusers.length,
                                          (index) => DataRow(
                                            onLongPress: () async {
                                              final response =
                                                  await Api.getuserbyid(
                                                      filteredusers[index]
                                                          ['id']);
                                              // Navigator.of(context).push(
                                              //     MaterialPageRoute(
                                              //         builder: (context) {
                                              //   print(response.body);
                                              //   return Profile(
                                              //       username: response.body);
                                              // }));
                                              print(
                                                  'Row tapped for ${filteredusers[index]['name']}');
                                            },
                                            cells: [
                                              DataCell(GestureDetector(
                                                onTap: () async {
                                                  final response =
                                                      await Api.getuserbyid(
                                                          filteredusers[index]
                                                              ['_id']);
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              ProfileUser(
                                                                userinfo:
                                                                    response
                                                                        .body,
                                                                visit: true,
                                                              )));
                                                  print(
                                                      'Row tapped for ${filteredusers[index]['name']}');
                                                },
                                                child: Text(
                                                  filteredusers[index]['name']!,
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                              )),
                                              DataCell(
                                                Text(
                                                  filteredusers[index]
                                                      ['phoneNumber']!,
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  filteredusers[index]
                                                      ['email']!,
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  filteredusers[index]['city']!,
                                                  style: TextStyle(
                                                      color: Colors.black),
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
                                                      title: 'Delete User',
                                                      desc:
                                                          'Are you sure you want to delete this user?',
                                                      btnCancelOnPress: () {},
                                                      btnOkOnPress: () async {
                                                        final response2 = await Api
                                                            .deleteUserById(
                                                                filteredusers[
                                                                        index]
                                                                    ['_id']);
                                                        if (response2
                                                                .statusCode ==
                                                            200) {
                                                          setState(() {
                                                            filteredusers
                                                                .removeAt(
                                                                    index);
                                                            users.removeAt(
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
    );
  }
}
