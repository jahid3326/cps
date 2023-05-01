import 'dart:async';
import 'dart:convert';
import 'package:cps/pages/admin/add_garage_form_a.dart';
// import 'package:cps/pages/admin/update_garage_form_a.dart';
// import 'package:cps/pages/garage/garage_map.dart';

import 'package:cps/common/theme_helper.dart';
import 'package:cps/pages/admin/add_garage_form_b.dart';
import 'package:cps/pages/admin/notifications.dart';
import 'package:cps/pages/admin/sidebar_nav.dart';
import 'package:cps/pages/admin/upload_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:cps/pages/widgets/header_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;



class GarageListAdmin extends StatefulWidget {
  const GarageListAdmin({super.key});

  @override
  State<GarageListAdmin> createState() => _GarageListAdminState();
}

class _GarageListAdminState extends State<GarageListAdmin> {
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

  List<TableList> _garages = [];
  List<TableList> _filterGarages = [];


  Future<dynamic> generateTableList() async {
    var client = http.Client();
    try {
      _timer?.cancel();

      EasyLoading.instance
        ..loadingStyle = EasyLoadingStyle.light;

      await EasyLoading.show(
        maskType: EasyLoadingMaskType.black,
        indicator: Lottie.asset("assets/animations/loading.json", width: 125, height: 75)
      );

      var res = await client.get(Uri.https('creativeparkingsolutions.com', 'garage/garage_list_app'));
        
      var list = jsonDecode(res.body);
      // print(list);
      if(res.statusCode == 200){

        EasyLoading.dismiss();
        
        List<TableList> _tableLists =
          await list.map<TableList>((json) => TableList.fromJson(json)).toList();
          
          return _tableLists;
        
      }
    } catch (e) {
      
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
    });
    
    generateTableList().then((value) {
      setState(() {
        _garages = value;
        _filterGarages = value;
      });
      print(_filterGarages);
      print("Length : ${_filterGarages.length}");
    });

    getCountNotification();
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Garage List",
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

              _timer?.cancel();

              EasyLoading.instance
                ..loadingStyle = EasyLoadingStyle.light;

              await EasyLoading.show(
                maskType: EasyLoadingMaskType.black,
                indicator: Lottie.asset("assets/animations/loading.json", width: 125, height: 75)
              );

              var res = await client.get(Uri.https('creativeparkingsolutions.com', 'admin/view_notification_count'));
              // print(res.statusCode);
              
              var response = jsonDecode(res.body);
              // print("Notification Count : ${response}");
              if(response['status'] == true){
                setState(() {
                  count_notification = '';
                });  
                EasyLoading.dismiss();

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
            onPressed: () {
              
            },
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
                        image: "https://creativeparkingsolutions.com/public/assets/admin/images/user/$getProfilePictureName",
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
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          child: TextFormField(
                            decoration: ThemeHelper().textInputDecoration('Search by any keywords', 'Enter any keywords'),
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (value) {
                              setState(() {
                                  _filterGarages = _garages.where((element) => 
                                    (element.garage_id!.toLowerCase().contains(value.toLowerCase()) ||
                                    element.garage_name!.toLowerCase().contains(value.toLowerCase()) ||
                                    element.status!.toLowerCase().contains(value.toLowerCase()))
                                  ).toList();
                              });
                            },
                          ),
                          decoration: ThemeHelper().inputBoxDecorationShaddow(),
                        ),
                      ),
                      SizedBox(width: 5,),
                      ElevatedButton(
                        onPressed: (){
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context)=>AddGarageFormAAdmin())
                          );
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(builder: (context)=>AddGarageFormBAdmin())
                          // );
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(builder: (context)=>UploadImage())
                          // );
                        },
                        child: Row(
                          children: [
                            Icon(Icons.add),
                            Text("Add New")
                          ],
                        ),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                      ),
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
                    child: Container(
                      padding: EdgeInsets.all(20),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor: MaterialStateColor.resolveWith((states) => Colors.blue.shade300),
                            showBottomBorder: true,
                            border: TableBorder(
                              left: BorderSide(width: 1.0, color: Colors.grey.shade400),
                              right: BorderSide(width: 1.0, color: Colors.grey.shade400)
                            ),
                            columns: [
                              DataColumn(
                                label: Center(child: Text('Garage ID', style: TextStyle(color: Colors.white),)),
                              ),
                              DataColumn(
                                label: Center(child: Text('Garage Name', style: TextStyle(color: Colors.white),)),
                              ),
                              DataColumn(
                                label: Center(child: Text('Status', style: TextStyle(color: Colors.white),)),
                              ),
                              DataColumn(
                                label: Center(child: Text('Action', style: TextStyle(color: Colors.white),)),
                              )
                            ],
                            rows: _filterGarages
                                .map(
                                  (garage) => 
                                  DataRow(
                                    color: _filterGarages.indexOf(garage) % 2 == 0 ? MaterialStateColor.resolveWith((states) => Colors.grey.shade200):MaterialStateColor.resolveWith((states) => Colors.white),
                                    cells: [
                                      DataCell(
                                        Center(
                                          child: Text(
                                            garage.garage_id.toString(),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          garage.garage_name.toString(),
                                        ),
                                      ),
                                      DataCell(
                                        Center(
                                          child: garage.status.toString() == 'Active' ?
                                          Text(
                                            garage.status.toString(),
                                            style: TextStyle(color: Colors.green),
                                          ) :
                                          Text(
                                            garage.status.toString(),
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        SizedBox(
                                          width: 100,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              garage.status.toString() == 'Active' ?
                                              Expanded(
                                                child: ElevatedButton(
                                                  onPressed: (){
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext context){
                                                        return AlertDialog(
                                                          content: Expanded(
                                                            child: Container(
                                                              height: 220,
                                                              width: 200,
                                                              child: Column(
                                                                children: [
                                                                  // Container(
                                                                  //   height: 200,
                                                                  //   width: 200,
                                                                  //   child: Image.asset("assets/images/Questions-pana-1.png", width: 200, height: 200,),
                                                                  // ),
                                                                  const Text("Do you want to deactive this ?", style: TextStyle(color: Colors.grey),)
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
                                                              onPressed: () async{
                                                                Navigator.of(context).pop(false);

                                                                var client = http.Client();
                                                                _timer?.cancel();

                                                                EasyLoading.instance
                                                                  ..loadingStyle = EasyLoadingStyle.light;

                                                                await EasyLoading.show(
                                                                  maskType: EasyLoadingMaskType.black,
                                                                  indicator: Lottie.asset("assets/animations/loading.json", width: 125, height: 75)
                                                                );
                                                                
                                                                var res = await client.get(Uri.https('creativeparkingsolutions.com', 'garage/garage_active_deactive_app/${garage.id.toString()}/deactive'));
                              
                                                                var jsonData= jsonDecode(res.body);
                                                                var list = jsonData['garage_list'];

                                                                // print(list);
                                                                if(res.statusCode == 200){

                                                                  if(jsonData['action'] == 'success'){
                                                                    
                                                                    EasyLoading.instance
                                                                      ..loadingStyle = EasyLoadingStyle.custom
                                                                      ..backgroundColor = Colors.green.shade200
                                                                      ..indicatorColor = Colors.green.shade900
                                                                      ..textColor = Colors.green.shade900;
                                                                    EasyLoading.showSuccess('Deactive Success!');
                                                                    EasyLoading.dismiss();
                                                                  
                                                                    List<TableList> _tableLists =
                                                                      await list.map<TableList>((json) => TableList.fromJson(json)).toList();
                                                                    setState(() {
                                                                      _garages = _tableLists;
                                                                      _filterGarages = _tableLists;
                                                                    });
                                                                    

                                                                  }else{
                                                                    EasyLoading.instance
                                                                      ..loadingStyle = EasyLoadingStyle.custom
                                                                      ..backgroundColor = Colors.red.shade200
                                                                      ..indicatorColor = Colors.red.shade900
                                                                      ..textColor = Colors.red.shade900;
                                                                    EasyLoading.showError('Deactive Failed!');
                                                                    EasyLoading.dismiss();
                                                                  }
                                                                  
                                                                }
                                                              },
                                                              child: const Text("Yes"),
                                                              style: TextButton.styleFrom(backgroundColor: Colors.green.shade900, foregroundColor: Colors.white),
                                                            )
                                                          ],
                                                        );
                                                      }
                                                    );
                                                  },
                                                  child: CircleAvatar(child: Icon(Icons.close, size: 20,), backgroundColor: Colors.red, radius: 12, ),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.transparent,
                                                    elevation: 0,
                                                    side: const BorderSide(
                                                      width: 0,
                                                      color: Colors.transparent,
                                                    ),
                                                    padding: EdgeInsets.all(0)
                                                  ),
                                                ),
                                              ) : 
                                              Expanded(
                                                child: ElevatedButton(
                                                  onPressed: (){
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext context){
                                                        return AlertDialog(
                                                          content: Expanded(
                                                            child: Container(
                                                              height: 220,
                                                              width: 200,
                                                              child: Column(
                                                                children: [
                                                                  // Container(
                                                                  //   height: 200,
                                                                  //   width: 200,
                                                                  //   child: Image.asset("assets/images/Questions-pana-1.png", width: 200, height: 200,),
                                                                  // ),
                                                                  const Text("Do you want to active this ?", style: TextStyle(color: Colors.grey),)
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
                                                              onPressed: () async{
                                                                Navigator.of(context).pop(false);

                                                                var client = http.Client();
                                                                _timer?.cancel();

                                                                EasyLoading.instance
                                                                  ..loadingStyle = EasyLoadingStyle.light;

                                                                await EasyLoading.show(
                                                                  maskType: EasyLoadingMaskType.black,
                                                                  indicator: Lottie.asset("assets/animations/loading.json", width: 125, height: 75)
                                                                );
                                                                
                                                                var res = await client.get(Uri.https('creativeparkingsolutions.com', 'garage/garage_active_deactive_app/${garage.id.toString()}/active'));
                              
                                                                var jsonData= jsonDecode(res.body);
                                                                var list = jsonData['garage_list'];

                                                                // print(list);
                                                                if(res.statusCode == 200){

                                                                  if(jsonData['action'] == 'success'){
                                                                    
                                                                    EasyLoading.instance
                                                                      ..loadingStyle = EasyLoadingStyle.custom
                                                                      ..backgroundColor = Colors.green.shade200
                                                                      ..indicatorColor = Colors.green.shade900
                                                                      ..textColor = Colors.green.shade900;
                                                                    EasyLoading.showSuccess('Active Success!');
                                                                    EasyLoading.dismiss();
                                                                  
                                                                    List<TableList> _tableLists =
                                                                      await list.map<TableList>((json) => TableList.fromJson(json)).toList();
                                                                    setState(() {
                                                                      _garages = _tableLists;
                                                                      _filterGarages = _tableLists;
                                                                    });
                                                                    

                                                                  }else{
                                                                    EasyLoading.instance
                                                                      ..loadingStyle = EasyLoadingStyle.custom
                                                                      ..backgroundColor = Colors.red.shade200
                                                                      ..indicatorColor = Colors.red.shade900
                                                                      ..textColor = Colors.red.shade900;
                                                                    EasyLoading.showError('Active Failed!');
                                                                    EasyLoading.dismiss();
                                                                  }
                                                                  
                                                                }
                                                              },
                                                              child: const Text("Yes"),
                                                              style: TextButton.styleFrom(backgroundColor: Colors.green.shade900, foregroundColor: Colors.white),
                                                            )
                                                          ],
                                                        );
                                                      }
                                                    );
                                                  },
                                                  child: CircleAvatar(child: Icon(Icons.check, size: 20,), backgroundColor: Colors.green, radius: 12, ),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.transparent,
                                                    elevation: 0,
                                                    side: const BorderSide(
                                                      width: 0,
                                                      color: Colors.transparent,
                                                    ),
                                                    padding: EdgeInsets.all(0)
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: 
                                                ElevatedButton(
                                                  onPressed: (){
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext context){
                                                        return AlertDialog(
                                                          content: Expanded(
                                                            child: Container(
                                                              height: 220,
                                                              width: 200,
                                                              child: Column(
                                                                children: [
                                                                  // Container(
                                                                  //   height: 200,
                                                                  //   width: 200,
                                                                  //   child: Image.asset("assets/images/Questions-pana-1.png", width: 200, height: 200,),
                                                                  // ),
                                                                  const Text("Do you want to delete this ?", style: TextStyle(color: Colors.grey),)
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
                                                              onPressed: () async{
                                                                Navigator.of(context).pop(false);

                                                                var client = http.Client();
                                                                _timer?.cancel();

                                                                EasyLoading.instance
                                                                  ..loadingStyle = EasyLoadingStyle.light;

                                                                await EasyLoading.show(
                                                                  maskType: EasyLoadingMaskType.black,
                                                                  indicator: Lottie.asset("assets/animations/loading.json", width: 125, height: 75)
                                                                );
                                                                
                                                                var res = await client.get(Uri.https('creativeparkingsolutions.com', 'garage/delete_garage_app/${garage.id.toString()}'));
                              
                                                                var jsonData= jsonDecode(res.body);
                                                                var list = jsonData['garage_list'];

                                                                // print(list);
                                                                if(res.statusCode == 200){

                                                                  if(jsonData['action'] == 'success'){
                                                                    
                                                                    EasyLoading.instance
                                                                      ..loadingStyle = EasyLoadingStyle.custom
                                                                      ..backgroundColor = Colors.green.shade200
                                                                      ..indicatorColor = Colors.green.shade900
                                                                      ..textColor = Colors.green.shade900;
                                                                    EasyLoading.showSuccess('Delete Success!');
                                                                    EasyLoading.dismiss();
                                                                  
                                                                    List<TableList> _tableLists =
                                                                      await list.map<TableList>((json) => TableList.fromJson(json)).toList();
                                                                    setState(() {
                                                                      _garages = _tableLists;
                                                                      _filterGarages = _tableLists;
                                                                    });
                                                                    

                                                                  }else{
                                                                    EasyLoading.instance
                                                                      ..loadingStyle = EasyLoadingStyle.custom
                                                                      ..backgroundColor = Colors.red.shade200
                                                                      ..indicatorColor = Colors.red.shade900
                                                                      ..textColor = Colors.red.shade900;
                                                                    EasyLoading.showError('Delete Failed!');
                                                                    EasyLoading.dismiss();
                                                                  }
                                                                  
                                                                }
                                                              },
                                                              child: const Text("Yes"),
                                                              style: TextButton.styleFrom(backgroundColor: Colors.green.shade900, foregroundColor: Colors.white),
                                                            )
                                                          ],
                                                        );
                                                      }
                                                    );
                                                  },
                                                  child: Icon(Icons.delete, size: 25, color: Colors.red,),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.transparent,
                                                    elevation: 0,
                                                    side: const BorderSide(
                                                      width: 0,
                                                      color: Colors.transparent,
                                                    ),
                                                    padding: EdgeInsets.all(0)
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: 
                                                ElevatedButton(
                                                  onPressed: (){
                                                    //print(garage.cid);
                                                    // Navigator.push(context, MaterialPageRoute(builder: (context)=>UpdateGarageFormAAdmin(cid: garage.cid.toString(), gid: garage.id.toString())));

                                                  },
                                                  child: Icon(Icons.edit_note_rounded, size: 25, color: Colors.blue,),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.transparent,
                                                    elevation: 0,
                                                    side: const BorderSide(
                                                      width: 0,
                                                      color: Colors.transparent,
                                                    ),
                                                    padding: EdgeInsets.all(0)
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: 
                                                ElevatedButton(
                                                  onPressed: (){
                                                    // Navigator.push(context, MaterialPageRoute(builder: (context)=>GarageMapGarage(garage_id: garage.garage_id.toString())));
                                                  },
                                                  child: Icon(Icons.location_on_sharp, size: 25, color: Colors.blue,),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.transparent,
                                                    elevation: 0,
                                                    side: const BorderSide(
                                                      width: 0,
                                                      color: Colors.transparent,
                                                    ),
                                                    padding: EdgeInsets.all(0)
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      )
                                    ]
                                  ),
                                ).toList(),
                          ),
                        ),
                      )
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
 
class TableList {
  int? id;
  int? cid;
  String? garage_id;
  String? garage_name;
  String? status;

 
  TableList({this.id, this.cid, this.garage_id, this.garage_name, this.status});
 
  factory TableList.fromJson(Map<String, dynamic> json) {
    
    return TableList(
        id: int.parse(json['id']),
        cid: int.parse(json['ID']),
        garage_id: json['G_id'] as String,
        garage_name: json['name'] as String,
        status: json['status'] as String,
    );
  }
}