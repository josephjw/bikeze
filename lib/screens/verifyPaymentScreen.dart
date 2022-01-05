import 'dart:convert';
import 'dart:ui';

import 'package:bikezopartner/preference/Constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/routes/default_transitions.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slidable_button/slidable_button.dart';
import 'package:maps_launcher/maps_launcher.dart';

import 'package:bikezopartner/screens/profilescreen.dart';
import 'package:http/http.dart' as http;

class VerifyPaymentScreen extends StatefulWidget {
  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<VerifyPaymentScreen> {
  dynamic argumentData = Get.arguments;

  final ImagePicker picker = ImagePicker();


  bool _loading=false;
  @override
  void initState() {
    super.initState();

    getProfile().whenComplete(() {
      paymentVerify();
    });
  }
  String userName = " ",userid='',package="",
  est_price= "",
  total= "",
  total_payable=" ",
  status="";

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

  Future updatePayment() async {
    final SharedPreferences sharedPreferences =
    await SharedPreferences.getInstance();
    sharedPreferences.setBool( argumentData[0]["leadId"], true);

  }


  getImageFromGallery() async {
    final XFile? image = await picker.pickImage(
        source: ImageSource.gallery, maxHeight: 500, maxWidth: 500);
  }

  getImagefromCamera() async {
    final XFile? photo = await picker.pickImage(
        source: ImageSource.camera, maxHeight: 500, maxWidth: 500);
  }

  Future<void> paymentVerify() async {
    String url = "https://manyatechnosys.com/bikezo/verify_payment.php";
    var map = new Map<String, String>();

    map['lead_id'] =  argumentData[0]["leadId"]?? "5" ;
    map['assign'] =userid ;
    print("userid"+userid );
    _loading=false;

    var res = await http.Client().post(Uri.parse(url),body: map);
    if (res.statusCode == 200) {
      print("status : ${res.statusCode}");
      var jsonResponse = res.body;

      try{
      final json = jsonDecode(jsonResponse);

      setState(() {
        package=json['package'];
        est_price=json['est_price'];
        total=json['total'];
        total_payable=json['total_payable'];
        status=json['payment_status'];

      });

      }catch(e){
        print(e);

      }
      // userid
      print(jsonResponse);
    _loading=true;
    } else {
      throw Exception('failed to load data');
    }
    _loading=true;

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: !_loading?
            Column(
mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 75,
                ),
                Center(child: CircularProgressIndicator()),
              ],
            ) :package!=""?Column(
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
                const Text("VERIFY CUSTOMER PAYMENT",
                    style: TextStyle(
                        color: Color(0xff324A59),
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Container(
                  width: 300,
                  // color: Colors.yellow,
                  child:
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Package Selected",
                              style: TextStyle(
                                  color: Color(0xff324A59),
                                  fontFamily: 'Poppins',
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),

                          Text(
                            "\u{20B9} ${package}",
                            style: TextStyle(
                                color: Color(0xff324A59),
                                fontFamily: 'Poppins',
                                fontSize: 17,
                                fontWeight: FontWeight.bold),
                          ),

                          Text(
                            " ( ${status} )",
                            style: TextStyle(
                                color: status!="Not Paid"?Colors.green:Colors.red,
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),

                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Estimated Price",
                              style: TextStyle(
                                  color: Color(0xff324A59),
                                  fontFamily: 'Poppins',
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),

                          Text(
                            "\u{20B9}  ${est_price}",
                            style: TextStyle(
                                color: Color(0xff324A59),
                                fontFamily: 'Poppins',
                                fontSize: 17,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Total Price",
                              style: TextStyle(
                                  color: Color(0xff324A59),
                                  fontFamily: 'Poppins',
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),

                          Text(
                            " \u{20B9} ${total}",
                            style: TextStyle(
                                color: Color(0xff324A59),
                                fontFamily: 'Poppins',
                                fontSize: 17,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),


                      const SizedBox(
                        height: 40,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            "TOTAL PAYABLE",
                            style: TextStyle(
                                color: Color(0xff324A59),
                                fontFamily: 'Poppins',
                                fontSize: 17,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 10,
                          ),

                          Text(
                            " \u{20B9} ${total_payable}",
                            style: TextStyle(
                                color: Color(0xff324A59),
                                fontFamily: 'Poppins',
                                fontSize: 17,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),


                      const SizedBox(
                        height: 10,
                      ),

                    ],
                  ),
                ),
                const SizedBox(
                  width: 35,
                ),

                Container(
                  child: SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: ()async {
                        SharedPreferences sharedPreferences =
                        await SharedPreferences.getInstance();
                         sharedPreferences.setBool(argumentData[6]['leadId']+"pay", true);
                        Get.back();


                      },
                      child: const Text(" Payment Verified ",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                          )),
                      style: ElevatedButton.styleFrom(
                        primary: const Color(0xff324759), // background
                        onPrimary: Colors.white, // foreground
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),

                Container(
                  height: 120,
                  width: 150,
                  //color: Colors.yellow,
                  child: Image.network(
                      "https://external-content.duckduckgo.com/iu/?u=http%3A%2F%2Fwww.pngall.com%2Fwp-content%2Fuploads%2F2%2FQR-Code-PNG-Image-HD.png&f=1&nofb=1"),
                ),
                Text(
                  "Scan & Pay now at",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontFamily: 'Poppins', fontSize: 12),
                ),
              ],
            ):Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 45,
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
                  Image.network("https://www.pngkey.com/png/full/846-8466599_list-is-empty.png"),
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: Text("No Data",style: TextStyle(fontSize: 16),)),
                ],
              ),
            )
           ,
          ),
        ),
      ),
    );
  }
}
