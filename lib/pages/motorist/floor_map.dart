import 'dart:async';
import 'dart:convert';

import 'package:cps/pages/motorist/garage_floor_map.dart';
import 'package:cps/pages/motorist/sidebar_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:cps/pages/widgets/header_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;


class FloorMapMotorist extends StatefulWidget {

  FloorMapMotorist({super.key, required this.garage_id});
  String garage_id;

  @override
  State<FloorMapMotorist> createState() => _FloorMapMotoristState();
}

class _FloorMapMotoristState extends State<FloorMapMotorist> with TickerProviderStateMixin{
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
  
  List<FloorMap> floorMap = [];

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
  
  // final List<FloorMap> floorMap = [
  //   FloorMap(20, 40, 100, 100),
  //   FloorMap(20, 180, 100, 100)
  // ];

  String? map_image;
  var floor_no;
  bool isFloor = true;

  Future <List<FloorMap>> getFloorMap() async{
    var client = http.Client();

    _timer?.cancel();
      
    EasyLoading.instance
      ..loadingStyle = EasyLoadingStyle.light;

    await EasyLoading.show(
      maskType: EasyLoadingMaskType.black,
      indicator: Lottie.asset("assets/animations/loading.json", width: 125, height: 75)
    );
    
    var res = await client.get(Uri.https("creativeparkingsolutions.com", "motorist/floor_map_app/${widget.garage_id}"));
    
    var jsonData = jsonDecode(res.body);

    List<FloorMap> floorMaps = [];

    print(res.statusCode);

    if(res.statusCode == 200){
      EasyLoading.dismiss(); 
      //print(jsonData);
      if(jsonData['found'] == true){
        
        isFloor = true;
        
        map_image = jsonData['map_image'];
        floor_no = jsonData['floor_no'];
        // print(map_image);
        

        for(var jsonFloor in jsonData['virtualData']){
          var pos_x = jsonFloor['pos_x'];
          var pos_y = jsonFloor['pos_y'];
          var hight = jsonFloor['hight'];
          var width = jsonFloor['width'];
          var parking_no= jsonFloor['parking_no'];
          var status= jsonFloor['status'].toString();
          
          FloorMap floorMap = FloorMap(pos_x, pos_y, hight, width, parking_no, status);

          floorMaps.add(floorMap);
        }

        return floorMaps;
      }else{
        isFloor = false;
        return floorMaps;
      }
    }
    
    return floorMaps;

  }

  Future <List<FloorMap>> getFloorMap2() async{
    var client = http.Client();

    
    var res = await client.get(Uri.https("creativeparkingsolutions.com", "motorist/floor_map_app/${widget.garage_id}"));
    
    var jsonData = jsonDecode(res.body);

    List<FloorMap> floorMaps = [];

    

    if(res.statusCode == 200){
     
      if(jsonData['found'] == true){
        
        isFloor = true;
        
        map_image = jsonData['map_image'];
        floor_no = jsonData['floor_no'];
        // print(map_image);
        

        for(var jsonFloor in jsonData['virtualData']){
          var pos_x = jsonFloor['pos_x'];
          var pos_y = jsonFloor['pos_y'];
          var hight = jsonFloor['hight'];
          var width = jsonFloor['width'];
          var parking_no= jsonFloor['parking_no'];
          var status= jsonFloor['status'].toString();
          
          FloorMap floorMap = FloorMap(pos_x, pos_y, hight, width, parking_no, status);

          floorMaps.add(floorMap);
        }

        return floorMaps;
      }else{
        isFloor = false;
        return floorMaps;
      }
    }
    
    return floorMaps;

  }

  void startRefresh(){

    final timer = Timer.periodic(Duration(seconds: 15), (timer) {
      getFloorMap2().then((value){
        setState(() {
          floorMap = value;
        });
        // print("object");
      });
    });
  }

  Future<dynamic> getAllFloor() async{

    var client = http.Client();

    var res = await client.get(Uri.https("creativeparkingsolutions.com", "motorist/get_all_floor_app/${widget.garage_id}"));
    
    var jsonData = jsonDecode(res.body);

    var array = [];

    // print(jsonData);
    for(var jsonArray in jsonData){
      array.add(jsonArray['floor_no']);
    }

    // print(array);

    return array;
  }

  late AnimationController animation;
  late Animation<double> _fadeInFadeOut;
  
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

    getFloorMap().then((value){
      setState(() {
        floorMap = value;
      });
    });

    animation = AnimationController(vsync: this, duration: Duration(milliseconds: 500),);
    _fadeInFadeOut = Tween<double>(begin: 0.0, end: 1).animate(animation);

    animation.addStatusListener((status){
      if(status == AnimationStatus.completed){
        animation.reverse();
      }
      else if(status == AnimationStatus.dismissed){
        animation.forward();
      }
    });
    animation.forward();

    startRefresh();
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("Floor Map",
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
        // actions: [
        //   Container(
        //     margin: EdgeInsets.only( top: 16, right: 16,),
        //     child: Stack(
        //       children: <Widget>[
        //         Icon(Icons.notifications),
        //         Positioned(
        //           right: 0,
        //           child: Container(
        //             padding: EdgeInsets.all(1),
        //             decoration: BoxDecoration( color: Colors.red, borderRadius: BorderRadius.circular(6),),
        //             constraints: BoxConstraints( minWidth: 12, minHeight: 12, ),
        //             child: Text( '5', style: TextStyle(color: Colors.white, fontSize: 8,), textAlign: TextAlign.center,),
        //           ),
        //         )
        //       ],
        //     ),
        //   )
        // ],
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
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      SizedBox(height: 5,),
                      floor_no == null ? 
                      Center(
                        child: SizedBox(
                          height: 30,
                          width: 30,
                          child: CircularProgressIndicator(color: Colors.blue, strokeWidth: 3.0,),
                        ),
                      ):
                      Center(child: Text("Garage : ${widget.garage_id}, Floor : ${floor_no}", style: TextStyle(fontSize: 15),)),
                      Container(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                !isFloor ? Center(child: Text("Floor not found!", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18),)) :
                                map_image == null ? Text("") :
                                FadeInImage.assetNetwork(
                                  placeholder: "assets/animations/image-thumbnail.gif",
                                  image: "https://creativeparkingsolutions.com/public/assets/admin/images/map_images/${map_image}",
                                  width: 300,
                                  height: 200,
                                  fit: BoxFit.fill,
                                  fadeInDuration: Duration(milliseconds: 5),
                                  fadeOutDuration: Duration(milliseconds: 5),
                                  imageErrorBuilder: (context, error, stackTrace){
                                    return Image.asset("assets/images/image-thumbnail.jpg", width: 300, height: 200, fit: BoxFit.fill,);
                                  },
                                ),
                                Container(
                                  height: 200,
                                  width: 300,
                                  child: CustomPaint(
                                    painter: RectPainter(floorMap, context),
                                  ),
                                ),
                                // !isFloor ? Text("Floor not found") :
                                map_image == null ? Text("") :
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Container(
                                    padding: EdgeInsets.only(top: 3, bottom: 3, left: 5, right: 5),
                                    child: FadeTransition(
                                      opacity: _fadeInFadeOut,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          ClipOval(
                                            child: Container(
                                              height: 10,
                                              width: 10,
                                              color: Colors.red,
                                            ),
                                          ),
                                          SizedBox(width: 2,),
                                          Text("Live", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),)
                                        ],
                                      ),
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: Colors.red,
                                      ),
                                    ),
                                  )
                                )
                                
                              ],
                            ),
                            
                          ],
                        ),
                      )
                    ]
                  )
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Container(
                        padding: EdgeInsets.only(left: 40, right: 40),
                        child: FutureBuilder(
                          future: getAllFloor(),
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
                              var itemCount = snapshot.data.length;
                              return GridView.builder(
                                itemCount: itemCount,
                                shrinkWrap: true,
                                physics: ScrollPhysics(),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: (1/.3)
                                ),
                                itemBuilder: (context, index){
                                  return Container(
                                    child: GestureDetector(
                                      child: Card(
                                        color: Colors.blue,
                                        child: Center(
                                          child: Text(
                                            "Floor ${snapshot.data[index]}",
                                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),)
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (context)=> GarageFloorMapMotorist(garage_id: widget.garage_id, floor_no: snapshot.data[index])));
                                      },
                                    )
                                  );
                                }
                              );
                            }
                            }
                            
                        ),
                      )
                    ]
                  )
                )
              ],
            )
          )
        ],
      ),
    );
  }
}

class RectPainter extends CustomPainter {
  
  final BuildContext context;
  List<FloorMap> floorMap;

  RectPainter(this.floorMap, this.context);
  

  //RectPainter({required this.floorMap});

  @override
  void paint(Canvas canvas, Size size) {

    // var myCanvas = TouchyCanvas(context, canvas);
    //print(floorMap);
    floorMap.forEach((element) {
      // print("pos_x : ${element.pos_x}, pos_y : ${element.pos_y}, height : ${element.height}, width : ${element.width}, isPark : ${element.isPark}");

      double left = double.parse(element.pos_x) * 0.156;
      double top = double.parse(element.pos_y) *0.18;
      double width = double.parse(element.width) *0.17;
      double height = double.parse(element.height) *0.2;
      var parking_no = element.parking_no;
      var status = element.status;

      Color fillColor = Colors.green;
      if(status == 'park'){
        fillColor = Colors.grey;
      }else{
        fillColor = Colors.green;
      }
      

      

      final paint = Paint()
        ..strokeWidth  = 10
        ..color = fillColor
        ..style = PaintingStyle.fill;

      canvas.drawRect(
        Rect.fromLTWH(left, top, width, height),
        paint,
      );

      // myCanvas.drawRect(
      //   Rect.fromLTWH(left, top, width, height),
      //   paint,
      //   onTapUp: (details){
      //     print("Space touched");
      //   }
      // );

      final textSpan = TextSpan(text: parking_no);
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr
      );

      var textPosition = Offset(left+(width/5), top+height/3);
      textPainter.layout(minWidth: 0, maxWidth: 50);
      textPainter.paint(canvas, textPosition);

    });

    // double left = 10;
    // double top = 10;
    // double width = 100;
    // double height = 100;

    // final paint = Paint()
    //   ..strokeWidth  = 10
    //   ..color = Colors.green
    //   ..style = PaintingStyle.fill;

    // canvas.drawRect(
    //   Rect.fromLTWH(left, top, width, height),
    //   paint
    // );
    // final textSpan = TextSpan(text: 'text');
    // final textPainter = TextPainter(
    //   text: textSpan,
    //   textAlign: TextAlign.center,
    //   textDirection: TextDirection.ltr
    // );

    // var textPosition = Offset(20, 20);
    // textPainter.layout(minWidth: 0, maxWidth: 50);
    // textPainter.paint(canvas, textPosition);

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class FloorMap{
  
  var pos_x;
  var pos_y;
  var height;
  var width;
  var parking_no;
  var status;

  FloorMap(this.pos_x, this.pos_y, this.height, this.width, this.parking_no, this.status);

}