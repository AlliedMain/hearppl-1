import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Constants {
  fontFamily({type = "regular"}) {
    return type == 'regular' ? 'popins' : 'popins_bold';
  }

  deviceWidth(context) {
    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return isPortrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;
  }

  deviceHeight(context) {
    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return isPortrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
  }

  redColor() {
    return Color(0xC4F04444);
  }

  primaryColor() {
    return const Color(0xff407BFF);
  }

  secondaryColor() {
    return const Color(0xffF42B5B);
  }

  tertiaryColor() {
    return const Color(0xffB9B9B9);
  }

  whiteColor() {
    return const Color(0xffffffff);
  }

  backgroundColor() {
    return const Color(0xff808080);
  }

  blackColor({opc = 1.0}) {
    return const Color(0xff000000).withOpacity(opc);
  }

  getFontSizeMedium(context) {
    return deviceHeight(context) * 0.018;
  }

  getFontSize(context) {
    return deviceHeight(context) * 0.018;
  }

  getFontSizeSmall(context) {
    return deviceHeight(context) * 0.02;
  }

  getFontSizeXS(context) {
    return deviceHeight(context) * 0.017;
  }

  getFontSizeLabel(context) {
    return deviceHeight(context) * 0.021;
  }

  getFontSizeLarge(context) {
    return deviceHeight(context) * 0.035;
  }

  getColor(str) {
    if (str == 'green') {
      return Colors.green;
    } else if (str == 'red') {
      return Colors.red;
    } else if (str == 'yellow') {
      return Colors.yellow;
    } else if (str == 'blue') {
      return Colors.blue;
    } else if (str == 'orange') {
      return Colors.orange;
    } else if (str == 'pink') {
      return Colors.pink;
    } else if (str == 'grey') {
      return const Color(0xffBDBDBD);
    } else if (str == 'black') {
      return const Color(0xff252525);
    } else if (str == 'light_black') {
      return const Color(0xff808080);
    } else if (str == 'light_blue') {
      return const Color(0xffDAF1FF);
    } else if (str == 'dark_blue') {
      return const Color(0xff407BFF);
    }
  }

  getURL() {
    return 'https://hamiters.com/Hamiters/hearppl/';
  }

  getAppBar(title, context, {transition = false}) {
    return CupertinoNavigationBar(
      padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),

      // backgroundColor:  getBrownColor(),
      // actionsForegroundColor: getWhit  eColor(),
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,

      transitionBetweenRoutes: transition,

      middle: Text(
        title,
        style: TextStyle(
            fontFamily: fontFamily(),
            letterSpacing: 1.1,
            color: Colors.black,
            // fontWeight: FontWeight.bold,
            fontSize: getFontSizeSmall(context)),
      ),
    );
  }

  getDivider(height) {
    return Divider(
      height: height,
      color: Colors.transparent,
    );
  }

  showInSnackBar(context, String value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value),
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<bool> setshared(String name, String value) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString(name, value);
    return true;
  }

  Future<String> getshared(String skey) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(skey).toString();
  }
}
