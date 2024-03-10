import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localstorage/localstorage.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:untitled/MessagesHomeScreen.dart';
import 'package:untitled/model/doctor.dart';
import 'package:untitled/servicies/api.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class UserEditAppointment extends StatefulWidget {
  final String doctorinfo;
  final String userid;
  final String appoinmentid;

  const UserEditAppointment(
      {required this.doctorinfo,
      required this.userid,
      required this.appoinmentid});

  @override
  BookAppointment createState() => BookAppointment();
}

class BookAppointment extends State<UserEditAppointment> {
  late DateTime today = DateTime.now(); // Initialize DateTime
  late DateTime todayy = DateTime.now();
  List Times = [];
  Doctor doctor = Doctor();
  bool isOpen = true;
  List<bool> timeEnable = List.filled(100, false);
  String selectday = 'Sunday';

  Future<void> checkopen(String selectedDay) async {
    //  });
    setState(() {
      isOpen = false;
      for (int i = 0; i < doctor.workingDays!.length; i++) {
        if (doctor.workingDays?[i] == selectedDay) {
          isOpen = true;
          break;
        }
      }
      if (isOpen == false) {
        print('Close in $selectedDay');
      }
    });
  }

  var token = "";
  int appointmentTime = 30;
  void getinfo() async {
    List<Map<String, String>> filteredReservations = [];
    print("Initializing Appiontment");
    Map<String, dynamic> parsedJson = json.decode(widget.doctorinfo);
    setState(() {
      doctor.id = parsedJson['user']['_id'];
      doctor.name = parsedJson['user']['name'];
      doctor.email = parsedJson['user']['email'];
      doctor.startTime = parsedJson['user']['StartTime'];
      doctor.endTime = parsedJson['user']['EndTime'];
      doctor.workingDays = List<String>.from(parsedJson['user']['WorkingDays']);
      token = parsedJson['user']['token'];
      appointmentTime = parsedJson['user']['appointmentTime'] as int;
      print("OOOPPPEINING TIMEEE---->${doctor.startTime}");
    });
    final DateFormat timeFormat = DateFormat('hh:mm a');
    final String start = doctor.startTime ?? "8:00 AM";
    final String end = doctor.endTime ?? "2:00 PM";

    final DateTime startTime = timeFormat.parse(start);
    final DateTime endTime = timeFormat.parse(end);

    List<String> timeIntervals = [];

    DateTime currentTime = startTime;
    final Duration increment = Duration(minutes: appointmentTime);
    setState(() {
      Times.clear();
      int dayOfWeek = today.weekday;
      String dayName = getDayName(dayOfWeek);
      checkopen(dayName);
      selectday = dayName;
      print("day is $dayName");
      if (isOpen) {
        while (currentTime.isBefore(endTime) ||
            currentTime.isAtSameMomentAs(endTime)) {
          timeIntervals.add(timeFormat.format(currentTime));
          currentTime = currentTime.add(increment);
        }
      }
    });
    if (isOpen) {
      int i = 0;
      for (String time in timeIntervals) {
        String selectedDate = DateFormat('yyyy-MM-dd').format(today);
        var data = {"appointmentTime": time, "appointmentDate": selectedDate};
        final res = await Api.timesapointment(data, widget.userid, doctor.id!);
        print("Response -> ${res.body}");
        if (res.statusCode == 400) {
          print("Have appointment, skipping...");
        } else if (res.statusCode == 200) {
          ////////////////////////----------------*************---------------/////////=========
          final resp = await Api.getdoctorappointment(doctor.id!);
          if (res.statusCode == 200) {
            List<dynamic> parsedJsonList = json.decode(resp.body);
            int ii = 0;
            bool accept = true;
            for (var parsedJson in parsedJsonList) {
              String temp = parsedJson['user'];
              print('useridpatient is $temp');
              setState(() {
                filteredReservations.add({
                  "id": parsedJson['_id'],
                  "date": parsedJson['appointmentDate'],
                  "time": parsedJson['appointmentTime'],
                  "userid": parsedJson['user'],
                  "appointmentPeriod":
                      parsedJson['appointmentPeriod'].toString(),
                });

                if (filteredReservations[ii]['date'] == selectedDate &&
                    isTimeOverlapping(
                        filteredReservations[ii]['time']!,
                        int.parse(
                            filteredReservations[ii]['appointmentPeriod']!),
                        time,
                        appointmentTime,
                        selectedDate)) {
                  setState(() {
                    accept = false;
                  });
                }
                ii++;
              });
            }
            if (accept) {
              setState(() {
                List<String> timeParts = time.split(" ");
                List<String> hourMinute = timeParts[0].split(":");
                int customHour = int.tryParse(hourMinute[0]) ?? 0;
                int customMinute = int.tryParse(hourMinute[1]) ?? 0;
                String amPm = timeParts[1];

                // Convert to 24-hour format
                if (amPm.toLowerCase() == 'pm' && customHour < 12) {
                  customHour += 12;
                } else if (amPm.toLowerCase() == 'am' && customHour == 12) {
                  customHour = 0;
                }
                DateTime currentTimee = DateTime.now();
                // Create a custom time
                DateTime customTime = DateTime(
                  today.year,
                  today.month,
                  today.day,
                  customHour,
                  customMinute,
                );
                // Compare the custom time with the current time
                if (customTime.isBefore(currentTimee)) {
                  timeEnable[i] = true;
                  print("The custom time is before the current time.");
                } else if (customTime.isAfter(currentTimee)) {
                  print("The custom time is after the current time.");
                } else {
                  print("The custom time is the same as the current time.");
                }
                i++;
                Times.add(time);
                print("--> " + time);
              });
            }
          }
        }
      }
    }
  }

  final LocalStorage storage = new LocalStorage('my_data');

  Map<String, dynamic>? getUserData() {
    // Get the existing data from LocalStorage
    Map<String, dynamic>? existingData = storage.getItem('user_data_new');

    return existingData;
  }

  // Retrieve user data
  String emailUser = "";
  String nameUser = "";
  @override
  void initState() {
    super.initState();
    setState(() {
      Map<String, dynamic>? userData = getUserData();

      if (userData != null) {
        // Do something with the user data
        setState(() {
          emailUser = userData['email'];
          nameUser = userData['name'];
        });
      }
      timeEnable = List.filled(100, false);
      today = DateTime.now();
      int dayOfWeek = today.weekday;
      String dayName = getDayName(dayOfWeek);
      selectday = dayName;
      print("day is $dayName");

      // Set the current date as the initial date
      // Initialize user data with default values
      getinfo();
    });
  }

  DateTime parseTimeString(String timeString, String format) {
    return DateFormat(format).parse(timeString);
  }

  bool isTimeOverlapping(String startTime1, int duration1, String startTime2,
      int duration2, String date) {
    //String date = filteredReservations[index]['date']!;

    DateTime dateTime1 =
        parseTimeString("$date $startTime1", "yyyy-MM-dd hh:mm a");
    DateTime endTime1 = dateTime1.add(Duration(minutes: duration1));

    DateTime dateTime2 =
        parseTimeString("$date $startTime2", "yyyy-MM-dd hh:mm a");
    DateTime endTime2 = dateTime2.add(Duration(minutes: duration2));

    return dateTime1.isBefore(endTime2) && endTime1.isAfter(dateTime2);
  }

  void _onDaySelected(DateTime day, DateTime focusedDay) async {
    List<Map<String, String>> filteredReservations = [];

    final DateFormat timeFormat = DateFormat('hh:mm a');
    final String start = doctor.startTime ?? "8:00 AM";
    final String end = doctor.endTime ?? "2:00 PM";

    final DateTime startTime = timeFormat.parse(start);
    final DateTime endTime = timeFormat.parse(end);

    List<String> timeIntervals = [];

    DateTime currentTime = startTime;
    final Duration increment = Duration(minutes: appointmentTime);
    setState(() {
      Times.clear();
      int dayOfWeek = day.weekday;
      String dayName = getDayName(dayOfWeek);
      checkopen(dayName);
      selectday = dayName;
      print("day is $dayName");
      if (day.isBefore(todayy)) {
        day = today; // Set the selected day to todaynow if it's before todaynow
      }
      today = day;
      if (isOpen) {
        while (currentTime.isBefore(endTime) ||
            currentTime.isAtSameMomentAs(endTime)) {
          timeIntervals.add(timeFormat.format(currentTime));
          currentTime = currentTime.add(increment);
        }
      }
    });
    if (isOpen) {
      int i = 0;
      timeEnable = List.filled(100, false);
      for (String time in timeIntervals) {
        String selectedDate = DateFormat('yyyy-MM-dd').format(today);
        var data = {"appointmentTime": time, "appointmentDate": selectedDate};
        final res = await Api.timesapointment(data, widget.userid, doctor.id!);
        print("Response -> ${res.body}");
        if (res.statusCode == 400) {
          print("Have appointment, skipping...");
        } else if (res.statusCode == 200) {
          ////////////////////////----------------*************---------------/////////=========
          final resp = await Api.getdoctorappointment(doctor.id!);
          if (res.statusCode == 200) {
            List<dynamic> parsedJsonList = json.decode(resp.body);
            int ii = 0;
            bool accept = true;
            for (var parsedJson in parsedJsonList) {
              String temp = parsedJson['user'];
              print('useridpatient is $temp');
              setState(() {
                filteredReservations.add({
                  "id": parsedJson['_id'],
                  "date": parsedJson['appointmentDate'],
                  "time": parsedJson['appointmentTime'],
                  "userid": parsedJson['user'],
                  "appointmentPeriod":
                      parsedJson['appointmentPeriod'].toString(),
                });

                if (filteredReservations[ii]['date'] == selectedDate &&
                    isTimeOverlapping(
                        filteredReservations[ii]['time']!,
                        int.parse(
                            filteredReservations[ii]['appointmentPeriod']!),
                        time,
                        appointmentTime,
                        selectedDate)) {
                  setState(() {
                    accept = false;
                  });
                }
                ii++;
              });
            }
            if (accept) {
              setState(() {
                List<String> timeParts = time.split(" ");
                List<String> hourMinute = timeParts[0].split(":");
                int customHour = int.tryParse(hourMinute[0]) ?? 0;
                int customMinute = int.tryParse(hourMinute[1]) ?? 0;
                String amPm = timeParts[1];

                // Convert to 24-hour format
                if (amPm.toLowerCase() == 'pm' && customHour < 12) {
                  customHour += 12;
                } else if (amPm.toLowerCase() == 'am' && customHour == 12) {
                  customHour = 0;
                }
                DateTime currentTimee = DateTime.now();
                // Create a custom time
                DateTime customTime = DateTime(
                  focusedDay.year,
                  focusedDay.month,
                  focusedDay.day,
                  customHour,
                  customMinute,
                );

                // Compare the custom time with the current time
                if (customTime.isBefore(currentTimee)) {
                  timeEnable[i] = true;
                  print("The custom time is before the current time.");
                } else if (customTime.isAfter(currentTimee)) {
                  print("The custom time is after the current time.");
                } else {
                  print("The custom time is the same as the current time.");
                }
                i++;
                Times.add(time);
                print("--> " + time);
              });
            }
          }
        }
      }
    }
    //  });
  }

  String getDayName(int dayOfWeek) {
    switch (dayOfWeek) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return 'Invalid day';
    }
  }

  int _selectedIndex = 0;
  static const List<IconData> _icons = [
    Icons.message_outlined,
    Icons.notifications,
    Icons.logout,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Center(
          child: Text('Booking Appointment',
              style: GoogleFonts.lora(
                textStyle: TextStyle(color: Colors.white),
              )),
        ),
        backgroundColor: Color(0xFF389AAB),
      ),
      body: Row(
        children: [
          Expanded(
              flex: 2,
              child: Image.asset(
                "images/appointmentsTest.png",
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.scaleDown,
              )),
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              // Wrap content in a SingleChildScrollView
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 50),
                child: Column(
                  children: [
                    //   showDatePicker(context: context, initialDate: DateTime.utc(2023), firstDate: DateTime.utc(2050), lastDate: DateTime.utc(2023)),
                    Padding(
                      padding: const EdgeInsets.all(13),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                Color.fromARGB(255, 2, 88, 101), // Border color
                            width: 2.0, // Border width
                          ),
                          borderRadius: BorderRadius.circular(
                              16.0), // Adjust the border radius as needed
                        ),
                        child: TableCalendar(
                          locale: "en_US",
                          rowHeight: 35,
                          headerStyle: HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                          ),
                          availableGestures: AvailableGestures.all,
                          selectedDayPredicate: (day) => isSameDay(day, today),
                          onDaySelected: _onDaySelected,
                          focusedDay: today,
                          firstDay: DateTime.utc(2023),
                          lastDay: DateTime.utc(2050),
                          calendarStyle: CalendarStyle(
                            // To change the background color of the calendar
                            todayDecoration: BoxDecoration(
                              color: Color.fromARGB(193, 56, 154, 171),
                              shape: BoxShape.circle,
                            ),
                            selectedDecoration: BoxDecoration(
                              color: Color.fromARGB(255, 2, 88, 101),
                              shape: BoxShape.circle,
                            ),
                            outsideDaysVisible: false,
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.more_time,
                            color: Color.fromARGB(255, 2, 88, 101),
                          ),
                          Text(
                            ' Choose Time:',
                            style: GoogleFonts.lora(
                              textStyle: TextStyle(
                                color: Color.fromARGB(255, 2, 88, 101),
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height - 450,
                      child: Column(
                        children: [
                          isOpen
                              ? Expanded(
                                  child: GridView.builder(
                                    shrinkWrap: true,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount:
                                          MediaQuery.of(context).size.width >
                                                  600
                                              ? 5
                                              : 3,
                                      crossAxisSpacing:
                                          MediaQuery.of(context).size.width *
                                              .01,
                                      mainAxisSpacing:
                                          MediaQuery.of(context).size.width * 0,
                                      childAspectRatio: 2,
                                      //
                                    ),
                                    itemCount: Times.length,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 1, vertical: 8),
                                    itemBuilder: (context, i) {
                                      return GestureDetector(
                                          child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            print(
                                                "Iss Unenable ? ${timeEnable[i]}");
                                            if (lastSelectedIndex != -1) {
                                              isSelectedList[
                                                      lastSelectedIndex] =
                                                  false; // Clear the previous selection
                                            }
                                            isSelectedList[i] =
                                                true; // Set the current box as selected
                                            lastSelectedIndex =
                                                i; // Update the last selected index
                                            lastSelectedTimeLabel =
                                                Times[lastSelectedIndex];
                                            if (timeEnable[i]) {
                                              print(i);
                                              isSelectedList[i] = false;
                                            }
                                          });
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(5),
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
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: isSelectedList[i]
                                                  ? Color.fromARGB(
                                                      255, 2, 88, 101)
                                                  : Color(0xFFF2F8FF),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: !timeEnable[i]
                                                      ? Color(0xFF389AAB)
                                                      : Color.fromARGB(
                                                          111, 60, 78, 81),
                                                  // Color(0xFF389AAB),
                                                  blurRadius: 4,
                                                  spreadRadius: 2,
                                                ),
                                              ],
                                            ),
                                            child: Container(
                                              padding: EdgeInsets.only(
                                                  right: 8, left: 8),
                                              child: Row(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    child: Text(
                                                      Times[i],
                                                      style: GoogleFonts.lora(
                                                        textStyle: TextStyle(
                                                          fontSize: 17,
                                                          color: isSelectedList[
                                                                  i]
                                                              ? Colors.white
                                                              : !timeEnable[i]
                                                                  ? Color(
                                                                      0xFF389AAB)
                                                                  : Color
                                                                      .fromARGB(
                                                                          111,
                                                                          60,
                                                                          78,
                                                                          81),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ));
                                    },
                                  ),
                                )
                              : Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        "There is no appointments this day",
                                        style: GoogleFonts.lora(
                                          textStyle: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF389AAB),
                                            shadows: [
                                              Shadow(
                                                blurRadius: 4.0,
                                                color: Color(0xFF389AAB),
                                                offset: Offset(
                                                  MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.002,
                                                  MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.002,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        "The Clinic on $selectday is closed",
                                        style: GoogleFonts.lora(
                                          textStyle: TextStyle(
                                            fontSize: 17,
                                            color: Color(0xFF389AAB),
                                            shadows: [
                                              Shadow(
                                                blurRadius: 5.0,
                                                color: Color.fromARGB(
                                                    0, 56, 154, 171),
                                                offset: Offset(
                                                  MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.002,
                                                  MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.002,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                          isOpen
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                      left: 18, right: 18),
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Color(0xFF389AAB)),
                                    ),
                                    child: Text(
                                      'Edit Appointment',
                                      style: GoogleFonts.lora(
                                        textStyle: TextStyle(
                                            fontSize: 17, color: Colors.white),
                                      ),
                                    ),
                                    onPressed: () async {
                                      if (lastSelectedIndex != -1 &&
                                          isSelectedList[lastSelectedIndex]) {
                                        String selecteddate =
                                            DateFormat('yyyy-MM-dd')
                                                .format(today);
                                        var data = {
                                          "appointmentTime":
                                              lastSelectedTimeLabel,
                                          "appointmentDate": selecteddate,
                                          "appointmentPeriod": appointmentTime
                                        };
                                        final response =
                                            await Api.addapointment(data,
                                                widget.userid, doctor.id ?? '');

                                        if (response.statusCode == 200) {
                                          DateTime now = DateTime.now();
                                          int hour = now.hour;
                                          String currentTime;
                                          if (hour < 12) {
                                            currentTime =
                                                "$hour:${now.minute} AM";
                                          } else {
                                            currentTime =
                                                "${hour - 12}:${now.minute} PM";
                                          }

                                          String time = lastSelectedTimeLabel;
                                          String date = selecteddate;

                                          // Combine date and time into a single string

                                          String combinedDateTimeString =
                                              "$date $time";

                                          // Use DateTime.parse to convert the combined string to a DateTime object
                                          DateTime dateTime = DateFormat(
                                                  "yyyy-MM-dd hh:mm a")
                                              .parse(combinedDateTimeString);

                                          // Subtract 30 minutes
                                          DateTime thirtyMinutesBefore =
                                              dateTime.subtract(
                                                  Duration(minutes: 30));

                                          // Print the original and adjusted times
                                          print("Original Time: $dateTime");

                                          print(
                                              "Time 30 Minutes Before: $thirtyMinutesBefore");
                                          String befor30minTime;
                                          if (thirtyMinutesBefore.hour < 12) {
                                            befor30minTime =
                                                "${thirtyMinutesBefore.hour}:${thirtyMinutesBefore.minute} AM";
                                          } else {
                                            befor30minTime =
                                                "${thirtyMinutesBefore.hour - 12}:${thirtyMinutesBefore.minute} PM";
                                          }
                                          final ress =
                                              await Api.deleteppointmentbyid(
                                                  widget.appoinmentid);
                                          var data = {
                                            "useremail": emailUser,
                                            "content":
                                                // Your appointment with ${doctor.name} has been changed to ${selectday} at ${selecteddate} $lastSelectedTimeLabel
                                                "Reminder: Your appointment with ${doctor.name} has been changed to ${selectday} at ${selecteddate} $lastSelectedTimeLabel",
                                            "title": "Appointment Update",
                                            "date": currentTime, // time to send
                                            "read": false,
                                            "onTime": true,
                                            "dateTime":
                                                DateTime.now() //send now
                                          };
                                          var data2 = {
                                            "useremail": emailUser,
                                            "content":
                                                "Your appointment with ${doctor.name} is on ${selectday} at ${selecteddate} $lastSelectedTimeLabel",
                                            "title":
                                                "Reminder you have an appointment after a few minutes",
                                            "date":
                                                befor30minTime, // time to send "before 30 minutes of the appointment"
                                            "read": false,
                                            "onTime": false,
                                            "dateTime":
                                                thirtyMinutesBefore // send before 30 minutes of the appointment
                                          };
                                          var data3 = {
                                            "useremail": doctor.email,
                                            "content":
                                                "You have a reservation with ${nameUser} has been changed to ${selectday} at ${selecteddate} $lastSelectedTimeLabel.",
                                            "title": "Appointment Update",
                                            "date":
                                                currentTime, // time to send "before 30 minutes of the appointment"
                                            "read": false,
                                            "onTime": true,
                                            "dateTime": DateTime
                                                .now(), // send before 30 minutes of the appointment
                                          };
                                          //  final res = await Api.addNotification(data);
                                          var serverToken =
                                              "AAAAjxD3gc0:APA91bHJ7Wk4v_wxhhTe93vwHi78rfrZf7VOxWNp6BY7Z-bDOb8fA3Z-jfLpNPpHXqnJu8SO7KYGf06zUWpvWMbi6J_4k7-mSQT1QVbH59bOFhw8IVudg6vs-vZZpM485SyJMd7KrGeZ";
                                          await http.post(
                                            Uri.parse(
                                                'https://fcm.googleapis.com/fcm/send'),
                                            headers: <String, String>{
                                              'Content-Type':
                                                  'application/json',
                                              'Authorization':
                                                  'key=$serverToken',
                                            },
                                            body: jsonEncode(
                                              <String, dynamic>{
                                                'notification':
                                                    <String, dynamic>{
                                                  'body':
                                                      "You have a new reservation with ${nameUser} booked for ${selectday} at ${selecteddate} $lastSelectedTimeLabel.",
                                                  'title':
                                                      'You have an appointment'
                                                },
                                                'priority': 'high',
                                                'data': <String, dynamic>{
                                                  'click_action':
                                                      'FLUTTER_NOTIFICATION_CLICK',
                                                  'id': widget.userid,
                                                  "Doctor": doctor.name,
                                                  'status': 'done',
                                                  'body':
                                                      "You have a new reservation with ${nameUser} booked for ${selectday} at ${selecteddate} $lastSelectedTimeLabel.",
                                                  'title':
                                                      'You have an appointment'
                                                },
                                                'to': token
                                                //"dgG3ikHDSxiQGs68SclTuI:APA91bEG7lmQ_UvIiR_hAJnQLGWCwLC84_WDT8iQ0TXzX1sqF1h8bI4NTfww0CjtavIb18sNhu6aZoUMXXlNXLbwld181N2uMajSme3_MALMv0u9y8VwmWBUMs5ZPe7oeczlUZBaOLdl",
                                              },
                                            ),
                                          );
                                          FirebaseFirestore.instance
                                              .collection('notifications')
                                              .add(data)
                                              .then(
                                                  (DocumentReference document) {
                                            print(
                                                'Notification added with ID: ${document.id}');
                                          }).catchError((error) {
                                            print(
                                                'Error adding notification: $error');
                                          });
                                          FirebaseFirestore.instance
                                              .collection('notifications')
                                              .add(data2)
                                              .then(
                                                  (DocumentReference document) {
                                            print(
                                                'Notification added with ID: ${document.id}');
                                          }).catchError((error) {
                                            print(
                                                'Error adding notification: $error');
                                          });
                                          FirebaseFirestore.instance
                                              .collection('notifications')
                                              .add(data3)
                                              .then(
                                                  (DocumentReference document) {
                                            print(
                                                'Notification added with ID: ${document.id}');
                                          }).catchError((error) {
                                            print(
                                                'Error adding notification: $error');
                                          });
                                          AwesomeDialog(
                                            width: 500,
                                            context: context,
                                            dialogType: DialogType.SUCCES,
                                            animType: AnimType.BOTTOMSLIDE,
                                            title: 'Success',
                                            desc:
                                                'Book on date $selecteddate in Time $lastSelectedTimeLabel',
                                            btnOkOnPress: () {},
                                            btnOkText: 'Okay',
                                            btnOkColor: Color.fromARGB(
                                                193, 56, 154, 171),
                                          )..show();
                                          setState(() {
                                            isSelectedList[lastSelectedIndex] =
                                                false;
                                            Times.removeAt(lastSelectedIndex);
                                          });
                                        } else if (response.statusCode == 400) {
                                          Map<String, dynamic> parsedJson =
                                              json.decode(response.body);

                                          AwesomeDialog(
                                            width: 500,
                                            context: context,
                                            dialogType: DialogType.WARNING,
                                            animType: AnimType.BOTTOMSLIDE,
                                            title: 'WARNING!!',
                                            desc: parsedJson['error'],
                                            btnOkOnPress: () {},
                                            btnOkText: 'Okay',
                                            btnOkColor: Color.fromARGB(
                                                193, 56, 154, 171),
                                          )..show();
                                        } else {
                                          AwesomeDialog(
                                            width: 500,
                                            context: context,
                                            dialogType: DialogType.ERROR,
                                            animType: AnimType.BOTTOMSLIDE,
                                            title: 'ERROR',
                                            desc: response.body,
                                            btnOkOnPress: () {},
                                            btnOkText: 'Okay',
                                            btnOkColor: Color.fromARGB(
                                                193, 56, 154, 171),
                                          )..show();
                                        }

                                        print(
                                            "Book on date $today in Time $lastSelectedTimeLabel");
                                      } else {
                                        AwesomeDialog(
                                          width: 500,
                                          context: context,
                                          dialogType: DialogType.WARNING,
                                          animType: AnimType.BOTTOMSLIDE,
                                          title: 'No Time!',
                                          desc: "Please specify a time",
                                          btnOkOnPress: () {},
                                          btnOkText: 'Okay',
                                          btnOkColor:
                                              Color.fromARGB(193, 56, 154, 171),
                                        )..show();
                                      }
                                    },
                                  ),
                                )
                              : Container()
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

  List<bool> isSelectedList = List.filled(100, false);
  int lastSelectedIndex = -1; // Initialize with an invalid index
  List<String> timeLabel = List.filled(15, '');
  late String lastSelectedTimeLabel;
}
