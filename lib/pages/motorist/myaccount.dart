import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cps/pages/login_page.dart';
import 'package:cps/pages/motorist/billing_detials.dart';
import 'package:cps/pages/motorist/permit.dart';
import 'package:cps/pages/motorist/sidebar_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:cps/pages/widgets/header_widget.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;



class MyAccountMotorist extends StatefulWidget {
  const MyAccountMotorist({super.key});

  @override
  State<MyAccountMotorist> createState() => _MyAccountMotoristState();
}

class _MyAccountMotoristState extends State<MyAccountMotorist> {
  Timer? _timer;
  double  _drawerIconSize = 24;
  double _drawerFontSize = 17;

  bool _isCurrentPassSecure = true;
  bool _isNewPassSecure = true;
  bool _isConfirmPassSecure = true;

  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();

  TextEditingController input_user_name = TextEditingController();
  TextEditingController input_first_name = TextEditingController();
  TextEditingController input_last_name = TextEditingController();

  TextEditingController current_password = TextEditingController();
  TextEditingController new_password = TextEditingController();
  TextEditingController confirm_password = TextEditingController();

  bool editProfile = false;

  bool logged_in = false;
  String? user_type;
  String? user_id;
  String? first_name;
  String? last_name;
  String? user_name;
  String? user_email;
  String? profile_picture;
  String? created_at;

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
    String? getCreatedAt = sharedPreferences.getString('created_at');

    setState(() {
      logged_in = getLoggedIn!;
      user_type = getUserType;
      user_id = getUserId;
      first_name = getFirstName;
      last_name = getLastName;
      user_name = getUserName;
      user_email = getUserEmail;
      profile_picture = getProfilePicture;
      created_at = getCreatedAt;
    });
  }

  File? imagePath;
  String? imageName;
  String? imageData;

  Future<void> getImageCamara() async{

    final XFile? photo = await ImagePicker().pickImage(source: ImageSource.camera);
    setState(() {
      imagePath = File(photo!.path);
      imageName = photo.path.split('/').last;
      imageData = base64Encode(imagePath!.readAsBytesSync());
    });
  }

  Future<void> getImageGallery() async{

    final XFile? photo = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      imagePath = File(photo!.path);
      imageName = photo.path.split('/').last;
      imageData = base64Encode(imagePath!.readAsBytesSync());
      // print(imagePath);
      // print(imageName);
      // print(imageData);
    });
  }

  Future<void> uploadImage() async{
    var client = http.Client();
    try {
      
      _timer?.cancel();
        
      EasyLoading.instance
        ..loadingStyle = EasyLoadingStyle.light;

      await EasyLoading.show(
        maskType: EasyLoadingMaskType.black,
        indicator: Lottie.asset("assets/animations/loading.json", width: 125, height: 75)
      );

      var res = await client.post(Uri.https('creativeparkingsolutions.com', 'public/upload_image.php'), body: {
          'user_id' : user_id,
          'user_type' : user_type,
          'name' : imageName,
          'data' : imageData,
          'profile_picture' : profile_picture,
      });
      // print(res.statusCode);
      
      var response = jsonDecode(res.body);  
      // print(response);    

      if(res.statusCode == 200){
        if(response['status'] == true){

          var image_name = response['image_name'];

          EasyLoading.instance
            ..loadingStyle = EasyLoadingStyle.custom
            ..backgroundColor = Colors.green.shade200
            ..indicatorColor = Colors.green.shade900
            ..textColor = Colors.green.shade900;
          EasyLoading.showSuccess('Upload Success!');
          EasyLoading.dismiss();

          final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
          sharedPreferences.setString('profile_picture', image_name);

          setState(() {
            profile_picture = image_name;
          });

        }else{
          EasyLoading.instance
            ..loadingStyle = EasyLoadingStyle.custom
            ..backgroundColor = Colors.red.shade200
            ..indicatorColor = Colors.red.shade900
            ..textColor = Colors.red.shade900;
          EasyLoading.showError('Upload Failed!');
          EasyLoading.dismiss();
        }
      }
    
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateUserInfo()async{
    var client = http.Client();

    try {
      _timer?.cancel();
      
      EasyLoading.instance
        ..loadingStyle = EasyLoadingStyle.light;

      await EasyLoading.show(
        maskType: EasyLoadingMaskType.black,
        indicator: Lottie.asset("assets/animations/loading.json", width: 125, height: 75)
      );
      
      var res = await client.post(Uri.https('creativeparkingsolutions.com', 'motorist/update_profile_app'), body: {
          'update_type' : 'user_info',
          'user_id' : user_id,
          'user_name' : input_user_name.text,
          'first_name' : input_first_name.text,
          'last_name' : input_last_name.text,
      });
      print(res.statusCode);
      
      var response = jsonDecode(res.body);

      print(response);

      if(res.statusCode == 200){
        
        if(response['user_info_update'] == true){
          EasyLoading.instance
            ..loadingStyle = EasyLoadingStyle.custom
            ..backgroundColor = Colors.green.shade200
            ..indicatorColor = Colors.green.shade900
            ..textColor = Colors.green.shade900;
          EasyLoading.showSuccess('Update Success!');
          EasyLoading.dismiss();

          final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
          sharedPreferences.setString('user_name', input_user_name.text);
          sharedPreferences.setString('first_name', input_first_name.text);
          sharedPreferences.setString('last_name', input_last_name.text);

          setState(() {
            user_name = input_user_name.text;
            first_name = input_first_name.text;
            last_name = input_last_name.text;
          });
          
        }else{

          EasyLoading.instance
            ..loadingStyle = EasyLoadingStyle.custom
            ..backgroundColor = Colors.red.shade200
            ..indicatorColor = Colors.red.shade900
            ..textColor = Colors.red.shade900;
          EasyLoading.showError('Update failed!');
          EasyLoading.dismiss();
        }

      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> updatePasswordInfo()async{
    var client = http.Client();

    try {
      _timer?.cancel();
      
      EasyLoading.instance
        ..loadingStyle = EasyLoadingStyle.light;

      await EasyLoading.show(
        maskType: EasyLoadingMaskType.black,
        indicator: Lottie.asset("assets/animations/loading.json", width: 125, height: 75)
      );
      
      var res = await client.post(Uri.https('creativeparkingsolutions.com', 'motorist/update_profile_app'), body: {
          'update_type' : 'user_password',
          'email' : user_email,
          'user_id' : user_id,
          'current_password' : current_password.text,
          'password' : new_password.text,
      });
      print(res.statusCode);
      
      var response = jsonDecode(res.body);

      print(response);

      if(res.statusCode == 200){
        
        if(response['current_password'] == true){

          if(response['password_update'] == true){

            EasyLoading.instance
              ..loadingStyle = EasyLoadingStyle.custom
              ..backgroundColor = Colors.green.shade200
              ..indicatorColor = Colors.green.shade900
              ..textColor = Colors.green.shade900;
            EasyLoading.showSuccess('Update Success!');
            EasyLoading.dismiss();

            final sharedPreferences = await SharedPreferences.getInstance();
            sharedPreferences.remove('logged_in');
            sharedPreferences.remove('user_type');
            sharedPreferences.remove('user_id');
            sharedPreferences.remove('first_name');
            sharedPreferences.remove('last_name');
            sharedPreferences.remove('user_name');
            sharedPreferences.remove('user_email');
            sharedPreferences.remove('profile_picture');
            sharedPreferences.remove('created_at');
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginPage()));
          }
          
        }else{

          EasyLoading.instance
            ..loadingStyle = EasyLoadingStyle.custom
            ..backgroundColor = Colors.red.shade200
            ..indicatorColor = Colors.red.shade900
            ..textColor = Colors.red.shade900;
          EasyLoading.showError('Current password does not match!');
          EasyLoading.dismiss();
        }

      }
    } catch (e) {
      print(e);
    }
  }

  ///////////// Timer //////////////
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
        input_user_name.text = user_name!;
        input_first_name.text = first_name!;
        input_last_name.text = last_name!;
      });

      setExpired();
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool keyboardIsOpened = MediaQuery.of(context).viewInsets.bottom != 0.0;
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("My Account",
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
      floatingActionButton: keyboardIsOpened ? null : Container(
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
                  child: Stack(
                    children: [
                      imagePath == null ?
                      getProfilePictureName != '' ?
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
                      ):
                      Container(
                        height: 120,
                        width: 120,
                        child: ClipOval(
                          child: FittedBox(
                            child: Image.file(imagePath!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 15,
                        child: Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black,
                                blurRadius: 5
                              )
                            ]
                          ),
                          child: GestureDetector(
                            child: Icon(Icons.camera_alt_rounded),
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (context){
                                  return Container(
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black,
                                          blurRadius: 5
                                        )
                                      ]
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          onPressed: (){
                                            getImageCamara();
                                            Navigator.pop(context);
                                            showModalBottomSheet(
                                              context: context,
                                              builder: (context){
                                                return Container(
                                                  height: 100,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black,
                                                        blurRadius: 5
                                                      )
                                                    ]
                                                  ),
                                                  child: Center(
                                                    child: ElevatedButton(
                                                      onPressed: ()async{
                                                        Navigator.pop(context);
                                                        uploadImage();
                                                      },
                                                      child: Text("Upload"),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Colors.blue,
                                                        foregroundColor: Colors.white
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }
                                            );
                                          },
                                          icon: Icon(Icons.camera_sharp, size: 35,)
                                        ),
                                        IconButton(
                                          onPressed: (){
                                            getImageGallery();
                                            Navigator.pop(context);
                                            showModalBottomSheet(
                                              context: context,
                                              builder: (context){
                                                return Container(
                                                  height: 100,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black,
                                                        blurRadius: 5
                                                      )
                                                    ]
                                                  ),
                                                  child: Center(
                                                    child: ElevatedButton(
                                                      onPressed: ()async{
                                                        Navigator.pop(context);
                                                        uploadImage();
                                                      },
                                                      child: Text("Upload"),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Colors.blue,
                                                        foregroundColor: Colors.white
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }
                                            );
                                          },
                                          icon: Icon(Icons.photo_library, size: 35,)
                                        )
                                      ],
                                    ),
                                  );
                                }
                              );
                            },
                          ),
                        )
                      )
                    ],
                  )
                ),
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.fromLTRB(10, 125, 10, 0),
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: size.width/2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "$user_name",
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 10,),
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: Colors.green,
                              ),
                            ),
                            SizedBox(width: 5,),
                            Text(
                              "Approved",
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.green),
                            )
                          ],
                        )
                      ),
                      SizedBox(height: 10,),
                      Text(
                        "$user_email",
                        style: TextStyle(fontSize: 17, color: Colors.black54),
                      ),
                      SizedBox(height: 10,),
                      
                      Text(
                        "Member Since ${DateFormat.yMMM('en_US').format(DateTime.parse(created_at!))}",
                        style: TextStyle(fontSize: 17, color: Colors.black54),
                      ),
                      SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          !editProfile ?
                          ElevatedButton(
                            onPressed: (){
                              setState(() {
                                editProfile = true;
                              });
                            },
                            child: Text("Edit Profile"),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                          ) :
                          ElevatedButton(
                            onPressed: (){
                              setState(() {
                                editProfile = false;
                              });
                            },
                            child: Text("Close Edit"),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  )
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
            Expanded(
              child: Scrollbar(
                    isAlwaysShown: true, //always show scrollbar
                    thickness: 5, //width of scrollbar
                    radius: Radius.circular(20), //corner radius of scrollbar
                    scrollbarOrientation: ScrollbarOrientation.right, //which side to show scrollbar
                    child: ListView(
                      // padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      children: [
                        editProfile ?
                        Container(
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.all(10),
                          child: Column(
                            children: [
                              Card(
                                child: Form(
                                  key: _formKey,
                                  child: Container(
                                    padding: EdgeInsets.all(15),
                                    width: double.infinity,
                                    alignment: Alignment.topLeft,
                                    child: Column(
                                      children: [
                                        Text("Basic Information", style: TextStyle(fontSize: 17),),
                                        Divider(),
                                        TextFormField(
                                          controller: input_user_name,
                                          // initialValue: user_name,
                                          decoration: InputDecoration(
                                            labelText: "User Name",
                                            hintText: "Enter your user name",
                                            fillColor: Colors.white,
                                            filled: true,
                                            contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.grey)),
                                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.grey.shade400)),
                                            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.red, width: 2.0)),
                                            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.red, width: 2.0)),
                                          ),
                                          validator: (val) {
                                            if(val!.trim().isEmpty){
                                              return "User Name is required";
                                            }
                                            else{
                                              return null;
                                            }
                                            
                                          },
                                        ),
                                        SizedBox(height: 15,),
                                        TextFormField(
                                          controller: input_first_name,
                                          // initialValue: first_name,
                                          decoration: InputDecoration(
                                            labelText: "First Name",
                                            hintText: "Enter your first name",
                                            fillColor: Colors.white,
                                            filled: true,
                                            contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.grey)),
                                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.grey.shade400)),
                                            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.red, width: 2.0)),
                                            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.red, width: 2.0)),
                                          ),
                                          validator: (val) {
                                            if(val!.trim().isEmpty){
                                              return "First Name is required";
                                            }
                                            else{
                                              return null;
                                            }
                                            
                                          },
                                        ),
                                        SizedBox(height: 15,),
                                        TextFormField(
                                          controller: input_last_name,
                                          // initialValue: last_name,
                                          decoration: InputDecoration(
                                            labelText: "Last Name",
                                            hintText: "Enter your last name",
                                            fillColor: Colors.white,
                                            filled: true,
                                            contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.grey)),
                                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.grey.shade400)),
                                            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.red, width: 2.0)),
                                            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.red, width: 2.0)),
                                          ),
                                          validator: (val) {
                                            if(val!.trim().isEmpty){
                                              return "Last Name is required";
                                            }
                                            else{
                                              return null;
                                            }
                                            
                                          },
                                        ),
                                        Divider(),
                                        ElevatedButton(
                                          onPressed: (){
                                            if (_formKey.currentState!.validate()) {
                                              updateUserInfo();
                                            }
                                          },
                                          child: Text("Update"),
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                                        )
                                      ],
                                    ),
                                  )
                                ),
                              ),
                              Card(
                                child: Form(
                                  key: _formKey2,
                                  child: Container(
                                    padding: EdgeInsets.all(15),
                                    width: double.infinity,
                                    alignment: Alignment.topLeft,
                                    child: Column(
                                      children: [
                                        Text("Change Password", style: TextStyle(fontSize: 17),),
                                        Divider(),
                                        TextFormField(
                                          controller: current_password,
                                          obscureText: _isCurrentPassSecure,
                                          decoration: InputDecoration(
                                            labelText: "Current Password",
                                            hintText: "Enter your current password",
                                            fillColor: Colors.white,
                                            filled: true,
                                            contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.grey)),
                                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.grey.shade400)),
                                            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.red, width: 2.0)),
                                            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.red, width: 2.0)),
                                            suffixIcon: IconButton(
                                              icon: Icon( _isCurrentPassSecure ? Icons.visibility : Icons.visibility_off),
                                              onPressed: (){
                                                setState(() {
                                                  if(_isCurrentPassSecure){
                                                    _isCurrentPassSecure = false;
                                                  }else{
                                                    _isCurrentPassSecure = true;
                                                  }
                                                });
                                              },
                                            ),
                                          ),
                                          validator: (val) {
                                            if (val!.isEmpty) {
                                              return "Current Password is required";
                                            }
                                            return null;
                                          },
                                        ),
                                        SizedBox(height: 5,),
                                        TextFormField(
                                          controller: new_password,
                                          obscureText: _isNewPassSecure,
                                          decoration: InputDecoration(
                                            labelText: "New Password",
                                            hintText: "Enter your new password",
                                            fillColor: Colors.white,
                                            filled: true,
                                            contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.grey)),
                                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.grey.shade400)),
                                            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.red, width: 2.0)),
                                            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.red, width: 2.0)),
                                            suffixIcon: IconButton(
                                              icon: Icon( _isNewPassSecure ? Icons.visibility : Icons.visibility_off),
                                              onPressed: (){
                                                setState(() {
                                                  if(_isNewPassSecure){
                                                    _isNewPassSecure = false;
                                                  }else{
                                                    _isNewPassSecure = true;
                                                  }
                                                });
                                              },
                                            ),
                                          ),
                                          validator: (val) {
                                            if (val!.isEmpty) {
                                              return "New Password is required";
                                            }else if(val.length < 8){
                                              return "New Password must be at least 8 characters";
                                            }
                                            return null;
                                          },
                                        ),
                                        SizedBox(height: 5,),
                                        TextFormField(
                                          controller: confirm_password,
                                          obscureText: _isConfirmPassSecure,
                                          decoration: InputDecoration(
                                            labelText: "Confirm Password",
                                            hintText: "Enter your confirm password",
                                            fillColor: Colors.white,
                                            filled: true,
                                            contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.grey)),
                                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.grey.shade400)),
                                            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.red, width: 2.0)),
                                            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.red, width: 2.0)),
                                            suffixIcon: IconButton(
                                              icon: Icon( _isConfirmPassSecure ? Icons.visibility : Icons.visibility_off),
                                              onPressed: (){
                                                setState(() {
                                                  if(_isConfirmPassSecure){
                                                    _isConfirmPassSecure = false;
                                                  }else{
                                                    _isConfirmPassSecure = true;
                                                  }
                                                });
                                              },
                                            ),
                                          ),
                                          validator: (val) {
                                            if (val!.isEmpty) {
                                              return "Confirm password is required";
                                            }else if(val != new_password.text){
                                              return "Confirm password does not match";
                                            }
                                            return null;
                                          },
                                        ),
                                        Divider(),
                                        ElevatedButton(
                                          onPressed: (){
                                            if (_formKey2.currentState!.validate()) {
                                              updatePasswordInfo();
                                            }
                                          },
                                          child: Text("Change"),
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                                        )
                                      ],
                                    ),
                                  )
                                ),
                              )
                            ],
                          ),
                        )
                        :
                        Card(
                          child: Container(
                            alignment: Alignment.topLeft,
                            padding: EdgeInsets.all(15),
                            child: Column(
                              children: <Widget>[
                                Column(
                                  children: <Widget>[
                                    ...ListTile.divideTiles(
                                      color: Colors.grey,
                                      tiles: [
                                        ListTile(
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 4),
                                          leading: Icon(Icons.person),
                                          title: Text("Username"),
                                          subtitle: Text("$user_name"),
                                        ),
                                        ListTile(
                                          leading: Icon(Icons.perm_identity),
                                          title: Text("Full Name"),
                                          subtitle: Text("$first_name $last_name"),
                                        ),
                                        ListTile(
                                          leading: Icon(Icons.payment_rounded),
                                          title: Text("Billing Details"),
                                          onTap: () {
                                            // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>BillingDetailsMotorist()));
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context)=>BillingDetailsMotorist())
                                            );
                                          },
                                        ),
                                        ListTile(
                                          leading: Icon(Icons.local_parking_rounded),
                                          title: Text("Parking History"),
                                        ),
                                        ListTile(
                                          leading: Icon(Icons.workspace_premium),
                                          title: Text("Permit"),
                                          onTap: () {
                                            //permitData();
                                            // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>PermitMotorist()));
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context)=>PermitMotorist())
                                            );
                                          },
                                        ),
                                        ListTile(
                                          leading: Icon(Icons.info_rounded),
                                          title: Text("Support"),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    )
                )
            ),
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