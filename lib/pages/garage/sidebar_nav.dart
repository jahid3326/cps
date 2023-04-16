import 'package:cps/pages/garage/add_new_staff.dart';
import 'package:cps/pages/garage/citiation.dart';
import 'package:cps/pages/garage/dashboard.dart';
import 'package:cps/pages/garage/garages.dart';
import 'package:cps/pages/garage/managers.dart';
import 'package:cps/pages/garage/myaccount.dart';
import 'package:cps/pages/garage/permit.dart';
import 'package:cps/pages/garage/pricing_rates.dart';
import 'package:cps/pages/garage/view_staff.dart';
import 'package:cps/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SideBarNav extends StatelessWidget {
  SideBarNav({super.key, required this.profilePicture, required this.userName, required this.userEmail});

  String profilePicture;
  String userName;
  String userEmail;

  double  _drawerIconSize = 24;
  double _drawerFontSize = 17;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Drawer(
      width: 230,
      child: Container(
        decoration:BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, 1.0],
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.2),
                  Theme.of(context).accentColor.withOpacity(0.5),
                ]
            )
        ) ,
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                child: DrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: [0.0, 1.0],
                      colors: [ Theme.of(context).primaryColor,Theme.of(context).accentColor,],
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        profilePicture != '' ?
                        ClipOval(
                          child: FadeInImage.assetNetwork(
                            placeholder: "assets/animations/avator.gif",
                            image: "https://creativeparkingsolutions.com/public/assets/garage/images/user/$profilePicture",
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
                        
                        // Image.network(
                        //   "https://creativeparkingsolutions.com/public/assets/motorist/images/user/1671606484_a70cb22b885a3e2c1c55.png",
                        //   width: 100,
                        //   height: 100,
                        // ),
                        SizedBox(height: 10,),
                        Text(userName, style: TextStyle(fontSize: 18),),
                        SizedBox(height: 10,),
                        Text(userEmail),
                        
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: ListView(children: [
                ListTile(
                  leading: Icon(Icons.dashboard_rounded, size: _drawerIconSize, color: Theme.of(context).accentColor,),
                  title: Text('Dashboard', style: TextStyle(fontSize: 17, color: Theme.of(context).accentColor),),
                  minLeadingWidth : 10,
                  selectedTileColor: Colors.grey,
                  onTap: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>DashboardGarage()));
                  },
                ),
                Divider(color: Theme.of(context).primaryColor, height: 1,),
                ExpansionTile(
                  tilePadding: EdgeInsets.symmetric(horizontal: 0),  
                  title: ListTile(
                    leading: Icon(Icons.car_rental_rounded, size: _drawerIconSize, color: Theme.of(context).accentColor,),
                    title: Text('My Garage(s)', style: TextStyle(fontSize: 17, color: Theme.of(context).accentColor),),
                    minLeadingWidth : 10,
                  ),
                  children: [
                    // ListTile(
                    //   contentPadding: EdgeInsets.only(left: 50.0,),
                    //   leading: Icon(Icons.circle, color: Colors.blue.shade300,),
                    //   title: Text("Hours of Operation", style: TextStyle(color: Colors.black87),),
                    //   minLeadingWidth: 10,
                    //   onTap: () {
                    //     // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>PermitMotorist()));
                    //   },
                    // ),
                    ListTile(
                      contentPadding: EdgeInsets.only(left: 50.0,),
                      leading: Icon(Icons.arrow_right_alt_rounded, color: Colors.blue.shade500,),
                      title: Text("Pricing/Rates", style: TextStyle(color: Colors.black87),),
                      minLeadingWidth: 10,
                      onTap: () {
                        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>PricingRatesGarage()));
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context)=>PricingRatesGarage())
                        );
                      },
                    ),
                    // ListTile(
                    //   contentPadding: EdgeInsets.only(left: 50.0,),
                    //   leading: Icon(Icons.circle, color: Colors.blue.shade300,),
                    //   title: Text("Stats", style: TextStyle(color: Colors.black87),),
                    //   minLeadingWidth: 10,
                    //   onTap: () {
                    //     // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>PermitMotorist()));
                    //   },
                    // ),
                    ListTile(
                      contentPadding: EdgeInsets.only(left: 50.0,),
                      leading: Icon(Icons.arrow_right_alt_rounded, color: Colors.blue.shade500,),
                      title: Text("View Garages", style: TextStyle(color: Colors.black87),),
                      minLeadingWidth: 10,
                      onTap: () {
                        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Garage()));
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context)=>Garage())
                        );
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.only(left: 50.0,),
                      leading: Icon(Icons.arrow_right_alt_rounded, color: Colors.blue.shade500,),
                      title: Text("Garage Manage", style: TextStyle(color: Colors.black87),),
                      minLeadingWidth: 10,
                      onTap: () {
                        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>PermitMotorist()));
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.only(left: 50.0,),
                      leading: Icon(Icons.arrow_right_alt_rounded, color: Colors.blue.shade500,),
                      title: Text("Graphs", style: TextStyle(color: Colors.black87),),
                      minLeadingWidth: 10,
                      onTap: () {
                        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>PermitMotorist()));
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.only(left: 50.0,),
                      leading: Icon(Icons.arrow_right_alt_rounded, color: Colors.blue.shade500,),
                      title: Text("Managers", style: TextStyle(color: Colors.black87),),
                      minLeadingWidth: 10,
                      onTap: () {
                        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>ManagersGarage()));
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context)=>ManagersGarage())
                        );
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.only(left: 50.0,),
                      leading: Icon(Icons.arrow_right_alt_rounded, color: Colors.blue.shade500,),
                      title: Text("Permit", style: TextStyle(color: Colors.black87),),
                      minLeadingWidth: 10,
                      onTap: () {
                        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>PermitGarage()));
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context)=>PermitGarage())
                        );
                      },
                    ),
                  ],
                ),
                Divider(color: Theme.of(context).primaryColor, height: 1,),
                ListTile(
                  leading: Icon(Icons.account_box_rounded, size: _drawerIconSize, color: Theme.of(context).accentColor,),
                  title: Text('My Profile', style: TextStyle(fontSize: 17, color: Theme.of(context).accentColor),),
                  minLeadingWidth : 10,
                  selectedTileColor: Colors.grey,
                  onTap: () {
                    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>MyAccountGarage()));
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context)=>MyAccountGarage())
                    );
                  },
                ),
                Divider(color: Theme.of(context).primaryColor, height: 1,),
                ExpansionTile(
                  tilePadding: EdgeInsets.symmetric(horizontal: 0),  
                  title: ListTile(
                    leading: Icon(Icons.person, size: _drawerIconSize, color: Theme.of(context).accentColor,),
                    title: Text('Staff', style: TextStyle(fontSize: 17, color: Theme.of(context).accentColor),),
                    minLeadingWidth : 10,
                  ),
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.only(left: 50.0,),
                      leading: Icon(Icons.circle, color: Colors.blue.shade300,),
                      title: Text("Add New Staff", style: TextStyle(color: Colors.black87),),
                      minLeadingWidth: 10,
                      onTap: () {
                        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>AddNewStaffGarage()));
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context)=>AddNewStaffGarage())
                        );
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.only(left: 50.0,),
                      leading: Icon(Icons.circle, color: Colors.blue.shade300,),
                      title: Text("View Staff", style: TextStyle(color: Colors.black87),),
                      minLeadingWidth: 10,
                      onTap: () {
                        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>ViewStaffGarage()));
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context)=>ViewStaffGarage())
                        );
                      },
                    )
                  ],
                ),
                Divider(color: Theme.of(context).primaryColor, height: 1,),
                ListTile(
                  leading: Icon(Icons.description_rounded, size: _drawerIconSize, color: Theme.of(context).accentColor,),
                  title: Text('Citiation', style: TextStyle(fontSize: 17, color: Theme.of(context).accentColor),),
                  minLeadingWidth : 10,
                  selectedTileColor: Colors.grey,
                  onTap: () {
                    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>CitiationGarage()));
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context)=>CitiationGarage())
                    );
                  },
                ),
                Divider(color: Theme.of(context).primaryColor, height: 1,),
                ListTile(
                  leading: Icon(Icons.logout_rounded, size: _drawerIconSize, color: Theme.of(context).accentColor,),
                  title: Text('Logout', style: TextStyle(fontSize: 17, color: Theme.of(context).accentColor),),
                  minLeadingWidth : 10,
                  selectedTileColor: Colors.grey,
                  onTap: () async{
                    final sharedPreferences = await SharedPreferences.getInstance();
                    sharedPreferences.remove('logged_in');
                    sharedPreferences.remove('user_type');
                    sharedPreferences.remove('user_id');
                    sharedPreferences.remove('first_name');
                    sharedPreferences.remove('last_name');
                    sharedPreferences.remove('user_name');
                    sharedPreferences.remove('user_email');
                    sharedPreferences.remove('profile_picture');
                    sharedPreferences.remove('created_at');
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginPage()));
                  },
                ),
              ]),
            )
          ],
        )
      ),
    );
  }
}