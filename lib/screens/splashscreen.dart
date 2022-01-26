import 'dart:async';

import 'package:bikeze/widgets/dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity/connectivity.dart';

import 'homescreen.dart';
import 'loginscreen.dart';

class SplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  var finalNumber;
  bool login=false;
  @override
  void initState() {
    getValidationData().whenComplete(() => {
          Timer(Duration(seconds: 4),
              () => Get.off(login  ? LoginScreen() : HomeScreen()))
        });
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    super.initState();
  }

  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  Future<void> initConnectivity() async {
    ConnectivityResult result = ConnectivityResult.none;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }
  String _conec="";
  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
      case ConnectivityResult.none:
      _conec="${result.toString()}";
        break;
      default:
        CommonDialogs.showGenericToast( 'Failed to get Internet  connectivity.', );
        break;

  }
}

  Future getValidationData() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var obtainedNumber = sharedPreferences.getString("MobileNumber");
    var email = sharedPreferences.getString("email");

    setState(() {
      finalNumber = obtainedNumber;
      login=email==null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 10),

          Center(
            child: Container(
              // height: 120,
              width: 300,
              child: Image.asset(
                "assets/images/logo.png",
                fit: BoxFit.fill,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          // Center(
          //     child: Container(
          //   height: 200,
          //   width: 200,
          //   child: Column(
          //     children: [
          //       const Text(
          //         "bikeze.IN",
          //         style: TextStyle(
          //             color: Colors.white,
          //             fontSize: 30,
          //             fontWeight: FontWeight.bold),
          //       ),
          //       Row(
          //         children: const [
          //           SizedBox(width: 110),
          //           Text(
          //             "Partner",
          //             style: TextStyle(color: Colors.white, fontSize: 25),
          //           ),
          //         ],
          //       )
          //     ],
          //   ), //Image.asset("assets/images/logo.jpeg")),
          // )),
        ],
      ),
    );
  }
}
