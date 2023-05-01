import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cps/pages/garage/notifications.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

import 'package:cps/common/theme_helper.dart';
import 'package:cps/pages/garage/sidebar_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:cps/pages/widgets/header_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;


class NewCitiationGarage extends StatefulWidget {
  const NewCitiationGarage({super.key});

  @override
  State<NewCitiationGarage> createState() => _NewCitiationGarageState();
}

class _NewCitiationGarageState extends State<NewCitiationGarage> {
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

  final _formKey = GlobalKey<FormState>();

  List _stateList = [];

  Future<dynamic> getState() async {
    String data =
        await DefaultAssetBundle.of(context).loadString("assets/json/state.json");

    var jsonData = jsonDecode(data);

    List stateList = [];
    for(var jsonList in jsonData){
      stateList.add(jsonList['name']);
    }
    // print(jsonData);
    return stateList;
  }

  List _stateCityList = [];

  DateTime currentIssueDate = DateTime.now().toUtc().subtract(Duration(hours: 8));

  TextEditingController license_plate = TextEditingController();
  TextEditingController make = TextEditingController();
  TextEditingController model = TextEditingController();
  TextEditingController color = TextEditingController();
  TextEditingController zone = TextEditingController();
  TextEditingController violation = TextEditingController();
  TextEditingController fine = TextEditingController();
  TextEditingController issue_date = TextEditingController();
  TextEditingController upload_license = TextEditingController();

  Future<void> _selectIssueDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: currentIssueDate,
        firstDate: DateTime(2015),
        lastDate: DateTime(2050));
    if (pickedDate != null && pickedDate != currentIssueDate)
      setState(() {
        currentIssueDate = pickedDate;
        issue_date.text = DateFormat("dd/MM/yyyy").format(pickedDate);
      });
  }

  FilePickerResult? result;
  String? _fileName;
  PlatformFile? pickedfile;
  File? filePath;
  String? fileData;

  void pickFile() async{
    try {
      result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false
      );

      if(result != null){
        setState(() {
          _fileName = result!.files.first.name;
          pickedfile = result!.files.first;
          filePath = File(pickedfile!.path.toString());
          fileData = base64Encode(filePath!.readAsBytesSync());
          upload_license.text = result!.files.first.name;
        });
        
        // print("File name : $_fileName");
        // print("File path : $filePath");

      }
    } catch (e) {
      
    }
  }
  
  Future<void> add_permit()async{
    
    var client = http.Client();
    try {
      _timer?.cancel();
        
      EasyLoading.instance
        ..loadingStyle = EasyLoadingStyle.light;

      await EasyLoading.show(
        maskType: EasyLoadingMaskType.black,
        indicator: Lottie.asset("assets/animations/loading.json", width: 125, height: 75)
      );

      var res = await client.post(Uri.https('creativeparkingsolutions.com', 'public/add_citiation_app.php'), body: {
          'license_plate' : license_plate.text,
          'make' : make.text,
          'model' : model.text,
          'color' : color.text,
          'zone' : zone.text,
          'violation' : violation.text,
          'fine' : fine.text,
          'issue_date' : issue_date.text,
          'file_name' : _fileName,
          'file_data' : fileData,
      });


      print(res.statusCode);
      // print(_fileName);
      var jsonData = jsonDecode(res.body);
      print(jsonData);

      if(res.statusCode == 200){
        if(jsonData['status'] == true){

          setState(() {
            license_plate.text = '';
            make.text = '';
            model.text = '';
            color.text = '';
            zone.text = '';
            violation.text = '';
            fine.text = '';
            issue_date.text = '';
            upload_license.text = '';
          });

          EasyLoading.instance
            ..loadingStyle = EasyLoadingStyle.custom
            ..backgroundColor = Colors.green.shade200
            ..indicatorColor = Colors.green.shade900
            ..textColor = Colors.green.shade900;
          EasyLoading.showSuccess('New citation added successfully');
          EasyLoading.dismiss();
        }else{
          EasyLoading.instance
            ..loadingStyle = EasyLoadingStyle.custom
            ..backgroundColor = Colors.red.shade200
            ..indicatorColor = Colors.red.shade900
            ..textColor = Colors.red.shade900;
          EasyLoading.showError('Add Failed!');
          EasyLoading.dismiss();
        }
      }

    } catch (e) {
      EasyLoading.instance
        ..loadingStyle = EasyLoadingStyle.custom
        ..backgroundColor = Colors.red.shade200
        ..indicatorColor = Colors.red.shade900
        ..textColor = Colors.red.shade900;
      EasyLoading.showError('Add Failed!');
      EasyLoading.dismiss();
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
    });
    
    getState().then((value){
      setState(() {
        _stateList = value;
      });
    });

    issue_date.text = '';

    getCountNotification();

  }
  

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool showFab = MediaQuery.of(context).viewInsets.bottom != 0;
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("New Citiation",
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
      floatingActionButton: Visibility(
        visible: !showFab,
        child: Container(
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
            Expanded(
              child: 
              CustomScrollView(
                slivers: [
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Container(
                          padding: EdgeInsets.all(10),
                          child: 
                          Column(
                            children: [
                              Text("Add Citation", style: TextStyle(fontSize: 20, color: Colors.black54, fontWeight: FontWeight.bold),),
                              SizedBox(height: 5,),
                              Form(
                                key: _formKey,
                                child: 
                                Column(
                                  children: [
                                    Container(
                                      child: TextFormField(
                                        controller: license_plate,
                                        decoration: ThemeHelper().textInputDecoration('License Plate #', 'Enter your License Plate Number'),
                                        validator: (val) {
                                          if(val!.trim().isEmpty){
                                            return "License is required";
                                          }
                                          else{
                                            return null;
                                          }
                                          
                                        },
                                      ),
                                      decoration: ThemeHelper().inputBoxDecorationShaddow(),
                                    ),
                                    SizedBox(height: 10,),
                                    Container(
                                      child: TextFormField(
                                        controller: make,
                                        decoration: ThemeHelper().textInputDecoration('Make', 'Enter make'),
                                        validator: (val) {
                                          if(val!.trim().isEmpty){
                                            return "Make is required";
                                          }
                                          else{
                                            return null;
                                          }
                                          
                                        },
                                      ),
                                      decoration: ThemeHelper().inputBoxDecorationShaddow(),
                                    ),
                                    SizedBox(height: 10,),
                                    Container(
                                      child: TextFormField(
                                        controller: model,
                                        decoration: ThemeHelper().textInputDecoration('Model', 'Enter model number'),
                                        validator: (val) {
                                          if(val!.trim().isEmpty){
                                            return "Model is required";
                                          }
                                          else{
                                            return null;
                                          }
                                          
                                        },
                                      ),
                                      decoration: ThemeHelper().inputBoxDecorationShaddow(),
                                    ),
                                    SizedBox(height: 10,),
                                    Container(
                                      child: TextFormField(
                                        controller: color,
                                        decoration: ThemeHelper().textInputDecoration('Color', 'Enter color'),
                                        validator: (val) {
                                          if(val!.trim().isEmpty){
                                            return "Color is required";
                                          }
                                          else{
                                            return null;
                                          }
                                          
                                        },
                                      ),
                                      decoration: ThemeHelper().inputBoxDecorationShaddow(),
                                    ),
                                    SizedBox(height: 10,),
                                    Container(
                                      child: TextFormField(
                                        controller: zone,
                                        decoration: ThemeHelper().textInputDecoration('Zone', 'Enter your zone'),
                                        validator: (val) {
                                          if(val!.trim().isEmpty){
                                            return "Zone is required";
                                          }
                                          else{
                                            return null;
                                          }
                                          
                                        },
                                      ),
                                      decoration: ThemeHelper().inputBoxDecorationShaddow(),
                                    ),
                                    SizedBox(height: 10,),
                                    Container(
                                      child: TextFormField(
                                        controller: violation,
                                        decoration: ThemeHelper().textInputDecoration('Violation Description', 'Enter violation here'),
                                        validator: (val) {
                                          if(val!.trim().isEmpty){
                                            return "Violation is required";
                                          }
                                          else{
                                            return null;
                                          }
                                          
                                        },
                                      ),
                                      decoration: ThemeHelper().inputBoxDecorationShaddow(),
                                    ),
                                    SizedBox(height: 10,),
                                    Container(
                                      child: TextFormField(
                                        controller: fine,
                                        decoration: ThemeHelper().textInputDecoration('Fine', '\$20.00'),
                                        validator: (val) {
                                          if(val!.trim().isEmpty){
                                            return "Fine is required";
                                          }
                                          else{
                                            return null;
                                          }
                                          
                                        },
                                      ),
                                      decoration: ThemeHelper().inputBoxDecorationShaddow(),
                                    ),
                                    SizedBox(height: 10,),
                                    Container(
                                      child: TextFormField(
                                        controller: issue_date,
                                        readOnly: true,
                                        onTap: () {
                                          _selectIssueDate(context);
                                        },
                                        decoration: InputDecoration(
                                          labelText: "Issue Date",
                                          hintText: "Select Issue Date",
                                          fillColor: Colors.white,
                                          filled: true,
                                          contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.grey)),
                                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.grey.shade400)),
                                          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.red, width: 2.0)),
                                          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.red, width: 2.0)),
                                          suffixIcon: IconButton(
                                            icon: Icon(Icons.calendar_month),
                                            onPressed: (){
                                              _selectIssueDate(context);
                                            },
                                          ),
                                          
                                        )
                                      ),
                                      decoration: ThemeHelper().inputBoxDecorationShaddow(),
                                    ),
                                    SizedBox(height: 10,),
                                    Container(
                                      child: TextFormField(
                                        controller: upload_license,
                                        readOnly: true,
                                        onTap: () {
                                          pickFile();
                                        },
                                        decoration: InputDecoration(
                                          labelText: "Attach File",
                                          hintText: "Select file",
                                          fillColor: Colors.white,
                                          filled: true,
                                          contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.grey)),
                                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.grey.shade400)),
                                          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.red, width: 2.0)),
                                          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.red, width: 2.0)),
                                          suffixIcon: IconButton(
                                            icon: Icon(Icons.file_upload),
                                            onPressed: (){
                                              pickFile();
                                            },
                                          ),
                                          
                                        )
                                      ),
                                      decoration: ThemeHelper().inputBoxDecorationShaddow(),
                                    ),
                                    SizedBox(height: 15.0),
                                    Container(
                                      decoration: ThemeHelper().buttonBoxDecoration(context),
                                      child: ElevatedButton(
                                        style: ThemeHelper().buttonStyle(),
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
                                          child: Text(
                                            "Submit".toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        onPressed: () {
                                          
                                          // if (_formKey.currentState!.validate()) {
                                            
                                          // }
                                          add_permit();

                                        },
                                      ),
                                    ),
                                    SizedBox(height: 30.0),
                                  ],
                                )
                              )
                            ],

                          ),
                        )
                      ]
                    )
                  )
                ],
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