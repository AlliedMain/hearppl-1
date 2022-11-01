import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'dart:math' as math; // import this
import 'package:auto_size_text/auto_size_text.dart';
import 'package:camera/camera.dart';
import 'package:chewie/chewie.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:hearppl/NoInternet.dart';
import 'package:hearppl/constants.dart';
import 'package:hearppl/deleteMe.dart';
import 'package:hearppl/home.dart';
import 'package:hearppl/main.dart';
import 'package:hearppl/profile.dart';
import 'package:hearppl/register.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:path/path.dart' as Path;
import 'package:hearppl/topics.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:status_alert/status_alert.dart';
import 'package:system_settings/system_settings.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart' as thumb;

class NewFeed extends StatefulWidget {
  @override
  _NewFeedState createState() => _NewFeedState();
}

class _NewFeedState extends State<NewFeed> {
  Constants c = Constants();
  final _formKey = GlobalKey<FormState>();
  List? data;
  TextEditingController caption = TextEditingController();
  TextEditingController location = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSubmitted = false;
  // Response? form_response;

  bool _isCameraPermissionGranted = false;
  bool hide_password = true;
  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  bool _islocationgranted = false;
  bool _isRearCameraSelected = true;
  bool showstudio = false;

  bool isimage = true;
  // Current values
  double _currentZoomLevel = 1.0;
  double _currentExposureOffset = 0.0;

  bool _isCameraInitialized = false;

  late CameraController _Cameracontroller;
  ResolutionPreset currentResolutionPreset = ResolutionPreset.high;

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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (_Cameracontroller == null || !_Cameracontroller.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _Cameracontroller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(_Cameracontroller.description);
    }
  }

  void resetCameraValues() async {
    _currentZoomLevel = 1.0;
    _currentExposureOffset = 0.0;
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    final previousCameraController = _Cameracontroller;

    final CameraController cameraController = CameraController(
      cameraDescription,
      currentResolutionPreset,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await previousCameraController.dispose();

    resetCameraValues();

    if (mounted) {
      // print("setting");
      setState(() {
        _Cameracontroller = cameraController;
      });
    }

    // Update UI if controller updated
    // cameraController.addListener(() {
    //   if (mounted) setState(() {});
    // });

    try {
      await cameraController.initialize();
      await Future.wait([
        cameraController
            .getMinExposureOffset()
            .then((value) => _minAvailableExposureOffset = value),
        cameraController
            .getMaxExposureOffset()
            .then((value) => _maxAvailableExposureOffset = value),
        cameraController
            .getMaxZoomLevel()
            .then((value) => _maxAvailableZoom = value),
        cameraController
            .getMinZoomLevel()
            .then((value) => _minAvailableZoom = value),
        cameraController.setFlashMode(FlashMode.off)
      ]);

      //_currentFlashMode = controller!.value.flashMode;
    } on CameraException catch (e) {
      // print('Error initializing camera: $e');
      // Navigator.push(
      //     context, CupertinoPageRoute(builder: (context) => NewFeed()));
      setState(() {});
    }

    if (mounted) {
      setState(() {
        _isCameraInitialized = _Cameracontroller.value.isInitialized;
      });
    }
  }

  String recordingTime = '00:00'; // to store value

  bool recording = false;
  void recordTime() {
    var startTime = DateTime.now();
    Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (!recording) {
        t.cancel(); //cancel function calling
      }
      setState(() {
        var diff = DateTime.now().difference(startTime);
        recordingTime =
            '${diff.inHours < 60 ? diff.inHours : 0}:${diff.inMinutes < 60 ? diff.inMinutes : 0}:${diff.inSeconds < 60 ? diff.inSeconds : 0}';
        // print("recordingTime $recordingTime");
      });
    });
  }

  bool isLoading = true;
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
    print("getting");
    await Permission.camera.request();
    await Permission.microphone.request();
    var status = await Permission.camera.status;
    if (status.isGranted) {
      // print("granted");
      setState(() {
        _isCameraPermissionGranted = true;
        _Cameracontroller = CameraController(cameras[0], ResolutionPreset.max);
        _Cameracontroller.initialize().then((_) {
          if (!mounted) {
            return;
          }
          setState(() {
            isLoading = false;
          });
        }).catchError((Object e) {
          if (e is CameraException) {
            switch (e.code) {
              case 'CameraAccessDenied':
                print('User denied camera access.');
                break;
              default:
                print('Handle other errors.');
                break;
            }
          }
        });
      });
    }
  }

  Future<void> startvideo() async {
    setState(() {
      recording = true;
      showstudio = false;
    });
    if (!_Cameracontroller.value.isRecordingVideo) {
      _Cameracontroller.startVideoRecording().catchError((e) {
        // print("error whiel startung $e");
      });
    }
  }

  File? imagex;
  getimage(bool camera, String imageType) async {
    // final typeGroup = XTypeGroup(label: 'videos', extensions: ['mov', 'mp4']);
    XFile? pickedFile = await ImagePicker().pickVideo(
      source: camera ? ImageSource.camera : ImageSource.gallery,
      // maxWidth: 1200,
      // maxHeight: 1600,
    );
    if (pickedFile != null) {
      setState(() {
        if (imageType == 'image') {
          imagex = File(pickedFile.path);
        }
      });
    }
    showModalBottomSheetCupetino();

    ///showImageFile();
  }

  var thumbnail;

  stopvideo() async {
    // Fluttertoast.showToast(
    //   msg: "Please Wait...",
    //   toastLength: Toast.LENGTH_SHORT,
    //   gravity: ToastGravity.CENTER,
    //   timeInSecForIosWeb: 1,
    //   backgroundColor: Colors.red,
    //   textColor: Colors.white,
    //   fontSize: 16.0,
    // );
    setState(() {
      recording = false;
    });
    // timer.cancel();

    if (_Cameracontroller.value.isRecordingVideo) {
      XFile video = await _Cameracontroller.stopVideoRecording();
      // print(video.path); //and there is more in this XFile object
      File videofile = File(video.path);
      Directory appDocDir = await getTemporaryDirectory();
      String appDocPath = appDocDir.path;
      final fileName = Path.basename(videofile.path);
      final File localVideo = await videofile.copy('$appDocPath/$fileName');
      setState(() {
        imagex = File(localVideo.path);
      });
      // print(imagex!.absolute);
      await GallerySaver.saveVideo(imagex!.path, albumName: "fileName")
          .then((data) {
        print("Saved to galley");
        print(data);
      });
      compress(imagex!.path);
      showModalBottomSheetCupetino();
    }
    // XFile video = await controller.stopVideoRecording();

// XFile thumb = getFileThumbnail()
    // await VideoCompress.getFileThumbnail(imagex!.path,
    //         quality: 50, // default(100)
    //         position: -1 // default(-1)
    //         )
    //     .then((value) {
    //   setState(() {
    //     thumbnail = value;

    //     print("thumnail is $value");
    //   });
    // });
    // // await thumb.VideoThumbnail.thumbnailData(
    // //   video: videofile.path,
    // //   imageFormat: thumb.ImageFormat.JPEG,
    // //   maxWidth:
    // //       128, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
    // //   quality: 25,
    // // );
    // await VideoCompress.setLogLevel(0);
    // await VideoCompress.compressVideo(
    //   localVideo.path,
    //   quality: VideoQuality.MediumQuality,
    //   deleteOrigin: false,
    //   includeAudio: true,
    // ).then((value) {
    //   print("Comprssed file is at ${value!.path}");
    // });

    // showModalBottomSheetCupetino();
  }

  ImagePicker picker = new ImagePicker();
  void _recordVideo() async {
    picker
        .pickVideo(
            source: ImageSource.camera,
            maxDuration: Duration(seconds: 30),
            preferredCameraDevice:
                !_isRearCameraSelected ? CameraDevice.rear : CameraDevice.front)
        .then((recordedVideo) {
      if (recordedVideo != null && recordedVideo.path != null) {
        setState(() {
          // secondButtonText = 'saving in progress...';
          imagex = File(recordedVideo.path);
        });
        GallerySaver.saveVideo(recordedVideo.path).then((path) {
          setState(() {
            // secondButtonText = 'video saved!';
            showModalBottomSheetCupetino();
          });
        });
      }
    });
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

  List<String> topics = [];
  void initState() {
    super.initState();

    print("topics are $topics");
    WidgetsFlutterBinding.ensureInitialized();
    getPermissionStatus();
    c.getshared("topics").then((value) {
      // print("CatVal $value");
      if (value != '' && value != null && value != ' ' && value != 'null') {
        decodeCat(value);
      }
      _category();
    });
  }

  void onDonePress() {
    print("End of slides");
    Navigator.pop(context);
    Navigator.push(context, CupertinoPageRoute(builder: (context) => Topics()));
  }

  var currentSelectedValue;

  void showModalBottomSheetCupetino() async {
    await showCupertinoModalBottomSheet(
      useRootNavigator: true,
      context: context,
      bounce: true,
      isDismissible: true,
      expand: true,
      builder: (context) => Material(child: StatefulBuilder(builder:
          (BuildContext context,
              StateSetter setState /*You can rename this!*/) {
        return Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            // mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 17),
                      child: AutoSizeText(
                        "What's New",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: c.getFontSizeLarge(context),
                          fontWeight: FontWeight.w800,
                        ),
                      )),
                ],
              ),
              Card(
                margin: EdgeInsets.only(
                  top: 30.0,
                  left: MediaQuery.of(context).size.height * 0.02,
                  right: MediaQuery.of(context).size.height * 0.02,
                ),
                shape: BeveledRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                color: c.getColor("light_blue"),
                child: Container(
                  height: 220,
                  width: 120,
                  child: Center(
                    child: Image.asset("assets/icons/video.png"),
                  ),
                ),
              ),
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
                        fontSize: c.getFontSize(context),
                        color: Colors.black.withOpacity(0.7)),
                    controller: caption,
                    maxLength: 200,
                    decoration: InputDecoration(
                      hintText: " Caption",
                      fillColor: c.getColor("light_blue"),
                      filled: true, // dont forget this line
                      hintStyle: TextStyle(
                          fontSize: c.getFontSize(context),
                          color: Colors.black.withOpacity(0.7)),
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
                  // top: 30.0,r
                  left: MediaQuery.of(context).size.height * 0.02,
                  right: MediaQuery.of(context).size.height * 0.02,
                ),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.082,
                  width: MediaQuery.of(context).size.width * 8.0,
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    controller: location,
                    maxLength: 100,
                    validator: (value) {
                      if (value!.isEmpty) {
                        // return 'Mobile number is mandatory';
                        return 'Cannot send empty comments';
                      }
                    },
                    style: TextStyle(
                        fontSize: c.getFontSize(context),
                        color: Colors.black.withOpacity(0.7)),
                    decoration: InputDecoration(
                      hintText: " Location",
                      fillColor: c.getColor("light_blue"),
                      filled: true, // dont forget this line
                      hintStyle: TextStyle(
                          fontSize: c.getFontSize(context),
                          color: Colors.black.withOpacity(0.7)),
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
              Container(
                padding: EdgeInsets.only(
                  bottom: 30.0,
                  left: MediaQuery.of(context).size.height * 0.02,
                  right: MediaQuery.of(context).size.height * 0.02,
                ),
                child: FormField<String>(
                  builder: (FormFieldState<String> state) {
                    return InputDecorator(
                      decoration: InputDecoration(
                          fillColor: c.getColor("light_blue"),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          )),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          hint: Text("Topics"),
                          value: currentSelectedValue,
                          isDense: true,
                          onChanged: (newValue) {
                            setState(() {
                              currentSelectedValue = newValue;
                            });
                            print(currentSelectedValue);
                          },
                          items: topics.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
              ),
              _isSubmitted
                  ? Center(
                      child: LinearProgressIndicator(),
                    )
                  : Padding(
                      padding: EdgeInsets.only(
                        // top: 30.0,
                        bottom: 30.0,
                        left: MediaQuery.of(context).size.height * 0.02,
                        right: MediaQuery.of(context).size.height * 0.02,
                      ),
                      child: InkResponse(
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              _isSubmitted = true;
                            });
                            // Navigator.of(context).pop("cancel");
                            c.getshared("user_id").then((value) {
                              _login(value);
                            });
                            StatusAlert.show(
                              context,
                              duration: Duration(seconds: 2),
                              title: 'Added Post!',
                              subtitle:
                                  'Processing Completed, Your post will be visible to everyone now!',
                              configuration: IconConfiguration(
                                icon: Icons.done_all,
                              ),
                              // maxWidth: 260,
                            );
                            Future.delayed(Duration(seconds: 1), () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Profile()));
                            });
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(13),
                          decoration: BoxDecoration(
                            color: c.getColor("black"),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              "POST",
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
                  Navigator.of(context).pop("cancel");
                },
                child: Center(
                  child: Text(
                    "Close",
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.7),
                      // fontWeight: FontWeight.w600,
                      fontSize: c.getFontSizeLabel(context),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      })),
    );
  }

  compress(path) async {
    MediaInfo? mediaInfo = await VideoCompress.compressVideo(
      path,
      quality: VideoQuality.DefaultQuality,
      deleteOrigin: false, // It's false by default
    );
    setState(() {
      var str = mediaInfo!.path;
      imagex = File(str!);
    });
  }

  _login(user_id) async {
    setState(() {
      print("trying");
      _isSubmitted = true;
      FocusManager.instance.primaryFocus?.unfocus();
    });
    try {
      var dio = Dio();

      final result = await InternetAddress.lookup('www.google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        FormData formData = FormData.fromMap({
          "savePosts": "savePosts",
          "location": location.text.toString(),
          "caption": caption.text.toString(),
          "topic": currentSelectedValue.toString(),
          "user_id": user_id,
          "files": await MultipartFile.fromFile(
            (imagex!.path),
            filename: (imagex!.path).toString().split("/").last,
          ),
        });
        print(formData);
        try {
          form_response = await dio.post(
            c.getURL() + 'posts.php',
            data: formData,
          );
          print(form_response);
        } on DioError catch (e) {
          print(e.message);
        }
        setState(() {
          print("Response got in login " + form_response.toString().trim());
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
            setState(() {
              _isSubmitted = false;
            });
            getThumbFromUrl(data![0]['video'], (data![0]['last_id']));
            // showInSnackBar("Sign in completed please wait...");

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

  Future getThumbFromUrl(url, id) async {
    print('[Getting Thumbnail File] start');

    final thumbnailFile =
        await VideoCompress.getFileThumbnail(url, quality: 50);
    _updateThumb(id, thumbnailFile);
  }

  _updateThumb(id, img) async {
    var user_id = '';
    File _img = File(img.path);
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
          "updatePosts": "updatePosts",
          "user_id": user_id,
          "post_id": id,
          "files": await MultipartFile.fromFile(
            img!.path,
            filename: _img.path.toString().split("/").last,
          ),
        });
        try {
          form_response = await dio.post(
            c.getURL() + 'posts.php',
            data: formData,
          );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Stack(
                children: [
                  SizedBox(
                      height: c.deviceHeight(context),
                      width: c.deviceWidth(context),
                      child: !_isCameraPermissionGranted
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(),
                                Padding(
                                  padding: const EdgeInsets.all(18.0),
                                  child: Text(
                                    'Camera permssion is denied, make sure camera pemission is allowed from settings and restart the app.',
                                    textAlign: TextAlign.justify,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: SystemSettings.app,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Give Permission',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : CameraPreview(_Cameracontroller)),
                  Positioned(
                    top: 5,
                    child: Container(
                      width: c.deviceWidth(context),
                      padding: EdgeInsets.all(15),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
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
                                  Icons.close,
                                  color: Colors.white,
                                  size: c.deviceWidth(context) * 0.09,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                getimage(false, "image");
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
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
                                      Icons.image,
                                      color: Colors.white,
                                      size: c.deviceWidth(context) * 0.06,
                                    ),
                                  ),
                                  Container(
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.2),
                                              blurRadius: 10.0,
                                            ),
                                          ]),
                                      child: Text(
                                        "Pick from gallery",
                                        style: TextStyle(
                                            fontSize: c.getFontSize(context),
                                            color: Colors.white,
                                            fontFamily: c.fontFamily()),
                                      ))
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _isCameraInitialized = false;
                                });
                                onNewCameraSelected(
                                    cameras[_isRearCameraSelected ? 1 : 0]);
                                setState(() {
                                  _isRearCameraSelected =
                                      !_isRearCameraSelected;
                                });
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
                                  Icons.crop_rotate_rounded,
                                  color: Colors.white,
                                  size: c.deviceWidth(context) * 0.07,
                                ),
                              ),
                            ),
                          ]),
                    ),
                  ),
                  Positioned(
                      bottom: 10,
                      right: c.deviceWidth(context) * 0.4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (recording)
                            Text(
                              recordingTime,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: c.fontFamily(),
                                  fontSize: c.getFontSizeLabel(context)),
                            ),
                          Divider(),
                          InkWell(
                            onTap: () {
                              setState(() {
                                isimage = false;
                              });
                              // if (recording) {
                              //   stopvideo();
                              // } else {
                              //   recordTime();
                              //   startvideo();
                              // }
                              _recordVideo();
                              recordTime();
                              // Navigator.push(context,
                              //     CupertinoPageRoute(builder: (_) => SamplePage()));
                            },
                            child: Icon(
                              recording
                                  ? Icons.fiber_manual_record
                                  : Icons.fiber_manual_record_outlined,
                              color: Colors.red,
                              size: c.deviceWidth(context) * 0.2,
                            ),
                          )
                        ],
                      ))
                ],
              ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}

class FileVideo extends StatefulWidget {
  String videofile;
  FileVideo({required this.videofile});
  @override
  _FileVideoState createState() => _FileVideoState();
}

class _FileVideoState extends State<FileVideo> {
  late VideoPlayerController _controller;
  Future<void>? _initializavideplayerfuture;
  bool playing = false;
  ChewieController? chcontroller;
  void initState() {
    //print("start");

    // TODO: implement initState
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videofile));
    _initializavideplayerfuture = _controller.initialize().then(
      (value) {
        print(_controller.value.aspectRatio);
        chcontroller = ChewieController(
          allowPlaybackSpeedChanging: false,
          //isLive: true,
          // showControls: false,
          showOptions: false,
          aspectRatio: _controller.value.aspectRatio,
          videoPlayerController: _controller,
          autoPlay: false,
          looping: false,
          autoInitialize: true,
          overlay: Padding(
            padding: const EdgeInsets.all(10),
            child: Image.asset(
              "assets/logo.gif",
              height: 30,
            ),
          ),
        );
        //chcontroller!.autoInitialize;
        setState(() {});
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    chcontroller!.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      // _controller.value.aspectRatio < 1
      //     ? 1
      //     : _controller.value.aspectRatio,
      child: chcontroller != null &&
              chcontroller!.videoPlayerController.value.isInitialized
          ? FittedBox(
              fit: BoxFit.cover,
              child: Chewie(
                controller: chcontroller!,
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/logo.png",
                  height: 20,
                ),
              ],
            ),
    );
    // Stack(
  }
}
