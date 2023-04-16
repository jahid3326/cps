import 'package:cps/pages/admin/add_new_client.dart';
import 'package:cps/pages/admin/add_new_staff.dart';
import 'package:cps/pages/admin/admin_control.dart';
import 'package:cps/pages/admin/all_order.dart';
import 'package:cps/pages/admin/approve.dart';
import 'package:cps/pages/admin/dashboard.dart';
import 'package:cps/pages/admin/garage_list.dart';
import 'package:cps/pages/admin/garage_owners.dart';
import 'package:cps/pages/admin/garage_pricing.dart';
import 'package:cps/pages/admin/management.dart';
import 'package:cps/pages/admin/managers.dart';
import 'package:cps/pages/admin/motorist.dart';
import 'package:cps/pages/admin/my_profile.dart';
import 'package:cps/pages/admin/new_admin.dart';
import 'package:cps/pages/admin/trash_garages.dart';
import 'package:cps/pages/admin/view_staff.dart';
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
                            image: "https://creativeparkingsolutions.com/public/assets/admin/images/user/$profilePicture",
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
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>DashboardAdmin()));
                  },
                ),
                Divider(color: Theme.of(context).primaryColor, height: 1,),
                ExpansionTile(
                  tilePadding: EdgeInsets.symmetric(horizontal: 0),  
                  title: ListTile(
                    leading: Icon(Icons.person_pin, size: _drawerIconSize, color: Theme.of(context).accentColor,),
                    title: Text('Account Management', style: TextStyle(fontSize: 17, color: Theme.of(context).accentColor),),
                    minLeadingWidth : 10,
                  ),
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.only(left: 50.0,),
                      leading: Icon(Icons.arrow_right_alt_rounded, color: Colors.blue.shade500,),
                      title: Text("My Profile", style: TextStyle(color: Colors.black87),),
                      minLeadingWidth: 10,
                      onTap: () {
                        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>MyAccountAdmin()));
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context)=>MyAccountAdmin())
                        );
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.only(left: 50.0,),
                      leading: Icon(Icons.arrow_right_alt_rounded, color: Colors.blue.shade500,),
                      title: Text("Management", style: TextStyle(color: Colors.black87),),
                      minLeadingWidth: 10,
                      onTap: () {
                        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>ManagementAdmin()));
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context)=>ManagementAdmin())
                        );
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.only(left: 50.0,),
                      leading: Icon(Icons.arrow_right_alt_rounded, color: Colors.blue.shade500,),
                      title: Text("Motorist", style: TextStyle(color: Colors.black87),),
                      minLeadingWidth: 10,
                      onTap: () {
                        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>MotoristAdmin()));
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context)=>MotoristAdmin())
                        );
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.only(left: 50.0,),
                      leading: Icon(Icons.arrow_right_alt_rounded, color: Colors.blue.shade500,),
                      title: Text("Garage Owners", style: TextStyle(color: Colors.black87),),
                      minLeadingWidth: 10,
                      onTap: () {
                        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>GarageOwnersAdmin()));
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context)=>GarageOwnersAdmin())
                        );
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.only(left: 50.0,),
                      leading: Icon(Icons.arrow_right_alt_rounded, color: Colors.blue.shade500,),
                      title: Text("Admins", style: TextStyle(color: Colors.black87),),
                      minLeadingWidth: 10,
                      onTap: () {
                        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>AdminControlAdmin()));
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context)=>AdminControlAdmin())
                        );
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.only(left: 50.0,),
                      leading: Icon(Icons.arrow_right_alt_rounded, color: Colors.blue.shade500,),
                      title: Text("Add Admin", style: TextStyle(color: Colors.black87),),
                      minLeadingWidth: 10,
                      onTap: () {
                        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>NewAdmin()));
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context)=>NewAdmin())
                        );
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.only(left: 50.0,),
                      leading: Icon(Icons.arrow_right_alt_rounded, color: Colors.blue.shade500,),
                      title: Text("Add New Client", style: TextStyle(color: Colors.black87),),
                      minLeadingWidth: 10,
                      onTap: () {
                        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>AddNewClientAdmin()));
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context)=>AddNewClientAdmin())
                        );
                      },
                    ),
                  ],
                ),
                Divider(color: Theme.of(context).primaryColor, height: 1,),
                ExpansionTile(
                  tilePadding: EdgeInsets.symmetric(horizontal: 0),  
                  title: ListTile(
                    leading: Icon(Icons.car_rental_outlined, size: _drawerIconSize, color: Theme.of(context).accentColor,),
                    title: Text('Garage Management', style: TextStyle(fontSize: 17, color: Theme.of(context).accentColor),),
                    minLeadingWidth : 10,
                  ),
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.only(left: 50.0,),
                      leading: Icon(Icons.arrow_right_alt_rounded, color: Colors.blue.shade500,),
                      title: Text("Approve", style: TextStyle(color: Colors.black87),),
                      minLeadingWidth: 10,
                      onTap: () {
                        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>ApproveAdmin()));
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context)=>ApproveAdmin())
                        );
                      },
                    ),
                    // ListTile(
                    //   contentPadding: EdgeInsets.only(left: 50.0,),
                    //   leading: Icon(Icons.circle, color: Colors.blue.shade300,),
                    //   title: Text("Admin Control", style: TextStyle(color: Colors.black87),),
                    //   minLeadingWidth: 10,
                    //   onTap: () {
                    //     // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>PermitMotorist()));
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(builder: (context)=>AdminControlAdmin())
                    //     );
                    //   },
                    // ),
                    ListTile(
                      contentPadding: EdgeInsets.only(left: 50.0,),
                      leading: Icon(Icons.arrow_right_alt_rounded, color: Colors.blue.shade500,),
                      title: Text("Map Management", style: TextStyle(color: Colors.black87),),
                      minLeadingWidth: 10,
                      onTap: () {
                        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>PermitMotorist()));
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.only(left: 50.0,),
                      leading: Icon(Icons.arrow_right_alt_rounded, color: Colors.blue.shade500,),
                      title: Text("Graphs/Stats", style: TextStyle(color: Colors.black87),),
                      minLeadingWidth: 10,
                      onTap: () {
                        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>PermitMotorist()));
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.only(left: 50.0,),
                      leading: Icon(Icons.arrow_right_alt_rounded, color: Colors.blue.shade500,),
                      title: Text("Garage Pricing", style: TextStyle(color: Colors.black87),),
                      minLeadingWidth: 10,
                      onTap: () {
                        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>GaragePricingAdmin()));
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context)=>GaragePricingAdmin())
                        );
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.only(left: 50.0,),
                      leading: Icon(Icons.arrow_right_alt_rounded, color: Colors.blue.shade500,),
                      title: Text("Garages", style: TextStyle(color: Colors.black87),),
                      minLeadingWidth: 10,
                      onTap: () {
                        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>GarageListAdmin()));
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context)=>GarageListAdmin())
                        );
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.only(left: 50.0,),
                      leading: Icon(Icons.arrow_right_alt_rounded, color: Colors.blue.shade500,),
                      title: Text("Trash Garages", style: TextStyle(color: Colors.black87),),
                      minLeadingWidth: 10,
                      onTap: () {
                        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>TrashGarageAdmin()));
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context)=>TrashGarageAdmin())
                        );
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.only(left: 50.0,),
                      leading: Icon(Icons.arrow_right_alt_rounded, color: Colors.blue.shade500,),
                      title: Text("Managers", style: TextStyle(color: Colors.black87),),
                      minLeadingWidth: 10,
                      onTap: () {
                        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>ManagersAdmin()));
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context)=>ManagersAdmin())
                        );
                      },
                    ),
                  ],
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
                      leading: Icon(Icons.arrow_right_alt_rounded, color: Colors.blue.shade500,),
                      title: Text("Add New Staff", style: TextStyle(color: Colors.black87),),
                      minLeadingWidth: 10,
                      onTap: () {
                        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>AddNewStaffAdmin()));
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context)=>AddNewStaffAdmin())
                        );
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.only(left: 50.0,),
                      leading: Icon(Icons.arrow_right_alt_rounded, color: Colors.blue.shade500,),
                      title: Text("View Staff", style: TextStyle(color: Colors.black87),),
                      minLeadingWidth: 10,
                      onTap: () {
                        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>ViewStaffAdmin()));
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context)=>ViewStaffAdmin())
                        );
                      },
                    )
                  ],
                ),
                Divider(color: Theme.of(context).primaryColor, height: 1,),
                ListTile(
                  leading: Icon(Icons.account_box_rounded, size: _drawerIconSize, color: Theme.of(context).accentColor,),
                  title: Text('All Orders', style: TextStyle(fontSize: 17, color: Theme.of(context).accentColor),),
                  minLeadingWidth : 10,
                  selectedTileColor: Colors.grey,
                  onTap: () {
                    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>OrdersAdmin()));
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context)=>OrdersAdmin())
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