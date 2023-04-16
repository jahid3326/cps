import 'dart:async';

import 'package:cps/pages/admin/dashboard.dart';
import 'package:cps/pages/garage/dashboard.dart';
import 'package:cps/pages/motorist/dashboard.dart';
import 'package:cps/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.title});

  final String title;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin{
  late AnimationController _controller;
  bool _isVisible = false;

  bool logged_in = false;
  String? user_type;

  Future getUserData()async{
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    bool? getLoggedIn = sharedPreferences.getBool('logged_in');
    String? getUserType = sharedPreferences.getString('user_type');

    setState(() {
      logged_in = getLoggedIn!;
      user_type = getUserType;
    });
  }

  _SplashScreenState(){

    // new Timer(
    //   Duration(milliseconds: 2000), (){
    //     setState(() {
    //       Navigator.of(context).pushAndRemoveUntil(
    //         MaterialPageRoute(builder: (context)=>LoginPage()), (route) => false);
    //     });
    //   }
    // );

    new Timer(
      Duration(milliseconds: 10), (){
        setState(() {
          _isVisible = true;
        });
      }
    );
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black
        // gradient: LinearGradient(
        //   colors: [Theme.of(context).accentColor, Theme.of(context).primaryColor],
        //   begin: FractionalOffset(0.0, 0.0),
        //   end: FractionalOffset(1.0, 0.0),
        //   stops: [0.0, 1.0],
        //   tileMode: TileMode.clamp
        // )
      ),
      child: Center(
        child: AnimatedOpacity(
            opacity: _isVisible ? 1.0 : 0,
            duration: Duration(milliseconds: 1200),
            child: Padding(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Lottie.asset(
                'assets/animations/car_parking.json',
                alignment: Alignment.center,
                controller: _controller,
                onLoaded: (composition) {
                  _controller
                    ..duration = composition.duration
                    ..forward().whenComplete(() => getUserData().whenComplete(() async{
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context){
                          if(logged_in){
                            if(user_type! == "motorist"){
                              return DashboardMotorist();
                            }else if(user_type! == "garage"){
                              return DashboardGarage();
                            }else if(user_type! == "admin"){
                              return DashboardAdmin();
                            }
                          }
                          return LoginPage();
                        })
                        //MaterialPageRoute(builder: (context)=> logged_in ? MainPageMotorist(page: 1) : LoginPage())
                      );
                    }));
                },
              ),
            ),
          ),
      )
      /*
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedOpacity(
            opacity: _isVisible ? 1.0 : 0,
            duration: Duration(milliseconds: 1200),
            child: Padding(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Lottie.asset(
                'assets/animations/car_parking.json',
                alignment: Alignment.center,
                controller: _controller,
                onLoaded: (composition) {
                  _controller
                    ..duration = composition.duration
                    ..forward().whenComplete(() => getUserData().whenComplete(() async{
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context){
                          if(logged_in){
                            if(user_type! == "motorist"){
                              return DashboardMotorist();
                            }else if(user_type! == "garage"){
                              return DashboardGarage();
                            }else if(user_type! == "admin"){
                              return DashboardAdmin();
                            }
                          }
                          return LoginPage();
                        })
                        //MaterialPageRoute(builder: (context)=> logged_in ? MainPageMotorist(page: 1) : LoginPage())
                      );
                    }));
                },
              ),
            ),
          )
        ],
      )
      */
    );
  }
}