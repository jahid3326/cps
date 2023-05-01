import 'dart:async';
import 'dart:convert';

import 'package:cps/common/theme_helper.dart';
import 'package:cps/pages/garage/notifications.dart';
import 'package:cps/pages/garage/update_staff.dart';
import 'package:cps/pages/garage/sidebar_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:cps/pages/widgets/header_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';



class ViewStaffGarage extends StatefulWidget {
  const ViewStaffGarage({super.key});

  @override
  State<ViewStaffGarage> createState() => _ViewStaffGarageState();
}

class _ViewStaffGarageState extends State<ViewStaffGarage> {
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

      var res = await client.get(Uri.https('creativeparkingsolutions.com', 'garage/get_notification_count'));
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

  /////////// Start Staff Data List ///////////////
  List<StaffList> _staffList = [];
  List<StaffList> _filterStaffData = [];


  Future<dynamic> generateStaffList() async {
    var client = http.Client();
    try {
      _timer?.cancel();

      EasyLoading.instance
        ..loadingStyle = EasyLoadingStyle.light;

      await EasyLoading.show(
        maskType: EasyLoadingMaskType.black,
        indicator: Lottie.asset("assets/animations/loading.json", width: 125, height: 75)
      );

      var res = await client.get(Uri.https('creativeparkingsolutions.com', 'admin/get_staff_app'));
      // print(res.statusCode);  
      var list = jsonDecode(res.body);
      // print(list);
      if(res.statusCode == 200){
        EasyLoading.dismiss();
        List<StaffList> _staffTableLists =
          await list.map<StaffList>((json) => StaffList.fromJson(json)).toList();
          
          return _staffTableLists;
        
      }
    } catch (e) {
      
    }
  }
  /////////// End Client Data List ////////////////
  
  late TooltipBehavior _tooltipBehavior;
  late TooltipBehavior _tooltipBehavior2;

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

    _tooltipBehavior = TooltipBehavior(enable: true);
    _tooltipBehavior2 = TooltipBehavior(enable: true);

    generateStaffList().then((value){
      // print("Value of Client : ${value}");
      setState(() {
        _staffList = value;
        _filterStaffData = value;
      });
      // print(_filterClientData);
      // print("Length : ${_filterClientData.length}");
    });

    getCountNotification();

  }

  bool chartLoading1 = false;
  String? selectedGarage1;

  bool chartLoading2 = false;
  String? selectedGarage2;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("View Staff",
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

              var res = await client.get(Uri.https('creativeparkingsolutions.com', 'garage/view_notification_count'));
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
                  MaterialPageRoute(builder: (context)=>NotificationGarage())
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
                        image: "https://creativeparkingsolutions.com/public/assets/garage/images/user/$getProfilePictureName",
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
            SizedBox(height: 10,),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: Container(
                            width: double.infinity,
                            height: 500,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black54,
                                  offset: Offset(0, 0),
                                  blurRadius: 6.0,
                                  spreadRadius: 0.1
                                )
                              ]
                            ),
                            child: 
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(7),
                                  child: Row(
                                    children: [
                                      Text("Staff", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black54),),
                                      SizedBox(width: 10,),
                                      Expanded(
                                        child: Container(
                                          alignment: Alignment.center,
                                          child: TextFormField(
                                            decoration: ThemeHelper().textInputDecoration('Search by any keywords', 'Enter any keywords'),
                                            keyboardType: TextInputType.emailAddress,
                                            onChanged: (value) {
                                              setState(() {
                                                  _filterStaffData = _staffList.where((element) => 
                                                    (element.first_name!.toLowerCase().contains(value.toLowerCase()) ||
                                                    element.last_name!.toLowerCase().contains(value.toLowerCase()) ||
                                                    element.email!.toLowerCase().contains(value.toLowerCase()) ||
                                                    element.work_type!.toLowerCase().contains(value.toLowerCase())
                                                    )
                                                  ).toList();
                                              });
                                            },
                                          ),
                                          decoration: ThemeHelper().inputBoxDecorationShaddow(),
                                        ),
                                      )
                                    ],
                                  )
                                  // Row(
                                  //   children: [
                                  //     Text("My Clients", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black54),),
                                      
                                  //   ],
                                  // ),
                                ),
                                Expanded(
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
                                            label: Center(child: Text('First Name', style: TextStyle(color: Colors.white),)),
                                          ),
                                          DataColumn(
                                            label: Center(child: Text('Last Name', style: TextStyle(color: Colors.white),)),
                                          ),
                                          DataColumn(
                                            label: Center(child: Text('Email', style: TextStyle(color: Colors.white),)),
                                          ),
                                          DataColumn(
                                            label: Center(child: Text('Roll', style: TextStyle(color: Colors.white),)),
                                          ),
                                          DataColumn(
                                            label: Center(child: Text('Action', style: TextStyle(color: Colors.white),)),
                                          ),
                                          
                                        ],
                                        rows: _filterStaffData
                                            .map(
                                              (data) => 
                                              DataRow(
                                                color: _filterStaffData.indexOf(data) % 2 == 0 ? MaterialStateColor.resolveWith((states) => Colors.grey.shade200):MaterialStateColor.resolveWith((states) => Colors.white),
                                                cells: [
                                                  DataCell(
                                                    ConstrainedBox(
                                                      constraints: BoxConstraints(maxWidth: 90),
                                                      child: Text(
                                                        data.first_name.toString(),
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    ConstrainedBox(
                                                      constraints: BoxConstraints(maxWidth: 90),
                                                      child: Text(
                                                        data.last_name.toString(),
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    ConstrainedBox(
                                                      constraints: BoxConstraints(maxWidth: 90),
                                                      child: Text(
                                                        data.email.toString(),
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    ConstrainedBox(
                                                      constraints: BoxConstraints(maxWidth: 90),
                                                      child: Text(
                                                        data.work_type.toString(),
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                   SizedBox(
                                                    width: 50,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Expanded(
                                                          child: 
                                                            ElevatedButton(
                                                              onPressed: (){
                                                                //print(garage.cid);
                                                                Navigator.push(context, MaterialPageRoute(builder: (context)=>UpdateStaffGarage(id: data.id.toString())));

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
                                                                              Container(
                                                                                height: 200,
                                                                                width: 200,
                                                                                child: Image.asset("assets/images/Questions-pana-1.png", width: 200, height: 200,),
                                                                              ),
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
                                                                            
                                                                            var res = await client.get(Uri.https('creativeparkingsolutions.com', 'admin/delete_staff_app/${data.id.toString()}'));
                                          
                                                                            var jsonData= jsonDecode(res.body);
                                                                            var list = jsonData['staff_data'];

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
                                                                              
                                                                                List<StaffList> _staffLists =
                                                                                  await list.map<StaffList>((json) => StaffList.fromJson(json)).toList();
                                                                                setState(() {
                                                                                  _staffList= _staffLists;
                                                                                  _filterStaffData = _staffLists;
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
                                                      ],
                                                    ),
                                                   )
                                                  ),
                                                ]
                                              ),
                                            ).toList(), 
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ),
                        )
                      ]
                    )
                  ),
                ],
              ),
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

class StaffList {
  int? id;
  String? first_name;
  String? last_name;
  String? email;
  String? work_type;
  
  StaffList({this.id, this.first_name, this.last_name, this.email, this.work_type});
 
  factory StaffList.fromJson(Map<String, dynamic> json) {
    
    return StaffList(
        id: int.parse(json['staff_id']),
        first_name: json['first_name'] as String,
        last_name: json['last_name'] as String,
        email: json['email'] as String,
        work_type: json['work_type'] as String,
    );
  }
}