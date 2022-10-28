import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hearppl/constants.dart';
import 'package:hearppl/register.dart';
import 'package:hearppl/topics.dart';
import 'package:intro_slider/intro_slider.dart';

class Intros extends StatefulWidget {
  @override
  _IntrosState createState() => _IntrosState();
}

class _IntrosState extends State<Intros> {
  Constants c = Constants();
  final _formKey = GlobalKey<FormState>();
  List? data;
  TextEditingController email = TextEditingController();
  TextEditingController pwd = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSubmitted = false;
  // Response? form_response;

  bool hide_password = true;
  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: AutoSizeText(value,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: c.getFontSizeLabel(context),
              fontFamily: c.fontFamily(),
              color: Colors.white)),
      duration: Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      elevation: 5.0,
    ));
  }

  List<ContentConfig> listContentConfig = [];
  var close = 0;
  Future<bool> _exitApp(BuildContext context) async {
    if (close == 0) {
      showInSnackBar("Press back again to close app");
      close++;
    } else {
      exit(0);
    }
    return Future.value(false);
  }

  void initState() {
    super.initState();

    listContentConfig.add(
      const ContentConfig(
        description:
            "Hearppl enables people to share videos about the latest events happening in and around them so that people can see and hear real news straight from the source.",
        pathImage: "assets/slider-3.png",
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        styleDescription: TextStyle(
          color: Colors.black,
          fontSize: 20,
          height: 1.8,
        ),
        textAlignDescription: TextAlign.center,
      ),
    );
    listContentConfig.add(
      const ContentConfig(
        description:
            "No manipulated media, no ads, just plain news from people on the ground direct to your phones. Simply add #YOURTOPIC with @LOCATION and upload it for other people to watch and hear in one click ",
        pathImage: "assets/slider-4.png",
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        styleDescription: TextStyle(
          color: Colors.black,
          fontSize: 20,
          height: 1.8,
        ),
        textAlignDescription: TextAlign.center,
      ),
    );
    listContentConfig.add(
      const ContentConfig(
        description:
            "Still wondering how to begin. Don't worry; choose the topics that interest you the most on the next screen and begin your journey of Hearing from the People.",
        pathImage: "assets/slider-5.png",
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        styleDescription: TextStyle(
          color: Colors.black,
          fontSize: 20,
          height: 1.8,
        ),
        textAlignDescription: TextAlign.center,
      ),
    );
  }

  void onDonePress() {
    print("End of slides");
    Navigator.pop(context);
    Navigator.push(context, CupertinoPageRoute(builder: (context) => Topics()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: WillPopScope(
        onWillPop: () => _exitApp(context),
        child: SafeArea(
            child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: IntroSlider(
            key: UniqueKey(),
            listContentConfig: listContentConfig,
            onDonePress: onDonePress,
          ),
        )),
      ),
    );
  }
}
