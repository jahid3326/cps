import 'package:cps/pages/login_page.dart';
import 'package:cps/pages/motorist/dashboard.dart';
import 'package:cps/pages/motorist/garage.dart';
import 'package:cps/pages/motorist/myaccount.dart';
// import 'package:cps/pages/motorist/myaccount.dart';
import 'package:cps/pages/motorist/package.dart';
import 'package:cps/pages/motorist/permit.dart';
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
                            image: "https://creativeparkingsolutions.com/public/assets/motorist/images/user/$profilePicture",
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
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>DashboardMotorist()));
                  },
                ),
                Divider(color: Theme.of(context).primaryColor, height: 1,),
                ListTile(
                  leading: Icon(Icons.account_box_rounded, size: _drawerIconSize, color: Theme.of(context).accentColor,),
                  title: Text('My Account', style: TextStyle(fontSize: 17, color: Theme.of(context).accentColor),),
                  minLeadingWidth : 10,
                  selectedTileColor: Colors.grey,
                  onTap: () {
                    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>MyAccountMotorist()));
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context)=>MyAccountMotorist())
                    );
                  },
                ),
                Divider(color: Theme.of(context).primaryColor, height: 1,),
                ExpansionTile(
                  tilePadding: EdgeInsets.symmetric(horizontal: 0),  
                  title: ListTile(
                    leading: Icon(Icons.settings, size: _drawerIconSize, color: Theme.of(context).accentColor,),
                    title: Text('Settings', style: TextStyle(fontSize: 17, color: Theme.of(context).accentColor),),
                    minLeadingWidth : 10,
                  ),
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.only(left: 50.0,),
                      leading: Icon(Icons.arrow_right_alt_rounded, color: Colors.blue.shade500,),
                      title: Text("Permits", style: TextStyle(color: Colors.black87),),
                      minLeadingWidth: 10,
                      onTap: () {
                        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>PermitMotorist()));
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context)=>PermitMotorist())
                        );
                      },
                    )
                  ],
                ),
                Divider(color: Theme.of(context).primaryColor, height: 1,),
                ListTile(
                  leading: Icon(Icons.add_card, size: _drawerIconSize, color: Theme.of(context).accentColor,),
                  title: Text('Package', style: TextStyle(fontSize: 17, color: Theme.of(context).accentColor),),
                  minLeadingWidth : 10,
                  selectedTileColor: Colors.grey,
                  onTap: () {
                    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>PackageMotorist()));
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context)=>PackageMotorist())
                    );
                  },
                ),
                // Divider(color: Theme.of(context).primaryColor, height: 1,),
                // ListTile(
                //   leading: Icon(Icons.car_rental_rounded, size: _drawerIconSize, color: Theme.of(context).accentColor,),
                //   title: Text('Garage', style: TextStyle(fontSize: 17, color: Theme.of(context).accentColor),),
                //   minLeadingWidth : 10,
                //   selectedTileColor: Colors.grey,
                //   onTap: () {
                //     // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>GarageMotorist()));
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(builder: (context)=>GarageMotorist())
                //     );
                //   },
                // ),
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