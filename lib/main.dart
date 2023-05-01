import 'package:cps/pages/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'homescreen.dart';

void main() async {
  //Initialize Flutter Binding
  WidgetsFlutterBinding.ensureInitialized();

  //Assign publishable key to flutter_stripe
  // pk_live_51Ha7ksFqvNa68R4aELbp4FEzIubfoBRFInwUSMLEnfQBiqgjMp3KIoJOwpo4nXofLMKKgnOmykVkaIN1JRQ5VTY900QSl0vA43
  // pk_test_51MppgACRix9ffceRBgiV8R0sSFGxFq6NbzSnHxtt5Y2Q7G860qKPMkn52uXFaYBHsqXTR3PxxSwXTiXYaKfbo1SQ003o0LctVn
  Stripe.publishableKey =
      "pk_live_51Ha7ksFqvNa68R4aELbp4FEzIubfoBRFInwUSMLEnfQBiqgjMp3KIoJOwpo4nXofLMKKgnOmykVkaIN1JRQ5VTY900QSl0vA43";

  //Load our .env file that contains our Stripe Secret key
  await dotenv.load(fileName: "assets/.env");

  runApp(MyApp());
  configLoading();
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.yellow
    ..backgroundColor = Colors.green
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = true
    ..dismissOnTap = false;
    // ..customAnimation = CustomAnimation();
}

class MyApp extends StatelessWidget {
  Color _primaryColor = HexColor('#49c0ff');
  Color _accentColor = HexColor('#0762BD');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CPS',
      theme: ThemeData(
        primaryColor: _primaryColor,
        accentColor: _accentColor,
        scaffoldBackgroundColor: Colors.grey.shade100,
        primarySwatch: Colors.grey
      ),
      //initial route
      home: Scaffold(
        body: SplashScreen(title: 'CPS'),
      ),
      builder: EasyLoading.init(),
    );
  }
}
