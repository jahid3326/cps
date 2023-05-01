import 'dart:async';
import 'dart:convert';

import 'package:cps/common/theme_helper.dart';
import 'package:cps/pages/admin/notifications.dart';
import 'package:cps/pages/admin/sidebar_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:cps/pages/widgets/header_widget.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';



class DashboardAdmin extends StatefulWidget {
  const DashboardAdmin({super.key});

  @override
  State<DashboardAdmin> createState() => _DashboardAdminState();
}

class _DashboardAdminState extends State<DashboardAdmin> {
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

  Future<List> getData()async{
    var client = http.Client();

    try {
      
      // EasyLoading.instance
      //   ..loadingStyle = EasyLoadingStyle.light;

      // await EasyLoading.show(
      //   maskType: EasyLoadingMaskType.black,
      //   indicator: Lottie.asset("assets/animations/loading.json", width: 125, height: 75)
      // );

      var res = await client.get(Uri.https('creativeparkingsolutions.com', 'garage/index_app'));
      // print(res.statusCode);
      
      var response = jsonDecode(res.body);

      if(res.statusCode == 200){
        EasyLoading.dismiss();

        List newList = [response['total_earn'], response['count_total_space'], response['count_available_space'], response['count_free_space'], response['count_active_permit'], response['count_pending_permit'], response['count_active_citiation']];

        return newList;
      }else{
        return [];
      }

      //print(response);
      

    } catch (e) {
      //print(e);
      return [];
    }
  }

  List<ChartData> _chartData = [];

  Future <List<ChartData>> getChartData() async {
    var client = http.Client();

    var res = await client.get(Uri.https("creativeparkingsolutions.com", "admin/chart_month_app/all"));
    
    var jsonData = jsonDecode(res.body);

    final List<ChartData> chartData = [];
    
    for(var jsonArray in jsonData['values']){
      var day = jsonArray['day'];
      double value = double.parse(jsonArray['value']);
      ChartData values = ChartData(day, value);
      chartData.add(values);
    }
    
    return chartData;
  }

  List<ChartData2> _chartData2 = [];

  Future <List<ChartData2>> getChartData2() async {
    var client = http.Client();

    var res = await client.get(Uri.https("creativeparkingsolutions.com", "admin/chart_hour_app/all"));
    
    var jsonData = jsonDecode(res.body);

    final List<ChartData2> chartData2 = [];
    
    for(var jsonArray in jsonData['values']){
      var time = jsonArray['time'];
      double value = double.parse(jsonArray['value']);
      ChartData2 values = ChartData2(time, value);
      chartData2.add(values);
    }
    
    return chartData2;
  }

  /////////// Start Client Data List ///////////////
  List<ClientList> _clientList = [];
  List<ClientList> _filterClientData = [];


  Future<dynamic> generateClientList() async {
    var client = http.Client();
    try {
      _timer?.cancel();

      var res = await client.get(Uri.https('creativeparkingsolutions.com', 'admin/get_client_app'));
      // print(res.statusCode);  
      var list = jsonDecode(res.body);
      // print(list);
      if(res.statusCode == 200){

        List<ClientList> _clientTableLists =
          await list.map<ClientList>((json) => ClientList.fromJson(json)).toList();
          
          return _clientTableLists;
        
      }
    } catch (e) {
      
    }
  }
  /////////// End Client Data List ////////////////
  
  ////////// Start User & Roll /////////////////
  List<UserList> _userList = [];
  List<UserList> _filterUserData = [];


  Future<dynamic> generateUserTableList() async {
    var client = http.Client();
    try {
      _timer?.cancel();

      // EasyLoading.instance
      //   ..loadingStyle = EasyLoadingStyle.light;

      // await EasyLoading.show(
      //   maskType: EasyLoadingMaskType.black,
      //   indicator: Lottie.asset("assets/animations/loading.json", width: 125, height: 75)
      // );

      var res = await client.get(Uri.https('creativeparkingsolutions.com', 'garage/my_staff_app'));
        
      var list = jsonDecode(res.body);
      // print(list);
      if(res.statusCode == 200){

        // EasyLoading.dismiss();
        
        List<UserList> _tableLists =
          await list.map<UserList>((json) => UserList.fromJson(json)).toList();
          
          return _tableLists;
        
      }
    } catch (e) {
      
    }
  }
  ///////// End User & Roll //////////////////
  
  //////// Garage Dropdown List ////////////
  
  List _garage_list = [''];

  Future<dynamic> garageList() async {
    var client = http.Client();
    try {
      _timer?.cancel();

      // EasyLoading.instance
      //   ..loadingStyle = EasyLoadingStyle.light;

      // await EasyLoading.show(
      //   maskType: EasyLoadingMaskType.black,
      //   indicator: Lottie.asset("assets/animations/loading.json", width: 125, height: 75)
      // );

      var res = await client.get(Uri.https('creativeparkingsolutions.com', 'admin/get_dropdown_garage_app'));
        
      var list = jsonDecode(res.body);
      // print(list);
      
      List garage_list = [];

      for(var jsonData in list){
        garage_list.add(jsonData['G_id']);
      }

      //print(garage_list);

      // print(res.statusCode);
      return garage_list;
      
    } catch (e) {
      
    }
  }
  /////// End Garage Dropdown List /////////
  
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

    generateClientList().then((value){
      // print("Value of Client : ${value}");
      setState(() {
        _clientList = value;
        _filterClientData = value;
      });
      // print(_filterClientData);
      // print("Length : ${_filterClientData.length}");
    });

    generateUserTableList().then((value){
      setState(() {
        _userList = value;
        _filterUserData = value;
      });
      // print(_filterUserData);
      // print("Length : ${_filterUserData.length}");
    });

    // generateClientList();
    
    // _chartData=getChartData();

    getChartData().then((value){
      setState(() {
        _chartData = value;
      });

      // print(_chartData);
      // print("object length ${_chartData.length}");
    });

    getChartData2().then((value){
      setState(() {
        _chartData2 = value;
      });

      // print(_chartData);
      // print("object length ${_chartData.length}");
    });

    garageList().then((value) {
      setState(() {
        _garage_list = value;
      });
      
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
            SizedBox(height: 10,),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        SizedBox(height: 20,),
                        Container(
                          child: FutureBuilder(
                            future: getData(),
                            builder: (context, snapshot){
                              if(snapshot.data == null){
                                return Center(
                                  child: SizedBox(
                                    height: 30,
                                    width: 30,
                                    child: CircularProgressIndicator(color: Colors.blue, strokeWidth: 3.0,),
                                  ),
                                );
                              }else{
                                double totalEarn = double.parse(snapshot.data![0]);
                                String totalEarnString = totalEarn.toStringAsFixed(2);
                                return Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: Container(
                                              width: size.width/2.5,
                                              height: 80,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(5),
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
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                children: [
                                                  Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        "Total Earning",
                                                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey.shade600),),
                                                      Text(
                                                        "\$${totalEarnString}",
                                                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)
                                                    ],
                                                  ),
                                                  Container(
                                                    padding: EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
                                                    child: Text("\$", style: TextStyle(fontSize: 30, color: Colors.white),),
                                                    decoration: BoxDecoration(
                                                      color: Colors.blue,
                                                      borderRadius: BorderRadius.circular(10)
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 10,),
                                          Expanded(
                                            flex: 1,
                                            child: Container(
                                              width: size.width/2.5,
                                              height: 80,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(5),
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
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                children: [
                                                  Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        "Total Space",
                                                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey.shade600),),
                                                      Text(
                                                        "${snapshot.data![1]}",
                                                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)
                                                    ],
                                                  ),
                                                  Container(
                                                    padding: EdgeInsets.only(left: 13, right: 13, top: 7, bottom: 7),
                                                    child: Icon(Icons.border_all_outlined, color: Colors.white, size: 30,),
                                                    decoration: BoxDecoration(
                                                      color: Colors.blue,
                                                      borderRadius: BorderRadius.circular(10)
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10,),
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: Container(
                                              width: size.width/2.5,
                                              height: 80,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(5),
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
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                children: [
                                                  Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        "Available Space",
                                                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade600),),
                                                      Text(
                                                        "${snapshot.data![2]}",
                                                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)
                                                    ],
                                                  ),
                                                  Container(
                                                    padding: EdgeInsets.only(left: 13, right: 13, top: 7, bottom: 7),
                                                    child: Icon(Icons.auto_awesome_mosaic_outlined, color: Colors.white, size: 30,),
                                                    decoration: BoxDecoration(
                                                      color: Colors.blue,
                                                      borderRadius: BorderRadius.circular(10)
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 10,),
                                          Expanded(
                                            flex: 1,
                                            child: Container(
                                              width: size.width/2.5,
                                              height: 80,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(5),
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
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                children: [
                                                  Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        "Free Space",
                                                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey.shade600),),
                                                      Text(
                                                        "${snapshot.data![3]}",
                                                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)
                                                    ],
                                                  ),
                                                  Container(
                                                    padding: EdgeInsets.only(left: 13, right: 13, top: 7, bottom: 7),
                                                    child: Icon(Icons.ballot_outlined, color: Colors.white, size: 30,),
                                                    decoration: BoxDecoration(
                                                      color: Colors.blue,
                                                      borderRadius: BorderRadius.circular(10)
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                );
                              }
                            }
                          ),
                        )
                      ]
                    )
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: Container(
                            width: double.infinity,
                            height: 340,
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
                                      Text("My Clients", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black54),),
                                      SizedBox(width: 10,),
                                      Expanded(
                                        child: Container(
                                          alignment: Alignment.center,
                                          child: TextFormField(
                                            decoration: ThemeHelper().textInputDecoration('Search by any keywords', 'Enter any keywords'),
                                            keyboardType: TextInputType.emailAddress,
                                            onChanged: (value) {
                                              setState(() {
                                                  _filterClientData = _clientList.where((element) => 
                                                    (element.ClientID!.toLowerCase().contains(value.toLowerCase()) ||
                                                    element.FullName!.toLowerCase().contains(value.toLowerCase()) ||
                                                    element.Address!.toLowerCase().contains(value.toLowerCase()) ||
                                                    element.State!.toLowerCase().contains(value.toLowerCase())
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
                                            label: Center(child: Text('Client ID', style: TextStyle(color: Colors.white),)),
                                          ),
                                          DataColumn(
                                            label: Center(child: Text('Client Name', style: TextStyle(color: Colors.white),)),
                                          ),
                                          DataColumn(
                                            label: Center(child: Text('Address', style: TextStyle(color: Colors.white),)),
                                          ),
                                          DataColumn(
                                            label: Center(child: Text('State', style: TextStyle(color: Colors.white),)),
                                          ),
                                          DataColumn(
                                            label: Center(child: Text('View Details', style: TextStyle(color: Colors.white),)),
                                          ),
                                          
                                        ],
                                        rows: _filterClientData
                                            .map(
                                              (data) => 
                                              DataRow(
                                                color: _filterClientData.indexOf(data) % 2 == 0 ? MaterialStateColor.resolveWith((states) => Colors.grey.shade200):MaterialStateColor.resolveWith((states) => Colors.white),
                                                cells: [
                                                  DataCell(
                                                    ConstrainedBox(
                                                      constraints: BoxConstraints(maxWidth: 90),
                                                      child: Text(
                                                        data.ClientID.toString(),
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    ConstrainedBox(
                                                      constraints: BoxConstraints(maxWidth: 90),
                                                      child: Text(
                                                        data.FullName.toString(),
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    ConstrainedBox(
                                                      constraints: BoxConstraints(maxWidth: 90),
                                                      child: Text(
                                                        data.Address.toString(),
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    ConstrainedBox(
                                                      constraints: BoxConstraints(maxWidth: 90),
                                                      child: Text(
                                                        data.State.toString(),
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                   Text("Details")
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
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: Container(
                            width: double.infinity,
                            height: 340,
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
                                      Text("Users & Roll", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black54),),
                                      SizedBox(width: 10,),
                                      Expanded(
                                        child: Container(
                                          alignment: Alignment.center,
                                          child: TextFormField(
                                            decoration: ThemeHelper().textInputDecoration('Search by any keywords', 'Enter any keywords'),
                                            keyboardType: TextInputType.emailAddress,
                                            onChanged: (value) {
                                              setState(() {
                                                _filterUserData = _userList.where((element) => 
                                                  (element.name!.toLowerCase().contains(value.toLowerCase()) ||
                                                  element.email!.toLowerCase().contains(value.toLowerCase()) ||
                                                  element.roll!.toLowerCase().contains(value.toLowerCase()))
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
                                            label: Center(child: Text('Name', style: TextStyle(color: Colors.white),)),
                                          ),
                                          DataColumn(
                                            label: Center(child: Text('Email', style: TextStyle(color: Colors.white),)),
                                          ),
                                          DataColumn(
                                            label: Center(child: Text('Roll', style: TextStyle(color: Colors.white),)),
                                          ),
                                        ],
                                        rows: _filterUserData
                                            .map(
                                              (data) => 
                                              DataRow(
                                                color: _filterUserData.indexOf(data) % 2 == 0 ? MaterialStateColor.resolveWith((states) => Colors.grey.shade200):MaterialStateColor.resolveWith((states) => Colors.white),
                                                cells: [
                                                  DataCell(
                                                    ConstrainedBox(
                                                      constraints: BoxConstraints(maxWidth: 90),
                                                      child: Text(
                                                        data.name.toString(),
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
                                                        maxWidth: 80
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                            data.roll.toString(),
                                                          ),
                                                        ),
                                                    )
                                                  ),
                                                ]
                                              ),
                                            ).toList(),
                                      ),
                                    ),
                                  )
                                ),
                              ],
                            )
                          ),
                        )
                      ]
                    )
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: Container(
                            width: double.infinity,
                            height: 300,
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
                                SizedBox(height: 5,),
                                Padding(
                                  padding: const EdgeInsets.only(left:18.0, bottom: 5),
                                  child: Text("Per day Sales by garage", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left:8.0),
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(color: Colors.black38, width: 1),
                                      borderRadius: BorderRadius.circular(50),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color.fromRGBO(0, 0, 0, 0.2),
                                          blurRadius: 2
                                        )
                                      ]
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 30, right: 30, top: 0, bottom: 0),
                                      child:
                                        DropdownButton(
                                          icon: const Icon(Icons.keyboard_arrow_down),
                                          hint: Text("Choose Garage"),
                                          value: selectedGarage1,
                                          items: _garage_list.map((items) {
                                            return DropdownMenuItem(
                                              value: items,
                                              child: Text(items),
                                            );
                                          }).toList(),
                                          
                                          onChanged: (newValue) async{
                                            setState(() {
                                              chartLoading1 = true;
                                              selectedGarage1 = newValue.toString();
                                            });

                                            var client = http.Client();

                                            var res = await client.get(Uri.https("creativeparkingsolutions.com", "admin/chart_month_app/${newValue.toString()}"));
                                            
                                            var jsonData = jsonDecode(res.body);

                                            

                                            final List<ChartData> chartData = [];

                                            print(res.statusCode);
                                            
                                            for(var jsonArray in jsonData['values']){
                                              var day = jsonArray['day'];
                                              double value = double.parse(jsonArray['value']);
                                              ChartData values = ChartData(day, value);
                                              chartData.add(values);
                                            }
                                            setState(() {
                                              chartLoading1 = false;
                                              _chartData = chartData;
                                            });
                                            
                                          },
                                          underline: Container(),
                                          isExpanded: true,
                                        ),
                                    ),
                                  ),
                                ),
                                
                                Expanded(
                                  child: 
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SfCartesianChart(
                                        // title: ChartTitle(text: "Last Month"),
                                        tooltipBehavior: _tooltipBehavior,
                                        series: [
                                          SplineSeries<ChartData, String>(
                                            name: 'Earn',
                                            dataSource: _chartData,
                                            xValueMapper: (ChartData values, _) => values.day,
                                            yValueMapper: (ChartData values, _) => values.values,
                                            markerSettings: MarkerSettings(
                                              isVisible: true,
                                              color: Colors.blue.shade200
                                            ),
                                            // dataLabelSettings: DataLabelSettings(
                                            //   isVisible: true,
                                            // ),
                                            enableTooltip: true
                                          )
                                        ],
                                        primaryXAxis: CategoryAxis(
                                          edgeLabelPlacement: EdgeLabelPlacement.shift,
                                          majorGridLines: MajorGridLines(width: 0),
                                          labelRotation: 90
                                        ),
                                        primaryYAxis: NumericAxis(
                                          edgeLabelPlacement: EdgeLabelPlacement.shift,
                                          majorGridLines: MajorGridLines(width: 0),
                                          numberFormat: NumberFormat.simpleCurrency(),
                                          
                                        ),
                                      ),
                                      chartLoading1 ?
                                      SizedBox(
                                        height: 30,
                                        width: 30,
                                        child: CircularProgressIndicator(color: Colors.blue, strokeWidth: 3.0,),
                                      ) : Text(""),
                                    ],
                                  )
                                )
                              ],
                            )
                          ),
                        )
                      ]
                    )
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: Container(
                            width: double.infinity,
                            height: 300,
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
                                SizedBox(height: 5,),
                                Padding(
                                  padding: const EdgeInsets.only(left:18.0, bottom: 5),
                                  child: Text("Per hour Sales by garage", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left:8.0),
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(color: Colors.black38, width: 1),
                                      borderRadius: BorderRadius.circular(50),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color.fromRGBO(0, 0, 0, 0.2),
                                          blurRadius: 2
                                        )
                                      ]
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 30, right: 30, top: 0, bottom: 0),
                                      child:
                                        DropdownButton(
                                          icon: const Icon(Icons.keyboard_arrow_down),
                                          hint: Text("Choose Garage"),
                                          value: selectedGarage2,
                                          items: _garage_list.map((items) {
                                            return DropdownMenuItem(
                                              value: items,
                                              child: Text(items),
                                            );
                                          }).toList(),
                                          
                                          onChanged: (newValue) async{
                                            setState(() {
                                              chartLoading2 = true;
                                              selectedGarage2 = newValue.toString();
                                            });

                                            var client = http.Client();

                                            var res = await client.get(Uri.https("creativeparkingsolutions.com", "admin/chart_hour_app/${newValue.toString()}"));
                                            
                                            var jsonData = jsonDecode(res.body);

                                            

                                            final List<ChartData2> chartData2 = [];

                                            print(res.statusCode);
                                            
                                            for(var jsonArray in jsonData['values']){
                                              var day = jsonArray['time'];
                                              double value = double.parse(jsonArray['value']);
                                              ChartData2 values = ChartData2(day, value);
                                              chartData2.add(values);
                                            }
                                            setState(() {
                                              chartLoading2 = false;
                                              _chartData2 = chartData2;
                                            });
                                            
                                          },
                                          underline: Container(),
                                          isExpanded: true,
                                        ),
                                    ),
                                  ),
                                ),
                                
                                Expanded(
                                  child: 
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SfCartesianChart(
                                        // title: ChartTitle(text: "Last Month"),
                                        tooltipBehavior: _tooltipBehavior2,
                                        series: [
                                          SplineSeries<ChartData2, String>(
                                            name: 'Earn',
                                            dataSource: _chartData2,
                                            xValueMapper: (ChartData2 values, _) => values.time,
                                            yValueMapper: (ChartData2 values, _) => values.values,
                                            markerSettings: MarkerSettings(
                                              isVisible: true,
                                              color: Colors.blue.shade200
                                            ),
                                            // dataLabelSettings: DataLabelSettings(
                                            //   isVisible: true,
                                            // ),
                                            enableTooltip: true
                                          )
                                        ],
                                        primaryXAxis: CategoryAxis(
                                          edgeLabelPlacement: EdgeLabelPlacement.shift,
                                          majorGridLines: MajorGridLines(width: 0),
                                          labelRotation: 90
                                        ),
                                        primaryYAxis: NumericAxis(
                                          edgeLabelPlacement: EdgeLabelPlacement.shift,
                                          majorGridLines: MajorGridLines(width: 0),
                                          numberFormat: NumberFormat.simpleCurrency(),
                                          
                                        ),
                                      ),
                                      chartLoading2 ?
                                      SizedBox(
                                        height: 30,
                                        width: 30,
                                        child: CircularProgressIndicator(color: Colors.blue, strokeWidth: 3.0,),
                                      ) : Text(""),
                                    ],
                                  )
                                )
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

// class Choice{
//   Choice({this.title, this.icon});
//   final String? title;
//   final IconData? icon;

// }

class ChartData{

  final String day;
  final double values;

  ChartData(this.day, this.values);
}

class ChartData2{

  final String time;
  final double values;

  ChartData2(this.time, this.values);
}

class ClientList {
  int? id;
  String? ClientID;
  String? FullName;
  // String? Garage_Name;
  String? Address;
  String? State;
  
  ClientList({this.id, this.ClientID, this.FullName, this.Address, this.State});
 
  factory ClientList.fromJson(Map<String, dynamic> json) {
    
    return ClientList(
        id: int.parse(json['ID']),
        ClientID: json['ClientID'] as String,
        FullName: json['Client_First_Name'] +" "+ json['Client_Last_Name'] as String,
        Address: json['Address'] as String,
        // Garage_Name: json['Garage_Name'] as String,
        State: json['State'] as String,
    );
  }
}

class UserList {
  int? id;
  String? name;
  String? email;
  String? roll;

 
  UserList({this.id, this.name, this.email, this.roll});
 
  factory UserList.fromJson(Map<String, dynamic> json) {
    
    return UserList(
        id: int.parse(json['user_id']),
        name: json['first_name'] +" "+ json['last_name'] as String,
        email: json['email'] as String,
        roll: json['user_type'] as String
    );
  }
}