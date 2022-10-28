import 'package:cached_video_player/cached_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:hearppl/constants.dart';
import 'package:hearppl/explore.dart';
import 'package:hearppl/feedView.dart';
import 'package:hearppl/feeds.dart';
import 'package:hearppl/notifictaions.dart';
import 'package:hearppl/profile.dart';
import 'home.dart';

class BottomNav extends StatefulWidget {
  final currentPage, url;

  BottomNav({this.currentPage, this.url});

  @override
  _BottomNavState createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  var _currentIndex = 0;
  Constants c = new Constants();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      elevation: 0,
      backgroundColor: c.getColor("dark_blue"),
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: false,
      currentIndex: widget.currentPage,
      selectedItemColor: Colors.black,
      items: [
        BottomNavigationBarItem(
          backgroundColor: c.tertiaryColor(),
          icon: Icon(
            Icons.home,
            color: Colors.white,
            size: 26,
          ),
          activeIcon: Icon(
            Icons.home,
            color: Colors.black,
            size: 26,
          ),
          label: "Home",
        ),
        BottomNavigationBarItem(
            icon: Icon(
              Icons.search_rounded,
              color: Colors.white,
              size: 26,
            ),
            activeIcon: Icon(
              Icons.search_rounded,
              color: Colors.black,
              size: 26,
            ),
            label: "Explore"),
        BottomNavigationBarItem(
            icon: Icon(
              Icons.video_collection_rounded,
              color: Colors.white,
              size: 26,
            ),
            activeIcon: Icon(
              Icons.video_collection_rounded,
              color: Colors.black,
              size: 26,
            ),
            label: "Feeds"),
        BottomNavigationBarItem(
            icon: Icon(
              Icons.notifications_active,
              color: Colors.white,
              size: 26,
            ),
            activeIcon: Icon(
              Icons.notifications_active,
              color: Colors.black,
              size: 26,
            ),
            label: "Activity"),
        BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              color: Colors.white,
              size: 26,
            ),
            activeIcon: Icon(
              Icons.person,
              color: Colors.black,
              size: 26,
            ),
            label: "Profile"),
      ],
      onTap: (index) {
        _currentIndex = widget.currentPage;
        if (index == 0) {
          Navigator.pop(context);
          Navigator.push(
              context, CupertinoPageRoute(builder: (context) => Home()));
          // Navigator.of(context).pushNamedAndRemoveUntil(
          //     '/HomePage', (Route<dynamic> route) => false);
        }
        if (index == 1) {
          Navigator.pop(context);
          Navigator.push(
              context, CupertinoPageRoute(builder: (context) => Explore()));
          // Navigator.of(context).pushNamedAndRemoveUntil(
          //     '/LearnPage', (Route<dynamic> route) => false);
        }
        if (index == 2) {
          Navigator.pop(context);
          Navigator.push(
              context, CupertinoPageRoute(builder: (context) => Feeds()));
        }
        if (index == 3) {
          Navigator.pop(context);
          Navigator.push(context,
              CupertinoPageRoute(builder: (context) => Notifications()));
        }
        if (index == 4) {
          Navigator.pop(context);
          Navigator.push(
              context, CupertinoPageRoute(builder: (context) => Profile()));
        }
      },
    );
  }
}
//for Logout and remove all presvios BACK
//Navigator.of(context).pushNamedAndRemoveUntil('/screen4', (Route<dynamic> route) => false);
