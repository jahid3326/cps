import 'dart:async';
import 'dart:convert';

import 'package:cps/pages/login_page.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cps/common/theme_helper.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets/header_widget.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({Key? key}) : super(key: key);

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  Timer? _timer;
  final _formKey = GlobalKey<FormState>();

  TextEditingController user_password = TextEditingController();
  TextEditingController confirm_password = TextEditingController();

  bool _isPassSecure = true;
  bool _isConPassSecure = true;

  String? user_email;
  String? user_verify_code;

  Future getVerifyData()async{
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? getUserEmail = sharedPreferences.getString('set_email');
    String? getVerifyCode = sharedPreferences.getString('set_verify_code');

    setState(() {
      user_email = getUserEmail;
      user_verify_code = getVerifyCode;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getVerifyData().whenComplete(()async{
      setState(() {
        user_email = user_email;
        user_verify_code = user_verify_code;
      });
    });

  }

  Future<void> reset()async{

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
      
      var res = await client.post(Uri.https('creativeparkingsolutions.com', '/reset_password_app'), body: {
          'email' : user_email,
          'password' : user_password.text,
      });
      print(res.statusCode);
      
      var response = jsonDecode(res.body);

      if(res.statusCode == 200){
        // print(response);
        if(response['status']['email'] == true){
          EasyLoading.instance
            ..loadingStyle = EasyLoadingStyle.custom
            ..backgroundColor = Colors.green.shade200
            ..indicatorColor = Colors.green.shade900
            ..textColor = Colors.green.shade900;
          EasyLoading.showSuccess('Reset Success!');
          EasyLoading.dismiss();

          final sharedPreferences = await SharedPreferences.getInstance();

          sharedPreferences.remove('set_email');
          sharedPreferences.remove('set_verify_code');

          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginPage()));
          
        }else{
          
          EasyLoading.instance
            ..loadingStyle = EasyLoadingStyle.custom
            ..backgroundColor = Colors.red.shade200
            ..indicatorColor = Colors.red.shade900
            ..textColor = Colors.red.shade900;
          EasyLoading.showError('Reset Failed!');
          EasyLoading.dismiss();
        }
      }
      
    }catch(e){
      EasyLoading.instance
        ..loadingStyle = EasyLoadingStyle.custom
        ..backgroundColor = Colors.red.shade200
        ..indicatorColor = Colors.red.shade900
        ..textColor = Colors.red.shade900;
      EasyLoading.showError('Reset Failed!');
      EasyLoading.dismiss();
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    double _headerHeight = 300;
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: _headerHeight,
                child: HeaderWidget(_headerHeight, true, Icons.password_rounded),
              ),
              SafeArea(
                child: Container(
                  margin: EdgeInsets.fromLTRB(25, 10, 25, 10),
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.topLeft,
                        margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Reset Password?',
                              style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54
                              ),
                              // textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 40.0),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            Container(
                              child: TextFormField(
                                controller: user_password,
                                obscureText: _isPassSecure,
                                decoration: InputDecoration(
                                  labelText: "New Password",
                                  hintText: "Enter new password",
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
                                    return "New Password is required";
                                  }else if(val.length < 8){
                                    return "New password must be at least 8 characters";
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
                                  }
                                  else if(val != user_password.text){
                                    return "Confirm password does not match";
                                  }
                                  return null;
                                },
                              ),
                              decoration: ThemeHelper().inputBoxDecorationShaddow(),
                            ),
                            SizedBox(height: 40.0),
                            Container(
                              decoration: ThemeHelper().buttonBoxDecoration(context),
                              child: ElevatedButton(
                                style: ThemeHelper().buttonStyle(),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      40, 10, 40, 10),
                                  child: Text(
                                    "Reset".toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  if(_formKey.currentState!.validate()) {
                                    // Navigator.pushReplacement(
                                    //   context,
                                    //   MaterialPageRoute(
                                    //       builder: (context) => ForgotPasswordVerificationPage()),
                                    // );
                                    reset();
                                  }
                                },
                              ),
                            ),
                            SizedBox(height: 30.0),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(text: "Remember your password? "),
                                  TextSpan(
                                    text: 'Login',
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => LoginPage()),
                                        );
                                      },
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        )
    );
  }
}
