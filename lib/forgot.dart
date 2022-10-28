import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hearppl/NoInternet.dart';
import 'package:hearppl/constants.dart';
import 'package:hearppl/intros.dart';
import 'package:hearppl/login.dart';
import 'package:hearppl/register.dart';
import 'package:hearppl/topics.dart';

class ForgotPage extends StatefulWidget {
  @override
  _ForgotPageState createState() => _ForgotPageState();
}

class _ForgotPageState extends State<ForgotPage> {
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

  Response? form_response;
  _login() async {
    setState(() {
      _isSubmitted = true;
      FocusManager.instance.primaryFocus?.unfocus();
    });
    try {
      var dio = Dio();

      final result = await InternetAddress.lookup('www.google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        FormData formData = FormData.fromMap({
          "user_login": "login",
          // "alias": alias.text.toString(),
          "email": email.text.toString(),
          "password": pwd.text.toString(),
        });
        try {
          form_response = await dio.post(
            c.getURL() + 'user_api.php',
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
            showInSnackBar("Sign in completed please wait...");

            Future.delayed(Duration(seconds: 2), () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Topics()));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        body: WillPopScope(
            onWillPop: () => _exitApp(context),
            child: SafeArea(
                child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(7),
                            child: Container(
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 20, right: 20, top: 20),
                                child: Container(
                                    child: Image.asset("assets/slider-1.png")),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 17),
                                  child: AutoSizeText(
                                    'Welcome Onboard',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontSize: c.getFontSizeLarge(context),
                                      fontWeight: FontWeight.w800,
                                    ),
                                  )),
                            ],
                          ),
                          Row(
                            children: [
                              Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 17),
                                  child: AutoSizeText(
                                    'Enter the email associated with your account and we’ll send an email with instructions to reset your password.',
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        fontSize: c.getFontSizeSmall(context),
                                        // fontWeight: FontWeight.w800,
                                        color: c.getColor("grey")),
                                  )),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              top: 30.0,
                              left: MediaQuery.of(context).size.height * 0.02,
                              right: MediaQuery.of(context).size.height * 0.02,
                            ),
                            child: SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.082,
                              width: MediaQuery.of(context).size.width * 8.0,
                              child: TextFormField(
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    // return 'Mobile number is mandatory';
                                    return 'Email ID cannot be empty';
                                  }
                                },
                                controller: email,
                                style: TextStyle(
                                    fontSize: c.getFontSize(context),
                                    color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: "Email",
                                  fillColor: c.primaryColor(),
                                  filled: true, // dont forget this line
                                  hintStyle: TextStyle(
                                      fontSize: c.getFontSize(context),
                                      color: Colors.white),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide(
                                      width: 0,
                                      style: BorderStyle.none,
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.all(16),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              // top: 30.0,
                              bottom: 30.0,
                              left: MediaQuery.of(context).size.height * 0.02,
                              right: MediaQuery.of(context).size.height * 0.02,
                            ),
                            child: InkResponse(
                              onTap: () {
                                // if (_formKey.currentState!.validate()) {
                                //   _checkLogin(email.text.toString(),
                                //       passsword.text.toString());
                                // } else {}

                                Future.delayed(const Duration(seconds: 0), () {
                                  Navigator.of(context).pop();
                                  Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                          builder: (_) => LoginPage()));
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.all(13),
                                decoration: BoxDecoration(
                                  color: c.getColor("black"),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Text(
                                    "Request Reset Link",
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
                          InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (_) => LoginPage()));
                              // CupertinoPageRoute(builder: (context) => AA02Disclaimer())
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text.rich(
                                  TextSpan(
                                    style: TextStyle(
                                        fontSize: c.getFontSizeLabel(context),
                                        fontFamily: c.fontFamily()),
                                    children: [
                                      TextSpan(text: "I have acccont? "),
                                      TextSpan(
                                        text: 'Sign In',
                                        style: TextStyle(
                                            color: c.primaryColor(),
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      )),
                )
              ],
            ))));
  }
}
