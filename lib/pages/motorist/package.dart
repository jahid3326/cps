import 'dart:async';
import 'dart:convert';

import 'package:cps/pages/motorist/sidebar_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:cps/pages/widgets/header_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter/src/material/card.dart' as Card;



class PackageMotorist extends StatefulWidget {
  const PackageMotorist({super.key});

  @override
  State<PackageMotorist> createState() => _PackageMotoristState();
}

class _PackageMotoristState extends State<PackageMotorist> {
  Timer? _timer;
  double  _drawerIconSize = 24;
  double _drawerFontSize = 17;

  Map<String, dynamic>? paymentIntent;

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
        title: Text("Package",
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
      body:Column(
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
            // SizedBox(height: 5,),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Container(
                          padding: EdgeInsets.only(left: 20, top: 5, right: 20),
                          child: 
                          Card.Card(
                            child: Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Color.fromARGB(218, 61, 61, 94),
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
                                  Stack(
                                    children: [
                                      FadeInImage.assetNetwork(
                                        placeholder: "assets/animations/image-thumbnail.gif",
                                        image: "https://creativeparkingsolutions.com/public/assets/motorist/packege/images/01.jpg",
                                        width: double.infinity,
                                        height: 200,
                                        fit: BoxFit.cover,
                                        fadeInDuration: Duration(milliseconds: 5),
                                        fadeOutDuration: Duration(milliseconds: 5),
                                      ),
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: Container(
                                          padding: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              left: BorderSide(
                                                color: Colors.red,
                                                width: 5
                                              )
                                            ),
                                            color: Colors.black87.withOpacity(0.4),
                                          ),
                                          child: 
                                            Text(
                                              "\$0.99/DAY",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold
                                              ),
                                            ),
                                        )
                                      )
                                    ],
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 40, top: 50, right: 40, bottom: 10),
                                    child: Text(
                                        "FULL ACCESS AND FEATURES FOR AN ENTIRE 24 HOURS!",
                                        style: TextStyle(fontSize: 18, color: Colors.white),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 40, bottom: 30),
                                    child: Container(
                                      height: 5,
                                      width: 100,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Center(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        ElevatedButton(
                                          onPressed: ()async{
                                            //Navigator.push(context, MaterialPageRoute(builder: (context)=>FloorMapMotorist(garage_id: garages[index]['G_id'],)));
                                            return showDialog<void>(
                                              context: context,
                                              barrierDismissible: true, // user must tap button!
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Text('Feature Detail'),
                                                  content: SingleChildScrollView(
                                                    child: ListBody(
                                                      children: const <Widget>[
                                                        Text('Experience all the features including all parking spaces available within our system in real time for the entire day!', textAlign: TextAlign.justify,),
                                                      ],
                                                    ),
                                                  ),
                                                  actions: <Widget>[
                                                    ElevatedButton(
                                                      onPressed: (){
                                                        Navigator.of(context).pop();
                                                      },
                                                      child: Text("Ok"),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Color.fromARGB(255, 8, 106, 187),
                                                        foregroundColor: Colors.white,
                                                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                        textStyle: TextStyle(fontSize: 14),
                                                      ),
                                                    )
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          child: Text("VIEW DETAILS"),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color.fromARGB(255, 21, 40, 56),
                                            foregroundColor: Colors.white,
                                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            textStyle: TextStyle(fontSize: 18),
                                            fixedSize: Size(150, 40)
                                          ),
                                        ),
                                        SizedBox(height: 10,),
                                        ElevatedButton(
                                          onPressed: () async{

                                            dayExpireFound == 1 ?
                                            showDialog<void>(
                                              context: context,
                                              barrierDismissible: true, // user must tap button!
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Text('Warning!'),
                                                  content: SingleChildScrollView(
                                                    child: ListBody(
                                                      children: const <Widget>[
                                                        Text('You are already activate!', textAlign: TextAlign.justify,),
                                                      ],
                                                    ),
                                                  ),
                                                  actions: <Widget>[
                                                    ElevatedButton(
                                                      onPressed: (){
                                                        Navigator.of(context).pop();
                                                      },
                                                      child: Text("Ok"),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Color.fromARGB(255, 8, 106, 187),
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
                                            await makePayment('99', 'FULL ACCESS AND FEATURES FOR AN ENTIRE 24 HOURS!', 'Day', '24 hours');
                                            //Navigator.push(context, MaterialPageRoute(builder: (context)=>GarageMapMotorist(garage_id: garages[index]['G_id'],)));
                                          },
                                          child: Text("BUY NOW"),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color.fromARGB(255, 20, 20, 208),
                                            foregroundColor: Colors.white,
                                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            textStyle: TextStyle(fontSize: 18),
                                            fixedSize: Size(150, 40)
                                          ),
                                        ),
                                        SizedBox(height: 20,)
                                      ],
                                    ),
                                  )
                                ],
                              )
                              
                            ),
                          )
                        ),
                      ]
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Container(
                          padding: EdgeInsets.only(left:20, top: 20, right: 20),
                          child: 
                          Card.Card(
                            child: Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Color.fromARGB(218, 40, 173, 169),
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
                                  Stack(
                                    children: [
                                      FadeInImage.assetNetwork(
                                        placeholder: "assets/animations/image-thumbnail.gif",
                                        image: "https://creativeparkingsolutions.com/public/assets/motorist/packege/images/02.png",
                                        width: double.infinity,
                                        height: 200,
                                        fit: BoxFit.cover,
                                        fadeInDuration: Duration(milliseconds: 5),
                                        fadeOutDuration: Duration(milliseconds: 5),
                                      ),
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: Container(
                                          padding: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              left: BorderSide(
                                                color: Colors.red,
                                                width: 5
                                              )
                                            ),
                                            color: Colors.black87.withOpacity(0.4),
                                          ),
                                          child: 
                                            Text(
                                              "\$9.99/MONTH",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold
                                              ),
                                            ),
                                        )
                                      )
                                    ],
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 40, top: 50, right: 40, bottom: 10),
                                    child: Text(
                                        "FULL ACCESS AND FEATURES FOR AN ENTIRE MONTH!",
                                        style: TextStyle(fontSize: 18, color: Colors.white),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 40, bottom: 30),
                                    child: Container(
                                      height: 5,
                                      width: 100,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Center(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        ElevatedButton(
                                          onPressed: ()async{
                                            //Navigator.push(context, MaterialPageRoute(builder: (context)=>FloorMapMotorist(garage_id: garages[index]['G_id'],)));
                                            return showDialog<void>(
                                              context: context,
                                              barrierDismissible: true, // user must tap button!
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Text('Feature Detail'),
                                                  content: SingleChildScrollView(
                                                    child: ListBody(
                                                      children: const <Widget>[
                                                        Text('Constantly struggling with parking regularly? Try our monthly plan which gives you exclusive access to all available parking spaces 24/7! You will always know the status of the places you park at. !', textAlign: TextAlign.justify,),
                                                      ],
                                                    ),
                                                  ),
                                                  actions: <Widget>[
                                                    ElevatedButton(
                                                      onPressed: (){
                                                        Navigator.of(context).pop();
                                                      },
                                                      child: Text("Ok"),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Color.fromARGB(255, 8, 106, 187),
                                                        foregroundColor: Colors.white,
                                                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                        textStyle: TextStyle(fontSize: 14),
                                                      ),
                                                    )
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          child: Text("VIEW DETAILS"),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color.fromARGB(255, 21, 40, 56),
                                            foregroundColor: Colors.white,
                                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            textStyle: TextStyle(fontSize: 18),
                                            fixedSize: Size(150, 40)
                                          ),
                                        ),
                                        SizedBox(height: 10,),
                                        ElevatedButton(
                                          onPressed: ()async{

                                            expireFound == 1 ?
                                            showDialog<void>(
                                              context: context,
                                              barrierDismissible: true, // user must tap button!
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Text('Warning!'),
                                                  content: SingleChildScrollView(
                                                    child: ListBody(
                                                      children: const <Widget>[
                                                        Text('You are already activate!', textAlign: TextAlign.justify,),
                                                      ],
                                                    ),
                                                  ),
                                                  actions: <Widget>[
                                                    ElevatedButton(
                                                      onPressed: (){
                                                        Navigator.of(context).pop();
                                                      },
                                                      child: Text("Ok"),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Color.fromARGB(255, 8, 106, 187),
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
                                            await makePayment('999', 'FULL ACCESS AND FEATURES FOR AN ENTIRE MONTH!', 'Month', '1 month');
                                            //Navigator.push(context, MaterialPageRoute(builder: (context)=>FloorMapMotorist(garage_id: garages[index]['G_id'],)));
                                            
                                          },
                                          child: Text("BUY NOW"),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color.fromARGB(255, 20, 20, 208),
                                            foregroundColor: Colors.white,
                                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            textStyle: TextStyle(fontSize: 18),
                                            fixedSize: Size(150, 40)
                                          ),
                                        ),
                                        SizedBox(height: 20,)
                                      ],
                                    ),
                                  )
                                ],
                              )
                              
                            ),
                          )
                        ),
                      ]
                    ),  
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Container(
                          padding: EdgeInsets.only(left:20, top: 20, right: 20),
                          child: 
                          Card.Card(
                            child: Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Color.fromARGB(218, 245, 9, 9),
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
                                  Stack(
                                    children: [
                                      FadeInImage.assetNetwork(
                                        placeholder: "assets/animations/image-thumbnail.gif",
                                        image: "https://creativeparkingsolutions.com/public/assets/motorist/packege/images/03.png",
                                        width: double.infinity,
                                        height: 200,
                                        fit: BoxFit.cover,
                                        fadeInDuration: Duration(milliseconds: 5),
                                        fadeOutDuration: Duration(milliseconds: 5),
                                      ),
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: Container(
                                          padding: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              left: BorderSide(
                                                color: Colors.red,
                                                width: 5
                                              )
                                            ),
                                            color: Colors.black87.withOpacity(0.4),
                                          ),
                                          child: 
                                            Text(
                                              "\$19.99/MONTH",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold
                                              ),
                                            ),
                                        )
                                      )
                                    ],
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 40, top: 50, right: 40, bottom: 10),
                                    child: Text(
                                        "FULL ACCESS AND FEATURES FOR YOU AND FAMILY!",
                                        style: TextStyle(fontSize: 18, color: Colors.white),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 40, bottom: 30),
                                    child: Container(
                                      height: 5,
                                      width: 100,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Center(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () async{
                                            //Navigator.push(context, MaterialPageRoute(builder: (context)=>FloorMapMotorist(garage_id: garages[index]['G_id'],)));
                                            return showDialog<void>(
                                              context: context,
                                              barrierDismissible: true, // user must tap button!
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Text('Feature Detail'),
                                                  content: SingleChildScrollView(
                                                    child: ListBody(
                                                      children: const <Widget>[
                                                        Text('There’s nothing quite like our family plan packages which allows you and all your close ones to take advantage of the unique services that we have to offer! For less than \$1 per user, add up to 5 friends or family who want to get in on the action!', textAlign: TextAlign.justify,),
                                                      ],
                                                    ),
                                                  ),
                                                  actions: <Widget>[
                                                    ElevatedButton(
                                                      onPressed: (){
                                                        Navigator.of(context).pop();
                                                      },
                                                      child: Text("Ok"),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Color.fromARGB(255, 8, 106, 187),
                                                        foregroundColor: Colors.white,
                                                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                        textStyle: TextStyle(fontSize: 14),
                                                      ),
                                                    )
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          child: Text("VIEW DETAILS"),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color.fromARGB(255, 21, 40, 56),
                                            foregroundColor: Colors.white,
                                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            textStyle: TextStyle(fontSize: 18),
                                            fixedSize: Size(150, 40)
                                          ),
                                        ),
                                        SizedBox(height: 10,),
                                        ElevatedButton(
                                          onPressed: () async{
                                            expireFound == 1 ?
                                            showDialog<void>(
                                              context: context,
                                              barrierDismissible: true, // user must tap button!
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Text('Warning!'),
                                                  content: SingleChildScrollView(
                                                    child: ListBody(
                                                      children: const <Widget>[
                                                        Text('You are already activate!', textAlign: TextAlign.justify,),
                                                      ],
                                                    ),
                                                  ),
                                                  actions: <Widget>[
                                                    ElevatedButton(
                                                      onPressed: (){
                                                        Navigator.of(context).pop();
                                                      },
                                                      child: Text("Ok"),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Color.fromARGB(255, 8, 106, 187),
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
                                            await makePayment('1999', 'FULL ACCESS AND FEATURES FOR YOU AND FAMILY!', 'Month', '1 month');
                                            //Navigator.push(context, MaterialPageRoute(builder: (context)=>GarageMapMotorist(garage_id: garages[index]['G_id'],)));
                                          },
                                          child: Text("BUY NOW"),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color.fromARGB(255, 20, 20, 208),
                                            foregroundColor: Colors.white,
                                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            textStyle: TextStyle(fontSize: 18),
                                            fixedSize: Size(150, 40)
                                          ),
                                        ),
                                        SizedBox(height: 20,)
                                      ],
                                    ),
                                  )
                                ],
                              )
                              
                            ),
                          )
                        ),
                      ]
                    ),  
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Container(
                          padding: EdgeInsets.only(left:20, top: 20, right: 20),
                          child: 
                          Card.Card(
                            child: Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Color.fromARGB(218, 7, 104, 4),
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
                                  Stack(
                                    children: [
                                      FadeInImage.assetNetwork(
                                        placeholder: "assets/animations/image-thumbnail.gif",
                                        image: "https://creativeparkingsolutions.com/public/assets/motorist/packege/images/04.png",
                                        width: double.infinity,
                                        height: 200,
                                        fit: BoxFit.cover,
                                        fadeInDuration: Duration(milliseconds: 5),
                                        fadeOutDuration: Duration(milliseconds: 5),
                                      ),
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: Container(
                                          padding: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              left: BorderSide(
                                                color: Colors.red,
                                                width: 5
                                              )
                                            ),
                                            color: Colors.black87.withOpacity(0.4),
                                          ),
                                          child: 
                                            Text(
                                              "\$39.99/ANNUALLY",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold
                                              ),
                                            ),
                                        )
                                      )
                                    ],
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 40, top: 50, right: 40, bottom: 10),
                                    child: Text(
                                        "FULL ACCESS AND FEATURES FOR AN ENTIRE YEAR!",
                                        style: TextStyle(fontSize: 18, color: Colors.white),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 40, bottom: 30),
                                    child: Container(
                                      height: 5,
                                      width: 100,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Center(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () async{
                                            //Navigator.push(context, MaterialPageRoute(builder: (context)=>FloorMapMotorist(garage_id: garages[index]['G_id'],)));
                                            return showDialog<void>(
                                              context: context,
                                              barrierDismissible: true, // user must tap button!
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Text('Feature Detail'),
                                                  content: SingleChildScrollView(
                                                    child: ListBody(
                                                      children: const <Widget>[
                                                        Text('We love to offer great value to our customers! Treat yourself to an entire year of unlimited access 365!', textAlign: TextAlign.justify,),
                                                      ],
                                                    ),
                                                  ),
                                                  actions: <Widget>[
                                                    ElevatedButton(
                                                      onPressed: (){
                                                        Navigator.of(context).pop();
                                                      },
                                                      child: Text("Ok"),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Color.fromARGB(255, 8, 106, 187),
                                                        foregroundColor: Colors.white,
                                                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                        textStyle: TextStyle(fontSize: 14),
                                                      ),
                                                    )
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          child: Text("VIEW DETAILS"),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color.fromARGB(255, 21, 40, 56),
                                            foregroundColor: Colors.white,
                                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            textStyle: TextStyle(fontSize: 18),
                                            fixedSize: Size(150, 40)
                                          ),
                                        ),
                                        SizedBox(height: 10,),
                                        ElevatedButton(
                                          onPressed: () async{
                                            expireFound == 1 ?
                                            showDialog<void>(
                                              context: context,
                                              barrierDismissible: true, // user must tap button!
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Text('Warning!'),
                                                  content: SingleChildScrollView(
                                                    child: ListBody(
                                                      children: const <Widget>[
                                                        Text('You are already activate!', textAlign: TextAlign.justify,),
                                                      ],
                                                    ),
                                                  ),
                                                  actions: <Widget>[
                                                    ElevatedButton(
                                                      onPressed: (){
                                                        Navigator.of(context).pop();
                                                      },
                                                      child: Text("Ok"),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Color.fromARGB(255, 8, 106, 187),
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
                                            await makePayment('3999', 'FULL ACCESS AND FEATURES FOR AN ENTIRE YEAR!', 'Annually', '1 year');
                                            //Navigator.push(context, MaterialPageRoute(builder: (context)=>GarageMapMotorist(garage_id: garages[index]['G_id'],)));
                                          },
                                          child: Text("BUY NOW"),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color.fromARGB(255, 20, 20, 208),
                                            foregroundColor: Colors.white,
                                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            textStyle: TextStyle(fontSize: 18),
                                            fixedSize: Size(150, 40)
                                          ),
                                        ),
                                        SizedBox(height: 20,)
                                      ],
                                    ),
                                  )
                                ],
                              )
                              
                            ),
                          )
                        ),
                      ]
                    ),  
                  )
                ]
              )
            )
          ],
        ),
    );
  }

Future<void> _packageOneDetails() async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('AlertDialog Title'),
        content: SingleChildScrollView(
          child: ListBody(
            children: const <Widget>[
              Text('This is a demo alert dialog.'),
              Text('Would you like to approve of this message?'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Approve'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
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

  Future<void> makePayment(String amount, String package_details, String package_type, String duration) async {
    try {
      var client = http.Client();

      // _timer?.cancel();
      
      // EasyLoading.instance
      //   ..loadingStyle = EasyLoadingStyle.light;

      // await EasyLoading.show(
      //   maskType: EasyLoadingMaskType.black,
      //   indicator: Lottie.asset("assets/animations/loading.json", width: 125, height: 75)
      // );

        paymentIntent = await createPaymentIntent(amount, 'USD');

        //STEP 2: Initialize Payment Sheet
        await Stripe.instance
            .initPaymentSheet(
                paymentSheetParameters: SetupPaymentSheetParameters(
                    paymentIntentClientSecret: paymentIntent![
                        'client_secret'], //Gotten from payment intent
                    style: ThemeMode.dark,
                    merchantDisplayName: 'Ikay'))
            .then((value) {});

        //STEP 3: Display Payment sheet
        displayPaymentSheet(amount, package_details, package_type, duration);
        // EasyLoading.dismiss();


    } catch (err) {
      throw Exception(err);
    }
  }

  displayPaymentSheet(String amount, String package_details, String package_type, String duration) async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) async{

        var client = http.Client();
        // var res = await client.post(Uri.https('creativeparkingsolutions.com', 'motorist/payment_success_app'), body: {
        //     'user_id'               : user_id,
        // });

        double calAmount = double.parse(amount)/100;
        String calAmount2 = calAmount.toStringAsFixed(2);
        
        var res = await client.post(Uri.https('creativeparkingsolutions.com', 'motorist/payment_success_app'), body: {
            'user_id'               : user_id,
            'amount'                : calAmount2,
            'package_details'       : package_details,
            'package_type'          : package_type,
            'duration'              : duration
        });
        
        print(res.statusCode);

        print(res.body);

        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 100.0,
                      ),
                      SizedBox(height: 10.0),
                      Text("Payment Successful!"),
                    ],
                  ),
                ));

        paymentIntent = null;
      }).onError((error, stackTrace) {
        throw Exception(error);
      });
    } on StripeException catch (e) {
      print('Error is:---> $e');
      AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: const [
                Icon(
                  Icons.cancel,
                  color: Colors.red,
                ),
                Text("Payment Failed"),
              ],
            ),
          ],
        ),
      );
    } catch (e) {
      print('$e');
    }
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      //Request body
      // double newAmount = double.parse(amount) / 100;
      // String calAmount = newAmount.toString();
      
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
      };

      //Make post request to Stripe
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          // 'Authorization': 'Bearer ${dotenv.env['STRIPE_SECRET']}',
          'Authorization': 'Bearer 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',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      return json.decode(response.body);
    } catch (err) {
      throw Exception(err.toString());
    }
  }

  calculateAmount(String amount) {
    // final calculatedAmout = int.parse(amount) * 100;
    final calculatedAmout = int.parse(amount);
    return calculatedAmout.toString();
  }

}
