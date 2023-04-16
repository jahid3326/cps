import 'package:cps/common/theme_helper.dart';
import 'package:cps/pages/motorist/add_new_permit.dart';
import 'package:cps/pages/widgets/header_widget.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:cps/pages/motorist/sidebar_nav.dart';


class PermitMotorist extends StatefulWidget {
  const PermitMotorist({super.key});

  @override
  State<PermitMotorist> createState() => _PermitMotoristState();
}

class _PermitMotoristState extends State<PermitMotorist> {

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

      var res = await client.get(Uri.https('creativeparkingsolutions.com', 'get_permit_app'));
        
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
    
    generateTableList().then((value) {
      setState(() {
        _dataLlist = value;
        _filterData = value;
      });
      // print(_filterData);
      // print("Length : ${_filterData.length}");
    });
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Permit",
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
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.fromLTRB(10, 5, 10, 0),
            child: 
            Row(
              children: [
                Expanded(
                  child: Container(
                    child: TextFormField(
                      decoration: ThemeHelper().textInputDecoration('Search by any keywords', 'Enter any keywords'),
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) {
                        setState(() {
                            _filterData = _dataLlist.where((element) => 
                              (element.fullName!.toLowerCase().contains(value.toLowerCase()) ||
                              element.Address!.toLowerCase().contains(value.toLowerCase()) ||
                              element.status!.toLowerCase().contains(value.toLowerCase()) ||
                              element.type!.toLowerCase().contains(value.toLowerCase()) ||
                              element.duration!.toLowerCase().contains(value.toLowerCase()) ||
                              element.section!.toLowerCase().contains(value.toLowerCase()) ||
                              element.license_plate_number!.toLowerCase().contains(value.toLowerCase())
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
                    //   MaterialPageRoute(builder: (context)=>NewPermitMotorist())
                    // );
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context)=>NewPermitMotorist())
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
            )
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
                              label: Center(child: Text('Name')),
                            ),
                            DataColumn(
                              label: Center(child: Text('Location')),
                            ),
                            DataColumn(
                              label: Center(child: Text('Status')),
                            ),
                            DataColumn(
                              label: Center(child: Text('Type')),
                            ),
                            DataColumn(
                              label: Center(child: Text('Duration')),
                            ),
                            DataColumn(
                              label: Center(child: Text('Section')),
                            ),
                            DataColumn(
                              label: Center(child: Text('License Plate #')),
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
                                        constraints: BoxConstraints(maxWidth: 90),
                                        child: Text(
                                          data.fullName.toString(),
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
                                        child:
                                        data.status.toString() == 'Active' ?
                                        Center(
                                          child: Text(
                                            data.status.toString(),
                                            style: TextStyle(color: Colors.green),
                                          ),
                                        ):
                                        Center(
                                          child: Text(
                                            data.status.toString(),
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      ConstrainedBox(
                                        constraints: BoxConstraints(maxWidth: 90),
                                        child: Text(
                                          data.type.toString(),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      ConstrainedBox(
                                        constraints: BoxConstraints(maxWidth: 90),
                                        child: Text(
                                          data.duration.toString(),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      ConstrainedBox(
                                        constraints: BoxConstraints(maxWidth: 90),
                                        child: Text(
                                          data.section.toString(),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      ConstrainedBox(
                                        constraints: BoxConstraints(maxWidth: 90),
                                        child: Text(
                                          data.license_plate_number.toString(),
                                        ),
                                      ),
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
      )
    );
  }
}

class TableList {
  int? id;
  String? fullName;
  String? Address;
  String? type;
  String? status;
  String? duration;
  String? section;
  String? license_plate_number;

 
  TableList({this.id, this.fullName, this.Address, this.type, this.status, this.duration, this.section, this.license_plate_number});
 
  factory TableList.fromJson(Map<String, dynamic> json) {
    DateTime register_date = DateTime.parse(json['register_date']);
    String rmonth = DateFormat("MM").format(register_date);
    String ryear = DateFormat("y").format(register_date);
    List months = ['Jan', 'Feb', 'Mar', 'Apr', 'May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    String rdate = months[int.parse(rmonth)-1]+' '+ryear;
    DateTime expiry_date = DateTime.parse(json['expiry_date']);
    String emonth = DateFormat("MM").format(expiry_date);
    String eyear = DateFormat("y").format(expiry_date);
    String edate = months[int.parse(emonth)-1]+' '+eyear;

    return TableList(
        id: int.parse(json['id']),
        fullName: json['first_name'] +" "+ json['last_name'] as String,
        Address: json['Address'] as String,
        type: json['type'] as String,
        status: json['status'] as String,
        duration: rdate + '-' + edate as String,
        section: json['section'] as String,
        license_plate_number: json['license_plate_number'] as String
    );
  }
}