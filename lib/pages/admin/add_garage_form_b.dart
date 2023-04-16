import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cps/pages/admin/notifications.dart';
import 'package:csc_picker/dropdown_with_search.dart';
import 'package:file_picker/file_picker.dart';

import 'package:cps/common/theme_helper.dart';
import 'package:cps/pages/admin/sidebar_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:cps/pages/widgets/header_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:search_map_location/utils/google_search/latlng.dart';
import 'package:search_map_location/utils/google_search/place.dart';
import 'package:search_map_location/search_map_location.dart';


class AddGarageFormBAdmin extends StatefulWidget {
  const AddGarageFormBAdmin({super.key});

  @override
  State<AddGarageFormBAdmin> createState() => _AddGarageFormBAdminState();
}

class _AddGarageFormBAdminState extends State<AddGarageFormBAdmin> {
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

  TextEditingController garage_id = TextEditingController();
  TextEditingController garage_name = TextEditingController();
  TextEditingController high_clearance = TextEditingController();
  TextEditingController floor_height = TextEditingController();
  TextEditingController length_of_parking_space = TextEditingController();
  TextEditingController width_of_parking_space = TextEditingController();
  TextEditingController comments = TextEditingController();
  TextEditingController upload_file = TextEditingController();
  
  

  double? lat;
  double? lng;
  String? location;

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

  var selectedClientValue = 'Choose Client';
  var selectedTotalNoOfFloorsValue = 'Choose total number of floors';
  var selectedSpacePerFloorValue = 'Choose space per floor';
  var selectedNoOfSpaceValue = 'Choose total number of space';
  var selectedNoOfRowsValue = 'Choose no of rows';
  var selectedNoOfColumnsValue = 'Choose no of columns';
  var selectedGarageLayoutValue = 'Choose garage layout';

  List _totalNoOfFloors = ['One', 'Two', 'Three', 'Four'];
  List _spacePerFloors = ['One', 'Two', 'Three', 'Four'];
  List _totalNoOfspace = ['One', 'Two', 'Three', 'Four'];
  List _noOfRows = ['One', 'Two', 'Three', 'Four'];
  List _noOfColumns = ['One', 'Two', 'Three', 'Four'];
  List _garageLayout = ['One', 'Two', 'Three', 'Four'];

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
          upload_file.text = result!.files.first.name;
        });
        
        // print("File name : $_fileName");
        // print("File path : $filePath");

      }
    } catch (e) {
      
    }
  }

  //////// Client Dropdown List ////////////
  
  
  List _client_list = [''];

  Future<dynamic> clientList() async {
    var client = http.Client();
    try {
      
      var res = await client.get(Uri.https('creativeparkingsolutions.com', 'garage/get_client_list_app'));
        
      var list = jsonDecode(res.body);
      // print(list);
      
      List client_list = [];

      for(var jsonData in list){
        client_list.add(jsonData['ClientID']);
      }

      return client_list;
      
    } catch (e) {
      
    }
  }
  /////// End Client Dropdown List /////////
  
  Future<void> add_garage_form_a()async{
    
    var client = http.Client();
    try {
      _timer?.cancel();
        
      EasyLoading.instance
        ..loadingStyle = EasyLoadingStyle.light;

      await EasyLoading.show(
        maskType: EasyLoadingMaskType.black,
        indicator: Lottie.asset("assets/animations/loading.json", width: 125, height: 75)
      );

      var res = await client.post(Uri.https('creativeparkingsolutions.com', 'public/add_garage_form_b_app.php'), body: {
        'client_id' : selectedClientValue,
        'garage_name' : garage_name.text,
        'high_clearance' : high_clearance.text,
        'floor_height' : floor_height.text,
        'length_of_parking_space' : length_of_parking_space.text,
        'width_of_parking_space' : width_of_parking_space.text,
        'total_number_of_floor' : selectedTotalNoOfFloorsValue,
        'space_per_floor' : selectedSpacePerFloorValue,
        'total_number_of_space' : selectedNoOfSpaceValue,
        'no_of_rows' : selectedNoOfRowsValue,
        'no_of_columns' : selectedNoOfColumnsValue,
        'garage_layout' : selectedGarageLayoutValue,
        'comments' : comments.text,
        'lat' : lat.toString(),
        'lng' : lng.toString(),
        'location' : location,
        'file_name' : _fileName,
        'file_data' : fileData,
      });

      // print(fileData);
      print(res.statusCode);
      // print(_fileName);
      var jsonData = jsonDecode(res.body);
      print(jsonData);

      if(res.statusCode == 200){
        if(jsonData['status'] == true){

          setState(() {
            selectedClientValue = 'Choose Client';
            // garage_id.text = '';
            garage_name.text = '';
            high_clearance.text = '';
            floor_height.text = '';
            length_of_parking_space.text = '';
            width_of_parking_space.text = '';
            selectedTotalNoOfFloorsValue = 'Choose total number of floors';
            selectedSpacePerFloorValue = 'Choose space per floor';
            selectedNoOfSpaceValue = 'Choose total number of space';
            selectedNoOfRowsValue = 'Choose no of rows';
            selectedNoOfColumnsValue = 'Choose no of columns';
            selectedGarageLayoutValue = 'Choose garage layout';
            comments.text = '';
            upload_file.text = '';
          });

          EasyLoading.instance
            ..loadingStyle = EasyLoadingStyle.custom
            ..backgroundColor = Colors.green.shade200
            ..indicatorColor = Colors.green.shade900
            ..textColor = Colors.green.shade900;
          EasyLoading.showSuccess('Add Success!');
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

    clientList().then((value) {
      setState(() {
        _client_list = value;
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
        title: Text("Add Garage Form B",
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
                              Text("Add Garage Form B", style: TextStyle(fontSize: 20, color: Colors.black54, fontWeight: FontWeight.bold),),
                              SizedBox(height: 5,),
                              Form(
                                key: _formKey,
                                child: 
                                Column(
                                  children: [
                                    Container(
                                      decoration: ThemeHelper().inputBoxDecorationShaddow(),
                                      child: SearchLocation(
                                        apiKey: "AIzaSyAM2xps49NZeNORyj-gwhUo2k0vbMbDRaY",// YOUR GOOGLE MAPS API KEY
                                        onSelected: (Place place) async{
                                          final geolocation = await place.geolocation;
                                          
                                          
                                          final latlng = LatLng(latitude: geolocation!.coordinates.latitude, longitude: geolocation.coordinates.longitude);
                                          setState(() {
                                            lat = latlng.latitude;
                                            lng = latlng.longitude;
                                          });
                                          print(lat);
                                          print(lng);
                                          
                                          getAddressFromLatLng(context, double lat, double lng) async {
                                            String _host = 'https://maps.google.com/maps/api/geocode/json';
                                            final url = '$_host?key=AIzaSyAM2xps49NZeNORyj-gwhUo2k0vbMbDRaY&language=en&latlng=$lat,$lng';
                                            if(lat != null && lng != null){
                                              var response = await http.get(Uri.parse(url));
                                              if(response.statusCode == 200) {
                                                Map data = jsonDecode(response.body);
                                                //String _formattedAddress = data["results"][0]["formatted_address"];
                                                //print("response ==== $_formattedAddress");
                                                String address = data['results'][0]["address_components"][1]['long_name'] +', '+data['results'][0]["address_components"][4]['long_name'];
                                                setState(() {
                                                  location = address;
                                                });

                                                // print(location);
                                              } else return null;
                                            } else return null;
                                          }

                                          getAddressFromLatLng(context, lat!, lng!);
                                          
                                        },
                                      ),
                                    ),
                                    Divider(),
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
                                          title: 'Client',
                                          placeHolder: 'Search Client ID',
                                          items: _client_list,
                                          selected: selectedClientValue,
                                          onChanged: (value) {

                                            setState(() {
                                              selectedClientValue = value;
                                            });

                                          },
                                          label: 'Client',
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(Radius.circular(100)),
                                            color: Colors.transparent,
                                            border: Border.all(color: Colors.transparent),
                                          ),
                                          
                                        ),
                                      )
                                    ),
                                    // SizedBox(height: 10,),
                                    // Container(
                                    //   child: TextFormField(
                                    //     controller: garage_id,
                                    //     decoration: ThemeHelper().textInputDecoration('Garage ID', 'Garage ID'),
                                    //     validator: (val) {
                                    //       if(val!.trim().isEmpty){
                                    //         return "Garage ID is required";
                                    //       }
                                    //       else{
                                    //         return null;
                                    //       }
                                          
                                    //     },
                                    //   ),
                                    //   decoration: ThemeHelper().inputBoxDecorationShaddow(),
                                    // ),
                                    SizedBox(height: 10,),
                                    Container(
                                      child: TextFormField(
                                        controller: garage_name,
                                        decoration: ThemeHelper().textInputDecoration('Garage Name', 'Garage Name'),
                                        validator: (val) {
                                          if(val!.trim().isEmpty){
                                            return "Garage Name is required";
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
                                        controller: high_clearance,
                                        decoration: ThemeHelper().textInputDecoration('High Clearance', 'High Clearance'),
                                        validator: (val) {
                                          if(val!.trim().isEmpty){
                                            return "High Clearance is required";
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
                                        controller: floor_height,
                                        decoration: ThemeHelper().textInputDecoration('Floor Height', 'Floor Height'),
                                        validator: (val) {
                                          if(val!.trim().isEmpty){
                                            return "Floor height is required";
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
                                        controller: length_of_parking_space,
                                        decoration: ThemeHelper().textInputDecoration('Length of parking space', 'Length of parking space'),
                                        validator: (val) {
                                          if(val!.trim().isEmpty){
                                            return "Length of parking space is required";
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
                                        controller: width_of_parking_space,
                                        decoration: ThemeHelper().textInputDecoration('Width of parking space', 'Width of parking space'),
                                        validator: (val) {
                                          if(val!.trim().isEmpty){
                                            return "Width of parking space is required";
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
                                          title: 'Total number of floors',
                                          placeHolder: 'Search total number of floors',
                                          items: _totalNoOfFloors,
                                          selected: selectedTotalNoOfFloorsValue,
                                          onChanged: (value) async{
                                            
                                            setState(() {
                                              selectedTotalNoOfFloorsValue = value;
                                            });

                                          },
                                          label: 'Total number of floors',
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
                                          title: 'Space per floor',
                                          placeHolder: 'Search space per floor',
                                          items: _spacePerFloors,
                                          selected: selectedSpacePerFloorValue,
                                          onChanged: (value) {

                                            setState(() {
                                              selectedSpacePerFloorValue = value;
                                            });

                                            //print(jsonData[value]);


                                          },
                                          label: 'Space per floor',
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
                                          title: 'Total number of space',
                                          placeHolder: 'Search total number of space',
                                          items: _totalNoOfspace,
                                          selected: selectedNoOfSpaceValue,
                                          onChanged: (value) {

                                            setState(() {
                                              selectedNoOfSpaceValue = value;
                                            });

                                            //print(jsonData[value]);


                                          },
                                          label: 'Total number of space',
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
                                          title: 'No of rows',
                                          placeHolder: 'Search no of rows',
                                          items: _noOfRows,
                                          selected: selectedNoOfRowsValue,
                                          onChanged: (value) {

                                            setState(() {
                                              selectedNoOfRowsValue = value;
                                            });

                                            //print(jsonData[value]);


                                          },
                                          label: 'No of rows',
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
                                          title: 'No of columns',
                                          placeHolder: 'Search no of columns',
                                          items: _noOfColumns,
                                          selected: selectedNoOfColumnsValue,
                                          onChanged: (value) {

                                            setState(() {
                                              selectedNoOfColumnsValue = value;
                                            });

                                            //print(jsonData[value]);


                                          },
                                          label: 'No of columns',
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
                                          title: 'Garage Layout',
                                          placeHolder: 'Search garage layout',
                                          items: _garageLayout,
                                          selected: selectedGarageLayoutValue,
                                          onChanged: (value) {

                                            setState(() {
                                              selectedGarageLayoutValue = value;
                                            });

                                            //print(jsonData[value]);


                                          },
                                          label: 'Garage Layout',
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
                                        controller: comments,
                                        decoration: ThemeHelper().textInputDecoration('Comments', 'Comments'),
                                        validator: (val) {
                                          if(val!.trim().isEmpty){
                                            return "Comments is required";
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
                                        controller: upload_file,
                                        readOnly: true,
                                        onTap: () {
                                          pickFile();
                                        },
                                        decoration: InputDecoration(
                                          labelText: "upload File",
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
                                            "Done".toUpperCase(),
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
                                          add_garage_form_a();

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
