
import 'dart:async';
import 'dart:convert';

import 'package:cps/pages/login_page.dart';
import 'package:cps/pages/registration_verification_page.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cps/common/theme_helper.dart';
import 'package:cps/pages/widgets/header_widget.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegistrationPage extends  StatefulWidget{
  @override
  State<StatefulWidget> createState() {
     return _RegistrationPageState();
  }
}

class _RegistrationPageState extends State<RegistrationPage> with TickerProviderStateMixin{
  Timer? _timer;

  final _formKey = GlobalKey<FormState>();
  bool checkedValue = false;
  bool checkboxValue = false;

  bool _isPassSecure = true;
  bool _isConPassSecure = true;
  
  int user_type=0;
  TextEditingController first_name = TextEditingController();
  TextEditingController last_name = TextEditingController();
  TextEditingController user_name = TextEditingController();
  TextEditingController user_email = TextEditingController();
  TextEditingController user_password = TextEditingController();
  TextEditingController confirm_password = TextEditingController();
  
  Future<void> signup()async{
    // print(user_type);

    var client = http.Client();

    try{
      _timer?.cancel();

      EasyLoading.instance
          ..loadingStyle = EasyLoadingStyle.light;

      await EasyLoading.show(
        // status: 'loading...',
        maskType: EasyLoadingMaskType.black,
        indicator: Lottie.asset("assets/animations/loading.json", width: 125, height: 75)
      );

      var res = await client.post(Uri.https('creativeparkingsolutions.com', '/register_app'), body: {
          'user_type'    : user_type.toString(),
          'first_name'    : first_name.text,
          'last_name'     : last_name.text,
          'user_name'     : user_name.text,
          'email'         : user_email.text,
          'password'      : user_password.text,
      });
      print(res.statusCode);
      
      var response = jsonDecode(res.body);

      if(res.statusCode == 200){

        if(response['status']['email'] == false){
          EasyLoading.instance
            ..loadingStyle = EasyLoadingStyle.custom
            ..backgroundColor = Colors.red.shade200
            ..indicatorColor = Colors.red.shade900
            ..textColor = Colors.red.shade900;
          EasyLoading.showError('Your email already exists.');
          EasyLoading.dismiss();
        }else{
          EasyLoading.instance
            ..loadingStyle = EasyLoadingStyle.custom
            ..backgroundColor = Colors.green.shade200
            ..indicatorColor = Colors.green.shade900
            ..textColor = Colors.green.shade900;
          EasyLoading.showSuccess('Sign Up Success!');
          EasyLoading.dismiss();

          var set_email = response['get']['email'];
          var set_verify_code = response['get']['verify_code'];

          final sharedPreferences = await SharedPreferences.getInstance();

          sharedPreferences.setString('set_email', set_email);
          sharedPreferences.setString('set_verify_code', set_verify_code.toString());

          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>RegistrationVerificationPage()));
        }
      }
      
    }catch(e){
      EasyLoading.instance
        ..loadingStyle = EasyLoadingStyle.custom
        ..backgroundColor = Colors.red.shade200
        ..indicatorColor = Colors.red.shade900
        ..textColor = Colors.red.shade900;
      EasyLoading.showError('Sign Up Failed!');
      EasyLoading.dismiss();
      print(e);
    }
  }


  @override
  Widget build(BuildContext context) {
    TabController _tabController = TabController(length: 3, vsync: this);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: 150,
              child: HeaderWidget(150, false, Icons.person_add_alt_1_rounded),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(25, 50, 25, 10),
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                                width: 5, color: Colors.white),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 20,
                                offset: const Offset(5, 5),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.add_circle_outline_sharp,
                            color: Colors.grey.shade300,
                            size: 80.0,
                          ),
                        ),
                        SizedBox(height: 20,),
                        Text("Sign Up".toUpperCase(), style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                        SizedBox(height: 10,),
                        Container(
                          child: TabBar(
                            controller: _tabController,
                            isScrollable: true,
                            onTap: (value) => user_type=value,
                            tabs: [
                              Tab(text: "I'm Motorist",),
                              Tab(text: "I'm Garage Owner",),
                              Tab(text: "I'm Admin",),
                            ]
                          ),
                        ),
                        Container(
                          width: double.maxFinite,
                          height: 100,
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                                ListView.builder(
                                  itemCount: 1,
                                  itemBuilder: (_, index){
                                   return Container(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Sign up as Motorist", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                                        Text("Our system is designed to ensure a world class parking experience"),
                                        // Text("$user_type")
                                      ],
                                    
                                    ),
                                   );
                                  }
                                ),
                                ListView.builder(
                                  itemCount: 1,
                                  itemBuilder: (_, index){
                                   return Container(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        
                                        Text("Sign up as Garage Owner", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                                        Text("Our system is designed to ensure a world class parking experience"),
                                        // Text("$user_type")
                                      ],
                                    ),
                                   );
                                  }
                                ),
                                ListView.builder(
                                  itemCount: 1,
                                  itemBuilder: (_, index){
                                   return Container(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Sign up as Admin", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                                        Text("Our system is designed to ensure a world class parking experience"),
                                        // Text("$user_type")
                                      ],
                                    ),
                                   );
                                  }
                                )
                            ]
                          ),
                        ),
                        Container(
                          child: TextFormField(
                            controller: first_name,
                            decoration: ThemeHelper().textInputDecoration('First Name', 'Enter your first name'),
                            validator: (val) {
                              if(val!.trim().isEmpty){
                                return "First Name is required";
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
                            controller: last_name,
                            decoration: ThemeHelper().textInputDecoration('Last Name', 'Enter your last name'),
                            validator: (val) {
                              if(val!.trim().isEmpty){
                                return "Last Name is required";
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
                            controller: user_name,
                            decoration: ThemeHelper().textInputDecoration('User Name', 'Enter your User name'),
                            validator: (val) {
                              if(val!.trim().isEmpty){
                                return "User Name is required";
                              }
                              else{
                                return null;
                              }
                              
                            },
                          ),
                          decoration: ThemeHelper().inputBoxDecorationShaddow(),
                        ),
                        SizedBox(height: 10.0),
                        Container(
                          child: TextFormField(
                            controller: user_email,
                            decoration: ThemeHelper().textInputDecoration("E-mail address", "Enter your email"),
                            keyboardType: TextInputType.emailAddress,
                            validator: (val) {
                              if(val!.trim().isEmpty){
                                return "Email is required";
                              }
                              else if(!(val!.isEmpty) && !RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$").hasMatch(val)){
                                return "Enter a valid email address";
                              }
                              return null;
                            },
                          ),
                          decoration: ThemeHelper().inputBoxDecorationShaddow(),
                        ),
                        SizedBox(height: 10.0),
                        Container(
                          child: TextFormField(
                            controller: user_password,
                            obscureText: _isPassSecure,
                            decoration: InputDecoration(
                              labelText: "Password",
                              hintText: "Enter your password",
                              fillColor: Colors.white,
                              filled: true,
                              contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.grey)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.grey.shade400)),
                              errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.red, width: 2.0)),
                              focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.red, width: 2.0)),
                              suffixIcon: IconButton(
                                icon: Icon( _isPassSecure ? Icons.visibility : Icons.visibility_off),
                                onPressed: (){
                                  setState(() {
                                    if(_isPassSecure){
                                      _isPassSecure = false;
                                    }else{
                                      _isPassSecure = true;
                                    }
                                  });
                                },
                              ),
                              
                            ),
                            validator: (val) {
                              if (val!.isEmpty) {
                                return "Password is required";
                              }else if(val.length < 8){
                                return "Password must be at least 8 characters";
                              }
                              return null;
                            },
                          ),
                          decoration: ThemeHelper().inputBoxDecorationShaddow(),
                        ),
                        SizedBox(height: 10.0),
                        Container(
                          child: TextFormField(
                            controller: confirm_password,
                            obscureText: _isConPassSecure,
                            decoration: InputDecoration(
                              labelText: "Confirm Password",
                              hintText: "Enter your confirm password",
                              fillColor: Colors.white,
                              filled: true,
                              contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.grey)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.grey.shade400)),
                              errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.red, width: 2.0)),
                              focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0), borderSide: BorderSide(color: Colors.red, width: 2.0)),
                              suffixIcon: IconButton(
                                icon: Icon( _isConPassSecure ? Icons.visibility : Icons.visibility_off),
                                onPressed: (){
                                  setState(() {
                                    if(_isConPassSecure){
                                      _isConPassSecure = false;
                                    }else{
                                      _isConPassSecure = true;
                                    }
                                  });
                                },
                              ),
                              
                            ),
                            validator: (val) {
                              if (val!.isEmpty) {
                                return "Confirm password is required";
                              }else if(val != user_password.text){
                                return "Confirm password does not match";
                              }
                              return null;
                            },
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
                                "Sign up".toUpperCase(),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            onPressed: () {
                              
                              if (_formKey.currentState!.validate()) {
                                // Navigator.of(context).pushAndRemoveUntil(
                                //     MaterialPageRoute(
                                //         builder: (context) => ProfilePage()
                                //     ),
                                //         (Route<dynamic> route) => false
                                // );
                                signup();
                              }
                            },
                          ),
                        ),
                        SizedBox(height: 20.0),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(text: "Already have an account? "),
                                TextSpan(
                                  text: 'Sign in',
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => LoginPage()),
                                      );
                                    },
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade900,
                                      fontSize: 16
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}