import 'dart:async';
import 'dart:convert';

import 'package:cps/pages/admin/notifications.dart';
import 'package:cps/pages/admin/sidebar_nav.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;

class GarageMapAdmin extends StatefulWidget {

  String garage_id;

  GarageMapAdmin({super.key, required this.garage_id,});

  

  @override
  State<GarageMapAdmin> createState() => _GarageMapAdminState();
}

class _GarageMapAdminState extends State<GarageMapAdmin> {

  Timer? _timer;

  double  _drawerIconSize = 24;
  double _drawerFontSize = 17;

  String count_notification='';

  bool logged_in = false;
  String? user_type;
  String? user_id;
  String? first_name;
  String? last_name;
  String? user_name;
  String? user_email;
  String? profile_picture;

  String? getProfilePictureName;

  // static double? lat;
  // static double? lng;  

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
    // double? getLat = sharedPreferences.getDouble('lat');
    // double? getLng = sharedPreferences.getDouble('lng');

    setState(() {
      logged_in = getLoggedIn!;
      user_type = getUserType;
      user_id = getUserId;
      first_name = getFirstName;
      last_name = getLastName;
      user_name = getUserName;
      user_email = getUserEmail;
      profile_picture = getProfilePicture;      
      // lat = getLat;
      // lng = getLng;
    });
  }

  Future getCountNotification()async{
    var client = http.Client();

    try {

      var res = await client.get(Uri.https('creativeparkingsolutions.com', 'admin/get_notification_count'));
      // print(res.statusCode);
      
      var response = jsonDecode(res.body);
      // print("Notification Count : ${response}");
      if(int.parse(response[0]['user_id']) > 0){
        setState(() {
          count_notification = response[0]['user_id'];
        });
      }

    } catch (e) {
      return '';
    }
  }

  Future<dynamic> getLatLng()async{
    
    var client = http.Client();

    _timer?.cancel();
      
    EasyLoading.instance
      ..loadingStyle = EasyLoadingStyle.light;

    await EasyLoading.show(
      maskType: EasyLoadingMaskType.black,
      indicator: Image.asset("assets/animations/loading.gif", height: 100, width: 125,)
      // indicator: Lottie.asset("assets/animations/loading.json", width: 125, height: 75)
    );
    
    var res = await client.get(Uri.https("creativeparkingsolutions.com", "motorist/get_map_app/${widget.garage_id}"));
    
    var jsonData = jsonDecode(res.body);

    print(res.statusCode);
    // print(jsonData);

    if(res.statusCode == 200){
      EasyLoading.dismiss();  

      double latValue = double.parse(jsonData['latitude']);
      double lngValue = double.parse(jsonData['longitude']);
      return [latValue, lngValue];
    }

  }

  // Completer<GoogleMapController> _controller = Completer();

  // static double lat1 = 25.7606545;
  // static double lng1 = 89.23113889999999;
  
  // static double? get latitude => lat;
  
  // static double? get longitude => lng;
  
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
    getCountNotification();

  }

  // static final CameraPosition _garageMap = CameraPosition(
  //   target: LatLng(latitude, longitude),
  //   zoom: 14.4746,
  // );

  // List<Marker> markers = [
  //   Marker(
  //     markerId: MarkerId('A'),
  //     position: LatLng(latitude, longitude),
  //     icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
  //   )
  // ];

  // void _onMapCreated(GoogleMapController controller) {
  //   _controller.complete(controller);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Garage Map",
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
        automaticallyImplyLeading: true,
        actions: [
          GestureDetector(
            child: Container(
              margin: EdgeInsets.only( top: 16, right: 16,),
              child: Stack(
                children: <Widget>[
                  Icon(Icons.notifications),
                  count_notification != '' ?
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(1),
                      decoration: BoxDecoration( color: Colors.red, borderRadius: BorderRadius.circular(6),),
                      constraints: BoxConstraints( minWidth: 12, minHeight: 12, ),
                      child: Text( "${count_notification}", style: TextStyle(color: Colors.white, fontSize: 8,), textAlign: TextAlign.center,),
                    ),
                  ):Text('')
                ],
              ),
            ),
            onTap: ()async{
              var client = http.Client();

              // _timer?.cancel();

              // EasyLoading.instance
              //   ..loadingStyle = EasyLoadingStyle.light;

              // await EasyLoading.show(
              //   maskType: EasyLoadingMaskType.black,
              //   indicator: Lottie.asset("assets/animations/loading.json", width: 125, height: 75)
              // );

              var res = await client.get(Uri.https('creativeparkingsolutions.com', 'admin/view_notification_count'));
              // print(res.statusCode);
              
              var response = jsonDecode(res.body);
              // print("Notification Count : ${response}");
              if(response['status'] == true){
                setState(() {
                  count_notification = '';
                });  
                // EasyLoading.dismiss();

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context)=>NotificationAdmin())
                );
              }
            },
          )
          
        ],
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
      body: FutureBuilder(
        future: getLatLng(),
        builder: (context, snapshot){
          
          if(snapshot.data == null){
            return Text("");
          }else{
            double lat = snapshot.data[0];
            double lng = snapshot.data[1];

            List<Marker> markers = [
              Marker(
                markerId: MarkerId('A'),
                position: LatLng(lat, lng),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
              )
            ];
            // return Text(widget.garage_id);
            return GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(lat, lng),
                zoom: 14.4746
              ),
              markers:  Set<Marker>.of(markers),
            );
          }
          
        }
      )
        // GoogleMap(
        //   mapType: MapType.normal,
        //   initialCameraPosition: CameraPosition(
        //     target: LatLng(latitude!, longitude!),
        //     zoom: 14.4746,
        //     tilt: 0,
        //     bearing: 0,
            
        //   ),
        //   onMapCreated: _onMapCreated,
        //   // markers:  Set<Marker>.of(markers),
        // ),
    );
  }
}