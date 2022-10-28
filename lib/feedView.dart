// ignore_for_file: duplicate_import

import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hearppl/NoInternet.dart';
import 'package:hearppl/bottomNav.dart';
import 'package:hearppl/constants.dart';
import 'package:hearppl/home.dart';
import 'package:hearppl/profile.dart';
import 'package:hearppl/register.dart';
import 'package:hearppl/topics.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:status_alert/status_alert.dart';
import 'dart:io';
import 'package:flutter_initicon/flutter_initicon.dart';
import 'package:chewie/chewie.dart';
// import 'package:chewie_example/app/theme.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:video_player/video_player.dart';

class FeedsView extends StatefulWidget {
  final data;
  FeedsView({this.data});
  @override
  _FeedsViewState createState() => _FeedsViewState();
}

class _FeedsViewState extends State<FeedsView> {
  Constants c = Constants();

  TextEditingController msg = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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

  double volume = 100;
  void showModalBottomSheetCupetino() async {
    await showCupertinoModalBottomSheet(
      useRootNavigator: true,
      context: context,
      bounce: true,
      isDismissible: true,
      expand: true,
      builder: (context) => Material(
        child: ListView(
          shrinkWrap: true,
          // mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                top: 30.0,
                left: MediaQuery.of(context).size.height * 0.02,
                right: MediaQuery.of(context).size.height * 0.02,
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.082,
                width: MediaQuery.of(context).size.width * 8.0,
                child: TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.isEmpty) {
                      // return 'Mobile number is mandatory';
                      return 'Cannot send empty comments';
                    }
                  },
                  style: TextStyle(
                      fontSize: c.getFontSize(context), color: Colors.white),
                  controller: msg,
                  onFieldSubmitted: (txt) {
                    _sendComment(msg.text.toString());
                    StatusAlert.show(
                      context,
                      duration: Duration(seconds: 2),
                      title: 'Sent!',
                      subtitle: 'Owner of the post will be notified',
                      configuration: IconConfiguration(
                        icon: Icons.done_all,
                      ),
                      // maxWidth: 260,
                    );
                    Navigator.of(context).pop('cancel');
                  },
                  maxLength: 200,
                  autocorrect: true,
                  decoration: InputDecoration(
                    suffixIcon: GestureDetector(
                      onTap: () {
                        _sendComment(msg.text.toString());
                        StatusAlert.show(
                          context,
                          duration: Duration(seconds: 2),
                          title: 'Sent!',
                          subtitle: 'Owner of the post will be notified',
                          configuration: IconConfiguration(
                            icon: Icons.done_all,
                          ),
                          // maxWidth: 260,
                        );
                        Navigator.of(context).pop('cancel');
                      },
                      child: Icon(
                        Icons.comment,
                        color: Colors.white,
                      ),
                    ),
                    hintText: " Say Something...",
                    fillColor: c.primaryColor(),
                    filled: true, // dont forget this line
                    hintStyle: TextStyle(
                        fontSize: c.getFontSize(context), color: Colors.white),
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
            (widget.data['comments']).length <= 0
                ? ListTile(
                    title: Text(
                      "Be the first one to comment",
                      style: TextStyle(
                          fontSize: c.getFontSizeLabel(context) - 3,
                          color: Colors.black.withOpacity(0.5),
                          fontFamily: c.fontFamily()),
                    ),
                  )
                : SizedBox(
                    height: c.deviceHeight(context) * 0.8,
                    child: ListView.builder(
                        padding: EdgeInsets.only(left: 10),
                        itemCount: (widget.data['comments']).length,
                        itemBuilder: (context, i) {
                          return ListTile(
                            leading: Initicon(
                                text: widget.data['comments'][i]['alias'],
                                elevation: 4),
                            subtitle: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  widget.data['comments'][i]['alias'],
                                  style: TextStyle(
                                      fontSize: c.getFontSizeLabel(context) - 7,
                                      color: Colors.black,
                                      fontFamily: c.fontFamily()),
                                ),
                                Text(
                                  widget.data['comments'][i]['added_on'],
                                  style: TextStyle(
                                      fontSize: c.getFontSizeLabel(context) - 7,
                                      color: Colors.black,
                                      fontFamily: c.fontFamily()),
                                )
                              ],
                            ),
                            title: Text(
                              widget.data['comments'][i]['msg'],
                              style: TextStyle(
                                  fontSize: c.getFontSizeLabel(context) - 3,
                                  color: Colors.black,
                                  fontFamily: c.fontFamily()),
                            ),
                            trailing: widget.data['comments'][i]['alias_id'] !=
                                    user_id
                                ? GestureDetector(
                                    child: Text(""),
                                  )
                                : GestureDetector(
                                    onTap: () {
                                      _deleteComment(widget.data['comments'][i]
                                          ['comment_id']);

                                      StatusAlert.show(
                                        context,
                                        duration: Duration(seconds: 2),
                                        title: 'Deleted!',
                                        subtitle:
                                            'This comments will be deleted for all users',
                                        configuration: IconConfiguration(
                                          icon: Icons.delete_outline_rounded,
                                        ),
                                      );
                                    },
                                    child: Icon(Icons.delete_outline_rounded)),
                          );
                        }))
          ],
        ),
      ),
    );
  }

  late VideoPlayerController _videoPlayerController1;
  ChewieController? _chewieController;
  bool liked = false;
  var user_id;
  @override
  void initState() {
    super.initState();
    print("FeedView data is ");
    print(widget.data);
    if (widget.data != null) {
      initializePlayer();
      setState(() {
        if (widget.data['my_likes'] == 'YES') liked = true;
      });
    }
    c.getshared("user_id").then((value) {
      if (value != '' && value != null && value != ' ' && value != 'null') {
        setState(() {
          user_id = value;
          // print("user id is $user_id");
        });
      }
    });
  }

  @override
  void dispose() {
    _videoPlayerController1.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> initializePlayer() async {
    _videoPlayerController1 =
        VideoPlayerController.network(widget.data['video']);
    await Future.wait([
      _videoPlayerController1.initialize(),
    ]);
    _createChewieController();
    setState(() {});
  }

  void _createChewieController() {
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController1,
      autoPlay: true,
      looping: true,
      aspectRatio:
          c.deviceHeight(context) * 0.81 / c.deviceWidth(context) * 0.31,
      // aspectRatio: 9 / 16,
      deviceOrientationsAfterFullScreen: [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown
      ],
      hideControlsTimer: const Duration(seconds: 1),
      showControls: false,
      autoInitialize: true,
    );
  }

  late Response form_response;
  _updateLike(id) async {
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
          "updateLike": "updateLike",
          "user_id": user_id,
          "post_id": id,
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

  _sendComment(msg) async {
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
          "addComments": "addComments",
          "user_id": user_id,
          "post_id": widget.data['id'],
          "msg": msg,
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

  _deleteComment(comment_id) async {
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
          "deleteComment": "deleteComment",
          "user_id": user_id,
          "comment_id": comment_id,
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Colors.grey.withOpacity(0.3),
        child: Stack(children: [
          _chewieController != null &&
                  _chewieController!.videoPlayerController.value.isInitialized
              ? Chewie(
                  controller: _chewieController!,
                )
              : Positioned(
                  child: CachedNetworkImage(
                  imageUrl: widget.data['thumbnail'],
                  placeholder: (context, url) => const Padding(
                    padding: EdgeInsets.all(18.0),
                    child: CircularProgressIndicator(),
                  ),
                  width: c.deviceWidth(context),
                  height: c.deviceHeight(context),
                  fit: BoxFit.fill,
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.circle_outlined),
                )),
          Positioned(
            top: 5,
            child: Container(
              width: c.deviceWidth(context),
              padding: EdgeInsets.all(15),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context,
                              CupertinoPageRoute(builder: (context) => Home()));
                        },
                        child: Container(
                          decoration:
                              BoxDecoration(shape: BoxShape.circle, boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 10.0,
                            ),
                          ]),
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: c.deviceWidth(context) * 0.09,
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            // Navigator.pop(context);
                            // Navigator.push(context,
                            //     CupertinoPageRoute(builder: (context) => Home()));

                            if (volume == 100) {
                              _chewieController?.setVolume(0);
                              setState(() {
                                volume = 0;
                              });
                            } else {
                              _chewieController?.setVolume(100);
                              setState(() {
                                volume = 100;
                              });
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    blurRadius: 10.0,
                                  ),
                                ]),
                            child: Icon(
                              volume == 100
                                  ? Icons.volume_up_rounded
                                  : Icons.volume_mute_rounded,
                              color: Colors.white,
                              size: c.deviceWidth(context) * 0.09,
                            ),
                          ),
                        ),
                        Container(
                          width: 2,
                        ),
                        GestureDetector(
                          onTap: () {
                            StatusAlert.show(
                              context,
                              duration: Duration(seconds: 2),
                              title: 'Reported!',
                              subtitle:
                                  'Thank you for reporting this user for sharing such content.',
                              configuration: IconConfiguration(
                                  icon: Icons.report, color: c.getColor("red")),
                              // maxWidth: 260,
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    blurRadius: 10.0,
                                  ),
                                ]),
                            child: Icon(
                              Icons.report,
                              color: Colors.white,
                              size: c.deviceWidth(context) * 0.09,
                            ),
                          ),
                        )
                      ],
                    )
                  ]),
            ),
          ),
          Positioned(
              bottom: 2,
              child: Container(
                padding: EdgeInsets.all(15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: c.deviceWidth(context) * 0.8,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                widget.data['alias'],
                                style: TextStyle(
                                    shadows: <Shadow>[
                                      Shadow(
                                        offset: Offset(1.0, 1.0),
                                        blurRadius: 1.0,
                                        color: Colors.grey,
                                      ),
                                      Shadow(
                                        offset: Offset(1.0, 1.0),
                                        blurRadius: 10.0,
                                        color: c.primaryColor(),
                                      ),
                                    ],
                                    fontSize: c.getFontSizeMedium(context) + 5,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontFamily: c.fontFamily()),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            // crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.2),
                                          blurRadius: 10.0,
                                        ),
                                      ]),
                                  child: Icon(Icons.tag, color: Colors.white)),
                              Text(
                                widget.data['titles'],
                                style: TextStyle(
                                    shadows: <Shadow>[
                                      Shadow(
                                        offset: Offset(1.0, 1.0),
                                        blurRadius: 1.0,
                                        color: Colors.grey,
                                      ),
                                      Shadow(
                                        offset: Offset(1.0, 1.0),
                                        blurRadius: 10.0,
                                        color: c.primaryColor(),
                                      ),
                                    ],
                                    fontSize: c.getFontSizeMedium(context) + 3,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontFamily: c.fontFamily()),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            // crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.2),
                                          blurRadius: 10.0,
                                        ),
                                      ]),
                                  child:
                                      Icon(Icons.place, color: Colors.white)),
                              Text(
                                widget.data['location'],
                                style: TextStyle(
                                    shadows: <Shadow>[
                                      Shadow(
                                        offset: Offset(1.0, 1.0),
                                        blurRadius: 1.0,
                                        color: Colors.grey,
                                      ),
                                      Shadow(
                                        offset: Offset(1.0, 1.0),
                                        blurRadius: 10.0,
                                        color: c.primaryColor(),
                                      ),
                                    ],
                                    fontSize: c.getFontSizeMedium(context) + 3,
                                    color: Colors.white,
                                    fontFamily: c.fontFamily()),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: c.deviceWidth(context) * 0.2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              _updateLike(widget.data['id']);
                              setState(() {
                                if (liked == true) {
                                  liked = false;
                                  if (int.parse(
                                          widget.data['likes'].toString()) >
                                      0)
                                    widget.data['likes'] = (int.parse(widget
                                                .data['likes']
                                                .toString()) -
                                            1)
                                        .toString();
                                } else {
                                  liked = true;
                                  widget.data['likes'] = (int.parse(
                                              widget.data['likes'].toString()) +
                                          1)
                                      .toString();
                                }
                              });
                            },
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.2),
                                          blurRadius: 10.0,
                                        ),
                                      ]),
                                  child: Icon(
                                    liked == true
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  widget.data['likes'],
                                  style: TextStyle(
                                      shadows: <Shadow>[
                                        Shadow(
                                          offset: Offset(1.0, 1.0),
                                          blurRadius: 1.0,
                                          color: Colors.grey,
                                        ),
                                        Shadow(
                                          offset: Offset(1.0, 1.0),
                                          blurRadius: 10.0,
                                          color: c.primaryColor(),
                                        ),
                                      ],
                                      fontSize: c.getFontSizeLabel(context) - 2,
                                      color: Colors.white,
                                      fontFamily: c.fontFamily()),
                                )
                              ],
                            ),
                          ),
                          c.getDivider(20.5),
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  showModalBottomSheetCupetino();
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.2),
                                          blurRadius: 10.0,
                                        ),
                                      ]),
                                  child: const Icon(
                                    Icons.comment,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Text(
                                (widget.data['comments'] == null)
                                    ? "0"
                                    : (widget.data['comments'])
                                        .length
                                        .toString(),
                                style: TextStyle(
                                    shadows: <Shadow>[
                                      Shadow(
                                        offset: Offset(1.0, 1.0),
                                        blurRadius: 1.0,
                                        color: Colors.grey,
                                      ),
                                      Shadow(
                                        offset: Offset(1.0, 1.0),
                                        blurRadius: 10.0,
                                        color: c.primaryColor(),
                                      ),
                                    ],
                                    fontSize: c.getFontSizeLabel(context) - 2,
                                    color: Colors.white,
                                    fontFamily: c.fontFamily()),
                              )
                            ],
                          ),
                          c.getDivider(20.5),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (_) => Profile(
                                            user_id: widget.data['alias_id'],
                                          )));
                            },
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.2),
                                          blurRadius: 10.0,
                                        ),
                                      ]),
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ))
        ]),
      ),
    );
  }
}
