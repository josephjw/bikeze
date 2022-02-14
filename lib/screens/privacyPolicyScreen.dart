import 'dart:convert';
import 'dart:ui';
import 'package:bikeze/preference/Constants.dart';
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
  final String type;

  const PrivacyPolScreen({Key? key, this.type="terms"}) : super(key: key);
  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<PrivacyPolScreen> {
  dynamic argumentData = Get.arguments;
  bool _loading =false;

  final ImagePicker picker = ImagePicker();


  @override
  void initState() {
    super.initState();

    paymentVerify();
  }
  String userName = " ",userid='';

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
    setState(() {
      _loading=true;
    });
    String url = widget.type=="aboutus"?"https://manyatechnosys.com/bikeze/aboutus.php":widget.type=="terms"?"https://manyatechnosys.com/bikeze/terms_condtions.php":"https://manyatechnosys.com/bikeze/privacy_policy.php";
    var res = await http.Client().post(Uri.parse(url));
    if (res.statusCode == 200) {
      print("status : ${res.statusCode}");
      var jsonResponse = res.body;
      final json = jsonDecode(jsonResponse);
      setState(() {
        policy=json[0]["description"];

      });
      print(jsonResponse);

    } else {
      throw Exception('failed to load data');
    }
    setState(() {
      _loading=false;
    });
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
                   _loading?Center(child: CircularProgressIndicator()): Wrap(
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
