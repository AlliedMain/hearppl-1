import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hearppl/NoInternet.dart';
import 'package:hearppl/constants.dart';
import 'package:hearppl/home.dart';
import 'package:hearppl/intros.dart';
import 'package:hearppl/login.dart';
import 'package:hearppl/register.dart';
import 'package:intro_slider/intro_slider.dart';
import 'dart:convert';

import 'package:status_alert/status_alert.dart';

class Topics extends StatefulWidget {
  @override
  _TopicsState createState() => _TopicsState();
}

class _TopicsState extends State<Topics> {
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
      backgroundColor: Colors.grey,
      content: AutoSizeText(value,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: c.getFontSizeLabel(context),
              fontFamily: c.fontFamily(),
              color: Colors.white)),
      duration: const Duration(seconds: 2),
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

  var allData;
  List<String> topics = [], ids = [], selectedTopics = [];
  bool isLoading = true;

  Response? form_response;
  _category() async {
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
        decodeCat(form_response.toString());
        c.setshared("topics", form_response.toString());
      } else {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => NoInternet()),
            ModalRoute.withName('/NoInternet'));
      }
    } catch (e, s) {
      print("Error " + e.toString() + " Stack " + s.toString());
    }
  }

  saveTopics() async {
    setState(() {
      _isSubmitted = true;
      FocusManager.instance.primaryFocus?.unfocus();
    });
    try {
      var dio = Dio();

      final result = await InternetAddress.lookup('www.google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        FormData formData = FormData.fromMap({
          "save_topics": "save_topics",
          "user_id": user_id,
          "topics": selectedTopics.join(', '),
        });
        try {
          form_response = await dio.post(
            c.getURL() + 'topics.php',
            data: formData,
          );
        } on DioError catch (e) {
          print(e.message);
        }
        setState(() {
          print("Response got " + form_response.toString().trim());
          var jsonval = json.decode(form_response.toString());
          data = jsonval["response"];
          if (data![0]['status'] == "failed") {
            if (data![0]['reason'] == "verification_pending") {
              showInSnackBar(
                  "Account verification pending, check registered email for verification link");
            } else {
              showInSnackBar("Invalid email id or password, try again.");
            }
            _isSubmitted = false;
          } else if (data![0]['status'] == "success") {
            showInSnackBar("Your preference is saved");

            Future.delayed(Duration(seconds: 1), () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Home()));
            });
            _isSubmitted = false;
          }
        });
      } else {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => NoInternet()),
            ModalRoute.withName('/NoInternet'));
      }
    } catch (e, s) {
      print("Error " + e.toString() + " Stack " + s.toString());
    }
  }

  var user_id;
  void initState() {
    super.initState();
    // getData();
    // _category()
    c.getshared("topics").then((value) {
      // print("CatVal $value");
      if (value != '' && value != null && value != ' ' && value != 'null') {
        decodeCat(value);
      }
      _category();
    });
    c.getshared("user_id").then((value) {
      if (value != '' && value != null && value != ' ' && value != 'null') {
        setState(() {
          user_id = value;
          print("user id is $user_id");
        });
      }
    });
  }

  late List data_category;
  decodeCat(js) {
    print(js);
    setState(() {
      var jsonval = json.decode(js);
      data_category = jsonval["response"];
      if (data_category[0]['status'] == "failed") {
        setState(() {
          // isLoading = false;
        });
      } else if (data_category[0]['status'] == "success") {
        setState(() {
          topics = [];
          for (int i = 0; i < data_category.length; i++) {
            topics.add(data_category[i]['title']);
          }
          topics.toSet().toList();
          isLoading = false;
        });
      }
    });
  }

  void onDonePress() {
    print("End of slides");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: WillPopScope(
        onWillPop: () => _exitApp(context),
        child: SafeArea(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(20, 20, 20, 5),
                            child: AutoSizeText(
                              'Topics',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: c.getFontSizeLarge(context),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 17, vertical: 1),
                              child: AutoSizeText(
                                'Please choose any 10 topics',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontSize: c.getFontSizeLabel(context),
                                ),
                              )),
                        ],
                      ),
                      Card(
                        elevation: 0,
                        child: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: SizedBox(
                            child: ChipsChoice<String>.multiple(
                              value: selectedTopics,
                              onChanged: (val) => setState(() {
                                // tags = val;
                                print(val);
                                if (selectedTopics.length <= 9) {
                                  selectedTopics = val;
                                } else {
                                  showInSnackBar(
                                      "Maximum 10 Topics can be selected");
                                  // maxWidth: 260,
                                }
                              }),
                              choiceItems: C2Choice.listFrom<String, String>(
                                source: topics,
                                value: (i, v) => v,
                                label: (i, v) => v,
                                tooltip: (i, v) => v,
                              ),
                              wrapped: true,
                              choiceStyle: C2ChipStyle.filled(
                                color: c.getColor("light_blue"),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(15)),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 3),
                                foregroundStyle: TextStyle(
                                    fontSize: c.getFontSizeLabel(context),
                                    fontFamily: c.fontFamily()),
                                selectedStyle: C2ChipStyle(
                                  // backgroundColor: c.getColor("light_blue"),
                                  backgroundColor: c.getColor("dark_blue"),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      _isSubmitted
                          ? Center(child: CircularProgressIndicator())
                          : Padding(
                              padding: EdgeInsets.only(
                                top: 30.0,
                                bottom: 30.0,
                                left: MediaQuery.of(context).size.height * 0.02,
                                right:
                                    MediaQuery.of(context).size.height * 0.02,
                              ),
                              child: InkResponse(
                                onTap: () {
                                  saveTopics();
                                  // print(selectedTopics);
                                  // Future.delayed(const Duration(seconds: 0), () {
                                  //   Navigator.of(context).pop();
                                  //   Navigator.push(context,
                                  //       CupertinoPageRoute(builder: (_) => Home()));
                                  // });
                                },
                                child: Container(
                                  padding: EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: c.getColor("black"),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Continue",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: c.getFontSizeLabel(context),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                    ],
                  )),
      ),
    );
  }
}
