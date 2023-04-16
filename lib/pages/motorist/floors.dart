import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cps/common/theme_helper.dart';
import 'package:cps/pages/login_page.dart';
import 'package:cps/pages/motorist/garage_floor_map.dart';
import 'package:cps/pages/motorist/main_page.dart';
import 'package:cps/pages/motorist/sidebar_nav.dart';
import 'package:cps/pages/network_utility.dart';
import 'package:cps/pages/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:cps/pages/widgets/header_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:multilevel_drawer/multilevel_drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;



class FloorsMotorist extends StatefulWidget {
  FloorsMotorist({super.key, required this.garage_id, required this.garage_name});

  String garage_id;
  String garage_name;

  @override
  State<FloorsMotorist> createState() => _FloorsMotoristState();
}

class _FloorsMotoristState extends State<FloorsMotorist> {
  Timer? _timer;
  double  _drawerIconSize = 24;
  double _drawerFontSize = 17;

  bool logged_in = false;
  String? user_type;
  String? user_id;
  String? first_name;
  String? last_name;
  String? user_name;
  String? user_email;
  String? profile_picture;

  String? getProfilePictureName;

  Future getUserData()async{
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    bool? getLoggedIn = sharedPreferences.getBool('logged_in');
    String? getUserType = sharedPreferences.getString('user_type');
    String? getUserId = sharedPreferences.getString('user_id');
    String? getFirstName = sharedPreferences.getString('first_name');
    String? getLastName = sharedPreferences.getString('last_name');
    String? getUserName = sharedPreferences.getString('user_name');
    String? getUserEmail = sharedPreferences.getString('user_email');
    String? getProfilePicture = sharedPreferences.getString('profile_picture');

    setState(() {
      logged_in = getLoggedIn!;
      user_type = getUserType;
      user_id = getUserId;
      first_name = getFirstName;
      last_name = getLastName;
      user_name = getUserName;
      user_email = getUserEmail;
      profile_picture = getProfilePicture;
    });
  }
  
  var data=[];
  bool floorCount = true;

  Future <List<Floors>> getFloor() async{
    var client = http.Client();

    _timer?.cancel();
      
    EasyLoading.instance
      ..loadingStyle = EasyLoadingStyle.light;

    await EasyLoading.show(
      maskType: EasyLoadingMaskType.black,
      indicator: Lottie.asset("assets/animations/loading.json", width: 125, height: 75)
    );

    var res = await client.get(Uri.https("creativeparkingsolutions.com", "motorist/get_floors_app/${widget.garage_id}"));
    
    var jsonData = jsonDecode(res.body);

    if(res.statusCode == 200){
      EasyLoading.dismiss();  
    }
    //print(jsonData['floor_count']);
    jsonData['floor_count'] > 0 ? floorCount = true : floorCount = false;

    List<Floors> floors = [];

    for(var jsonFloors in jsonData['floors']){
      var floor_id = jsonFloors['id'];
      var floor_no = jsonFloors['floor_no'];
      Floors floor = Floors(floor_id: floor_id, floor_no: floor_no);

      floors.add(floor);
    }

    return floors;

  }

  // Future<void> getGarages()async{
  //   var client = http.Client();

  //   try {
  //     _timer?.cancel();
        
  //     EasyLoading.instance
  //       ..loadingStyle = EasyLoadingStyle.light;

  //     await EasyLoading.show(
  //       maskType: EasyLoadingMaskType.black,
  //       indicator: Lottie.asset("assets/animations/loading.json", width: 125, height: 75)
  //     );
      
  //     var res = await client.get(Uri.https("creativeparkingsolutions.com", "/get_garages_app"));

  //     print(res.statusCode);

  //     var jsonData = jsonDecode(res.body);

  //     print(jsonData['garages']);
  //     print("ok");

  //   } catch (e) {
  //     print(e);
  //   }
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getUserData().whenComplete(()async{
      setState(() {
        logged_in = logged_in;
        getProfilePictureName = profile_picture;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("Floors",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0.5,
        iconTheme: IconThemeData(color: Colors.white),
        flexibleSpace:Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[Theme.of(context).primaryColor, Theme.of(context).accentColor,]
              )
          ),
        ),
        // actions: [
        //   Container(
        //     margin: EdgeInsets.only( top: 16, right: 16,),
        //     child: Stack(
        //       children: <Widget>[
        //         Icon(Icons.notifications),
        //         Positioned(
        //           right: 0,
        //           child: Container(
        //             padding: EdgeInsets.all(1),
        //             decoration: BoxDecoration( color: Colors.red, borderRadius: BorderRadius.circular(6),),
        //             constraints: BoxConstraints( minWidth: 12, minHeight: 12, ),
        //             child: Text( '5', style: TextStyle(color: Colors.white, fontSize: 8,), textAlign: TextAlign.center,),
        //           ),
        //         )
        //       ],
        //     ),
        //   )
        // ],
      ),
      drawer: SideBarNav(profilePicture: "$profile_picture", userName: "$user_name", userEmail: "$user_email",),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        height: 70.0,
        width: 70.0,
        child: FittedBox(
          child: FloatingActionButton(
            onPressed: () {},
            backgroundColor: Colors.blue.shade500,
            child: Image.asset("assets/images/cps_logo.png", fit: BoxFit.fitWidth,),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blue.shade500,
        shape: CircularNotchedRectangle(),
        child: Container(
          height: 50,
        ),
      ),
      body: Column(
        children: [
          Stack(
            children: [
              Container(height: 100, child: HeaderWidget(100,false,Icons.house_rounded),),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: getProfilePictureName != '' ?
                  ClipOval(
                    child: FadeInImage.assetNetwork(
                      placeholder: "assets/animations/avator.gif",
                      image: "https://creativeparkingsolutions.com/public/assets/motorist/images/user/$getProfilePictureName",
                      height: 120,
                      width: 120,
                      fit: BoxFit.cover,
                      fadeInDuration: Duration(milliseconds: 5),
                      fadeOutDuration: Duration(milliseconds: 5),
                    ),
                  ):
                  ClipOval(
                    child: Image(image: AssetImage("assets/images/avatar.jpg"), height: 120, width: 120,),
                  ),
              ),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.fromLTRB(10, 125, 10, 0),
                child: Text(
                  "Floors of ${widget.garage_name}",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
                )
              ),
            ],
          ),
          Expanded(
            child: Scrollbar(
                  isAlwaysShown: true, //always show scrollbar
                  thickness: 5, //width of scrollbar
                  radius: Radius.circular(20), //corner radius of scrollbar
                  scrollbarOrientation: ScrollbarOrientation.right, //which side to show scrollbar
                  child: Container(
                    padding: EdgeInsets.all(20),
                    
                    child: FutureBuilder(
                      future: getFloor(),
                      builder: (context, snapshot){
                        if(floorCount == false){
                          return Center(child: Text("Floor not found!", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18),));
                        }else{
                          if(snapshot.data == null){
                            return Text("");
                          }else{
                            List<Floors> floors = snapshot.data!;
                            return GridView.builder(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index){
                                Floors floor = floors[index];
                                return Card(
                                  color: Colors.blue.shade200,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        GestureDetector(
                                          child: CircleAvatar(
                                            backgroundColor: Colors.blue.shade600,
                                            child: Icon(Icons.arrow_forward_ios_rounded, size: 25,),
                                          ),
                                          onTap: () {
                                            // print("Click on garage");
                                            Navigator.push(context, MaterialPageRoute(builder: (context)=> GarageFloorMapMotorist(garage_id: widget.garage_id, floor_no: floor.floor_no)));
                                          },
                                        ),
                                        SizedBox(height: 5,),
                                        Text(
                                          "Floor ${floor.floor_no}",
                                          style: TextStyle(fontSize: 16),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              }
                            );
                          }
                        }
                        
                      }
                    ),
                  )
              )
          ),
        ],
      ),
    );
  }
}

class Floors{
  final String floor_id;
  final String floor_no;
  Floors({required this.floor_id, required this.floor_no});
}