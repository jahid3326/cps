import 'dart:async';
import 'dart:convert';

import 'package:cps/pages/login_page.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cps/common/theme_helper.dart';
import 'package:lottie/lottie.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets/header_widget.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;

class RegistrationVerificationPage extends StatefulWidget {
  const RegistrationVerificationPage({Key? key}) : super(key: key);

  @override
  _RegistrationVerificationPageState createState() => _RegistrationVerificationPageState();
}

class _RegistrationVerificationPageState extends State<RegistrationVerificationPage> {
  Timer? _timer;
  final _formKey = GlobalKey<FormState>();
  bool _pinSuccess = false;
  String? inputVerifyCode;

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

  Future<void> verify()async{
    var client = http.Client();

    try{
      _timer?.cancel();

      // print("User : $user_verify_code");
      // print("Input: $inputVerifyCode");

      EasyLoading.instance
        ..loadingStyle = EasyLoadingStyle.light;

      await EasyLoading.show(
        // status: 'loading...',
        maskType: EasyLoadingMaskType.black,
        indicator: Lottie.asset("assets/animations/loading.json", width: 125, height: 75)
      );

      if(user_verify_code.toString() != inputVerifyCode.toString()){
        EasyLoading.instance
          ..loadingStyle = EasyLoadingStyle.custom
          ..backgroundColor = Colors.red.shade200
          ..indicatorColor = Colors.red.shade900
          ..textColor = Colors.red.shade900;
        EasyLoading.showError('Verify code does not match!');
        EasyLoading.dismiss();
      }else{

        var res = await client.post(Uri.https('creativeparkingsolutions.com', '/register_verify_app'), body: {
            'email' : user_email,
        });
        print(res.statusCode);
        
        var response = jsonDecode(res.body);

        if(response['status'] == true){
          EasyLoading.instance
            ..loadingStyle = EasyLoadingStyle.custom
            ..backgroundColor = Colors.green.shade200
            ..indicatorColor = Color.fromARGB(255, 110, 239, 119)
            ..textColor = Colors.green.shade900;
          EasyLoading.showSuccess('Verifiy Success!');
          EasyLoading.dismiss();

          final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
          sharedPreferences.remove('set_email');
          sharedPreferences.remove('set_verify_code');

          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginPage()));
        }
      }
      /*
      if(user_verify_code != inputVerifyCode){
          EasyLoading.instance
            ..loadingStyle = EasyLoadingStyle.custom
            ..backgroundColor = Colors.red.shade200
            ..indicatorColor = Colors.red.shade900
            ..textColor = Colors.red.shade900;
          EasyLoading.showError('Verification does not match!');
          EasyLoading.dismiss();
      }else{
        EasyLoading.instance
          ..loadingStyle = EasyLoadingStyle.light;

        await EasyLoading.show(
          status: 'loading...',
          maskType: EasyLoadingMaskType.black
        );

        var res = await client.post(Uri.https('creativeparkingsolutions.com', '/register_verify_app'), body: {
            'email' : user_email,
        });
        print(res.statusCode);
        
        var response = jsonDecode(res.body);

        if(response['status'] == false){
          EasyLoading.instance
            ..loadingStyle = EasyLoadingStyle.custom
            ..backgroundColor = Colors.red.shade200
            ..indicatorColor = Colors.red.shade900
            ..textColor = Colors.red.shade900;
          EasyLoading.showError('Verify Failed');
          EasyLoading.dismiss();
        }else{
          EasyLoading.instance
            ..loadingStyle = EasyLoadingStyle.custom
            ..backgroundColor = Colors.green.shade200
            ..indicatorColor = Colors.green.shade900
            ..textColor = Colors.green.shade900;
          EasyLoading.showSuccess('Verify Success!');
          EasyLoading.dismiss();
        }
      }
      */

    }catch(e){
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
                child: HeaderWidget(
                    _headerHeight, true, Icons.privacy_tip_outlined),
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
                            Text('Verification',
                              style: TextStyle(
                                  fontSize: 35,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54
                              ),
                              // textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 10,),
                            Text(
                              'Enter the verification code we just sent you on your email address.',
                              style: TextStyle(
                                // fontSize: 20,
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
                            OTPTextField(
                              length: 6,
                              width: 300,
                              fieldWidth: 45,
                              style: TextStyle(
                                  fontSize: 30
                              ),
                              textFieldAlignment: MainAxisAlignment.spaceAround,
                              fieldStyle: FieldStyle.underline,
                              otpFieldStyle: OtpFieldStyle(
                                backgroundColor: Colors.grey.shade100
                              ),
                              onCompleted: (pin) {
                                //print(pin);
                                setState(() {
                                  _pinSuccess = true;
                                  inputVerifyCode = pin;
                                });
                              },
                              
                            ),
                            SizedBox(height: 50.0),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: "If you didn't receive a code! ",
                                    style: TextStyle(
                                      color: Colors.black38,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Resend',
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return ThemeHelper().alartDialog("Successful",
                                                "Verification code resend successful.",
                                                context);
                                          },
                                        );
                                      },
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 40.0),
                            Container(
                              decoration: _pinSuccess ? ThemeHelper().buttonBoxDecoration(context):ThemeHelper().buttonBoxDecoration(context, "#AAAAAA","#757575"),
                              child: ElevatedButton(
                                style: ThemeHelper().buttonStyle(),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      40, 10, 40, 10),
                                  child: Text(
                                    "Verify".toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                onPressed: _pinSuccess ? () {
                                  verify();
                                  // Navigator.of(context).pushAndRemoveUntil(
                                  //     MaterialPageRoute(
                                  //         builder: (context) => ProfilePage()
                                  //     ),
                                  //         (Route<dynamic> route) => false
                                  // );
                                } : null,
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
