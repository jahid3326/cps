import 'dart:async';
import 'dart:convert';
import 'package:cps/pages/garage/add_new_pricing.dart';
import 'package:cps/pages/garage/notifications.dart';
import 'package:intl/intl.dart';

import 'package:cps/common/theme_helper.dart';
import 'package:cps/pages/garage/sidebar_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:cps/pages/widgets/header_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;



class PricingRatesGarage extends StatefulWidget {
  const PricingRatesGarage({super.key});

  @override
  State<PricingRatesGarage> createState() => _PricingRatesGarageState();
}

class _PricingRatesGarageState extends State<PricingRatesGarage> {
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

  List<TableList> _dataLlist = [];
  List<TableList> _filterData = [];


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

      var res = await client.get(Uri.https('creativeparkingsolutions.com', 'garage/garage_pricing_app'));
        
      var list = jsonDecode(res.body);
      // print(list);
      // print(res.statusCode);
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
        _dataLlist = value;
        _filterData = value;
      });
      print(_filterData);
      print("Length : ${_filterData.length}");
    });

    getCountNotification();
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Garage Pricing",
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
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.fromLTRB(10, 125, 10, 0),
                  child: 
                  Row(
                    children: [
                      Expanded(
                        child: 
                        Container( 
                          child: TextFormField(
                            decoration: ThemeHelper().textInputDecoration('Search by any keywords', 'Enter any keywords'),
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (value) {
                              setState(() {
                                  _filterData = _dataLlist.where((element) => 
                                    (element.garage_id!.toLowerCase().contains(value.toLowerCase()) ||
                                    element.start_data!.toLowerCase().contains(value.toLowerCase()) ||
                                    element.end_date!.toLowerCase().contains(value.toLowerCase()) ||
                                    element.day!.toLowerCase().contains(value.toLowerCase()) ||
                                    element.price!.toLowerCase().contains(value.toLowerCase()) ||
                                    element.time!.toLowerCase().contains(value.toLowerCase())
                                    )
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
                          // Navigator.pushReplacement(
                          //   context,
                          //   MaterialPageRoute(builder: (context)=>NewPricingGarage())
                          // );
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context)=>NewPricingGarage())
                          );
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
                  ),
                )
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
                                label: Center(child: Text('Garage Id', style: TextStyle(color: Colors.white),)),
                              ),
                              DataColumn(
                                label: Center(child: Text('Start Date', style: TextStyle(color: Colors.white),)),
                              ),
                              DataColumn(
                                label: Center(child: Text('End Date', style: TextStyle(color: Colors.white),)),
                              ),
                              DataColumn(
                                label: Center(child: Text('Day', style: TextStyle(color: Colors.white),)),
                              ),
                              DataColumn(
                                label: Center(child: Text('Price', style: TextStyle(color: Colors.white),)),
                              ),
                              DataColumn(
                                label: Center(child: Text('Time', style: TextStyle(color: Colors.white),)),
                              ),
                              DataColumn(
                                label: Center(child: Text('Action', style: TextStyle(color: Colors.white),)),
                              ),
                            ],
                            rows: _filterData
                                .map(
                                  (data) => 
                                  DataRow(
                                    color: _filterData.indexOf(data) % 2 == 0 ? MaterialStateColor.resolveWith((states) => Colors.grey.shade200):MaterialStateColor.resolveWith((states) => Colors.white),
                                    cells: [
                                      DataCell(
                                        ConstrainedBox(
                                          constraints: BoxConstraints(maxWidth: 40),
                                          child: Text(
                                            data.garage_id.toString(),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        ConstrainedBox(
                                          constraints: BoxConstraints(maxWidth: 80),
                                          child: Text(
                                            data.start_data.toString(),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        ConstrainedBox(
                                          constraints: BoxConstraints(maxWidth: 80),
                                          child: Text(
                                            data.end_date.toString(),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        ConstrainedBox(
                                          constraints: BoxConstraints(maxWidth: 70),
                                          child: Text(
                                            data.day.toString(),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        ConstrainedBox(
                                          constraints: BoxConstraints(maxWidth: 90),
                                          child: Text(
                                            data.price.toString(),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        ConstrainedBox(
                                          constraints: BoxConstraints(maxWidth: 60),
                                          child: Text(
                                            data.time.toString(),
                                          ),
                                        ),
                                      ),
                                      DataCell(
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
                                                        
                                                        var res = await client.get(Uri.https('creativeparkingsolutions.com', 'garage/delete_garage_pricing_app/${data.id.toString()}'));
                      
                                                        var jsonData= jsonDecode(res.body);
                                                        var list = jsonData['garage_pricing_data'];

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
                                                              _dataLlist = _tableLists;
                                                              _filterData = _tableLists;
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
                                        )
                                      ),
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
  String? garage_id;
  String? start_data;
  String? end_date;
  String? day;
  String? price;
  String? time;

 
  TableList({this.id, this.garage_id, this.start_data, this.end_date, this.day, this.price, this.time});
 
  factory TableList.fromJson(Map<String, dynamic> json) {
    DateTime startDate = DateTime.parse(json['Start_date']);
    String sdate = DateFormat("dd/MM/yyyy").format(startDate);
    DateTime endDate = DateTime.parse(json['End_date']);
    String edate = DateFormat("dd/MM/yyyy").format(endDate);
    double price = double.parse(json['Price']);
    String price2 = price.toStringAsFixed(2);
    String D = '0000-00-00 '+json['Time'];
    DateTime time2 = DateTime.parse(D);
    String time3 = DateFormat('hh:mm a').format(time2);

    return TableList(
        id: int.parse(json['Id']),
        garage_id: json['Garagid'] as String,
        start_data: sdate,
        end_date: edate,
        day: json['Day'] as String,
        price: "\$${price2}",
        time: time3
    );
  }
}