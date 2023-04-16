import 'dart:async';
import 'dart:convert';

import 'package:cps/pages/garage/notifications.dart';
import 'package:cps/pages/garage/sidebar_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:cps/pages/widgets/header_widget.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';



class DashboardGarage extends StatefulWidget {
  const DashboardGarage({super.key});

  @override
  State<DashboardGarage> createState() => _DashboardGarageState();
}

class _DashboardGarageState extends State<DashboardGarage> {
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

  Future<List> getData()async{
    var client = http.Client();

    try {
      
      EasyLoading.instance
        ..loadingStyle = EasyLoadingStyle.light;

      await EasyLoading.show(
        maskType: EasyLoadingMaskType.black,
        indicator: Lottie.asset("assets/animations/loading.json", width: 125, height: 75)
      );

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

  Future<List> getData2() async{

    var client = http.Client();

    var response = await client.get(Uri.https('creativeparkingsolutions.com', 'garage/index_permit_ciation_app'));

    var jsonData = jsonDecode(response.body);
    List pcList = [jsonData['count_active_permit'], jsonData['count_pending_permit'], jsonData['count_active_citiation'] ];
    return pcList;
  }

  String from = '';
  String to = '';

  // List<ChartData> _chartData = [];

  // Future <List<ChartData>> getChartData() async {
  //   var client = http.Client();

  //   var res = await client.get(Uri.https("creativeparkingsolutions.com", "garage/chart12_month_app"));
    
  //   var jsonData = jsonDecode(res.body);

  //   final List<ChartData> chartData = [];
    
  //   for(var jsonArray in jsonData['values']){
  //     var month = jsonArray['month'];
  //     double value = double.parse(jsonArray['value']);
  //     ChartData values = ChartData(month, value);
  //     chartData.add(values);
  //   }
    
  //   return chartData;
  // }

  List<ChartData> _chartData = [];

  Future <List<ChartData>> getChartData() async {
    var client = http.Client();

    var res = await client.get(Uri.https("creativeparkingsolutions.com", "garage/chart12_month_app"));
    
    var jsonData = jsonDecode(res.body);

    final List<ChartData> chartData = [];

    setState((){
      from = jsonData['from'];
      to = jsonData['to'];
    });
    
    for(var jsonArray in jsonData['values']){
      var month = jsonArray['month'].toString();
      var stringValue = jsonArray['value'].toString();
      double value = double.parse(stringValue);
      ChartData values = ChartData(month, value);
      chartData.add(values);
    }
    
    return chartData;
  }

  late TooltipBehavior _tooltipBehavior;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getUserData().whenComplete(()async{
      setState(() {
        logged_in = logged_in;
        getProfilePictureName = profile_picture;
      });
      // print("Image Name : ${getProfilePictureName}");
      
    });

    _tooltipBehavior = TooltipBehavior(enable: true);
    
    getChartData().then((value){
      setState(() {
        _chartData = value;
      });

      // print(_chartData);
      // print("object length ${_chartData.length}");
    });

    getCountNotification();
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
                        image: "https://creativeparkingsolutions.com/public/assets/garage/images/user/${getProfilePictureName}",
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
                                                    child: Icon(Icons.mail_outline_rounded, color: Colors.white, size: 30,),
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
                                                    child: Icon(Icons.mail_outline_rounded, color: Colors.white, size: 30,),
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
                                                    child: Icon(Icons.mail_outline_rounded, color: Colors.white, size: 30,),
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
                                  child: Text("Last 12 Months", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),),
                                ),
                                Expanded(
                                  child: 
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SfCartesianChart(
                                        title: ChartTitle(text: "${from} - ${to}"),
                                        tooltipBehavior: _tooltipBehavior,
                                        series: [
                                          SplineSeries<ChartData, String>(
                                            name: 'Earn',
                                            dataSource: _chartData,
                                            xValueMapper: (ChartData values, _) => values.month,
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
                            height: 240,
                            // color: Colors.blue,
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
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(10),
                                      child: CircleAvatar(child: Icon(Icons.access_time_outlined), backgroundColor: Colors.blue.shade100, foregroundColor: Colors.blue,),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Text(
                                        "Time(s):",
                                        style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.grey.shade600),),
                                    )

                                  ],
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 20, top: 20, right: 20, bottom: 20),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          Text(
                                            "Busiest Times : ",
                                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.grey.shade600),),
                                          Spacer(),
                                          Text(
                                            "12:01 PM - 6:00 PM",
                                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.grey.shade800),),
                                        ],
                                      ),
                                      SizedBox(height: 10,),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        // mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          Text(
                                            "Idle Time : ",
                                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.grey.shade600),),
                                          Spacer(),
                                          Text(
                                            "01:01 AM - 5:00 AM",
                                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.grey.shade800),),
                                        ],
                                      ),
                                      SizedBox(height: 10,),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        // mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          Text(
                                            "Average Stay Time : ",
                                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.grey.shade600),),
                                          Spacer(),
                                          Text(
                                            "22 Minutes",
                                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.grey.shade800),),
                                        ],
                                      ),
                                      SizedBox(height: 10,),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        // mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          Text(
                                            "Time: Average Open Space Time : ",
                                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey.shade600),),
                                          Spacer(),
                                          Text(
                                            "45 Minutes",
                                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.grey.shade800),),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      ]
                    )
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Container(
                          child: FutureBuilder(
                            future: getData2(),
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
                                return Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Container(
                                    width: double.infinity,
                                    height: 200,
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
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.all(10),
                                              child: CircleAvatar(child: Icon(Icons.description_rounded), backgroundColor: Colors.blue.shade100, foregroundColor: Colors.blue,),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(10),
                                              child: Text(
                                                "Permit/Citations:",
                                                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.grey.shade600),),
                                            )

                                          ],
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(left: 20, top: 20, right: 20, bottom: 20),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                children: [
                                                  Text(
                                                    "Active Permit : ",
                                                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.grey.shade600),),
                                                  Spacer(),
                                                  Text(
                                                    "${snapshot.data![0]}",
                                                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.grey.shade800),),
                                                ],
                                              ),
                                              SizedBox(height: 10,),
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                // mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                children: [
                                                  Text(
                                                    "Pending Permit : ",
                                                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.grey.shade600),),
                                                  Spacer(),
                                                  Text(
                                                    "${snapshot.data![1]}",
                                                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.grey.shade800),),
                                                ],
                                              ),
                                              SizedBox(height: 10,),
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                // mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                children: [
                                                  Text(
                                                    "Active Citations : ",
                                                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.grey.shade600),),
                                                  Spacer(),
                                                  Text(
                                                    "${snapshot.data![2]}",
                                                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.grey.shade800),),
                                                ],
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                  
                                  //Text("${snapshot.data![0]}"),
                                );
                              }
                            }
                          )
                        )
                      ]
                    )
                  )
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

  final String month;
  final double values;

  ChartData(this.month, this.values);
}

// class ChartData{

//   final String month;
//   final double values;

//   ChartData(this.month, this.values);
// }

