import 'dart:async';
import 'dart:convert';
import 'package:cps/pages/admin/notifications.dart';
import 'package:csc_picker/dropdown_with_search.dart';
import 'package:cps/common/theme_helper.dart';
import 'package:cps/pages/admin/sidebar_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:cps/pages/widgets/header_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;


class AddNewStaffAdmin extends StatefulWidget {
  const AddNewStaffAdmin({super.key});

  @override
  State<AddNewStaffAdmin> createState() => _AddNewStaffAdminState();
}

class _AddNewStaffAdminState extends State<AddNewStaffAdmin> {
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

  TextEditingController worke_type = TextEditingController();
  TextEditingController staff_first_name = TextEditingController();
  TextEditingController staff_last_name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController address = TextEditingController();
  
  var selectedWorkType = 'Choose work type';
  List _worke_type = ['Manager', 'Lot Attendant'];

  var selectedStateValue = "Choose State";
  var selectedCityValue = "Choose City";

  List _stateList = [];

  Future<dynamic> getState() async {
    String data =
        await DefaultAssetBundle.of(context).loadString("assets/json/s.json");

    var jsonData = jsonDecode(data);

    List stateList = [];
    for(var jsonList in jsonData){
      stateList.add(jsonList['name']);
    }
    // print(jsonData);
    return stateList;
  }

  List _stateCityList = [];
  
  Future<void> add_new_staff()async{
    
    var client = http.Client();
    try {
      _timer?.cancel();
        
      EasyLoading.instance
        ..loadingStyle = EasyLoadingStyle.light;

      await EasyLoading.show(
        maskType: EasyLoadingMaskType.black,
        indicator: Lottie.asset("assets/animations/loading.json", width: 125, height: 75)
      );

      var res = await client.post(Uri.https('creativeparkingsolutions.com', 'admin/add_new_staff_app'), body: {
          'first_name' : staff_first_name.text,
          'last_name' : staff_last_name.text,
          'email' : email.text,
          'state' : selectedStateValue,
          'city' : selectedCityValue,
          'address' : address.text,
          'work_type' : selectedWorkType
      });


      print(res.statusCode);
      // print(_fileName);
      var jsonData = jsonDecode(res.body);
      print(jsonData);

      if(res.statusCode == 200){
        if(jsonData['status'] == true){

          setState(() {
            selectedWorkType = 'Choose work type';
            staff_first_name.text = '';
            staff_last_name.text = '';
            email.text = '';
            selectedStateValue = "Choose State";
            selectedCityValue = "Choose City";
            address.text = '';
          });

          EasyLoading.instance
            ..loadingStyle = EasyLoadingStyle.custom
            ..backgroundColor = Colors.green.shade200
            ..indicatorColor = Colors.green.shade900
            ..textColor = Colors.green.shade900;
          EasyLoading.showSuccess('New staff added successfully');
          EasyLoading.dismiss();
          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(builder: (context)=>AddGarageFormBGarage())
          // );
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
    getCountNotification();
  }
  

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool showFab = MediaQuery.of(context).viewInsets.bottom != 0;
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Add New Staff",
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
                              Text("Add New Staff", style: TextStyle(fontSize: 20, color: Colors.black54, fontWeight: FontWeight.bold),),
                              SizedBox(height: 5,),
                              Form(
                                key: _formKey,
                                child: 
                                Column(
                                  children: [
                                    Container(
                                      child: TextFormField(
                                        controller: staff_first_name,
                                        decoration: ThemeHelper().textInputDecoration('First name', 'Last name'),
                                        validator: (val) {
                                          if(val!.trim().isEmpty){
                                            return "First name is required";
                                          }
                                          else{
                                            return null;
                                          }
                                          
                                        },
                                      ),
                                      decoration: ThemeHelper().inputBoxDecorationShaddow(),
                                    ),SizedBox(height: 10,),
                                    Container(
                                      child: TextFormField(
                                        controller: staff_last_name,
                                        decoration: ThemeHelper().textInputDecoration('Last name', 'Last name'),
                                        validator: (val) {
                                          if(val!.trim().isEmpty){
                                            return "Last name is required";
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
                                        controller: email,
                                        decoration: ThemeHelper().textInputDecoration('Email', 'Email'),
                                        validator: (val) {
                                          if(val!.trim().isEmpty){
                                            return "Email is required";
                                          }
                                          else{
                                            return null;
                                          }
                                          
                                        },
                                      ),
                                      decoration: ThemeHelper().inputBoxDecorationShaddow(),
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
                                          title: 'State',
                                          placeHolder: 'Search State',
                                          items: _stateList,
                                          selected: selectedStateValue,
                                          onChanged: (value) async{
                                            
                                            String data = await DefaultAssetBundle.of(context).loadString("assets/json/s.json");

                                            var jsonData = jsonDecode(data);

                                            setState(() {
                                              selectedStateValue = value;
                                            });
                                            
                                            _stateCityList = [];
                                            for(var jsonList in jsonData){
                                              if(jsonList['name'] == value){
                                                for(var cityList in jsonList['cities']){
                                                  _stateCityList.add(cityList['name']);
                                                }
                                              }
                                            }
                                          },
                                          label: 'State',
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
                                          title: 'City',
                                          placeHolder: 'Search City',
                                          items: _stateCityList,
                                          selected: selectedCityValue,
                                          onChanged: (value) {

                                            setState(() {
                                              selectedCityValue = value;
                                            });

                                            //print(jsonData[value]);


                                          },
                                          label: 'City',
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
                                        controller: address,
                                        decoration: ThemeHelper().textInputDecoration('Address', 'Address'),
                                        validator: (val) {
                                          if(val!.trim().isEmpty){
                                            return "Address is required";
                                          }
                                          else{
                                            return null;
                                          }
                                          
                                        },
                                      ),
                                      decoration: ThemeHelper().inputBoxDecorationShaddow(),
                                    ),
                                    SizedBox(height: 15.0),
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
                                          title: 'Work Type',
                                          placeHolder: 'Search Work Type',
                                          items: _worke_type,
                                          selected: selectedWorkType,
                                          onChanged: (value) {

                                            setState(() {
                                              selectedWorkType = value;
                                            });

                                          },
                                          label: 'Work Type',
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(Radius.circular(100)),
                                            color: Colors.transparent,
                                            border: Border.all(color: Colors.transparent),
                                          ),
                                          
                                        ),
                                      )
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
                                          add_new_staff();

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
