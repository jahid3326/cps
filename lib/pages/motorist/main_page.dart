import 'package:cps/pages/motorist/dashboard.dart';
import 'package:cps/pages/motorist/garage.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar_with_label/curved_navigation_bar.dart';

class MainPageMotorist extends StatefulWidget {
  MainPageMotorist({super.key, required this.page});

  final int page;
  
  @override
  State<MainPageMotorist> createState() => _MainPageMotoristState();
}

class _MainPageMotoristState extends State<MainPageMotorist> {
  
  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  final pages = [
    DashboardMotorist(),
    // MyAccountMotorist(),
    GarageMotorist(),
    // SettingMotorist()
  ];

  int? _page;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _page = widget.page;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: _page!,
        height: 76.0,
        buttonBackgroundColor: Colors.grey.shade400,
        color: Colors.blue,
        items: [
          CurvedNavigationBarItem(icon: Icon(Icons.dashboard, size: 30), label: "Dashboard"),
          CurvedNavigationBarItem(icon: Icon(Icons.account_box_outlined, size: 30), label: "My Account"),
          CurvedNavigationBarItem(icon: Icon(Icons.car_rental_outlined, size: 30), label: "Garage"),
          CurvedNavigationBarItem(icon: Icon(Icons.settings, size: 30), label: "Settings"),
        ],
        backgroundColor: Colors.blueAccent,
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 600),
        onTap: (index) {
          setState(() {
            _page = index;
          });
        },
        letIndexChange: (index) => true,
      ),
      body: pages[_page!],
    );
  }
}