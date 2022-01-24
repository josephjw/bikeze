import 'dart:async';
import 'dart:convert';
import 'package:bikezee/models/profileresponse.dart';
import 'package:bikezee/preference/Constants.dart';
import 'package:bikezee/screens/privacyPolicyScreen.dart';
import 'package:bikezee/theme/style.dart';
import 'package:bikezee/widgets/dialog.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'loginscreen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  String? MobileNumber,
      address = "",
      image,
      qrimage,
      email = "",
      owner = "",
      userId = "",
      l_owner = "",
      l_address = "";
 ProfileResponse profileData=ProfileResponse();

  @override
  void initState() {
    getMobileNumber().whenComplete(() {
      profileData = fetchProfile(MobileNumber!) as ProfileResponse;
    });
    initConnectivity();
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

  String _conec = "";
  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
      case ConnectivityResult.none:
        _conec = "${result.toString()}";
        // CommonDialogs.showGenericToast( 'Failed to get Internet  connectivity.', );
        break;
      default:
        CommonDialogs.showGenericToast(
          'Failed to get Internet  connectivity.',
        );
        break;
    }
  }

  Future getMobileNumber() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();

    String? name = sharedPreferences.getString(Preferences.user_name);
    String? mobile = sharedPreferences.getString(Preferences.mobile);
    String? email = sharedPreferences.getString(Preferences.email);
    String? image = sharedPreferences.getString(Preferences.user_image);
    String? qr = sharedPreferences.getString(Preferences.qrimage);
    String? id = sharedPreferences.getString(Preferences.user_id);
    String? address = sharedPreferences.getString(Preferences.address);

    // print(obtainedNumber);
    setState(() {
      owner = name;
      MobileNumber = mobile;
      this.email = email;
      this.image = image;
      userId = id;
      this.address = address;
      qrimage = qr;
    });
  }

  Future<ProfileResponse> fetchProfile(String mobile) async {
    String url = "https://manyatechnosys.com/bikeze/profile_partner.php";
    var map = new Map<String, dynamic>();
    map['mobile'] = mobile;

    var res = await http.Client().post(Uri.parse(url), body: map);

    if (res.statusCode == 200) {
      print("status : ${res.statusCode}");
      var jsonResponse = res.body;
      print(jsonResponse);
      var json = jsonDecode(jsonResponse);
      print(json);
      List<ProfileResponse> profile = json.map<ProfileResponse>((json) {
        return ProfileResponse.fromJson(json);
      }).toList();
      return profile[0];
    } else {
      throw Exception("failed to load data");
    }
  }

  Future updateProfile(String name, String address) async {
    String url = "https://manyatechnosys.com/bikeze/editprofile.php";
    var map = new Map<String, dynamic>();
    map['mobile_no'] = MobileNumber;
    map['g_name'] = name;
    map['locality'] = address;
    map['p_id'] = userId;
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var res = await http.Client().post(Uri.parse(url), body: map);
    print("status : ${res.body.toString()}");

    if (res.statusCode == 200) {
      sharedPreferences.setString(Preferences.user_name, name);
      sharedPreferences.setString(Preferences.address, address);

      // List<ProfileResponse> profile = json.map<ProfileResponse>((json) {
      //   return ProfileResponse.fromJson(json);
      // }).toList();
      // return profile;
    } else {
      throw Exception("failed to load data");
    }
  }

  @override
  Widget build(BuildContext context) {
    getMobileNumber();
    return Scaffold(
        body: SafeArea(
          child: Container(
            child: Column(
            children: [
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: Icon(Icons.arrow_back),
                  style: ElevatedButton.styleFrom(
                    onPrimary: Color(0xff324A59),
                    primary: Colors.white54,
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(5),
                  ),
                ),
                SizedBox(
                  width: 100,
                ),
                Text("Profile",
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Color(0xff324A59),
                        fontSize: 18,
                        fontWeight: FontWeight.bold))
              ],
            ),
            SizedBox(height: 20),
            Container(
              height: 120,
              width: 300,
              child: Image.network(
                profileData.image?? image ??
                    "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fwallup.net%2Fwp-content%2Fuploads%2F2016%2F01%2F290880-orange-BMW-car-German_car-BMW_M3_GTS.jpg&f=1&nofb=1",
                fit: BoxFit.fill,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                SizedBox(width: 12),
                TextButton(
                  onPressed: () {},
                  child: Icon(
                    Icons.person,
                    color: Color(0xff324A59),
                    size: 30,
                  ),
                  style: ElevatedButton.styleFrom(
                    onPrimary: Color(0xff324A59),
                    primary: Colors.white54,
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(5),
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Garage Name",
                        style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            color: Color(0XFFAAAAAA)),
                      ),
                      Text("${ profileData.g_name ?? owner}",
                          style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              color: Color(0xff324A59))),
                    ],
                  ),
                ),
                IconButton(
                    onPressed: () {
                      Get.defaultDialog(
                          title: "Update Name",
                          content: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 1,
                              ),
                              const Text("Name :",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Poppins',
                                      fontSize: 14)),
                              const SizedBox(
                                height: 10,
                              ),
                              SizedBox(
                                width: 200,
                                child: TextField(
                                  keyboardType: TextInputType.text,
                                  onChanged: (txt) {
                                    l_owner = txt;
                                  },
                                  decoration: InputDecoration(
                                    hintText: "Enter Name",
                                    fillColor: Color(0xffE7E9EB),
                                    filled: true,
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xffE7E9EB))),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xffE7E9EB))),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 25,
                              ),
                              SizedBox(
                                width: 130,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    setState(() {});
                                    updateProfile(l_owner!, address!)
                                        .whenComplete(() {
                                      Navigator.pop(context);
                                    });
                                  },
                                  child: const Text("Update",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Poppins',
                                      )),
                                  style: ElevatedButton.styleFrom(
                                    primary:
                                        const Color(0xff324759), // background
                                    onPrimary: Colors.white, // foreground
                                  ),
                                ),
                              ),
                            ],
                          ));
                    },
                    icon: Icon(
                      Icons.edit,
                      color: Color(0xff324A59),
                      size: 20,
                    ))
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                SizedBox(width: 12),
                TextButton(
                  onPressed: () {},
                  child: Icon(
                    Icons.call,
                    color: Color(0xff324A59),
                    size: 30,
                  ),
                  style: ElevatedButton.styleFrom(
                    onPrimary: Colors.black,
                    primary: Colors.white54,
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(5),
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Mob Number",
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                            color: Color(0XFFAAAAAA)),
                      ),
                      Text("+91 ${profileData.mobile_no ?? MobileNumber}",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                              color: Color(0xff324A59))),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                SizedBox(width: 12),
                TextButton(
                  onPressed: () {},
                  child: Icon(
                    Icons.mail,
                    color: Color(0xff324A59),
                    size: 30,
                  ),
                  style: ElevatedButton.styleFrom(
                    onPrimary: Colors.black,
                    primary: Colors.white54,
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(5),
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Email",
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                            color: Color(0XFFAAAAAA)),
                      ),
                      Text("${profileData.email ?? email}",
                          style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              color: Color(0xff324A59))),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 3,
            ),
            Row(
              children: [
                SizedBox(width: 12),
                TextButton(
                  onPressed: () {},
                  child: Icon(
                    FontAwesomeIcons.mapMarkerAlt,
                    color: Color(0xff324A59),
                    size: 30,
                  ),
                  style: ElevatedButton.styleFrom(
                    onPrimary: Colors.black,
                    primary: Colors.white54,
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(5),
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Garage Location",
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                            color: Color(0XFFAAAAAA)),
                      ),
                      Text(profileData.locality?? address ?? "Garage Location",
                          style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              color: Color(0xff324A59))),
                    ],
                  ),
                ),
                IconButton(
                    onPressed: () {
                      Get.defaultDialog(
                          title: "Update address ",
                          content: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 1,
                              ),
                              const Text("Address :",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Poppins',
                                      fontSize: 14)),
                              const SizedBox(
                                height: 10,
                              ),
                              SizedBox(
                                width: 200,
                                child: TextField(
                                  keyboardType: TextInputType.text,
                                  onChanged: (txt) {
                                    l_address = txt;
                                  },
                                  decoration: InputDecoration(
                                    hintText: "Enter Address",
                                    fillColor: Color(0xffE7E9EB),
                                    filled: true,
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xffE7E9EB))),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xffE7E9EB))),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 25,
                              ),
                              SizedBox(
                                width: 130,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    updateProfile(owner!, l_address!)
                                        .whenComplete(() {
                                      Navigator.pop(context);
                                    });
                                  },
                                  child: const Text("Update",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Poppins',
                                      )),
                                  style: ElevatedButton.styleFrom(
                                    primary:
                                        const Color(0xff324759), // background
                                    onPrimary: Colors.white, // foreground
                                  ),
                                ),
                              ),
                            ],
                          ));
                    },
                    icon: Icon(
                      Icons.edit,
                      color: Color(0xff324A59),
                      size: 25,
                    ))
              ],
            ),
            Expanded(
              child: Container(
                height: 120,
                width: 150,
                //color: Colors.yellow,
                child: Image.network(qrimage ??
                    "https://external-content.duckduckgo.com/iu/?u=http%3A%2F%2Fwww.pngall.com%2Fwp-content%2Fuploads%2F2%2FQR-Code-PNG-Image-HD.png&f=1&nofb=1"),
              ),
            ),
            Text(
              "Scan & Pay now at",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  fontSize: 12),
            ),
            Text(
              "bikezee.IN Private Limited",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  fontSize: 12),
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
                onPressed: () async {

                  Get.defaultDialog(
                    title: "Are You Sure?",
                    content: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 1,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                logout();
                                CommonDialogs.showGenericToast( 'You have successfully logged out.', );
                              },
                              style: ElevatedButton.styleFrom(
                                  primary: HexColor('#181D2D')),
                              child: const Text("YES",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Poppins',
                                      fontSize: 14)),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Get.back();
                              },
                              style: ElevatedButton.styleFrom(
                                primary: HexColor('#181D2D'),
                              ),
                              child: const Text("NO",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Poppins',
                                      fontSize: 14)),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),


                        Padding(
                          padding: EdgeInsets.only(left: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'OTHER SETTINGS:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            Get.to(() => PrivacyPolScreen(),arguments: {
                              {'type': "terms"},
                            });
                          },
                          child: Row(
                            children: [
                              SizedBox(width: 12),
                              TextButton(
                                onPressed: () {},
                                child: Icon(
                                  Icons.room_service,
                                  color: Color(0xff324A59),
                                  size: 20,
                                ),
                                style: ElevatedButton.styleFrom(
                                  onPrimary: Color(0xff324A59),
                                  primary: Colors.white54,
                                  shape: CircleBorder(),
                                  padding: EdgeInsets.all(5),
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                "TERMS & CONDITION",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff324A59),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        InkWell(
                          onTap: (){
                            Get.to(() => PrivacyPolScreen(),arguments: {
                              {'type': "policy"},
                            });
                          },
                          child: Row(
                            children: [
                              SizedBox(width: 12),
                              TextButton(
                                onPressed: () {},
                                child: Icon(
                                  Icons.contact_phone,
                                  color: Color(0xff324A59),
                                  size: 20,
                                ),
                                style: ElevatedButton.styleFrom(
                                  onPrimary: Color(0xff324A59),
                                  primary: Colors.white54,
                                  shape: CircleBorder(),
                                  padding: EdgeInsets.all(5),
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                "PRIVACY POLICY ",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff324A59),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            SizedBox(width: 12),
                            TextButton(
                              onPressed: () {},
                              child: Icon(
                                Icons.info_outlined,
                                color: Color(0xff324A59),
                                size: 20,
                              ),
                              style: ElevatedButton.styleFrom(
                                onPrimary: Color(0xff324A59),
                                primary: Colors.white54,
                                shape: CircleBorder(),
                                padding: EdgeInsets.all(5),
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              "About Us",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff324A59)),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  );
                  // final SharedPreferences sharedPreferences =
                  //     await SharedPreferences.getInstance();
                  // sharedPreferences.remove("MobileNumber");
                  // Get.off(() => LoginScreen());
                },
                style: ElevatedButton.styleFrom(
                  primary: const Color(0xff324759), // background
                  onPrimary: Colors.white, // foreground
                ),
                child: Text(
                  "Log out",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Poppins',
                  ),
                ))
            ],
        ),
          ),
        ));
  }

  Future logout() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.clear();
    Navigator.pop(context);
    Navigator.pop(context);
    Get.to(() => LoginScreen());
    Get.snackbar(
      "bikezee.in",
      "Successfully Signed Out",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF324A59),
      colorText: Colors.white,
      isDismissible: true,
      // dismissDirection: SnackDismissDirection.HORIZONTAL,
      forwardAnimationCurve: Curves.easeOutBack,
    );
  }


}
