import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hearppl/NoInternet.dart';
import 'package:hearppl/bottomNav.dart';
import 'package:hearppl/constants.dart';
import 'package:hearppl/feedView.dart';
import 'package:hearppl/register.dart';
import 'package:hearppl/notifictaions.dart';
import 'package:hearppl/topics.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class Feeds extends StatefulWidget {
  final data;
  Feeds({this.data});
  @override
  _FeedsState createState() => _FeedsState();
}

int pageViewIndex = 0;

class _FeedsState extends State<Feeds> {
  Constants c = Constants();
  final _formKey = GlobalKey<FormState>();
  TextEditingController keyword = TextEditingController();
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

  var allData;
  List<String> topics = [], ids = [];
  int selectedTopics = 0;
  bool isLoading = true;
  int currentPageIndex = 0;
  int pageCount = 1;

  late List data_posts, temp_data = [];
  decodePosts(js) {
    print("posts are in feeds $js");
    setState(() {
      var jsonval = json.decode(js);
      data_posts = jsonval["response"];
      if (data_posts[0]['status'] == "success") {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  late Response form_response;
  posts(user_id) async {
    try {
      var dio = Dio();
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        FormData formData = new FormData.fromMap({
          "getAllFeeds": "getAllFeeds",
          "user_id": user_id,
        });
        try {
          form_response = await dio.post(
            c.getURL() + 'posts.php',
            data: formData,
          );
        } on DioError catch (e) {
          print(e.message);
        }
        decodePosts(form_response.toString());
        c.setshared("Feedposts", form_response.toString());
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

  void initState() {
    super.initState();
    print("heuy infeeds [age");
    print(widget.data);
    if (widget.data == null) {
      c.getshared("Feedposts").then((value) {
        // print("CatVal $value");
        if (value != '' && value != null && value != ' ' && value != 'null') {
          decodePosts(value);
        }
        c.getshared("user_id").then((value) {
          if (value != '' && value != null && value != ' ' && value != 'null') {
            setState(() {
              posts(value);
              // print("user id is $user_id");
            });
          }
        });
      });
    } else {
      setState(() {
        data_posts = [];
        data_posts.add(widget.data);
        isLoading = false;
      });
    }
  }

  getCurrentPage(int page) {
    pageViewIndex = page;
  }

  final PageController pageController = PageController();
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
                : PageView.builder(
                    scrollDirection: Axis.vertical,
                    controller: pageController,
                    onPageChanged: getCurrentPage,
                    itemCount: data_posts.length,
                    itemBuilder: (context, i) {
                      return FeedsView(data: data_posts[i]);
                      // return ChewieDemo(url:url);
                    })),
      ),
      bottomNavigationBar: BottomNav(currentPage: 2),
    );
  }
}
