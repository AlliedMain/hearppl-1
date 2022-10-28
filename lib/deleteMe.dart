import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';

class DeleteMe extends StatefulWidget {
  @override
  _DeleteMeState createState() => _DeleteMeState();
}

class _DeleteMeState extends State<DeleteMe> {
  String firstButtonText = 'Take photo';
  String secondButtonText = 'Record video';
  double textSize = 20;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          Flexible(
            flex: 1,
            child: Container(
              child: SizedBox.expand(
                child: TextButton(
                  // color: Colors.blue,
                  onPressed: () {},
                  child: Text(firstButtonText,
                      style:
                          TextStyle(fontSize: textSize, color: Colors.white)),
                ),
              ),
            ),
          ),
          Flexible(
            child: Container(
                child: SizedBox.expand(
              child: TextButton(
                // color: Colors.white,
                onPressed: _recordVideo,
                child: Text(secondButtonText,
                    style:
                        TextStyle(fontSize: textSize, color: Colors.blueGrey)),
              ),
            )),
            flex: 1,
          )
        ],
      ),
    ));
  }

  ImagePicker picker = new ImagePicker();

  void _recordVideo() async {
    picker.pickVideo(source: ImageSource.camera).then((recordedVideo) {
      if (recordedVideo != null && recordedVideo.path != null) {
        setState(() {
          secondButtonText = 'saving in progress...';
        });
        GallerySaver.saveVideo(recordedVideo.path).then((path) {
          setState(() {
            secondButtonText = 'video saved!';
          });
        });
      }
    });
  }
}
