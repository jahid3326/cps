import 'dart:async';
import 'dart:convert';

import 'package:cps/common/theme_helper.dart';
import 'package:cps/pages/motorist/floor_map.dart';
import 'package:cps/pages/motorist/garage_map.dart';
import 'package:cps/pages/motorist/package.dart';
import 'package:cps/pages/motorist/sidebar_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:cps/pages/widgets/header_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:search_map_location/utils/google_search/latlng.dart';
import 'package:search_map_location/utils/google_search/place.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:search_map_location/search_map_location.dart';
import 'package:http/http.dart' as http;



class DashboardMotorist extends StatefulWidget {
  const DashboardMotorist({super.key});

  @override
  State<DashboardMotorist> createState() => _DashboardMotoristState();
}

class _DashboardMotoristState extends State<DashboardMotorist> {
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

  double? lat;
  double? lng;

  var isData = "not_selected";
  var garages;

  Future<void> getGarages()async{
    var client = http.Client();

    try {
      
      EasyLoading.instance
        ..loadingStyle = EasyLoadingStyle.light;

      await EasyLoading.show(
        maskType: EasyLoadingMaskType.black,
        indicator: Lottie.asset("assets/animations/loading.json", width: 125, height: 75)
      );

      var res = await client.post(Uri.https('creativeparkingsolutions.com', '/public/testgarage.php'), body: {
          'lat' : lat.toString(),
          'lng' : lng.toString(),
      });
      print(res.statusCode);
      
      var response = jsonDecode(res.body);

      if(res.statusCode == 200){
        EasyLoading.dismiss();

        setState(() {
          isData = response['data']['found'];
          garages = response['gdata'];
          // print(garages);
        });
      }

      // print(response);

    } catch (e) {
      print(e);
    }
  }

  DateTime? createDate;
  DateTime? expireDate;

  DateTime? dayCreateDate;
  DateTime? dayExpireDate;

  var expireFound = 0;
  var dayExpireFound = 0;

  Future<void> setExpired()async{
    var client = http.Client();

    try {
      
      var res = await client.post(Uri.https('creativeparkingsolutions.com', '/public/set_expire.php'), body: {
          'motorist_id' : user_id,
      });
      print(res.statusCode);
      
      var response = jsonDecode(res.body);

      
      
      setState(() {
        expireFound = response['found'];
        dayExpireFound = response['found_day'];
        if(response['found'] == 1){
          createDate = DateTime.parse(response['createDate']);
          expireDate = DateTime.parse(response['expireDate']);
        }
        
        if(response['found_day'] == 1){
          dayCreateDate = DateTime.parse(response['dayCreateDate']);
          dayExpireDate = DateTime.parse(response['dayExpireDate']);
        }
        
      });
      if(expireFound == 1){
        startCountdown();
      }

      if(dayExpireFound == 1){
        startCountdown2();
      }

      // print(response['expireDate']);
      // print(expireDate);
      // print("object : ${user_id}");

    } catch (e) {
      print(e);
    }
  }

  var _days;
  var _hours;
  var _minutes;
  var _seconds;

  String time = "";
  Timer? mytimer;
  Timer? mytimer2;

  void startCountdown(){
    
    mytimer = Timer.periodic(Duration(seconds: 1), (timer) {
        DateTime timenow = DateTime.now().toUtc().add(Duration(hours: -7));  //get current date and time PST
        
        DateTime timenow2 = DateTime.parse(timenow.toString().split('.')[0]);
        Duration diff = expireDate!.difference(timenow2);
        
        var milliseconds = diff.inMilliseconds.toString();
        if(double.parse(milliseconds) > 0){
          var days = double.parse(milliseconds) / (1000*60*60*24);
          var hours = (double.parse(milliseconds) % (1000*60*60*24))/(1000*60*60);
          var minutes = (double.parse(milliseconds) % (1000*60*60))/(1000*60);
          var seconds = (double.parse(milliseconds) % (1000*60))/(1000);

          // time = days.floor().toString().padLeft(2,'0') + ":" + hours.floor().toString().padLeft(2,'0') + ":" + minutes.floor().toString().padLeft(2,'0') + ":" + seconds.floor().toString().padLeft(2,'0'); 
          // time = timenow.toString();
          setState(() {
            _days = days;
            _hours = hours;
            _minutes = minutes;
            _seconds = seconds;
          });
        }else{
          disabled_package('not_day');
          setState((){
            expireFound = 0;
          });
          mytimer?.cancel(); //to terminate this timer
        }
        
     });
  }

  void startCountdown2(){
    
    mytimer2 = Timer.periodic(Duration(seconds: 1), (timer) {
        DateTime timenow = DateTime.now().toUtc().add(Duration(hours: -7));  //get current date and time PST
        
        DateTime timenow2 = DateTime.parse(timenow.toString().split('.')[0]);
        Duration diff = dayExpireDate!.difference(timenow2);
        
        var milliseconds = diff.inMilliseconds.toString();
        if(double.parse(milliseconds) > 0){
          var days = double.parse(milliseconds) / (1000*60*60*24);
          var hours = (double.parse(milliseconds) % (1000*60*60*24))/(1000*60*60);
          var minutes = (double.parse(milliseconds) % (1000*60*60))/(1000*60);
          var seconds = (double.parse(milliseconds) % (1000*60))/(1000);

          // time = days.floor().toString().padLeft(2,'0') + ":" + hours.floor().toString().padLeft(2,'0') + ":" + minutes.floor().toString().padLeft(2,'0') + ":" + seconds.floor().toString().padLeft(2,'0'); 
          // time = timenow.toString();
        }else{
          disabled_package('day');
          setState((){
            dayExpireFound = 0;
          });
          mytimer2?.cancel(); //to terminate this timer
        }
        
     });
  }

  Future<void> disabled_package(String package_type)async{

    var client = http.Client();

    try {
      
      var res = await client.post(Uri.https('creativeparkingsolutions.com', '/public/disable_package.php'), body: {
          'motorist_id' : user_id,
          'package_type' : package_type
      });
      print(res.statusCode);

    } catch (e) {
      print(e);
    }
  }
  

  @override
  void initState() {
    // TODO: implement initState

    // _startTimer();

    

    super.initState();

    getUserData().whenComplete(()async{
      setState(() {
        logged_in = logged_in;
        getProfilePictureName = profile_picture;
      });

      setExpired();
      
    });

    //this.getGarages();

    

  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;


    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("DashBoard",
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
              ],
            ),
            SizedBox(height: 5,),
            expireFound == 0 ? Text("") : 
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _days == null ? Text("") :
                Container(
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.blue.shade500,
                              Colors.blue.shade300
                            ]
                          )
                        ),
                        padding: EdgeInsets.all(5),
                        child: Text(_days.floor().toString().padLeft(2,'0'), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white,),),
                      ),
                      Text("D", style: TextStyle(fontSize: 12),)
                    ],
                  )
                ),
                SizedBox(width: 5,),
                _hours == null ? Text("") :
                Container(
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.blue.shade500,
                              Colors.blue.shade300
                            ]
                          )
                        ),
                        padding: EdgeInsets.all(5),
                        child: Text(_hours.floor().toString().padLeft(2,'0'), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white,),),
                      ),
                      Text("H", style: TextStyle(fontSize: 12),)
                    ],
                  )
                ),
                SizedBox(width: 5,),
                _minutes == null ? Text("") :
                Container(
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.blue.shade500,
                              Colors.blue.shade300
                            ]
                          )
                        ),
                        padding: EdgeInsets.all(5),
                        child: Text(_minutes.floor().toString().padLeft(2,'0'), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white,),),
                      ),
                      Text("M", style: TextStyle(fontSize: 12),)
                    ],
                  )
                ),
                SizedBox(width: 5,),
                _seconds == null ? Text("") :
                Container(
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.blue.shade500,
                              Colors.blue.shade300
                            ]
                          )
                        ),
                        padding: EdgeInsets.all(5),
                        child: Text(_seconds.floor().toString().padLeft(2,'0'), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white,),),
                      ),
                      Text("S", style: TextStyle(fontSize: 12),)
                    ],
                  )
                ),
              ],
            ),
            SizedBox(height: 5,),
            Container(
              alignment: Alignment.center,
              // padding: EdgeInsets.fromLTRB(10, 125, 10, 0),
              // child: TextFormField(
              //   controller: _geoController,
              //   decoration: ThemeHelper().textInputDecoration('Search Location', 'Enter Destination here'),
              //   keyboardType: TextInputType.emailAddress,
              // ),
              decoration: ThemeHelper().inputBoxDecorationShaddow(),
              child: SearchLocation(
                apiKey: "AIzaSyAM2xps49NZeNORyj-gwhUo2k0vbMbDRaY",// YOUR GOOGLE MAPS API KEY
                onSelected: (Place place) async{
                  final geolocation = await place.geolocation;
                  
                  final latlng = LatLng(latitude: geolocation!.coordinates.latitude, longitude: geolocation.coordinates.longitude);
                  setState(() {
                    lat = latlng.latitude;
                    lng = latlng.longitude;
                  });
                  getGarages();
                },
              ),
            ),
            Column(
              children:[
              ]
            ),
            if(isData == 'not_selected')
              Container(
                padding: EdgeInsets.all(30),
                child: Text("Our engine will automatically find parking nearest to your destination location.", style: TextStyle(fontSize: 18, color: Colors.black54), textAlign: TextAlign.center,),
              )
            else if(isData == 'no')
              Container(
                padding: EdgeInsets.all(20),
                child: Text("There is not garage nearby available", style: TextStyle(fontSize: 18, color: Colors.black54), textAlign: TextAlign.center,),
              )
            else
              Expanded(
                child: Scrollbar(
                  isAlwaysShown: true,
                  thickness: 5,
                  radius: Radius.circular(20),
                  scrollbarOrientation: ScrollbarOrientation.right,
                  child: Container(
                    padding: EdgeInsets.all(20),
                    child: GridView.builder(
                      itemCount: garages == null ? 0 : garages.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 1, childAspectRatio: (1/1.1)),
                      itemBuilder: (context, index){
                        double distance = double.parse(garages[index]['distance']);
                        String distanceKM = distance.toStringAsFixed(2);
                        return Card(
                          child: Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.shade300,
                                  offset: Offset(0, 1),
                                  spreadRadius: 2,
                                  blurRadius: 3
                                )
                              ],
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0)
                              )
                            ),
                            child: 
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  child: 
                                  garages[index]['garage_image'] != '' ?
                                  ClipRect(
                                    child: FadeInImage.assetNetwork(
                                      placeholder: "assets/animations/image-thumbnail.gif",
                                      image: "https://creativeparkingsolutions.com/public/assets/admin/images/garage/${garages[index]['garage_image']}",
                                      width: double.infinity,
                                      height: 170,
                                      fit: BoxFit.cover,
                                      fadeInDuration: Duration(milliseconds: 5),
                                      fadeOutDuration: Duration(milliseconds: 5),
                                    ),
                                  ) :
                                  ClipRect(
                                    child: Image(image: AssetImage("assets/images/image-thumbnail.jpg"), height: 170, width: double.infinity,),
                                  )

                                ),
                                // FadeInImage.assetNetwork(
                                //   placeholder: "assets/animations/image-thumbnail.gif",
                                //   image: "https://creativeparkingsolutions.com/public/assets/admin/images/garage/${garages[index]['garage_image']}",
                                //   width: double.infinity,
                                //   height: 170,
                                //   fit: BoxFit.cover,
                                //   fadeInDuration: Duration(milliseconds: 5),
                                //   fadeOutDuration: Duration(milliseconds: 5),
                                // ),
                                Padding(
                                  padding: EdgeInsets.only(left: 7, top: 5),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          "Garage Name : ${garages[index]['G_id']}",
                                          style: TextStyle(fontSize: 18, color: Colors.white),
                                      ),
                                      Text(
                                          "Preferences : ${garages[index]['preferences_name']}",
                                          style: TextStyle(fontSize: 18, color: Colors.white),
                                      ),
                                      Text(
                                          "Location : ${garages[index]['location']}",
                                          style: TextStyle(fontSize: 18, color: Colors.white),
                                      ),
                                      Text(
                                          "Distance : ${distanceKM} km",
                                          style: TextStyle(fontSize: 18, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                                Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton(
                                        onPressed: (){
                                          // Navigator.push(context, MaterialPageRoute(builder: (context)=>FloorMapMotorist(garage_id: garages[index]['G_id'],)));
                                          dayExpireFound == 0 ?
                                          showDialog<void>(
                                            context: context,
                                            barrierDismissible: true, // user must tap button!
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text('Warning!'),
                                                content: SingleChildScrollView(
                                                  child: ListBody(
                                                    children: const <Widget>[
                                                      Text('Please buy 24 hours package then view any garage and space to park', textAlign: TextAlign.justify,),
                                                    ],
                                                  ),
                                                ),
                                                actions: <Widget>[
                                                  ElevatedButton(
                                                    onPressed: (){
                                                      Navigator.of(context).pop();
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(builder: (context)=>PackageMotorist())
                                                      );
                                                    },
                                                    child: Text("Yes"),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Color.fromARGB(255, 8, 106, 187),
                                                      foregroundColor: Colors.white,
                                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                      textStyle: TextStyle(fontSize: 14),
                                                    ),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: (){
                                                      Navigator.of(context).pop();
                                                    },
                                                    child: Text("No"),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Color.fromARGB(255, 187, 8, 8),
                                                      foregroundColor: Colors.white,
                                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                      textStyle: TextStyle(fontSize: 14),
                                                    ),
                                                  )
                                                ],
                                              );
                                            },
                                          )
                                          :
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context)=>FloorMapMotorist(garage_id: garages[index]['G_id'],))
                                          );
                                        },
                                        child: Text("Floors"),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                                          textStyle: TextStyle(fontSize: 20)
                                        ),
                                      ),
                                      SizedBox(width: 10,),
                                      ElevatedButton(
                                        onPressed: () async{
                                          // Navigator.push(context, MaterialPageRoute(builder: (context)=>GarageMapMotorist(garage_id: garages[index]['G_id'],)));
                                          dayExpireFound == 0 ?
                                          showDialog<void>(
                                            context: context,
                                            barrierDismissible: true, // user must tap button!
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text('Warning!'),
                                                content: SingleChildScrollView(
                                                  child: ListBody(
                                                    children: const <Widget>[
                                                      Text('Please buy 24 hours package then view any garage and space to park', textAlign: TextAlign.justify,),
                                                    ],
                                                  ),
                                                ),
                                                actions: <Widget>[
                                                  ElevatedButton(
                                                    onPressed: (){
                                                      Navigator.of(context).pop();
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(builder: (context)=>PackageMotorist())
                                                      );
                                                    },
                                                    child: Text("Yes"),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Color.fromARGB(255, 8, 106, 187),
                                                      foregroundColor: Colors.white,
                                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                      textStyle: TextStyle(fontSize: 14),
                                                    ),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: (){
                                                      Navigator.of(context).pop();
                                                    },
                                                    child: Text("No"),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Color.fromARGB(255, 187, 8, 8),
                                                      foregroundColor: Colors.white,
                                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                      textStyle: TextStyle(fontSize: 14),
                                                    ),
                                                  )
                                                ],
                                              );
                                            },
                                          )
                                          :
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context)=>GarageMapMotorist(garage_id: garages[index]['G_id'],))
                                          );
                                        },
                                        child: Text("Map"),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                                          textStyle: TextStyle(fontSize: 20)
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            )
                            
                          ),
                        );
                      }
                    ),
                  ),
                )
              )
          ],
        ),
    );
  }
  
  Future<bool> _onBackButtonPressed(BuildContext context) async{
    bool? exitApp = await showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          content: Expanded(
            child: Container(
              height: 220,
              width: 200,
              child: Column(
                children: [
                  Container(
                    height: 200,
                    width: 200,
                    child: Image.asset("assets/images/Questions-pana-1.png", width: 200, height: 200,),
                  ),
                  const Text("Do you want to close the app ?", style: TextStyle(color: Colors.grey),)
                ],
              ),
            )
          ),
          actions: [
            TextButton(
              onPressed: (){
                Navigator.of(context).pop(false);
              },
              child: const Text("No"),
              style: TextButton.styleFrom(backgroundColor: Colors.red.shade900, foregroundColor: Colors.white),
            ),
            TextButton(
              onPressed: (){
                Navigator.of(context).pop(true);
              },
              child: const Text("Yes"),
              style: TextButton.styleFrom(backgroundColor: Colors.green.shade900, foregroundColor: Colors.white),
            )
          ],
        );
      }
    );
    return exitApp ?? false;
  }
  
  
}
