import 'dart:async';
import 'dart:convert';
import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';

import 'package:cps/common/theme_helper.dart';
import 'package:cps/pages/admin/notifications.dart';
import 'package:cps/pages/admin/sidebar_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:cps/pages/widgets/header_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;



class ApproveAdmin extends StatefulWidget {
  const ApproveAdmin({super.key});

  @override
  State<ApproveAdmin> createState() => _ApproveAdminState();
}

class _ApproveAdminState extends State<ApproveAdmin> {
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

  /////////// Start Motorist Data List ///////////////
  List<MotoristList> _motoristList = [];
  List<MotoristList> _filterMotoristData = [];


  Future<dynamic> generateMotoristList() async {
    var client = http.Client();
    try {
      _timer?.cancel();

      EasyLoading.instance
        ..loadingStyle = EasyLoadingStyle.light;

      await EasyLoading.show(
        maskType: EasyLoadingMaskType.black,
        indicator: Lottie.asset("assets/animations/loading.json", width: 125, height: 75)
      );

      var res = await client.get(Uri.https('creativeparkingsolutions.com', 'admin/approve_app'));
      //print(res.statusCode);  
      var list = jsonDecode(res.body);
      //print(list);
      if(res.statusCode == 200){
        EasyLoading.dismiss();

        List<MotoristList> _motoristTableLists =
          await list['motorist'].map<MotoristList>((json) => MotoristList.fromJson(json)).toList();
          
          return _motoristTableLists;
        
      }
    } catch (e) {
      
    }
  }
  /////////// End Motorist Data List ////////////////
  
  //////// Start Garage Owner /////////////////
  List<GarageOwnerList> _garageOwnerList = [];
  List<GarageOwnerList> _filterGarageOwnerData = [];


  Future<dynamic> generateGarageOwnerTableList() async {
    var client = http.Client();
    try {
      _timer?.cancel();

      // EasyLoading.instance
      //   ..loadingStyle = EasyLoadingStyle.light;

      // await EasyLoading.show(
      //   maskType: EasyLoadingMaskType.black,
      //   indicator: Lottie.asset("assets/animations/loading.json", width: 125, height: 75)
      // );

      var res = await client.get(Uri.https('creativeparkingsolutions.com', 'admin/approve_app'));
        
      var list = jsonDecode(res.body);
      // print(list['garage']);
      if(res.statusCode == 200){

        // EasyLoading.dismiss();
        
        List<GarageOwnerList> _tableLists =
          await list['garage'].map<GarageOwnerList>((json) => GarageOwnerList.fromJson(json)).toList();
          
          return _tableLists;
        
      }
    } catch (e) {
      
    }
  }
  /////// End User & Roll //////////////////

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
    
    generateMotoristList().then((value) {
      setState(() {
        _motoristList = value;
        _filterMotoristData = value;
      });
      // print(_filterMotoristData);
      // print("Length : ${_filterMotoristData.length}");
    });

    generateGarageOwnerTableList().then((value){
      setState(() {
        _garageOwnerList = value;
        _filterGarageOwnerData = value;
      });
      // print("object");
      print(_filterGarageOwnerData);
      print("Length : ${_filterGarageOwnerData.length}");
    });
    // generateTableList2().then((value) {
    //   setState(() {
    //     _dataList2 = value;
    //     _filterData2 = value;
    //   });
    //   print(_filterData2);
    //   print("Length : ${_filterData2.length}");
    // });

    getCountNotification();
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Approve",
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
                      child: 
                      ContainedTabBarView(
                        tabs: [
                          Text("I'm Motorist"),
                          Text("I'm Garage Owner"),
                        ],
                        tabBarProperties: TabBarProperties(
                          background: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue.shade200,
                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4),
                                  spreadRadius: 0.5,
                                  blurRadius: 2,
                                  offset: Offset(1, -1),
                                ),
                              ],
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32.0,
                            vertical: 8.0,
                          ),
                          indicator: ContainerTabIndicator(
                            radius: BorderRadius.circular(16.0),
                            color: Colors.blue,
                            borderWidth: 1.0,
                            borderColor: Colors.black45,
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.black54,
                        ),
                        views: [
                          Column(

                            children: [
                              SizedBox(height: 5,),
                              TextFormField(
                                decoration: ThemeHelper().textInputDecoration('Search by any keywords', 'Enter any keywords'),
                                keyboardType: TextInputType.emailAddress,
                                onChanged: (value) {
                                  setState(() {
                                      _filterMotoristData = _motoristList.where((element) => 
                                        (element.username!.toLowerCase().contains(value.toLowerCase()) ||
                                        element.email!.toLowerCase().contains(value.toLowerCase()) ||
                                        element.status!.toLowerCase().contains(value.toLowerCase()))
                                      ).toList();
                                  });
                                },
                              ),
                              SizedBox(height: 5,),
                              Expanded(
                                child:
                                  SingleChildScrollView(
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
                                            label: Center(child: Text('User Name')),
                                          ),
                                          DataColumn(
                                            label: Center(child: Text('Email')),
                                          ),
                                          DataColumn(
                                            label: Center(child: Text('Status')),
                                          ),
                                          DataColumn(
                                            label: Center(child: Text('Action')),
                                          )
                                        ],
                                        rows: _filterMotoristData
                                            .map(
                                              (data) => 
                                              DataRow(
                                                color: _filterMotoristData.indexOf(data) % 2 == 0 ? MaterialStateColor.resolveWith((states) => Colors.grey.shade200):MaterialStateColor.resolveWith((states) => Colors.white),
                                                cells: [
                                                  DataCell(
                                                    ConstrainedBox(
                                                      constraints: BoxConstraints(maxWidth: 90),
                                                      child: Text(
                                                        data.username.toString(),
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    ConstrainedBox(
                                                      constraints: BoxConstraints(
                                                        maxWidth: 140
                                                      ),
                                                      child: Text(
                                                        data.email.toString(),
                                                      ),
                                                    )
                                                  ),
                                                  DataCell(
                                                    ConstrainedBox(
                                                      constraints: BoxConstraints(
                                                        maxWidth: 100
                                                      ),
                                                      child: Center(
                                                        child: 
                                                        data.status.toString() == 'approve' ?
                                                        DecoratedBox(
                                                          decoration: BoxDecoration(
                                                            shape: BoxShape.rectangle,
                                                            color: Colors.green
                                                          ),
                                                          child: 
                                                          Padding(
                                                            padding: const EdgeInsets.all(8.0),
                                                            child: Text(
                                                              data.status.toString(),
                                                              style: TextStyle(color: Colors.white),
                                                            ),
                                                          ),
                                                        ):
                                                        DecoratedBox(
                                                          decoration: BoxDecoration(
                                                            shape: BoxShape.rectangle,
                                                            color: Colors.red.shade600
                                                          ),
                                                          child: 
                                                          Padding(
                                                            padding: const EdgeInsets.all(8.0),
                                                            child: Text(
                                                              data.status.toString(),
                                                              style: TextStyle(color: Colors.white),
                                                            ),
                                                          ),
                                                        )
                                                        
                                                        ),
                                                    )
                                                  ),
                                                  DataCell(
                                                    SizedBox(
                                                      width: 100,
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          data.status.toString() == 'approve' ?
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
                                                                              Container(
                                                                                height: 200,
                                                                                width: 200,
                                                                                child: Image.asset("assets/images/Questions-pana-1.png", width: 200, height: 200,),
                                                                              ),
                                                                              const Text("Do you want to deapprove this ?", style: TextStyle(color: Colors.grey),)
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
                                                                            
                                                                            var res = await client.get(Uri.https('creativeparkingsolutions.com', 'admin/motorist_approve_reject_app/${data.id.toString()}/reject'));
                                          
                                                                            var jsonData= jsonDecode(res.body);
                                                                            var list = jsonData['motorist'];

                                                                            // print(res.statusCode);
                                                                            if(res.statusCode == 200){

                                                                              if(jsonData['action'] == 'success'){
                                                                                
                                                                                EasyLoading.instance
                                                                                  ..loadingStyle = EasyLoadingStyle.custom
                                                                                  ..backgroundColor = Colors.green.shade200
                                                                                  ..indicatorColor = Colors.green.shade900
                                                                                  ..textColor = Colors.green.shade900;
                                                                                EasyLoading.showSuccess('Deapprove Success!');
                                                                                EasyLoading.dismiss();
                                                                              
                                                                                List<MotoristList> _tableLists =
                                                                                  await list.map<MotoristList>((json) => MotoristList.fromJson(json)).toList();
                                                                                setState(() {
                                                                                  _motoristList = _tableLists;
                                                                                  _filterMotoristData = _tableLists;
                                                                                });
                                                                                

                                                                              }else{
                                                                                EasyLoading.instance
                                                                                  ..loadingStyle = EasyLoadingStyle.custom
                                                                                  ..backgroundColor = Colors.red.shade200
                                                                                  ..indicatorColor = Colors.red.shade900
                                                                                  ..textColor = Colors.red.shade900;
                                                                                EasyLoading.showError('Deapprove Failed!');
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
                                                                              Container(
                                                                                height: 200,
                                                                                width: 200,
                                                                                child: Image.asset("assets/images/Questions-pana-1.png", width: 200, height: 200,),
                                                                              ),
                                                                              const Text("Do you want to approve this ?", style: TextStyle(color: Colors.grey),)
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
                                                                            
                                                                            var res = await client.get(Uri.https('creativeparkingsolutions.com', 'admin/motorist_approve_reject_app/${data.id.toString()}/approve'));
                                          
                                                                            var jsonData= jsonDecode(res.body);
                                                                            var list = jsonData['motorist'];

                                                                            // print(list);
                                                                            if(res.statusCode == 200){

                                                                              if(jsonData['action'] == 'success'){
                                                                                
                                                                                EasyLoading.instance
                                                                                  ..loadingStyle = EasyLoadingStyle.custom
                                                                                  ..backgroundColor = Colors.green.shade200
                                                                                  ..indicatorColor = Colors.green.shade900
                                                                                  ..textColor = Colors.green.shade900;
                                                                                EasyLoading.showSuccess('Approve Success!');
                                                                                EasyLoading.dismiss();
                                                                              
                                                                                List<MotoristList> _tableLists =
                                                                                  await list.map<MotoristList>((json) => MotoristList.fromJson(json)).toList();
                                                                                setState(() {
                                                                                  _motoristList = _tableLists;
                                                                                  _filterMotoristData = _tableLists;
                                                                                });
                                                                                

                                                                              }else{
                                                                                EasyLoading.instance
                                                                                  ..loadingStyle = EasyLoadingStyle.custom
                                                                                  ..backgroundColor = Colors.red.shade200
                                                                                  ..indicatorColor = Colors.red.shade900
                                                                                  ..textColor = Colors.red.shade900;
                                                                                EasyLoading.showError('Approve Failed!');
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
                            ],
                          ),
                          // Container(color: Colors.green)
                          Column(

                            children: [
                              SizedBox(height: 5,),
                              TextFormField(
                                decoration: ThemeHelper().textInputDecoration('Search by any keywords', 'Enter any keywords'),
                                keyboardType: TextInputType.emailAddress,
                                onChanged: (value) {
                                  setState(() {
                                      _filterGarageOwnerData = _garageOwnerList.where((element) => 
                                        (element.username!.toLowerCase().contains(value.toLowerCase()) ||
                                        element.email!.toLowerCase().contains(value.toLowerCase()) ||
                                        element.status!.toLowerCase().contains(value.toLowerCase()))
                                      ).toList();
                                  });
                                },
                              ),
                              SizedBox(height: 5,),
                              Expanded(
                                child:
                                  SingleChildScrollView(
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
                                            label: Center(child: Text('User Name')),
                                          ),
                                          DataColumn(
                                            label: Center(child: Text('Email')),
                                          ),
                                          DataColumn(
                                            label: Center(child: Text('Status')),
                                          ),
                                          DataColumn(
                                            label: Center(child: Text('Action')),
                                          )
                                        ],
                                        rows: _filterGarageOwnerData
                                            .map(
                                              (data) => 
                                              DataRow(
                                                color: _filterGarageOwnerData.indexOf(data) % 2 == 0 ? MaterialStateColor.resolveWith((states) => Colors.grey.shade200):MaterialStateColor.resolveWith((states) => Colors.white),
                                                cells: [
                                                  DataCell(
                                                    ConstrainedBox(
                                                      constraints: BoxConstraints(maxWidth: 90),
                                                      child: Text(
                                                        data.username.toString(),
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    ConstrainedBox(
                                                      constraints: BoxConstraints(
                                                        maxWidth: 140
                                                      ),
                                                      child: Text(
                                                        data.email.toString(),
                                                      ),
                                                    )
                                                  ),
                                                  DataCell(
                                                    ConstrainedBox(
                                                      constraints: BoxConstraints(
                                                        maxWidth: 100
                                                      ),
                                                      child: Center(
                                                        child: 
                                                        data.status.toString() == 'approve' ?
                                                        DecoratedBox(
                                                          decoration: BoxDecoration(
                                                            shape: BoxShape.rectangle,
                                                            color: Colors.green
                                                          ),
                                                          child: 
                                                          Padding(
                                                            padding: const EdgeInsets.all(8.0),
                                                            child: Text(
                                                              data.status.toString(),
                                                              style: TextStyle(color: Colors.white),
                                                            ),
                                                          ),
                                                        ):
                                                        DecoratedBox(
                                                          decoration: BoxDecoration(
                                                            shape: BoxShape.rectangle,
                                                            color: Colors.red.shade600
                                                          ),
                                                          child: 
                                                          Padding(
                                                            padding: const EdgeInsets.all(8.0),
                                                            child: Text(
                                                              data.status.toString(),
                                                              style: TextStyle(color: Colors.white),
                                                            ),
                                                          ),
                                                        )
                                                        
                                                        ),
                                                    )
                                                  ),
                                                  DataCell(
                                                    SizedBox(
                                                      width: 100,
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          data.status.toString() == 'approve' ?
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
                                                                              Container(
                                                                                height: 200,
                                                                                width: 200,
                                                                                child: Image.asset("assets/images/Questions-pana-1.png", width: 200, height: 200,),
                                                                              ),
                                                                              const Text("Do you want to deapprove this ?", style: TextStyle(color: Colors.grey),)
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
                                                                            
                                                                            var res = await client.get(Uri.https('creativeparkingsolutions.com', 'admin/garage_owner_approve_reject_app/${data.id.toString()}/reject'));
                                          
                                                                            var jsonData= jsonDecode(res.body);
                                                                            var list = jsonData['garage'];

                                                                            // print(res.statusCode);
                                                                            if(res.statusCode == 200){

                                                                              if(jsonData['action'] == 'success'){
                                                                                
                                                                                EasyLoading.instance
                                                                                  ..loadingStyle = EasyLoadingStyle.custom
                                                                                  ..backgroundColor = Colors.green.shade200
                                                                                  ..indicatorColor = Colors.green.shade900
                                                                                  ..textColor = Colors.green.shade900;
                                                                                EasyLoading.showSuccess('Deapprove Success!');
                                                                                EasyLoading.dismiss();
                                                                              
                                                                                List<GarageOwnerList> _tableLists =
                                                                                  await list.map<GarageOwnerList>((json) => GarageOwnerList.fromJson(json)).toList();
                                                                                setState(() {
                                                                                  _garageOwnerList = _tableLists;
                                                                                  _filterGarageOwnerData = _tableLists;
                                                                                });
                                                                                

                                                                              }else{
                                                                                EasyLoading.instance
                                                                                  ..loadingStyle = EasyLoadingStyle.custom
                                                                                  ..backgroundColor = Colors.red.shade200
                                                                                  ..indicatorColor = Colors.red.shade900
                                                                                  ..textColor = Colors.red.shade900;
                                                                                EasyLoading.showError('Deapprove Failed!');
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
                                                                              Container(
                                                                                height: 200,
                                                                                width: 200,
                                                                                child: Image.asset("assets/images/Questions-pana-1.png", width: 200, height: 200,),
                                                                              ),
                                                                              const Text("Do you want to approve this ?", style: TextStyle(color: Colors.grey),)
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
                                                                            
                                                                            var res = await client.get(Uri.https('creativeparkingsolutions.com', 'admin/garage_owner_approve_reject_app/${data.id.toString()}/approve'));
                                          
                                                                            var jsonData= jsonDecode(res.body);
                                                                            var list = jsonData['garage'];

                                                                            // print(list);
                                                                            if(res.statusCode == 200){

                                                                              if(jsonData['action'] == 'success'){
                                                                                
                                                                                EasyLoading.instance
                                                                                  ..loadingStyle = EasyLoadingStyle.custom
                                                                                  ..backgroundColor = Colors.green.shade200
                                                                                  ..indicatorColor = Colors.green.shade900
                                                                                  ..textColor = Colors.green.shade900;
                                                                                EasyLoading.showSuccess('Approve Success!');
                                                                                EasyLoading.dismiss();
                                                                              
                                                                                List<GarageOwnerList> _tableLists =
                                                                                  await list.map<GarageOwnerList>((json) => GarageOwnerList.fromJson(json)).toList();
                                                                                setState(() {
                                                                                  _garageOwnerList = _tableLists;
                                                                                  _filterGarageOwnerData = _tableLists;
                                                                                });
                                                                                

                                                                              }else{
                                                                                EasyLoading.instance
                                                                                  ..loadingStyle = EasyLoadingStyle.custom
                                                                                  ..backgroundColor = Colors.red.shade200
                                                                                  ..indicatorColor = Colors.red.shade900
                                                                                  ..textColor = Colors.red.shade900;
                                                                                EasyLoading.showError('Approve Failed!');
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
                            ],
                          ),
                        ]
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
 
class MotoristList {
  int? id;
  String? username;
  String? email;
  String? status;

 
  MotoristList({this.id, this.username, this.email, this.status});
 
  factory MotoristList.fromJson(Map<String, dynamic> json) {
    
    return MotoristList(
        id: int.parse(json['user_id']),
        username: json['user_name'] as String,
        email: json['email'] as String,
        status: json['status'] as String
    );
  }
}

class GarageOwnerList {
  int? id;
  String? username;
  String? email;
  String? status;

 
  GarageOwnerList({this.id, this.username, this.email, this.status});
 
  factory GarageOwnerList.fromJson(Map<String, dynamic> json) {
    
    return GarageOwnerList(
        id: int.parse(json['user_id']),
        username: json['user_name'] as String,
        email: json['email'] as String,
        status: json['status'] as String
    );
  }
}

