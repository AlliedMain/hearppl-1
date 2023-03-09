import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_initicon/flutter_initicon.dart';
import 'package:hearppl/NoInternet.dart';
import 'package:hearppl/constants.dart';
import 'package:hearppl/deleteMe.dart';
import 'package:hearppl/feeds.dart';
import 'package:hearppl/intros.dart';
import 'package:hearppl/login.dart';
import 'package:hearppl/notifictaions.dart';
import 'package:hearppl/register.dart';

import 'package:hearppl/bottomNav.dart';
import 'package:hearppl/topics.dart'; 
import 'package:status_alert/status_alert.dart';
import 'package:url_launcher/url_launcher.dart';

class Profile extends StatefulWidget {
  final user_id;
  Profile({this.user_id});
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Constants c = Constants();
  final _formKey = GlobalKey<FormState>();
  List? data;
  TextEditingController email = TextEditingController();
  TextEditingController pwd = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoadingProfile = true, isLoadingFollowers = true;
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

  void showModalBottomSheetCupetino() async {
    await showModalBottomSheet(
      useRootNavigator: true,
      context: context,
      // bounce: true,
      isDismissible: true,
      builder: (context) => Material(child: StatefulBuilder(builder:
          (BuildContext context,
              StateSetter setState /*You can rename this!*/) {
        return Container(
          padding: EdgeInsets.all(20),
          color: c.primaryColor(),
          child: ListView(
            shrinkWrap: true,
            // mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                onTap: () {
                  Navigator.push(
                      context, CupertinoPageRoute(builder: (_) => Topics()));
                },
                leading: Image.asset("assets/icons/topics.png"),
                title: Text(
                  "Topics",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: c.getFontSizeLabel(context),
                  ),
                ),
              ),
              ListTile(
                onTap: () {
                  launchUrl(Uri.parse("https://google.com"),
                      mode: LaunchMode.externalApplication);
                },
                leading: Image.asset("assets/icons/about.png"),
                title: Text(
                  "About App",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: c.getFontSizeLabel(context),
                  ),
                ),
              ),
              ListTile(
                onTap: () {
                  Navigator.push(
                      context, CupertinoPageRoute(builder: (_) => LoginPage()));
                },
                leading: Image.asset("assets/icons/delete.png"),
                title: Text(
                  "Delete Account",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: c.getFontSizeLabel(context),
                  ),
                ),
              ),
              ListTile(
                onTap: () {
                  c.setshared("user_id", 'null');
                  Navigator.push(
                      context, CupertinoPageRoute(builder: (_) => LoginPage()));
                },
                leading: Image.asset("assets/icons/exit.png"),
                title: Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: c.getFontSizeLabel(context),
                  ),
                ),
              ),
            ],
          ),
        );
      })),
    );
  }

  late Response form_response;
  posts(user_id) async {
    try {
      var dio = Dio();
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        FormData formData = new FormData.fromMap({
          "getAllFeedsProfile": "getAllFeedsProfile",
          "user_id": user_id,
        });
        try {
          form_response = await dio.post(
            c.getURL() + 'profile.php',
            data: formData,
          );
        } on DioError catch (e) {
          print(e.message);
        }
        decodePosts(form_response.toString());
        setState(() {});
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

  profile(user_id) async {
    try {
      var dio = Dio();
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        FormData formData = new FormData.fromMap({
          "user_details": "user_details",
          "user_id": user_id,
        });
        try {
          form_response = await dio.post(
            c.getURL() + 'profile.php',
            data: formData,
          );
          print("Profile is");
          print(form_response.toString());
          var jsonval = json.decode(form_response.toString());
          data_user = jsonval["response"];
          setState(() {
            isLoadingProfile = false;
          });
        } on DioError catch (e) {
          print(e.message);
        }
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

  getMyFollowers(user_id) async {
    try {
      var dio = Dio();
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        FormData formData = new FormData.fromMap({
          "getMyFollowers": "getMyFollowers",
          "user_id": user_id,
        });
        try {
          form_response = await dio.post(
            c.getURL() + 'followers.php',
            data: formData,
          );
          print("followers is");
          print(form_response.toString());
          var jsonval = json.decode(form_response.toString());
          data_followers = jsonval["response"];
          if (data_followers[0]['status'] == "failed") {
            setState(() {
              isLoadingFollowers = false;
              no_followers = true;
            });
          } else if (data_followers[0]['status'] == "success") {
            setState(() {
              isLoadingFollowers = false;
            });
          }
        } on DioError catch (e) {
          print(e.message);
        }
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

  bool isLoading = true,
      is_my_profile = true,
      tabPost = true,
      no_posts = false,
      no_followers = false;
  late List data_posts, data_user, data_followers, temp_data = [];

  var user_id;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    c.getshared("user_id").then((value) {
      if (value != '' && value != null && value != ' ' && value != 'null') {
        setState(() {
          print("user_id in my acc is $value");
          profile(value);
          posts(value);
          getMyFollowers(value);
        });
      }
    });
    if (widget.user_id != null) {
      print("user_id in widget is ${(widget.user_id)}");
      profile(widget.user_id);
      posts(widget.user_id);
      getMyFollowers(widget.user_id);
      setState(() {
        is_my_profile = false;
      });
    } else {}
  }

  _updateLike() async {
    var user_id = '';
    c.getshared("user_id").then((value) {
      setState(() {
        user_id = value;
      });
    });
    try {
      var dio = Dio();
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        FormData formData = new FormData.fromMap({
          "follow": "follow",
          "user_id": user_id,
          "following_id": widget.user_id,
        });
        try {
          form_response = await dio.post(
            c.getURL() + 'followers.php',
            data: formData,
          );
        } on DioError catch (e) {
          print(e.message);
        }
        print("Lieked ");
        print(form_response.toString());
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

  deletePost(id) async {
    var user_id = '';
    StatusAlert.show(
      context,
      duration: Duration(seconds: 2),
      title: 'Deleted!',
      subtitle: 'Your post is successfully deleted',
      configuration: IconConfiguration(
        icon: Icons.delete_forever_rounded,
      ),
      // maxWidth: 260,
    );
    c.getshared("user_id").then((value) {
      setState(() {
        user_id = value;
      });
    });
    try {
      var dio = Dio();
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        FormData formData = new FormData.fromMap({
          "deletePost": "deletePost",
          "comment_id": id,
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
        print("Lieked ");
        // print(form_response.toString());
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

  showAlert(BuildContext context, id) {
    // set up the button
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Deleting Post"),
      content: Text("Are you sure you want to delete this post?"),
      actions: [
        TextButton(
          child: Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text("Confirm"),
          onPressed: () {
            deletePost(id);
          },
        )
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: CupertinoNavigationBar(
        padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),

        // backgroundColor:  getBrownColor(),
        // actionsForegroundColor: getWhit  eColor(),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,

        transitionBetweenRoutes: false,

        trailing: Stack(
          children: [
            Positioned(
                top: 5,
                right: 40,
                child: InkWell(
                  onTap: () {
                    Navigator.push(context,
                        CupertinoPageRoute(builder: (_) => Notifications()));
                  },
                  child: Icon(
                    Icons.notifications,
                    color: Colors.black.withOpacity(0.6),
                  ),
                )),
            Positioned(
                top: 5,
                right: 5,
                child: InkWell(
                  onTap: () {
                    showModalBottomSheetCupetino();
                  },
                  child: Icon(
                    Icons.more_vert_outlined,
                    color: Colors.black.withOpacity(0.6),
                  ),
                ))
          ],
        ),
      ),
      body: WillPopScope(
        onWillPop: () => _exitApp(context),
        child: SafeArea(
          child: ListView(
            shrinkWrap: true,
            // physics: NeverScrollableScrollPhysics(),
            children: [
              Divider(),
              Stack(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          // color: c.getColor("dark_blue"),
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                        ),
                        child: DottedBorder(
                          borderType: BorderType.RRect,
                          radius: Radius.circular(80),
                          dashPattern: [
                            10,
                            10,
                          ],
                          color: c.primaryColor(),
                          strokeWidth: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: DottedBorder(
                              borderType: BorderType.RRect,
                              radius: Radius.circular(80),
                              dashPattern: [10, 5],
                              color: c.primaryColor(),
                              strokeWidth: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: DottedBorder(
                                  borderType: BorderType.RRect,
                                  radius: Radius.circular(80),
                                  dashPattern: [3, 1],
                                  color: c.primaryColor(),
                                  strokeWidth: 2,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(80.0),
                                    child: Initicon(
                                        text: isLoadingProfile
                                            ? "User"
                                            : data_user[0]['alias'],
                                        elevation: 4),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                      left: c.deviceHeight(context) * 0.12,
                      right: 0,
                      top: c.deviceHeight(context) * 0.12,
                      child: Image.asset("assets/icons/edit.png")),
                ],
              ),
              is_my_profile
                  ? Container()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            top: 30.0,
                            bottom: 10.0,
                            left: MediaQuery.of(context).size.height * 0.02,
                            right: MediaQuery.of(context).size.height * 0.02,
                          ),
                          child: InkResponse(
                            onTap: () {
                              _updateLike();
                            },
                            child: Container(
                              padding: EdgeInsets.all(13),
                              decoration: BoxDecoration(
                                color: c.primaryColor(),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Text(
                                  "Follow",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: c.getFontSizeXS(context),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.height * 0.02,
                      right: MediaQuery.of(context).size.height * 0.02,
                    ),
                    child: Center(
                      child: Text(
                        isLoadingProfile ? "User" : data_user[0]['alias'],
                        style: TextStyle(
                          fontSize: c.getFontSizeLabel(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.height * 0.02,
                      right: MediaQuery.of(context).size.height * 0.02,
                    ),
                    child: Center(
                      child: Text(
                        isLoadingProfile ? "User" : data_user[0]['email'],
                        style: TextStyle(
                          fontSize: c.getFontSizeLabel(context),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          tabPost = true;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              //                    <--- top side
                              color: tabPost ? c.primaryColor() : Colors.grey,
                              width: 5.0,
                            ),
                          ),
                        ),
                        padding: EdgeInsets.only(
                          top: 20,
                          left: MediaQuery.of(context).size.height * 0.02,
                          right: MediaQuery.of(context).size.height * 0.02,
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Posts",
                              style: TextStyle(
                                  fontSize: c.getFontSizeLabel(context) + 1,
                                  fontWeight: FontWeight.w600,
                                  color: tabPost ? Colors.black : Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          tabPost = false;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: !tabPost ? c.primaryColor() : Colors.grey,
                              width: 5.0,
                            ),
                          ),
                        ),
                        padding: EdgeInsets.only(
                          top: 20,
                          left: MediaQuery.of(context).size.height * 0.02,
                          right: MediaQuery.of(context).size.height * 0.02,
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Followers",
                              style: TextStyle(
                                  fontSize: c.getFontSizeLabel(context) + 1,
                                  fontWeight: FontWeight.w600,
                                  color: !tabPost ? Colors.black : Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                height: 5,
              ),
              tabPost
                  ? Center(
                      child: isLoading
                          ? Container()
                          : no_posts
                              ? Center(
                                  child: Text("No Posts Found"),
                                )
                              : Container(
                                  color: Colors.white,
                                  child: GridView.builder(
                                      shrinkWrap: true,
                                      itemCount: data_posts.length,
                                      physics: NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        crossAxisSpacing: 0.010,
                                        mainAxisSpacing: 0.01,
                                      ),
                                      itemBuilder:
                                          (BuildContext context, int i) {
                                        return GestureDetector(
                                          onLongPress: () {
                                            print("lomg");
                                            is_my_profile
                                                ? showAlert(context,
                                                    data_posts[i]['id'])
                                                : print("Deleteing");
                                          },
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                CupertinoPageRoute(
                                                    builder: (context) => Feeds(
                                                        data: data_posts[i])));
                                          },
                                          child: SizedBox(
                                              width:
                                                  c.deviceWidth(context) * 0.4,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(2.0),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          2.0),
                                                  child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                      child: CachedNetworkImage(
                                                        imageUrl: data_posts[i]
                                                            ['thumbnail'],
                                                        placeholder:
                                                            (context, url) =>
                                                                const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  58.0),
                                                          child:
                                                              CircularProgressIndicator(),
                                                        ),
                                                        fit: BoxFit.cover,
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            const Icon(Icons
                                                                .circle_outlined),
                                                      )),
                                                ),
                                              )),
                                        );
                                      }),
                                ),
                    )
                  : Container(
                      child: isLoadingFollowers
                          ? Container()
                          : no_followers
                              ? Center(
                                  child: Text(
                                    "0 Followers",
                                    style: TextStyle(
                                      color: c.getColor("light_black"),
                                      fontSize:
                                          c.getFontSizeLarge(context) - 10,
                                    ),
                                  ),
                                )
                              : SizedBox(
                                  width: c.deviceWidth(context) * 0.6,
                                  child: ListView.builder(
                                      itemCount: data_followers.length,
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemBuilder: (context, i) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            // color: c.getColor("light_blue"),
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          margin: EdgeInsets.only(
                                            left: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.02,
                                            right: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.02,
                                          ),
                                          child: ListTile(
                                            leading: Initicon(
                                                text: data_followers[i]['alias']
                                                    .toString(),
                                                elevation: 4),
                                            title: Text(
                                              data_followers[i]['alias'],
                                              style: TextStyle(
                                                  fontSize: c.getFontSizeLabel(
                                                          context) -
                                                      3,
                                                  color: Colors.black,
                                                  fontFamily: c.fontFamily()),
                                            ),
                                            subtitle: Text.rich(
                                              TextSpan(
                                                style: TextStyle(
                                                    fontSize: c.getFontSizeXS(
                                                            context) -
                                                        3,
                                                    fontFamily: c.fontFamily()),
                                                children: [
                                                  TextSpan(
                                                    text: data_followers[i]
                                                            ['added_on']
                                                        .toString(),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            trailing: InkResponse(
                                              onTap: () {
                                                _updateLike();
                                              },
                                              child: Container(
                                                width: c.deviceWidth(context) *
                                                    0.2,
                                                decoration: BoxDecoration(
                                                  color:
                                                      c.getColor("light_blue"),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    "Follow",
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: c.getFontSizeXS(
                                                          context),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                ),
                    ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNav(currentPage: 4),
    );
  }
}
