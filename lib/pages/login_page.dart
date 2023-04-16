import 'dart:async';
import 'dart:convert';
import 'package:cps/pages/admin/dashboard.dart';
import 'package:cps/pages/forgot_password_page.dart';
import 'package:cps/pages/garage/dashboard.dart';
import 'package:cps/pages/motorist/dashboard.dart';
import 'package:cps/pages/registration_page.dart';
import 'package:cps/common/theme_helper.dart';
import 'package:cps/pages/widgets/header_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthData {
  final String? logged_in;
  final String? user_type;
  final String? user_id;
  final String? first_name;
  final String? last_name;
  final String? user_name;
  final String? user_email;
  final String? profile_picture;

  AuthData({this.logged_in, this.user_type, this.user_id, this.first_name, this.last_name, this.user_name, this.user_email, this.profile_picture});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> authData = Map<String, dynamic>();
    authData["logged_in"] = logged_in;
    authData["user_type"] = this.user_type;
    authData["user_id"] = this.user_id;
    authData["first_name"] = this.first_name;
    authData["last_name"] = this.last_name;
    authData["user_name"] = this.user_name;
    authData["user_email"] = this.user_email;
    authData["profile_picture"] = this.profile_picture;

    return authData;
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Timer? _timer;
  double _headerHeight = 250;
  final _formKey = GlobalKey<FormState>();

  Map<String, dynamic>? paymentIntent;

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  bool _isPassSecure = true;

  // void initState(){
  //   super.initState();
  //   EasyLoading.addStatusCallback((status) {
  //     print('EasyLoading Status $status');
  //     if (status == EasyLoadingStatus.dismiss) {
  //       _timer?.cancel();
  //     }
  //   });
  //   EasyLoading.showSuccess('Use in initState');
  // }

  Future<void> loginIn()async{
    var client = http.Client();
    
      try{
        _timer?.cancel();
        
        EasyLoading.instance
          ..loadingStyle = EasyLoadingStyle.light;

        await EasyLoading.show(
          maskType: EasyLoadingMaskType.black,
          indicator: Lottie.asset("assets/animations/loading.json", width: 125, height: 75)
        );
        
        var res = await client.post(Uri.https('creativeparkingsolutions.com', '/login_app'), body: {
            'email'         : email.text,
            'password'      : password.text,
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
            EasyLoading.showError('Wrong Email!');
            EasyLoading.dismiss();
          }
          else if(response['status']['password'] == false){
            EasyLoading.instance
              ..loadingStyle = EasyLoadingStyle.custom
              ..backgroundColor = Colors.red.shade200
              ..indicatorColor = Colors.red.shade900
              ..textColor = Colors.red.shade900;
            EasyLoading.showError('Wrong Password!');
            EasyLoading.dismiss();
          }
          else if(response['status']['approve'] == false){
            EasyLoading.instance
              ..loadingStyle = EasyLoadingStyle.custom
              ..backgroundColor = Colors.red.shade200
              ..indicatorColor = Colors.red.shade900
              ..textColor = Colors.red.shade900;
            EasyLoading.showError('Account not approved!');
            EasyLoading.dismiss();
          }
          else{
            EasyLoading.instance
              ..loadingStyle = EasyLoadingStyle.custom
              ..backgroundColor = Colors.green.shade200
              ..indicatorColor = Colors.green.shade900
              ..textColor = Colors.green.shade900;
            EasyLoading.showSuccess('Login Success!');
            EasyLoading.dismiss();

            var user_type = response['user_data']['user_type'];
            var user_id = response['user_data']['user_id'];
            var first_name = response['user_data']['first_name'];
            var last_name = response['user_data']['last_name'];
            var user_name = response['user_data']['user_name'];
            var user_email = response['user_data']['email'];
            var profile_picture = response['user_data']['profile_picture'] == null ? '' : response['user_data']['profile_picture'];
            var created_at = response['user_data']['created_at'];

            // AuthData authData = AuthData(logged_in: 'true', user_type: user_type, user_id: user_id, first_name: first_name, last_name: last_name, user_name: user_name, user_email: user_email, profile_picture: profile_picture);

            // await FlutterSession().set('authData', authData);

            final sharedPreferences = await SharedPreferences.getInstance();

            sharedPreferences.setBool('logged_in', true);
            sharedPreferences.setString('user_type', user_type);
            sharedPreferences.setString('user_id', user_id);
            sharedPreferences.setString('first_name', first_name);
            sharedPreferences.setString('last_name', last_name);
            sharedPreferences.setString('user_name', user_name);
            sharedPreferences.setString('user_email', user_email);
            sharedPreferences.setString('profile_picture', profile_picture);
            sharedPreferences.setString('created_at', created_at);
            print(user_type);

            if(user_type == 'motorist'){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>DashboardMotorist()));
            }
            else if(user_type == 'garage'){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>DashboardGarage()));
            }
            else if(user_type == 'admin'){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>DashboardAdmin()));
            }
          }
          
        }

        print("Ok");

      }catch(e){
        EasyLoading.instance
          ..loadingStyle = EasyLoadingStyle.custom
          ..backgroundColor = Colors.red.shade200
          ..indicatorColor = Colors.red.shade900
          ..textColor = Colors.red.shade900;
        EasyLoading.showError('Login Failed!');
        EasyLoading.dismiss();
        print(e);
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: WillPopScope(
        onWillPop: ()=> _onBackButtonPressed(context),
        child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: _headerHeight,
                  child: HeaderWidget(_headerHeight, true, Icons.login_rounded),
                ),
                SafeArea(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                    margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: Column(
                      children: [
                        Text("Welcome Back", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
                        Text("Login into your account", style: TextStyle(fontSize: 15, color: Colors.grey),),
                        SizedBox(height: 30.0,),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Container(
                                child: TextFormField(
                                  controller: email,
                                  decoration: ThemeHelper().textInputDecoration('Email', 'Enter your email'),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (val) {
                                    if(val!.trim().isEmpty){
                                      return "Email is required";
                                    }
                                    else if(!(val!.trim().isEmpty) && !RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$").hasMatch(val)){
                                      return "Enter a valid email address";
                                    }else{
                                      return null;
                                    }
                                    
                                  },
                                ),
                                decoration: ThemeHelper().inputBoxDecorationShaddow(),
                              ),
                              SizedBox(height: 15.0,),
                              Container(
                                child: TextFormField(
                                  controller: password,
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
                                    if(val!.trim().isEmpty){
                                      return "Password is required";
                                    }
                                    else{
                                      return null;
                                    }
                                    
                                  },
                                  
                                ),
                                decoration: ThemeHelper().inputBoxDecorationShaddow(),
                              ),
                              SizedBox(height: 15.0,),
                              Container(
                                margin: EdgeInsets.fromLTRB(10, 0, 10, 20),
                                alignment: Alignment.topRight,
                                child: GestureDetector(
                                  child: Text("Forgot your password?", style: TextStyle(color: Colors.grey),),
                                  onTap: (){
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPasswordPage()));
                                  },
                                ),
                              ),
                              Container(
                                decoration: ThemeHelper().buttonBoxDecoration(context),
                                child: ElevatedButton(
                                  style: ThemeHelper().buttonStyle(),
                                  onPressed: (){
                                    if (_formKey.currentState!.validate()) {
                                      // Navigator.of(context).pushAndRemoveUntil(
                                      //     MaterialPageRoute(
                                      //         builder: (context) => ProfilePage()
                                      //     ),
                                      //         (Route<dynamic> route) => false
                                      // );
                                      loginIn();
                                    }
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(40, 10, 40, 10),
                                    child: Text("Login", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),),
                                  )
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(10, 20, 10, 20),
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(text: "Don\'t have an account? "),
                                      TextSpan(
                                        text: "Signup",
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = (){
                                            Navigator.push(context, MaterialPageRoute(builder: (context) => RegistrationPage()));
                                          },
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).accentColor),
                                      )
                                    ]
                                  )
                                ),
                              )
                            ],
                          )
                        )
                      ],
                    ),
                  )
                )
              ],
            ),
          ),
      )
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
