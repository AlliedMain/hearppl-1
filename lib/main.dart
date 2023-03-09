import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/services.dart';
import 'package:hearppl/constants.dart';
import 'package:hearppl/home.dart';
import 'package:hearppl/intros.dart';
import 'package:hearppl/login.dart';
import 'package:hearppl/topics.dart';

late List<CameraDescription> cameras;
void main() async { 
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  Constants c = new Constants();
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hearppl',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: c.fontFamily()),
      home: const MyHomePage(title: 'Hearppl One Click News'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // ALL Dynamic Calls
  Response? form_response;
  posts() async {
    try {
      var dio = Dio();
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        FormData formData = new FormData.fromMap({
          "getAllPosts": "getAllPosts",
          "getAllPosts": "getAllPosts",
          "getAllPosts": "getAllPosts",
          "getAllPosts": "getAllPosts",
        });
        try {
          form_response = await dio.post(
            c.getURL() + 'posts.php',
            data: formData,
          );
        } on DioError catch (e) {
          print(e.message);
        }
        c.setshared("posts", form_response.toString());
      }
    } catch (e, s) {
      print("Error " + e.toString() + " Stack " + s.toString());
    }
  }

  category() async {
    try {
      var dio = Dio();
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        FormData formData = new FormData.fromMap({
          "topics_details": "topics_details",
        });
        try {
          form_response = await dio.post(
            c.getURL() + '/topics.php',
            data: formData,
          );
        } on DioError catch (e) {
          print(e.message);
        }
        c.setshared("topics", form_response.toString());
      }
    } catch (e, s) {
      print("Error " + e.toString() + " Stack " + s.toString());
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    posts();
    category();
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pop(context);
      c.getshared("user_id").then((value) {
        if (value != '' && value != null && value != ' ' && value != 'null') {
          Navigator.push(
              context, CupertinoPageRoute(builder: (context) => Home()));
        } else {
          Navigator.push(
              context, CupertinoPageRoute(builder: (context) => LoginPage()));
        }
      });
    });
  }

  Constants c = Constants();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/bg.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              // color: Colors.white,
              child: FadeIn(
                child: Image.asset("assets/Hearppl-logo.gif"),
              ),
            )),
      ),
    );
  }
}
