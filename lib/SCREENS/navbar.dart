import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import 'CALCULATER_SCREEN/calculater.dart';
import 'GOALS_SCREEN/goals.dart';
import 'HOME_SCREEN/home.dart';
import 'PROFILE_SCREEN/profile.dart';
import 'TRANSACTION_SCREEN/Create.dart';




class NavbarSide extends StatefulWidget {
  final int currentIndex;

  const NavbarSide(this.currentIndex, {Key? key}) : super(key: key);

  @override
  State<NavbarSide> createState() => _NavbarSideState();
}

class _NavbarSideState extends State<NavbarSide> {
  late PersistentTabController _controller;


  final List<Widget> _pages = [
    Home(),
    Goals(),
    AddTransactionPage(),
    Calculater(),
    Profile()

  ];

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: widget.currentIndex);
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
      icon: Transform.translate(
        offset: const Offset(0, 4), // move DOWN
        child: ImageIcon(
          AssetImage('assets/Home.png'),
          size: 24,
        ),
      ),
      title: "Home",
      activeColorPrimary: Colors.blueAccent,
      inactiveColorPrimary: Colors.grey,
    ),
      PersistentBottomNavBarItem(
        icon: Transform.translate(
          offset: const Offset(0, 4), // move DOWN
          child: ImageIcon(
            AssetImage('assets/Goals.png'),
            size: 24,
          ),
        ),
        title: "Goals",
        activeColorPrimary: Colors.blueAccent,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.add, color: Colors.white),
        title: "Create",
        activeColorPrimary: Colors.blueAccent,
        inactiveColorPrimary: Colors.blueAccent,
        iconSize: 35,
/*        onPressed: (context) {
          showProfessionalBottomSheet(context!);
        },*/
      ),
      PersistentBottomNavBarItem(
        icon: Transform.translate(
          offset: const Offset(0, 4), // move DOWN
          child: ImageIcon(
            AssetImage('assets/Calculator.png'),
            size: 24,
          ),
        ),
        title: "Calculator",
        activeColorPrimary: Colors.blueAccent,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Transform.translate(
          offset: const Offset(0, 4), // move DOWN
          child: ImageIcon(
            AssetImage('assets/Profile.png'),
            size: 24,
          ),
        ),
        title: "Profile",
        activeColorPrimary: Colors.blueAccent,
        inactiveColorPrimary: Colors.grey,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: _controller,
      screens: _pages,
      items: _navBarsItems(),
      confineToSafeArea: true,
      backgroundColor: Colors.white,
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(0.0),
        colorBehindNavBar: Colors.white,
      ),
      navBarStyle: NavBarStyle.style15,
    );
  }
}