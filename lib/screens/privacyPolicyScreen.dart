import 'dart:convert';
import 'dart:ui';

import 'package:bikezopartner/preference/Constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

class PrivacyPolScreen extends StatefulWidget {
  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<PrivacyPolScreen> {
  dynamic argumentData = Get.arguments;

  final ImagePicker picker = ImagePicker();


  @override
  void initState() {
    super.initState();

    getProfile();
    paymentVerify();
  }
  String userName = " ",userid='';

  Future getProfile() async {
    final SharedPreferences sharedPreferences =
    await SharedPreferences.getInstance();

    String? name = sharedPreferences.getString(Preferences.user_name);
    String? id = sharedPreferences.getString(Preferences.user_id);

    // print(obtainedNumber);
    setState(() {

      userName= name!;
      userid=id!;
    });
  }
 String policy ="At BikeDekho, we value our customers and are committed to protecting your privacy, as well as safeguarding the information we receive and maintain about you. We do not sell information about you to others. We only share it as expressly allowed by law. Consequently, you do not need to notify us not to share information about you, because we have chosen to limit this for you. This Notice will help you understand what information we collect, how we use it, and the ways we maintain your privacy and the security of personal information about you.";

  getImageFromGallery() async {
    final XFile? image = await picker.pickImage(
        source: ImageSource.gallery, maxHeight: 500, maxWidth: 500);
  }

  getImagefromCamera() async {
    final XFile? photo = await picker.pickImage(
        source: ImageSource.camera, maxHeight: 500, maxWidth: 500);
  }

  Future<void> paymentVerify() async {
    String url = argumentData[0]["type"]=="terms"?"https://manyatechnosys.com/bikezee/terms_condtions.php":"https://manyatechnosys.com/bikezee/privacy_policy.php";
    var res = await http.Client().post(Uri.parse(url));
    if (res.statusCode == 200) {
      print("status : ${res.statusCode}");
      var jsonResponse = res.body;
      final json = jsonDecode(jsonResponse);
      setState(() {
        policy=json["description"];

      });
      print(jsonResponse);

    } else {
      throw Exception('failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 65,
              ),

              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: const Icon(Icons.close_rounded,size: 30,),
                  style: ElevatedButton.styleFrom(
                    onPrimary: Colors.black,
                    primary: Colors.white54,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(5),
                  ),
                ),
              ),
              const SizedBox(
                height: 25,
              ),

              Container(
                width:300,
                // color: Colors.yellow,
                child:
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Wrap(
                      children:[ Text(
                        policy,
                        style: TextStyle(
                            color: Color(0xff324A59),
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ),]
                    ),





                  ],
                ),
              ),
              const SizedBox(
                width: 35,
              ),

            ],
          ),
        ),
      ),
    );
  }
}
