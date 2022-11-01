import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hearppl/bottomNav.dart';
import 'package:hearppl/constants.dart';
import 'package:hearppl/feeds.dart';
import 'package:hearppl/newFeed.dart';
import 'package:hearppl/register.dart';
import 'package:hearppl/topics.dart';
import 'package:intro_slider/intro_slider.dart';

class Explore extends StatefulWidget {
  final data, topic;
  Explore({this.data, this.topic});
  @override
  _ExploreState createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
  Constants c = Constants();
  final _formKey = GlobalKey<FormState>();
  TextEditingController keyword = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;
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

  void initState() {
    super.initState();
    c.getshared("posts").then((value) {
      // print("CatVal $value");
      if (value != '' && value != null && value != ' ' && value != 'null') {
        decodePosts(value);
      }
    });
    // if (widget.data != Null) {
    //   setState(() {
    //     data_posts = widget.data;
    //   });
    // }
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
            shrinkWrap: true,
            padding: EdgeInsets.all(5),
            physics: NeverScrollableScrollPhysics(),
            children: [
              ListTile(
                title: Padding(
                  padding: EdgeInsets.only(
                    top: 10.0,
                  ),
                  child: SizedBox(
                    child: TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value!.isEmpty) {
                          // return 'Mobile number is mandatory';
                          return 'Cannot search nothing, enter keyword';
                        }
                      },
                      controller: keyword,
                      autocorrect: true,
                      style: TextStyle(
                          fontSize: c.getFontSize(context),
                          color: Colors.white),
                      onChanged: (s) {
                        setState(() {
                          if (s.isNotEmpty) {
                            if (temp_data.isEmpty) {
                              temp_data = data_posts;
                            }
                            data_posts = [];
                            for (int d = 0; d < temp_data.length; d++) {
                              print(temp_data[d]['titles'].toString());
                              print(s.toString());
                              if (s.toString() == 'All' ||
                                  s.toString() == 'Select Category') {
                                data_posts.add(temp_data[d]);
                              } else if (temp_data[d]['titles']
                                  .toString()
                                  .toLowerCase()
                                  .contains(s.toString().toLowerCase())) {
                                data_posts.add(temp_data[d]);
                              }
                            }
                          } else {
                            data_posts = temp_data;
                          }
                        });
                      },
                      decoration: InputDecoration(
                        prefixIcon: InkWell(
                          onTap: () {
                            setState(() {
                              if (hide_password) {
                                hide_password = false;
                              } else {
                                hide_password = true;
                              }
                            });
                          },
                          child: Icon(
                            Icons.search,
                            color: Colors.white,
                          ),
                        ),

                        hintText: " Search",
                        fillColor: c.primaryColor(),
                        filled: true, // dont forget this line
                        hintStyle: TextStyle(
                            fontSize: c.getFontSize(context),
                            color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                            style: BorderStyle.none,
                          ),
                        ),
                        contentPadding: EdgeInsets.all(16),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                  height: c.deviceHeight(context) * 0.75,
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
                                      horizontal: 15.0),
                                  child: Text(
                                    data_posts[i]['titles'],
                                    style: TextStyle(
                                      color: c.getColor("light_black"),
                                      fontSize:
                                          c.getFontSizeLarge(context) - 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              // height: c.deviceHeight(context) * 0.2,
                              child: ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: data_posts[i]['posts'].length,
                                  itemBuilder: (context, j) {
                                    return GestureDetector(
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
                                          width: c.deviceWidth(context) * 0.4,
                                          height: c.deviceHeight(context) * 0.2,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(18.0),
                                                child: CachedNetworkImage(
                                                  imageUrl: data_posts[i]
                                                      ['posts'][j]['thumbnail'],
                                                  placeholder: (context, url) =>
                                                      const Padding(
                                                    padding:
                                                        EdgeInsets.all(18.0),
                                                    child:
                                                        CircularProgressIndicator(),
                                                  ),
                                                  fit: BoxFit.cover,
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          const Icon(Icons
                                                              .circle_outlined),
                                                )),
                                          )),
                                    );
                                  }),
                            )
                          ],
                        );
                      })),
              c.getDivider(250.2),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNav(currentPage: 1),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Color(0xFFF42B5B),
          onPressed: () {
            Navigator.push(
                context, CupertinoPageRoute(builder: (context) => NewFeed()));
          },
          child: Icon(
            Icons.add_box_rounded,
            color: Colors.white,
          )),
    );
  }
}
