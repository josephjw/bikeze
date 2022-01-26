// ignore_for_file: unnecessary_const

import 'dart:async';
import 'dart:convert';
import 'package:bikeze/preference/Constants.dart';
import 'package:bikeze/widgets/dialog.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'otpscreen.dart';



class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController mobNumber = TextEditingController();
  var now = new DateTime.now();

  SignIn(String number) async {

    setState(() {
      _loading=true;
    });
    String url = "https://manyatechnosys.com/bikeze/mobile_verification.php";
    var map = new Map<String, String>();

    map['mobile'] = '${number}';
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    sharedPreferences.setString("MobileNumber", number);
    var res = await http.Client().post(Uri.parse(url), body: map);
    print(res);
    if (res.statusCode == 200) {
      print("status code : ${res.statusCode}");
      var jsonResponse = res.body;
      print(jsonResponse);
      final json = jsonDecode(jsonResponse);
      // final signinresponse = SigninResponse.fromJson(json);
      sharedPreferences.setString(Preferences.user_image, json["g_image"]);
      sharedPreferences.setString(Preferences.qrimage, json["qrimage"]);


      if (json == "Invalid No") {
        Get.snackbar(
          "bikeze",
          "Invalid number",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF324A59),
          colorText: Colors.white,
          isDismissible: true,
          // dismissDirection: SnackDismissDirection.HORIZONTAL,
          forwardAnimationCurve: Curves.easeOutBack,
        );
      } else {
        Get.off(() => OtpScreen(number: number,));
      }
    } else {
      Get.snackbar(
        "bikeze.in",
        "Invalid Number",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF324A59),
        colorText: Colors.white,
        isDismissible: true,
        // dismissDirection: SnackDismissDirection.HORIZONTAL,
        forwardAnimationCurve: Curves.easeOutBack,
      );
    }
    setState(() {
      _loading=false;
    });
  }
 bool _loading=false;
  @override
  void initState() {
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
        // CommonDialogs.showGenericToast( 'Failed to get Internet  connectivity.', );
        break;
      default:
        CommonDialogs.showGenericToast( 'Failed to get Internet  connectivity.', );
        break;

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(children: <Widget>[
            const SizedBox(
              height: 280,
            ),
            Row(
              children: const [
                SizedBox(width: 35),
                Text(
                  "LOGIN",
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.black,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                const SizedBox(width: 35),
                Text("Welcome back",
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade400,
                    )),
              ],
            ),
            const SizedBox(height: 30),
            Container(
              height: 250,
              width: 320,
              //  color: Colors.yellow,
              child: Column(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.only(left: 15.0),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black)
                    ),
                    child: Row(
                      children: <Widget>[
                        const Text(
                          "+91",
                          style: const TextStyle(
                              //decoration: TextDecoration.underline,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: const Color(0xff324A59),
                              fontFamily: 'Poppins',
                              decorationColor: Colors.grey),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        const Text("|",
                            style: const TextStyle(
                                color: Colors.black, fontSize: 30)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: TextFormField(
                          cursorColor: Colors.black,
                          controller: mobNumber,

                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "MOB NUMBER",
                            hintStyle: TextStyle(color: Colors.black),
                          ),
                        ))
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),
                  const Expanded(
                      child: const Text(
                    "Please Enter your Registered Mob Number",
                    style: TextStyle(
                      color: Color(0XFF324b5a),
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                      fontFamily: 'Poppins',
                    ),
                  )),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if (mobNumber.text.isEmpty) {
                            Get.snackbar(
                              "bikeze.in",
                              "Please Enter Mob Number",
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: const Color(0xFF324A59),
                              colorText: Colors.white,
                              isDismissible: true,
                              // dismissDirection:
                                  // SnackDismissDirection.HORIZONTAL,
                              forwardAnimationCurve: Curves.easeOutBack,
                            );
                          } else {
                            SignIn(mobNumber.text);
                          }
                        },
                        child: _loading?CircularProgressIndicator(): Icon(Icons.arrow_forward),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.black,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(24),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 150),
            Container(
              //color: Colors.green,
              height: 100,
              width: 320,
              child: Column(
                children: [
                  Row(
                    children: const [
                      Text(
                        "Want to Join With us",
                        style: TextStyle(
                            color: const Color(0xFF324A59),
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            fontSize: 15),
                      ),
                    ],
                  ),
                  Row(
                    children: const [
                      Text("Please contact ",
                          style: TextStyle(
                              color: Color(0xFF324A59),
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              fontSize: 15)),
                      Text("partner@bikeze.in",
                          style: TextStyle(
                              color: Colors.red,
                              fontFamily: 'Poppins',
                              fontSize: 14))
                    ],
                  )
                ],
              ),
            ),
          ]),
        ));
  }
}
