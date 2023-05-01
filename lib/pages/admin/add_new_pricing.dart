import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cps/pages/admin/notifications.dart';
import 'package:csc_picker/dropdown_with_search.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

import 'package:cps/common/theme_helper.dart';
import 'package:cps/pages/admin/sidebar_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:cps/pages/widgets/header_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;


class NewPricingAdmin extends StatefulWidget {
  const NewPricingAdmin({super.key});

  @override
  State<NewPricingAdmin> createState() => _NewPricingAdminState();
}

class _NewPricingAdminState extends State<NewPricingAdmin> {
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

  DateTime currentStartDate = DateTime.now().toUtc().subtract(Duration(hours: 8));
  DateTime currentEndDate = DateTime.now().toUtc().subtract(Duration(hours: 8));

  TextEditingController price = TextEditingController();
  TextEditingController start_date = TextEditingController();
  TextEditingController end_date = TextEditingController();
  TextEditingController _time = TextEditingController();
  TextEditingController upload_license = TextEditingController();

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: currentStartDate,
        firstDate: DateTime(2015),
        lastDate: DateTime(2050));
    if (pickedDate != null && pickedDate != currentStartDate)
      setState(() {
        currentStartDate = pickedDate;
        start_date.text = DateFormat("dd/MM/yyyy").format(pickedDate);
      });
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: currentEndDate,
        firstDate: DateTime(2015),
        lastDate: DateTime(2050));
    if (pickedDate != null && pickedDate != currentEndDate)
      setState(() {
        currentEndDate = pickedDate;
        end_date.text = DateFormat("dd/MM/yyyy").format(pickedDate);
      });
  }
  

  // TimeOfDay timeOfDay = TimeOfDay(hour: hour, minute: minute);

  
  TimeOfDay timeOfDay = TimeOfDay.now();

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? result = await showTimePicker(
      context: context,
      initialTime: timeOfDay
    );
    if(result != null && result != timeOfDay){
      setState(() {
        timeOfDay = result;
        final hours = result.hour.toString().padLeft(2,'0');
        final minutes = result.minute.toString().padLeft(2,'0');
        _time.text = "${hours}:${minutes}";
      });
    }else{
      final hours = timeOfDay.hour.toString().padLeft(2,'0');
      final minutes = timeOfDay.minute.toString().padLeft(2,'0');
      _time.text = "${hours}:${minutes}";
    }
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

  //////// Garage Dropdown List ////////////
  var selectedGarageValue = 'Choose Garage';
  
  List _garage_list = [''];

  Future<dynamic> garageList() async {
    var client = http.Client();
    try {
      
      var res = await client.get(Uri.https('creativeparkingsolutions.com', 'admin/get_dropdown_garage_app'));
        
      var list = jsonDecode(res.body);
      // print(list);
      
      List garage_list = [];

      for(var jsonData in list){
        garage_list.add(jsonData['G_id']);
      }

      return garage_list;
      
    } catch (e) {
      
    }
  }
  /////// End Garage Dropdown List /////////
  var selectedDayValue = 'Choose Day';
  List _day_list = ['Saturday', 'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
  
  Future<void> add_price()async{
    
    var client = http.Client();
    try {
      _timer?.cancel();
        
      EasyLoading.instance
        ..loadingStyle = EasyLoadingStyle.light;

      await EasyLoading.show(
        maskType: EasyLoadingMaskType.black,
        indicator: Lottie.asset("assets/animations/loading.json", width: 125, height: 75)
      );

      var res = await client.post(Uri.https('creativeparkingsolutions.com', 'public/add_price_app.php'), body: {
          'garage_id' : selectedGarageValue,
          'day' : selectedDayValue,
          'price' : price.text,
          'time' : _time.text,
          'start_date' : start_date.text,
          'end_date' : end_date.text
      });


      print(res.statusCode);
      // print(_fileName);
      var jsonData = jsonDecode(res.body);
      print(jsonData);

      if(res.statusCode == 200){
        if(jsonData['status'] == true){

          setState(() {
            selectedGarageValue = 'Choose Garage';
            selectedDayValue = 'Choose Day';
            price.text = '';
            _time.text = '';
            start_date.text = '';
            end_date.text = '';
          });

          EasyLoading.instance
            ..loadingStyle = EasyLoadingStyle.custom
            ..backgroundColor = Colors.green.shade200
            ..indicatorColor = Colors.green.shade900
            ..textColor = Colors.green.shade900;
          EasyLoading.showSuccess('New pricing added successfully!');
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

    start_date.text = '';

    garageList().then((value) {
      setState(() {
        _garage_list = value;
      });
    });
    getCountNotification();
  }
  

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool showFab = MediaQuery.of(context).viewInsets.bottom != 0;
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("New Pricing/Rates",
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
                              Text("Add Garage Pricing", style: TextStyle(fontSize: 20, color: Colors.black54, fontWeight: FontWeight.bold),),
                              SizedBox(height: 5,),
                              Form(
                                key: _formKey,
                                child: 
                                Column(
                                  children: [
                                    DecoratedBox(
                                      decoration: BoxDecoration( 
                                        color:Colors.white, //background color of dropdown button
                                        border: Border.all(color: Colors.black26, width:1), //border of dropdown button
                                        borderRadius: BorderRadius.circular(100), //border raiuds of dropdown button
                                        boxShadow: <BoxShadow>[ //apply shadow on Dropdown button
                                                BoxShadow(
                                                    color: Color.fromRGBO(0, 0, 0, 0.1), //shadow for button
                                                    blurRadius: 5) //blur radius of shadow
                                              ]
                                      ),
                                      
                                      child:Padding(
                                        padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                                        child:
                                        DropdownWithSearch(
                                          title: 'Garage',
                                          placeHolder: 'Search Garage',
                                          items: _garage_list,
                                          selected: selectedGarageValue,
                                          onChanged: (value) {

                                            setState(() {
                                              selectedGarageValue = value;
                                            });

                                          },
                                          label: 'Garage',
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(Radius.circular(100)),
                                            color: Colors.transparent,
                                            border: Border.all(color: Colors.transparent),
                                          ),
                                          
                                        ),
                                      )
                                    ),
                                    SizedBox(height: 10,),
                                    DecoratedBox(
                                      decoration: BoxDecoration( 
                                        color:Colors.white, //background color of dropdown button
                                        border: Border.all(color: Colors.black26, width:1), //border of dropdown button
                                        borderRadius: BorderRadius.circular(100), //border raiuds of dropdown button
                                        boxShadow: <BoxShadow>[ //apply shadow on Dropdown button
                                                BoxShadow(
                                                    color: Color.fromRGBO(0, 0, 0, 0.1), //shadow for button
                                                    blurRadius: 5) //blur radius of shadow
                                              ]
                                      ),
                                      
                                      child:Padding(
                                        padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                                        child:
                                        DropdownWithSearch(
                                          title: 'Day',
                                          placeHolder: 'Search Day',
                                          items: _day_list,
                                          selected: selectedDayValue,
                                          onChanged: (value) {

                                            setState(() {
                                              selectedDayValue = value;
                                            });

                                          },
                                          label: 'Day',
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(Radius.circular(100)),
                                            color: Colors.transparent,
                                            border: Border.all(color: Colors.transparent),
                                          ),
                                          
                                        ),
                                      )
                                    ),
                                    SizedBox(height: 10,),
                                    Container(
                                      child: TextFormField(
                                        controller: price,
                                        decoration: ThemeHelper().textInputDecoration('Price', 'Enter price here'),
                                        validator: (val) {
                                          if(val!.trim().isEmpty){
                                            return "Price is required";
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
                                        controller: _time,
                                        readOnly: true,
                                        onTap: () {
                                          _selectTime(context);
                                        },
                                        decoration: InputDecoration(
                                          labelText: "Time",
                                          hintText: "Select time",
                                          fillColor: Colors.white,
                                          filled: true,
                                          contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.grey)),
                                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.grey.shade400)),
                                          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.red, width: 2.0)),
                                          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.red, width: 2.0)),
                                          suffixIcon: IconButton(
                                            icon: Icon(Icons.alarm),
                                            onPressed: (){
                                              _selectTime(context);
                                            },
                                          ),
                                          
                                        )
                                      ),
                                      decoration: ThemeHelper().inputBoxDecorationShaddow(),
                                    ),
                                    SizedBox(height: 10,),
                                    Container(
                                      child: TextFormField(
                                        controller: start_date,
                                        readOnly: true,
                                        onTap: () {
                                          _selectStartDate(context);
                                        },
                                        decoration: InputDecoration(
                                          labelText: "Start Date",
                                          hintText: "Select Start Date",
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
                                              _selectStartDate(context);
                                            },
                                          ),
                                          
                                        )
                                      ),
                                      decoration: ThemeHelper().inputBoxDecorationShaddow(),
                                    ),
                                    SizedBox(height: 10,),
                                    Container(
                                      child: TextFormField(
                                        controller: end_date,
                                        readOnly: true,
                                        onTap: () {
                                          _selectEndDate(context);
                                        },
                                        decoration: InputDecoration(
                                          labelText: "End Date",
                                          hintText: "Select End Date",
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
                                              _selectEndDate(context);
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
                                          add_price();

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
