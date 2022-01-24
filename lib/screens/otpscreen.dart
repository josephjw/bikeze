import 'dart:async';
import 'dart:convert';

import 'package:bikezopartner/preference/Constants.dart';
import 'package:bikezopartner/preference/shared_preference_helper.dart';
import 'package:bikezopartner/screens/homescreen.dart';
import 'package:bikezopartner/widgets/dialog.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OtpScreen extends StatefulWidget {
  final String number;
  const OtpScreen({Key? key,required this.number}) : super(key: key);

  @override
  _OtpScreenState createState() => _OtpScreenState(number: number);
}

class _OtpScreenState extends State<OtpScreen> {
  TextEditingController otpNumber = TextEditingController();
  String? OTPPIN,_fcm;
  SharedPreferenceHelper pref =SharedPreferenceHelper() ;
  final String number;
  _OtpScreenState({required this.number});
  SignIn(String number) async {

    setState(() {
      _loading=true;
    });
    String url = "https://manyatechnosys.com/bikezee/mobile_verification.php";
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
          "bikezee",
          "Invalid number",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF324A59),
          colorText: Colors.white,
          isDismissible: true,
          // dismissDirection: SnackDismissDirection.HORIZONTAL,
          forwardAnimationCurve: Curves.easeOutBack,
        );
      }
      // else {
      //   Navigator.pop(context);
      //   Get.to(() => OtpScreen());
      // }
    } else {
      Get.snackbar(
        "bikezee.in",
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


  late Timer _timer;
  int _start = 30;

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
          (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  void firebaseCloudMessaging_Listeners() {
    // if (Platform.isIOS) iOS_Permission();

    _firebaseMessaging.getToken().then((token){
      _fcm=token;
      print("toekn"+token!);
    });


  }

  otpVerify(String pin) async {
    setState(() {
      _loading=true;
    });
    String url = "https://manyatechnosys.com/bikezee/otp_verification.php";
    var map = Map<String, dynamic>();
    final SharedPreferences sharedPreferences =
    await SharedPreferences.getInstance();
    map['otp'] = pin;
    map['fcm'] = _fcm;

    var res = await http.Client().post(Uri.parse(url), body: map);
    var jsonResponse = res.body;
    print(jsonResponse);
    final json = jsonDecode(jsonResponse);
    print(json);
    if (res.statusCode == 200) {
      print("status code : ${res.statusCode}");
      if (json == "Invalid OTP") {
        Get.snackbar(
          "bikezee.in",
          " Invalid OTP",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF324A59),
          colorText: Colors.white,
          isDismissible: true,
          // dismissDirection: SnackDismissDirection.HORIZONTAL,
          forwardAnimationCurve: Curves.easeOutBack,
        );
      } else {
        sharedPreferences.setString(Preferences.email, json["email"]);
        sharedPreferences.setString(Preferences.mobile, json["mobile_no"]);
        sharedPreferences.setString(Preferences.user_name, json["owner_name"]);
        sharedPreferences.setString(Preferences.address, json["locality"]+json["city"]);
        sharedPreferences.setString(Preferences.user_id, json["p_id"]);
        // sharedPreferences.setString(Preferences.user_image, json["g_image"]);

        Navigator.pop(context);
        Get.off(() => HomeScreen());
        Get.snackbar(
          "bikezee.in",
          "Successfully Signed in",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF324A59),
          colorText: Colors.white,
          isDismissible: true,
          // dismissDirection: SnackDismissDirection.HORIZONTAL,
          forwardAnimationCurve: Curves.easeOutBack,
        );
      }
    } else {
      Get.snackbar(
        "bikezee.in",
        "Invalid OTP",
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


  @override
  void initState() {
    super.initState();
    startTimer();
    _firebaseMessaging= FirebaseMessaging.instance;
    firebaseCloudMessaging_Listeners();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
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


  late FirebaseMessaging _firebaseMessaging;
  init()async{
    SharedPreferenceHelper().init(await SharedPreferences.getInstance());
    pref.init(await SharedPreferences.getInstance());
  }
  bool _loading=false;

  @override
  Widget build(BuildContext context) {
    initConnectivity();
    return Scaffold(
      backgroundColor: const Color(0XFFfbfafb),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const SizedBox(
              height: 100,
            ),
            Center(
              child: Container(
                  height: 220,
                  width: 320,
                  //color: Colors.yellow,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextButton(
                        onPressed: () {
                          Get.back();
                        },
                        child: const Icon(Icons.arrow_back),
                        style: ElevatedButton.styleFrom(
                          onPrimary: Colors.black,
                          primary: Colors.white54,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(5),
                        ),
                      ),
                      const SizedBox(
                        height: 95,
                      ),
                      const Text("    Verification",
                          style: TextStyle(
                              fontSize: 25,
                              color: Color(0xff181D2D),
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),
                      const Text('      Enter the OTP code we sent you',
                          style: TextStyle(
                              color: Colors.grey,
                              fontFamily: 'Poppins',
                              fontSize: 17))
                    ],
                  )),
            ),
            const SizedBox(
              height: 20,
            ),
            OtpTextField(
              numberOfFields: 4,
              fillColor: const Color(0xff324759),
              showFieldAsBox: true,
              filled: true,
              borderColor: const Color(0xff324759),
              focusedBorderColor: const Color(0xff324759),
              enabledBorderColor: const Color(0xff324759),
              cursorColor: Colors.white,
              textStyle: const TextStyle(color: Colors.white),
              borderRadius: const BorderRadius.all(Radius.circular(12.0)),
              onSubmit: (String pin) {
                print(pin);
                // otpVerify(pin);
                OTPPIN = pin;
              },
            ),
            const SizedBox(
              height: 20,
            ),
            (_start!=0)?
            Text(
              "Resend in 00:${_start.toString().padLeft(2,'0')}",
              style: TextStyle(
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  fontSize: 15),
            ):
            GestureDetector(
              onTap: (){
                SignIn(number);
                setState(() {
                  _start=30;
                });
                startTimer();
              },
              child: Container(
                child: Text(
                  "Resend OTP",
                  style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      fontSize: 15,
                    decoration: TextDecoration.underline
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 90,
            ),
            Row(children: [
              const SizedBox(
                width: 250,
              ),
              ElevatedButton(
                onPressed: () {
                  if (OTPPIN == null) {
                    Get.snackbar(
                      "bikezee",
                      "Please Enter OTP",
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: const Color(0xFF324A59),
                      colorText: Colors.white,
                      isDismissible: true,
                      // dismissDirection: SnackDismissDirection.HORIZONTAL,
                      forwardAnimationCurve: Curves.easeOutBack,
                    );
                  } else if (OTPPIN != null) {
                    otpVerify(OTPPIN!);
                  }
                },
                child: _loading?CircularProgressIndicator(): Icon(Icons.arrow_forward),
                style: ElevatedButton.styleFrom(
                  primary: const Color(0xff324759),
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(20),
                ),
              )
            ])
          ],
        ),
      ),
    );
  }
}
