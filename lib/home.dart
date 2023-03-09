import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hearppl/NoInternet.dart';
import 'package:hearppl/bottomNav.dart';
import 'package:hearppl/constants.dart';
import 'package:hearppl/explore.dart';
import 'package:hearppl/feedView.dart';
import 'package:hearppl/feeds.dart';
import 'package:hearppl/newFeed.dart';
import 'package:hearppl/notifictaions.dart';
import 'package:hearppl/register.dart';
import 'package:hearppl/topics.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
// import 'package:video_compress/video_compress.dart';
import 'package:video_thumbnail_imageview/video_thumbnail_imageview.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Constants c = Constants();
  final _formKey = GlobalKey<FormState>();
  TextEditingController email = TextEditingController();
  TextEditingController pwd = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSubmitted = false;
  // Response? form_response;
  List<String> topics = [];
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

  getPermissionStatus() async {
    // print("getting");
    await Permission.camera.request();
    await Permission.storage.request();
    await Permission.microphone.request();
    var status = await Permission.camera.status;
  }

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

  posts() async {
    try {
      var dio = Dio();
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        FormData formData = new FormData.fromMap({
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
        decodePosts(form_response.toString());
        c.setshared("posts", form_response.toString());
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

  late List data_category;
  decodeCat(js) {
    // print(js);
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
        });
      }
    });
  }

  late List data_posts, temp_data = [];
  decodePosts(js) {
    print("posts are $js");
    setState(() {
      var jsonval = json.decode(js);
      data_posts = jsonval["response"];
      if (data_posts[0]['status'] == "failed") {
        setState(() {
          // isLoading = false;
        });
      } else if (data_posts[0]['status'] == "success") {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  var user_id, alias;
  int selectedTopics = 0;
  bool isLoading = true;

  void initState() {
    super.initState();
    getPermissionStatus();
    c.getshared("user_id").then((value) {
      if (value != '' && value != null && value != ' ' && value != 'null') {
        setState(() {
          user_id = value;
          // print("user id is $user_id");
        });
      }
    });
    c.getshared("topics").then((value) {
      // print("CatVal $value");
      if (value != '' && value != null && value != ' ' && value != 'null') {
        decodeCat(value);
      }
      _category();
    });
    c.getshared("posts").then((value) {
      // print("CatVal $value");
      if (value != '' && value != null && value != ' ' && value != 'null') {
        decodePosts(value);
      }
      posts();
    });

    c.getshared("alias").then((value) {
      if (value != '' && value != null && value != ' ' && value != 'null') {
        setState(() {
          alias = "Welcome " + value.toString();
          // print("user alias is $alias");
        });
      } else {
        setState(() {
          alias = "Welcome to Hearppl";
          // print("user alias is $alias");
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double _width = c.deviceWidth(context);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: WillPopScope(
        onWillPop: () => _exitApp(context),
        child: SafeArea(
            child: ListView(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: [
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: c.getColor("dark_blue"),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                ),
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                ),
              ),
              title: Text.rich(
                TextSpan(
                  style: TextStyle(
                      height: 0.9,
                      fontSize: c.getFontSizeLabel(context),
                      fontFamily: c.fontFamily()),
                  children: [
                    TextSpan(
                        text: "Hello",
                        style: TextStyle(
                            color: c.primaryColor(),
                            fontSize: c.getFontSizeLabel(context))),
                    TextSpan(
                      text: '\n$alias',
                      style: TextStyle(fontSize: c.getFontSizeLabel(context)),
                    ),
                  ],
                ),
              ),
              trailing: InkWell(
                onTap: () {
                  Navigator.push(context,
                      CupertinoPageRoute(builder: (_) => Notifications()));
                },
                child: Icon(
                  Icons.notifications,
                  size: c.getFontSizeLarge(context) - 3,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Image.asset(
                  "assets/icons/Ukraine.png",
                  scale: 1,
                ),
                Text(
                  "  We stand with Ukraine  ",
                  style: TextStyle(
                      fontSize: c.getFontSizeLabel(context) - 5,
                      fontFamily: c.fontFamily()),
                ),
              ],
            ),
            isLoading
                ? SizedBox()
                : Column(
                    children: [
                      SizedBox(
                        height: c.deviceHeight(context) * 0.06,
                        child: ListView.builder(
                            padding: EdgeInsets.only(left: 10),
                            itemCount: data_posts.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, i) {
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                          builder: (context) => Explore(
                                              data: data_posts[i],
                                              topic: data_posts[i]['titles'])));
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18.0),
                                    color: c.getColor("dark_blue"),
                                  ),
                                  margin: EdgeInsets.all(5),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Text(
                                      data_posts[i]['titles'],
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize:
                                              c.getFontSizeLabel(context) - 3,
                                          fontFamily: c.fontFamily()),
                                    ),
                                  ),
                                ),
                              );
                            }),
                      ),
                    ],
                  ),
            SizedBox(
                height: c.deviceHeight(context) * 0.73,
                child: ListView.builder(
                    itemCount: data_posts.length,
                    itemBuilder: (context, i) {
                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18.0),
                                child: Text(
                                  data_posts[i]['titles'],
                                  style: TextStyle(
                                    color: c.getColor("light_black"),
                                    fontSize: c.getFontSizeLarge(context) - 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: c.deviceHeight(context) * 0.23,
                            // width: c.deviceWidth(context) * 0.8,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: data_posts[i]['posts'].length,
                                itemBuilder: (context, j) {
                                  return InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          CupertinoPageRoute(
                                              builder: (context) => Feeds(
                                                  data: data_posts[i]['posts']
                                                      [j])));
                                    },
                                    child: SizedBox(
                                        // height: c.deviceHeight(context) * 0.2,
                                        width: c.deviceWidth(context) * 0.46,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(18.0),
                                              child: CachedNetworkImage(
                                                imageUrl: data_posts[i]['posts']
                                                        [j]['thumbnail']  ,
                                                placeholder: (context, url) =>
                                                    Image.asset(
                                                  "assets/load.gif",
                                                ),
                                                fit: BoxFit.cover,
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Image.asset(
                                                  "assets/load.gif",
                                                ),
                                              )),
                                        )),
                                  );
                                }),
                          )
                        ],
                      );
                    }))
          ],
        )),
      ),
      bottomNavigationBar: BottomNav(currentPage: 0),
      floatingActionButton: FloatingActionButton(
          backgroundColor: c.primaryColor(),
          onPressed: () {
            Navigator.push(
                context, CupertinoPageRoute(builder: (context) => NewFeed()));
          },
          child: Icon(Icons.add_box_rounded)),
    );
  }
}
