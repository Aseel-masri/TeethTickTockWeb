import 'dart:js';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:untitled/BookedAppointments.dart';
import 'package:untitled/Categories.dart';
import 'package:untitled/HomePage.dart';
import 'package:untitled/Messages.dart';
import 'package:untitled/MessagesHomeScreen.dart';
import 'package:untitled/MessagesUserList.dart';
import 'package:untitled/Profile/Review.dart';
import 'package:untitled/Profile/doctorHomePage.dart';
import 'package:untitled/Quickconsultation.dart';
import 'package:untitled/SendEmail.dart';
import 'package:untitled/UserProfile.dart';
import 'package:untitled/auth/LogIn.dart';
import 'package:untitled/auth/SelectedLogIn.dart';
import 'package:untitled/auth/SignUp.dart';
import 'package:untitled/auth/SignUpDoctor.dart';
import 'package:untitled/auth/WelcomePage.dart';
import 'package:untitled/specialty.dart';
import 'package:firebase_core/firebase_core.dart';

// import 'package:untitled/auth/WelcomePage.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:untitled/auth/WelcomePage.dart';

// //run when app is terminated //in the background //send notification
// Future backgroundMessage(RemoteMessage message) async {
//   print("********************background notification");
//   print("${message.notification!.body}");
// }
var fbm = FirebaseMessaging.instance;
Future<void> _requestPermissionAndToken() async {
  NotificationSettings settings = await fbm.requestPermission();
  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    var token = await fbm.getToken(
        vapidKey:
            "BGW8CJy4uIDk9X318YCdA3OhI37lM-fnP0o28IC38wLBoDh-BikG3ZpYD3hjgQfjMsVFQ87-K7CLDy0pTezrJ8Q");
    if (token != null) {
      print("FCM Token");
    } else {
      print("Cant reach Token");
    }
    print("FCM Token: $token");
  } else {
    print("Permission denied");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await Firebase.initializeApp();
  await Firebase.initializeApp(
    options: FirebaseOptions(
        apiKey: "AIzaSyAEoB1hAn7AB6HF5FDzuu41WyqmfaKZByA",
        authDomain: "messages-app-6cf66.firebaseapp.com",
        projectId: "messages-app-6cf66",
        storageBucket: "messages-app-6cf66.appspot.com",
        messagingSenderId: "614464979405",
        appId: "1:614464979405:web:fdd24c3595495ccf96c484"),
  );
  print("==================================================");
/*   fbm.getToken(vapidKey: 'BJUcPjYUGqGvqbi10CDhU8-NqS_-EWkc4At7fLWq0PrH43V8Fn6HgKOejPBmvJ0dUymW58dJMyVA8pIRNK0ntgI').then((token){
    print(token);
  }); */
  FirebaseMessaging.instance.getToken().then(print);
  // _requestPermissionAndToken();
  print("aseel==================================================");
/*   print("==================================================");
  fbm.getToken().then((token) {
    print("token=" + token!);
  });
  print("aseel=================================================="); */
  // FirebaseMessaging.onBackgroundMessage(backgroundMessage);
  runApp(MyApp());
}

// ignore: must_be_immutable
class MyApp extends StatelessWidget {
  Color textColor = const Color(0xFFBBF1FA); // Define custom color
  Color primaryColor = const Color(0xFF389AAB); // Custom button color
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: primaryColor,
      ),
      debugShowCheckedModeBanner: false,
      home: LogIn(),
      // home: SendEmail(),
      // home: DoctorHomePage(),
      // home: BookedAppointments(),
      // home: Messages(),
      // home: MessagesUserList(),
      routes: {
        "LogIn": (context) => LogIn(),
        "SignUp": (context) => SignUp(),
        "SignUpDoctor": (context) => SignUpDoctor(),
        "HomePage": (context) => HomePage(),
        "SelectedLogin": (context) => SelectedLogin(),
        "Categories": (context) => Categories(),
        "Specialty": (context) => Specialty(),
        "Quickconsultation": (context) => Quickconsultation(),
        "BookedAppointments": (context) => BookedAppointments(),
        "Messages": (context) => Messages(),
        "UserProfile": (context) => UserProfile(),
        "DoctorHomePage": (context) => DoctorHomePage(),
        "MessagesUserList": (context) => MessagesUserList(),
        "MessagesHomeScreen": (context) => MessagesHomeScreen(),
        "SendEmail": (context) => SendEmail(),
         "Review": (context) => Review(),
      },
    );
  }
}
