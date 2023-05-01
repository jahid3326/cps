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
import 'package:image_picker/image_picker.dart';
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
  final _titleController = TextEditingController();
  File? _image;
  final picker = ImagePicker();

  TextEditingController garage_id = TextEditingController();
  TextEditingController garage_name = TextEditingController();
  TextEditingController high_clearance = TextEditingController();
  TextEditingController floor_height = TextEditingController();
  TextEditingController length_of_parking_space = TextEditingController();
  TextEditingController width_of_parking_space = TextEditingController();
  TextEditingController comments = TextEditingController();
  TextEditingController upload_file = TextEditingController();

  TextEditingController selectedTotalNoOfFloorsValue = TextEditingController();
  TextEditingController selectedSpacePerFloorValue = TextEditingController();
  TextEditingController selectedNoOfSpaceValue = TextEditingController();
  TextEditingController selectedNoOfRowsValue = TextEditingController();
  TextEditingController selectedNoOfColumnsValue = TextEditingController();
  TextEditingController selectedGarageLayoutValue = TextEditingController();
  
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

  String? selectedGarageOwnerValue;
  String? selectedClientValue;
  String? selectedPreferencesValue;

  // FilePickerResult? result;
  // String? _fileName;
  // PlatformFile? pickedfile;
  // File? filePath;
  // String? fileData;

  Future pickFile() async{

    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        upload_file.text = pickedFile.path.split('/').last;
      } else {
        print('No image selected.');
      }
    });

    /*
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
    */

    // final XFile? photo = await ImagePicker().pickImage(source: ImageSource.gallery);
    // setState(() {
    //   filePath = File(photo!.path);
    //   _fileName = photo.path.split('/').last;
    //   fileData = base64Encode(filePath!.readAsBytesSync());
    //   upload_file.text = photo.path.split('/').last;
    // });
  }

  //////// Garage Owner Dropdown List ////////////
  
  
  List _garage_owner_list = [''];

  

  Future<void> garageOwnerList() async {
    var client = http.Client();
    try {
      Map<String, String> headers = {
        'Accept': 'application/json',
      };
      // var res = await client.get(Uri.https('creativeparkingsolutions.com', 'admin/get_garage_owner_app'));
      var res = await client.get(Uri.parse('https://creativeparkingsolutions.com/admin/get_garage_owner_app'), headers: headers);
        
      var list = jsonDecode(res.body);
      // print(list);
      setState(() {
        _garage_owner_list = list;
      });

      // print(list);

      //return 'Success';
      
    } catch (e) {
      print(e);
    }
  }
  /////// End Garage Owner Dropdown List /////////

  //////// Client Dropdown List ////////////
  
  
  List _client_list = [''];
  Future<void> clientList() async {
    var client = http.Client();
    try {
      Map<String, String> headers = {
        'Accept': 'application/json',
      };
      // var res = await client.get(Uri.https('creativeparkingsolutions.com', 'admin/get_garage_owner_app'));
      var res = await client.get(Uri.parse('https://creativeparkingsolutions.com/admin/get_client_app'), headers: headers);
        
      var list = jsonDecode(res.body);
      // print(list);
      setState(() {
        _client_list = list;
      });

      // print(list);

      //return 'Success';
      
    } catch (e) {
      print(e);
    }
  }

  List _preferences_list = [''];
  Future<void> preferencesList() async {
    var client = http.Client();
    try {
      Map<String, String> headers = {
        'Accept': 'application/json',
      };
      var res = await client.get(Uri.parse('https://creativeparkingsolutions.com/admin/get_preferences_app'), headers: headers);
        
      var list = jsonDecode(res.body);
      // print(list);
      setState(() {
        _preferences_list = list;
      });

      // print(list);

      //return 'Success';
      
    } catch (e) {
      print(e);
    }
  }
  /*
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
  */
  /////// End Client Dropdown List /////////
  
  Future<void> add_garage_form_b(Map<String, String> body, String filepath)async{
    _timer?.cancel();

    EasyLoading.instance
      ..loadingStyle = EasyLoadingStyle.light;

    await EasyLoading.show(
      maskType: EasyLoadingMaskType.black,
      indicator: Lottie.asset("assets/animations/loading.json", width: 125, height: 75)
    );

    Map<String, String> headers = {
      'Content-Type': 'multipart/form-data',
    };

    var uri = Uri.https('creativeparkingsolutions.com', 'admin/add_garage_form_b_app');

    var request = http.MultipartRequest('POST', uri)
      ..fields.addAll(body)
      ..headers.addAll(headers)
      ..files.add(await http.MultipartFile.fromPath('garage_image', filepath));

    // var response = await request.send();
    request.send().then((result) async {

      http.Response.fromStream(result).then((response) {
        print(response.statusCode);
        var jsonData = jsonDecode(response.body);
        print(jsonData);
        
        if(response.statusCode == 200){
          if(jsonData['status'] == true){

            EasyLoading.instance
              ..loadingStyle = EasyLoadingStyle.custom
              ..backgroundColor = Colors.green.shade200
              ..indicatorColor = Colors.green.shade900
              ..textColor = Colors.green.shade900;
            EasyLoading.showSuccess('New garage added successfully');
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
      });
    }).catchError((err){

      EasyLoading.instance
        ..loadingStyle = EasyLoadingStyle.custom
        ..backgroundColor = Colors.red.shade200
        ..indicatorColor = Colors.red.shade900
        ..textColor = Colors.red.shade900;
      EasyLoading.showError('Add Failed!');
      EasyLoading.dismiss();
      print('error: '+err.toString());
    }).whenComplete(() => null);

    /*
    var client = http.Client();
    try {
      _timer?.cancel();
        
      EasyLoading.instance
        ..loadingStyle = EasyLoadingStyle.light;

      await EasyLoading.show(
        maskType: EasyLoadingMaskType.black,
        indicator: Lottie.asset("assets/animations/loading.json", width: 125, height: 75)
      );
      
      // var res = await client.post(Uri.https('creativeparkingsolutions.com', 'public/add_garage_form_b_app.php'), body: {
        // 'client_id' : selectedClientValue,
        // 'garage_name' : garage_name.text,
        // 'high_clearance' : high_clearance.text,
        // 'floor_height' : floor_height.text,
        // 'length_of_parking_space' : length_of_parking_space.text,
        // 'width_of_parking_space' : width_of_parking_space.text,
        // 'total_number_of_floor' : selectedTotalNoOfFloorsValue,
        // 'space_per_floor' : selectedSpacePerFloorValue,
        // 'total_number_of_space' : selectedNoOfSpaceValue,
        // 'no_of_rows' : selectedNoOfRowsValue,
        // 'no_of_columns' : selectedNoOfColumnsValue,
        // 'garage_layout' : selectedGarageLayoutValue,
        // 'comments' : comments.text,
        // 'lat' : lat.toString(),
        // 'lng' : lng.toString(),
        // 'location' : location,
        // 'file_name' : _fileName,
        // 'file_data' : fileData,
      // });
      // var res = await client.post(Uri.https('creativeparkingsolutions.com', 'public/add_garage_form_b_app.php'), body: {
      //   'f':'/9j/4f98RXhpZgAASUkqAAgAAAATAAABBAABAAAAEAoAAAEBBAABAAAAjAcAAA4BAgAgAAAA8gAAAA8BAgAgAAAAEgEAABABAgAgAAAAMgEAABIBAwABAAAABgAAABoBBQABAAAAUgEAABsBBQABAAAAWgEAACgBAwABAAAAAgAAADEBAgAgAAAAYgEAADIBAgAUAAAAggEAABMCAwABAAAAAgAAACACBAABAAAAAAAAACECBAABAAAAAAAAACICBAABAAAAAAAAACMCBAABAAAAAAAAACQCBAABAAAAAAAAACUCAgAgAAAAlgEAAGmHBAABAAAAtgEAAKwDAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHNhbXN1bmcAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAU00tTTAyMkcAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABIAAAAAQAAAEgAAAABAAAATTAyMkdYWFUyQlVJNgAAAAAAAAAAAAAAAAAAAAAAAAAyMDIzOjA0OjIyIDExOjI1OjAxAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIACaggUAAQAAADwDAACdggUAAQAAAEQDAAAiiAMAAQAAAAIAAAAniAMAAQAAADIAAAAwiAMAAQAAAAAAAAAyiAQAAQAAAAAAAAAAkAcABAAAADAyMjADkAIAFAAAAEwDAAAEkAIAFAAAAGADAAABkQcABAAAAAECAwABkgoAAQAAAHQDAAACkgUAAQAAAHwDAAADkgoAAQAAAIQDAAAEkgoAAQAAAIwDAAAFkgUAAQAAAJQDAAAHkgMAAQAAAAEAAAAIkgMAAQAAAP8AAAAJkgMAAQAAADAAAAAKkgUAAQAAAJwDAACQkgIAAgAAADE1AACRkgIAAgAAADE1AACSkgIAAgAAADE1AAAAoAcABAAAADAxMDABoAMAAQAAAAEAAAACoAQAAQAAABAKAAADoAQAAQAAAIwHAAAFoAQ',
      //   'f2':"${fileData}"
      // });
      // print(fileData);
      // print(res.statusCode);
      // print(_fileName);

      
      // var jsonData = jsonDecode(res.body);
      // print(jsonData);
      EasyLoading.dismiss();
      /*
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
      */

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
    */
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

    // clientList().then((value) {
    //   setState(() {
    //     _client_list = value;
    //   });
    // });
    getCountNotification();

    garageOwnerList();
    clientList();
    preferencesList();
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
                                    _garage_owner_list[0] == '' ?
                                    Container(
                                      decoration: BoxDecoration(
                                          color:Colors.white, //background color of dropdown button
                                        border: Border.all(color: Colors.black26, width:1), //border of dropdown button
                                          borderRadius: BorderRadius.circular(100), //border raiuds of dropdown button
                                          boxShadow: <BoxShadow>[ //apply shadow on Dropdown button
                                                  BoxShadow(
                                                      color: Color.fromRGBO(0, 0, 0, 0.1), //shadow for button
                                                      blurRadius: 5) //blur radius of shadow
                                                ]),
                                      width: double.infinity,
                                      child: DropdownButtonHideUnderline(
                                        child: Padding(
                                          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                                          child: Row(
                                            children: [
                                              DropdownButton(
                                                value: selectedGarageOwnerValue,
                                                hint: Text("Garage Owner"),
                                                items:  _garage_owner_list.map((list){
                                                  return DropdownMenuItem(value: '',child: Text(''),);
                                                  // return DropdownMenuItem(child: Text('t'), value: "data",);
                                                }).toList(),
                                                onChanged: (val){
                                                  setState(() {
                                                    selectedGarageOwnerValue = val.toString();
                                                  });
                                                  print(selectedGarageOwnerValue.toString());
                                                }
                                              ),
                                              SizedBox(
                                                height: 20,
                                                width: 20,
                                                child: CircularProgressIndicator(color: Colors.blue, strokeWidth: 3.0,),
                                              ),
                                            ],
                                          )
                                        ),
                                      )
                                    )
                                    :
                                    Container(
                                      decoration: BoxDecoration(
                                          color:Colors.white, //background color of dropdown button
                                        border: Border.all(color: Colors.black26, width:1), //border of dropdown button
                                          borderRadius: BorderRadius.circular(100), //border raiuds of dropdown button
                                          boxShadow: <BoxShadow>[ //apply shadow on Dropdown button
                                                  BoxShadow(
                                                      color: Color.fromRGBO(0, 0, 0, 0.1), //shadow for button
                                                      blurRadius: 5) //blur radius of shadow
                                                ]),
                                      width: double.infinity,
                                      child: DropdownButtonHideUnderline(
                                        child: Padding(
                                          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                                          child: DropdownButton(
                                            value: selectedGarageOwnerValue,
                                            hint: Text("Garage Owner"),
                                            items:  _garage_owner_list.map((list){
                                              var name = list['first_name']+' '+list['last_name'];
                                              return DropdownMenuItem(value: list['garage_owner_id'].toString(),child: Text(name),);
                                              // return DropdownMenuItem(child: Text('t'), value: "data",);
                                            }).toList(),
                                            onChanged: (val){
                                              setState(() {
                                                selectedGarageOwnerValue = val.toString();
                                              });
                                              // print(selectedGarageOwnerValue.toString());
                                            }
                                          ),
                                        ),
                                      )
                                    ),
                                    SizedBox(height: 10,),
                                    _client_list[0] == '' ?
                                    Container(
                                      decoration: BoxDecoration(
                                          color:Colors.white, //background color of dropdown button
                                        border: Border.all(color: Colors.black26, width:1), //border of dropdown button
                                          borderRadius: BorderRadius.circular(100), //border raiuds of dropdown button
                                          boxShadow: <BoxShadow>[ //apply shadow on Dropdown button
                                                  BoxShadow(
                                                      color: Color.fromRGBO(0, 0, 0, 0.1), //shadow for button
                                                      blurRadius: 5) //blur radius of shadow
                                                ]),
                                      width: double.infinity,
                                      child: DropdownButtonHideUnderline(
                                        child: Padding(
                                          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                                          child: Row(
                                            children: [
                                              DropdownButton(
                                                value: selectedClientValue,
                                                hint: Text("Client ID"),
                                                items:  _client_list.map((list){
                                                  return DropdownMenuItem(value: '',child: Text(''),);
                                                  // return DropdownMenuItem(child: Text('t'), value: "data",);
                                                }).toList(),
                                                onChanged: (val){
                                                  setState(() {
                                                    selectedClientValue = val.toString();
                                                  });
                                                  // print(selectedClientValue.toString());
                                                }
                                              ),
                                              SizedBox(
                                                height: 20,
                                                width: 20,
                                                child: CircularProgressIndicator(color: Colors.blue, strokeWidth: 3.0,),
                                              ),
                                            ],
                                          )
                                        ),
                                      )
                                    )
                                    :
                                    Container(
                                      decoration: BoxDecoration(
                                          color:Colors.white, //background color of dropdown button
                                        border: Border.all(color: Colors.black26, width:1), //border of dropdown button
                                          borderRadius: BorderRadius.circular(100), //border raiuds of dropdown button
                                          boxShadow: <BoxShadow>[ //apply shadow on Dropdown button
                                                  BoxShadow(
                                                      color: Color.fromRGBO(0, 0, 0, 0.1), //shadow for button
                                                      blurRadius: 5) //blur radius of shadow
                                                ]),
                                      width: double.infinity,
                                      child: DropdownButtonHideUnderline(
                                        child: Padding(
                                          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                                          child: DropdownButton(
                                            value: selectedClientValue,
                                            hint: Text("Client ID"),
                                            items:  _client_list.map((list){
                                              var name = list['ClientID'];
                                              return DropdownMenuItem(value: list['ClientID'].toString(),child: Text(name),);
                                              // return DropdownMenuItem(child: Text('t'), value: "data",);
                                            }).toList(),
                                            onChanged: (val){
                                              setState(() {
                                                selectedClientValue = val.toString();
                                              });
                                              // print(selectedClientValue.toString());
                                            }
                                          ),
                                        ),
                                      )
                                    ),
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
                                    Container(
                                      child: TextFormField(
                                        controller: selectedTotalNoOfFloorsValue,
                                        decoration: ThemeHelper().textInputDecoration('Total number of floors', 'Total number of floors'),
                                        validator: (val) {
                                          if(val!.trim().isEmpty){
                                            return "Total number of floors is required";
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
                                        controller: selectedSpacePerFloorValue,
                                        decoration: ThemeHelper().textInputDecoration('Space per floor', 'Space per floor'),
                                        validator: (val) {
                                          if(val!.trim().isEmpty){
                                            return "Space per floor is required";
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
                                        controller: selectedNoOfSpaceValue,
                                        decoration: ThemeHelper().textInputDecoration('Total number of space', 'Total number of space'),
                                        validator: (val) {
                                          if(val!.trim().isEmpty){
                                            return "Total number of space is required";
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
                                        controller: selectedNoOfRowsValue,
                                        decoration: ThemeHelper().textInputDecoration('No of rows', 'No of rows'),
                                        validator: (val) {
                                          if(val!.trim().isEmpty){
                                            return "No of rows is required";
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
                                        controller: selectedNoOfColumnsValue,
                                        decoration: ThemeHelper().textInputDecoration('No of columns', 'No of columns'),
                                        validator: (val) {
                                          if(val!.trim().isEmpty){
                                            return "No of columns is required";
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
                                        controller: selectedGarageLayoutValue,
                                        decoration: ThemeHelper().textInputDecoration('Garage Layout', 'Garage Layout'),
                                        validator: (val) {
                                          if(val!.trim().isEmpty){
                                            return "Garage Layout is required";
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
                                    SizedBox(height: 10,),
                                    _preferences_list[0] == '' ?
                                    Container(
                                      decoration: BoxDecoration(
                                          color:Colors.white, //background color of dropdown button
                                        border: Border.all(color: Colors.black26, width:1), //border of dropdown button
                                          borderRadius: BorderRadius.circular(100), //border raiuds of dropdown button
                                          boxShadow: <BoxShadow>[ //apply shadow on Dropdown button
                                                  BoxShadow(
                                                      color: Color.fromRGBO(0, 0, 0, 0.1), //shadow for button
                                                      blurRadius: 5) //blur radius of shadow
                                                ]),
                                      width: double.infinity,
                                      child: DropdownButtonHideUnderline(
                                        child: Padding(
                                          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                                          child: Row(
                                            children: [
                                              DropdownButton(
                                                value: selectedPreferencesValue,
                                                hint: Text("Preferences"),
                                                items:  _preferences_list.map((list){
                                                  return DropdownMenuItem(value: '',child: Text(''),);
                                                  // return DropdownMenuItem(child: Text('t'), value: "data",);
                                                }).toList(),
                                                onChanged: (val){
                                                  setState(() {
                                                    selectedPreferencesValue = val.toString();
                                                  });
                                                  // print(selectedPreferencesValue.toString());
                                                }
                                              ),
                                              SizedBox(
                                                height: 20,
                                                width: 20,
                                                child: CircularProgressIndicator(color: Colors.blue, strokeWidth: 3.0,),
                                              ),
                                            ],
                                          )
                                        ),
                                      )
                                    )
                                    :
                                    Container(
                                      decoration: BoxDecoration(
                                          color:Colors.white, //background color of dropdown button
                                        border: Border.all(color: Colors.black26, width:1), //border of dropdown button
                                          borderRadius: BorderRadius.circular(100), //border raiuds of dropdown button
                                          boxShadow: <BoxShadow>[ //apply shadow on Dropdown button
                                                  BoxShadow(
                                                      color: Color.fromRGBO(0, 0, 0, 0.1), //shadow for button
                                                      blurRadius: 5) //blur radius of shadow
                                                ]),
                                      width: double.infinity,
                                      child: DropdownButtonHideUnderline(
                                        child: Padding(
                                          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                                          child: DropdownButton(
                                            value: selectedPreferencesValue,
                                            hint: Text("Preferences"),
                                            items:  _preferences_list.map((list){
                                              var name = list['preferences_name'];
                                              return DropdownMenuItem(value: list['id'].toString(),child: Text(name),);
                                              // return DropdownMenuItem(child: Text('t'), value: "data",);
                                            }).toList(),
                                            onChanged: (val){
                                              setState(() {
                                                selectedPreferencesValue = val.toString();
                                              });
                                              // print(selectedPreferencesValue.toString());
                                            }
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
                                          // add_garage_form_b();

                                          _formKey.currentState!.save();
                                          Map<String, String> body = {
                                            // 'title': upload_file.text
                                            'garage_owner_id' : selectedGarageOwnerValue!,
                                            'client_id' : selectedClientValue!,
                                            'preferences_id' : selectedPreferencesValue!,
                                            'garage_name' : garage_name.text,
                                            'high_clearance' : high_clearance.text,
                                            'floor_height' : floor_height.text,
                                            'length_of_parking_space' : length_of_parking_space.text,
                                            'width_of_parking_space' : width_of_parking_space.text,
                                            'total_number_of_floor' : selectedTotalNoOfFloorsValue.text,
                                            'space_per_floor' : selectedSpacePerFloorValue.text,
                                            'total_number_of_space' : selectedNoOfSpaceValue.text,
                                            'no_of_rows' : selectedNoOfRowsValue.text,
                                            'no_of_columns' : selectedNoOfColumnsValue.text,
                                            'garage_layout' : selectedGarageLayoutValue.text,
                                            'comments' : comments.text,
                                            'lat' : lat.toString(),
                                            'lng' : lng.toString(),
                                            'location' : location!
                                          };

                                          add_garage_form_b(body, _image!.path);

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
