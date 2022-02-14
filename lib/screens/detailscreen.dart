import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:bikeze/screens/fullscreenImage.dart';
import 'package:bikeze/screens/verifyPaymentScreen.dart';
import 'package:bikeze/permissions/permission_utils.dart';
import 'package:bikeze/preference/Constants.dart';
import 'package:bikeze/screens/verifyPaymentScreen.dart';
import 'package:bikeze/theme/style.dart';
import 'package:bikeze/widgets/dialog.dart';
import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:slide_to_act/slide_to_act.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart' as gt;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:multi_image_picker2/multi_image_picker2.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slidable_button/slidable_button.dart';
import 'package:maps_launcher/maps_launcher.dart';

class DetailScreen extends StatefulWidget {

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  dynamic argumentData = gt.Get.arguments;
  String estprice= "000";
  final ImagePicker picker = ImagePicker();
   late TextEditingController _controller ;


  @override
  void initState() {
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    _controller = TextEditingController();


    loadder = ProgressDialog(context: context);
    getProfile();
  }
  String userName = " ",userid='';

  Future getProfile() async {
    final SharedPreferences sharedPreferences =
    await SharedPreferences.getInstance();
    prefs = await SharedPreferences.getInstance();

    String? name = sharedPreferences.getString(Preferences.user_name);
    String? id = sharedPreferences.getString(Preferences.user_id);
    bool? upload = sharedPreferences.getBool(argumentData[6]['leadId']+"upload");
    bool? estimation = sharedPreferences.getBool(argumentData[6]['leadId']+"estimation");
    bool? pay = sharedPreferences.getBool(argumentData[6]['leadId']+"pay");

    // print(obtainedNumber);
    setState(() {
      verifypay=pay??false;
      userName= name!;
      userid=id!;
      esti_status=estimation ??argumentData[8]['ebool'];
      this.upload=upload ?? argumentData[9]['ibool'];
    });
  }
bool esti_status = false,verifypay = false,upload = false;

  getImageFromGallery() async {
    // List<Asset> resultList = <Asset>[];
    // List<Asset> images = <Asset>[];
    // PermissionUtils().checkAndRequestPermission(context, PERMISSION_TYPE.GALLERY, true, (status) async {
    //
    //   if (status == PERMISSION_STATUS.GRANTED) {
    //     resultList = await MultiImagePicker.pickImages(
    //       maxImages: 300,
    //     );
    //   }
    // });
    //  List<Asset> image = await MultiImagePicker.pickImages(
    //    maxImages: 10);
  PermissionUtils().checkAndRequestPermission(context,
        PERMISSION_TYPE.GALLERY,
        true,
        (val)async{
          List<XFile>? image = await picker.pickMultiImage(maxHeight: 500, maxWidth: 500);

          uploadToServer(null,image!);
        });



  }
  List<Asset> images = <Asset>[];

  Future<void> loadAssets() async {
    List<Asset> resultList = <Asset>[];
    String error = 'No Error Detected';

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 300,
        enableCamera: true,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(
          takePhotoIcon: "chat",
          doneButtonTitle: "Fatto",
        ),
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: "Example App",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      error = e.toString();
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      images = resultList;
      // _error = error;
    });
  }
  getImagefromCamera() async {


    final XFile? photo = await picker.pickImage(
        source: ImageSource.camera, maxHeight: 500, maxWidth: 500);
if(photo!=null){
  uploadToServer(File(photo.path),[]);

}
  }

  Future<void> completePayment() async {
    String url = "https://manyatechnosys.com/bikeze/complete_lead.php";
    var map = new Map<String, String>();

    map['lead_id'] = argumentData[6]['leadId'] ?? "4" ;
    map['assign'] = userid;

    var res = await http.Client().post(Uri.parse(url),body: map);
    if (res.statusCode == 200) {
      print("status : ${res.statusCode}");
      var jsonResponse = res.body;
      // final json = jsonDecode(jsonResponse).cast<Map<String, dynamic>>();

      print(jsonResponse);

    } else {
      throw Exception('failed to load data');
    }
  }

  Future<void> estimationPrice() async {
    String url = "https://manyatechnosys.com/bikeze/estimation_price.php";
    var map = new Map<String, String>();

    map['lead_id'] = argumentData[6]['leadId'] ?? "4" ;
    map['assign'] = userid;
    map['amount'] = estprice;

    var res = await http.Client().post(Uri.parse(url),body: map);
    if (res.statusCode == 200) {
      print("status : ${res.statusCode}");
      print("parameters : ${map.toString()}");

      var jsonResponse = res.body;
      // final json = jsonDecode(jsonResponse).cast<Map<String, dynamic>>();

      print(jsonResponse);

    } else {
      throw Exception('failed to load data');
    }
  }
  DateTime now = DateTime.now();
  // String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(now);
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
  List<File> _after =[];

  List<String> imags=[];
  Future<void> getimage() async {
    String url = "https://manyatechnosys.com/bikeze/checkinview_image.php";
    var map = new Map<String, String>();

    map['lead_id'] = argumentData[6]['leadId'];
    var res = await http.Client().post(Uri.parse(url),body: map);
    if (res.statusCode == 200) {
      // print("status : ${res.statusCode}");
      var jsonResponse = res.body;
      final json = jsonDecode(jsonResponse);
      // print("https://manyatechnosys.com/bikezo/getonline_offline.php"+jsonResponse);
      setState(() {
        // imags= json['images'] as List<String>;

        for(int i =0;i<json['images'].length;i++){
          imags.add(json['images'][i]);
          print("images ${json['images'][i]}");
        }


      });

    } else {
      throw Exception('failed to load data');
    }
  }


  @override
  Widget build(BuildContext context) {
    initConnectivity();
    getProfile();
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                TextButton(
                  onPressed: () {
                    gt.Get.back();
                  },
                  child: const Icon(Icons.arrow_back),
                  style: ElevatedButton.styleFrom(
                    onPrimary: Colors.black,
                    primary: Colors.white54,
                    shape: const CircleBorder(),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text("  Service Status",
                    style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        height: 100,
                        // color: Colors.yellow,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${argumentData[0]['name']}",
                                style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 19,
                                    color: Colors.black),
                              ),
                              const SizedBox(width: 2),
                              const SizedBox(
                                width: 2,
                              ),
                              const SizedBox(height: 2),
                              const Text("General Service",
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0XFFAAAAAA))),
                              const SizedBox(height: 5),
                              Row(
                                children:  [
                                  Icon(FontAwesomeIcons.calendarDay,
                                      size: 16,
                                      color: Color(0XFFAAAAAA)),
                                  SizedBox(
                                    width: 6,
                                  ),
                                  Text(
                                    argumentData[7]['date'],
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        color: Color(0XFFAAAAAA)),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                "${argumentData[2]['vehicle']}",
                                style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13,
                                    color: Color(0XFFAAAAAA)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    Container(
                      padding: EdgeInsets.only(top: 20),
                      child: SizedBox(
                        height: 25,
                        child: ElevatedButton(
                          onPressed: () {
                            FlutterPhoneDirectCaller.callNumber(argumentData[5]['mobile']);

                          },
                          child: const Text(" Customer Contact ",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontFamily: 'Poppins',
                              )),
                          style: ElevatedButton.styleFrom(
                            primary: HexColor('#EE7D59'), // background
                            onPrimary: Colors.white, // foreground
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  // height: 150,
                  // width: 340,
                  //color: Colors.yellow,
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: HexColor('#EE7D59'),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        "Customer Service Summary",
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                      const SizedBox(height: 7),
                      const Text(
                        "Selected Service : General Service",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        "Package Selected :  \u{20B9} ${argumentData[1]['package']}",
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Customer Remarks :",
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 40,
                              width: 30,
                              //color: Colors.yellow,
                              child: Text(
                                " ${argumentData[3]['remarks']}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(

                  padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: HexColor('#EE7D59'),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2),
                      const Text(
                        "Pickup details",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            color: Colors.white),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Current Location:  ",
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          Expanded(
                            child: Container(
                              height: 40,
                              width: 40,
                              //color: Colors.yellow,
                              child: Text("${argumentData[4]['location']}",
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold,
                                      color:Colors.white)),
                            ),
                          ),
                        ],
                      ),
                      Center(

                        child:
                        Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: SizedBox(
                            height: 30,

                            child: ElevatedButton.icon(

                              onPressed: () {
                                MapsLauncher.launchQuery(
                                    "${argumentData[4]['location']}");
                              },
                              icon:  Icon(FontAwesomeIcons.mapMarkerAlt,size: 16,
                                  color:HexColor('#EE7D59')),
                              label:  Text(
                                " View Map ",
                                style: TextStyle(
                                  color:HexColor('#EE7D59'),
                                  fontFamily: 'Poppins',
                                  fontSize: 16
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.white, // background
                                onPrimary: Colors.white, // foreground
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  "Service Progress Update",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      fontSize: 14),
                ),
                const SizedBox(
                  height: 20,
                ),
                InkWell(
                  onTap: () {
    if( !upload){
      gt.Get.bottomSheet(
          SizedBox(
            height: 150,
            child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        getImagefromCamera();
                      },
                      icon: const Icon(
                        Icons.camera,
                      ),
                      label: const Text("Camera"),
                      style: ElevatedButton.styleFrom(
                          primary: const Color(0xff324A59)),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        getImageFromGallery();
                        // loadAssets();
                      },
                      icon: const Icon(
                        Icons.image,
                      ),
                      label: const Text("Image"),
                      style: ElevatedButton.styleFrom(
                          primary: const Color(
                              0xff324A59) //elevated btton background color
                      ),
                    ),
                  ],
                )),
          ),
          enableDrag: true,
          backgroundColor: Colors.white
      );

    // gt.Get.defaultDialog(
    //                     title: "",
    //                     content: Center(
    //                         child: Row(
    //                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //                       children: [
    //                         ElevatedButton.icon(
    //                           onPressed: () {
    //                             getImagefromCamera();
    //                           },
    //                           icon: const Icon(
    //                             Icons.camera,
    //                           ),
    //                           label: const Text("Camera"),
    //                           style: ElevatedButton.styleFrom(
    //                               primary: const Color(0xff324A59)),
    //                         ),
    //                         ElevatedButton.icon(
    //                           onPressed: () {
    //                             getImageFromGallery();
    //                             // loadAssets();
    //                           },
    //                           icon: const Icon(
    //                             Icons.image,
    //                           ),
    //                           label: const Text("Image"),
    //                           style: ElevatedButton.styleFrom(
    //                               primary: const Color(
    //                                   0xff324A59) //elevated btton background color
    //                               ),
    //                         ),
    //                       ],
    //                     )));
    }
                  },
                  child: Center(
                    child: Container(
                        height: 80,
                        width: 320,
                        //color: Colors.yellow,
                        decoration: BoxDecoration(
                          border: Border.all(
                              width: 0.5, color: const Color(0xFFAAAAAA)),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 20),
                             Icon(
                              Icons.image,
                              size: 40,
                              color: !upload ? HexColor('#EE7D59').withOpacity(0.5):HexColor('#EE7D59'),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Column(
                                children: const [
                                  SizedBox(
                                    height: 18,
                                  ),
                                  Text(
                                    "Step 1",
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w300,
                                        fontFamily: 'Poppins',
                                        color: Color(0xFFAAAAAA)),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text("Check In",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w300,
                                        fontFamily: 'Poppins',
                                      ))
                                ],
                              ),
                            ),

                             Icon(
                              FontAwesomeIcons.solidCheckCircle,
                              color: upload  ?HexColor('#EE7D59'):Colors.grey,
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                          ],
                        )),
                  ),
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () {
                   if( !esti_status){

                    gt.Get.defaultDialog(
                        title: "",
                        content: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const SizedBox(
                              height: 1,
                            ),
                            const Text("ESTIMATED PRICE",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Poppins',
                                    fontSize: 20)),
                            const SizedBox(
                              height: 20,
                            ),
                             SizedBox(
                              width: 200,
                              child: TextField(

                                keyboardType: TextInputType.number,
                               onChanged: (txt){
                                  setState(() {
                                    estprice=txt;
                                  });

                               },
                                decoration: InputDecoration(
                                  hintText: "Enter Amount",
                                  fillColor: Color(0xffE7E9EB),
                                  filled: true,

                                  enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Color(0xffE7E9EB))),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Color(0xffE7E9EB))),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 25,
                            ),
                            SizedBox(
                              width: 130,
                              child: ElevatedButton(
                                onPressed: ()async {
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
                                              onPressed: () async{
                                                esti_status=false;
                                                SharedPreferences sharedPreferences =
                                                    await SharedPreferences.getInstance();

                                                await estimationPrice().whenComplete(() {
                                                  setState(() {
                                                    esti_status=true;
                                                  });
                                                  sharedPreferences.setBool(argumentData[6]['leadId']+"estimation", true);

                                                });
                                                Get.back();
                                                Navigator.pop(context);
                                                CommonDialogs.showGenericToast( 'You have successfully updated price.', );
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
                                                Navigator.pop(context);
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
                                      ],
                                    ),
                                  );



                                },
                                child: const Text("UPDATE PRICE",
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
                          ],
                        ));}
                  },
                  child: Center(
                    child: Container(
                        height: 80,
                        width: 320,
                        //color: Colors.yellow,
                        decoration: BoxDecoration(
                          border: Border.all(
                              width: 0.5, color: const Color(0xFFAAAAAA)),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 20),
                             Icon(
                              FontAwesomeIcons.fileInvoice,
                              size: 35,
                                color: !esti_status ?HexColor('#EE7D59').withOpacity(0.5):HexColor('#EE7D59')
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Column(
                                children:  [
                                  SizedBox(
                                    height: 14,
                                  ),
                                  Text(
                                    "Step 2",
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w300,
                                        color: Color(0xFFAAAAAA)
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text("Estimate Price",
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w300,
                                      ))
                                ],
                              ),
                            ),

                            esti_status ?

                            Icon(
                                FontAwesomeIcons.solidCheckCircle,
                                color: HexColor('#EE7D59')
                            ): Icon(FontAwesomeIcons.solidCheckCircle,color: Colors.grey,),
                            const SizedBox(width: 20),

                          ],
                        )),
                  ),
                ),

                upload?
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Check-in Images :",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          fontSize: 14),
                    ),

                    Container(
                      height: 50,
                      margin: EdgeInsets.only(left :20,top :12),
                      child: ListView.separated(
                          separatorBuilder: (BuildContext context, int index) =>
                              SizedBox(height: 10,width: 20,),
                          shrinkWrap: true,
                          // reverse: true,
                          physics: NeverScrollableScrollPhysics(),
                          scrollDirection: Axis.horizontal,

                          itemCount: _after.length==0? imags.length: _after.length,
                          itemBuilder: (BuildContext context, index) {
                            // if (      _oleads[index].booking_date != date
                            // ) {
                            return Center(
                                child: InkWell(
                                  onTap: () {

                                    Get.to(()=>FullscreenImage(fileimage:_after.isNotEmpty? _after[index]?.path:null,qrimage:imags.isNotEmpty? imags[index]:null,));
                                    // Get.to(() => DetailScreen(), arguments: [
                                    //   {'name': _oleads[index].user_name},
                                    //   {'package': _oleads[index].package},
                                    //   {'vehicle': _oleads[index].vehicle},
                                    //   {'remarks': _oleads[index].remarks},
                                    //   {'location': _oleads[index].location},
                                    //   {'mobile': _oleads[index].mobile_no},
                                    //   {'leadId': _oleads[index].lead_id},
                                    //   {'date': _oleads[index].booking_date},
                                    //   {'ebool': _oleads[index].est_price_boolval},
                                    //   {'ibool': _oleads[index].image_boolval}
                                    // ]);
                                  },
                                  child: Container(
                                    // height: 100,
                                    //   color: Colors.white,
                                    decoration: BoxDecoration(
                                        color:  Color(0xFF324A59),
                                        borderRadius: BorderRadius.circular(12)),
                                    child:_after.length==0?Image.network(imags[index],width: 50,):  Image.file(_after[index],width: 50,height: 100,
                                    ),
                                  ),
                                ));
                            // }
                            // else {
                            //   return SizedBox.shrink();
                            // }
                          }),
                    )

                  ],)


                    :Container(),

                const SizedBox(
                  height: 10,
                ),
                InkWell(
                  onTap: () async{
                    SharedPreferences sharedPreferences =
                        await SharedPreferences.getInstance();
                    if(esti_status&upload){
                      // setState(() {
                      //   verifypay=true;
                      //
                      // });


                    gt.Get.to(() => VerifyPaymentScreen(), arguments: [
                      {'leadId': argumentData[6]['leadId']},
                      {'estimatedPrice': estprice},
                      {'assign': argumentData[10]['assign']}

                    ]);
                  }else{
                      gt.Get.snackbar(
                        "bikeze",
                        " Please Provide Estimation price.",
                        snackPosition: gt.SnackPosition.BOTTOM,
                        backgroundColor: const Color(0xFF324A59),
                        colorText: Colors.white,
                        isDismissible: true,
                        // dismissDirection: gt.SnackDismissDirection.HORIZONTAL,
                        forwardAnimationCurve: Curves.easeOutBack,
                      );
                    }
                  },
                  child: Center(
                    child: Container(
                        height: 80,
                        width: 320,
                        //color: Colors.yellow,
                        decoration: BoxDecoration(
                          border: Border.all(
                              width: 0.5, color: const Color(0xFFAAAAAA)),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 20),
                             Icon(
                              FontAwesomeIcons.creditCard,
                              size: 35,
                              color: !verifypay ? HexColor('#EE7D59').withOpacity(0.5):HexColor('#EE7D59'),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Column(
                                children: const [
                                  SizedBox(
                                    height: 14,
                                  ),
                                  Text(
                                    "Step 3",
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w300,
                                        color: Color(0xFFAAAAAA)),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text("  Verify Payment",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w300,
                                        fontFamily: 'Poppins',
                                      )),
                                ],
                              ),
                            ),
                            verifypay ?

                            Icon(
                                FontAwesomeIcons.solidCheckCircle,
                                color: HexColor('#EE7D59')
                            ):
                            Icon(FontAwesomeIcons.solidCheckCircle,color: Colors.grey,),
                            const SizedBox(width: 20),
                          ],
                        )),
                  ),
                ),
                const SizedBox(height: 20),

                  Center(
                    child: SlideAction(
                    innerColor:Colors.white,
                    height: 50,
                    key: _key,
                    outerColor:const Color(0xff324759) ,
                    sliderButtonIconSize: 16,
                    reversed: false,
                    child: const Center(
                        child: Text("SWIPE TO FINISH",
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700))),
                    onSubmit: (){
                        if(esti_status&&verifypay){

                          completePayment().whenComplete(() {

                            gt.Get.defaultDialog(
                              title: "",
                                content: Container(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [

                                      Container(
                                        height: 70,
                                        width: 70,
                                        child: Image.asset(
                                            'assets/images/greentick.png'),
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(50)),
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      Text(
                                        "Thank you!!",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        "Successfully Completed",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.bold),
                                      )
                                    ],
                                  ),
                                ));


                          });
                          CommonDialogs.showGenericToast( 'Lead successfully completed.', );
                          Future.delayed(const Duration(milliseconds: 3000), () {

                            Navigator.pop(context);
                            Navigator.pop(context);

                          });

                        }else{
                          gt.Get.snackbar(
                            "bikeze",
                            " Please Fill all.",
                            snackPosition: gt.SnackPosition.BOTTOM,
                            backgroundColor: const Color(0xFF324A59),
                            colorText: Colors.white,
                            isDismissible: true,
                            // dismissDirection: gt.SnackDismissDirection.HORIZONTAL,
                            forwardAnimationCurve: Curves.easeOutBack,
                          );
                          _key.currentState?.reset();
                        }
                    },

                ),
                  ),
                // Center(
                //   child: SlidableButton(
                //     width: double.infinity,
                //     height: 50,
                //     buttonWidth: 10.0,
                //     key: _key,
                //
                //     border: Border.all(color: const Color(0xff324759)),
                //     label: const Icon(Icons.arrow_forward),
                //     buttonColor: Colors.white,
                //     color: const Color(0xff324759),
                //     child: const Center(
                //         child: Text("SWIPE TO FINISH",
                //             style: TextStyle(
                //                 fontFamily: 'Poppins',
                //                 color: Colors.white,
                //                 fontSize: 15,
                //                 fontWeight: FontWeight.w700))),
                //     dismissible: true,
                //     onChanged: (position) {
                //       setState(() {
                //         if (position == SlidableButtonPosition.right) {
                //           if(esti_status&&verifypay){
                //
                //             completePayment().whenComplete(() {
                //               gt.Get.defaultDialog(
                //                   title: "",
                //                   content: Container(
                //                     child: Column(
                //                       children: [
                //                         Align(
                //                           alignment: Alignment.topRight,
                //                           child: TextButton(
                //                             onPressed: () {
                //                               Navigator.pop(context);
                //                               gt.Get.back();
                //                             },
                //                             child: const Icon(Icons.close_rounded,size: 30,),
                //                             style: ElevatedButton.styleFrom(
                //                               onPrimary: Colors.black,
                //                               primary: Colors.white54,
                //                               shape: const CircleBorder(),
                //                               padding: const EdgeInsets.all(5),
                //                             ),
                //                           ),
                //                         ),
                //                         Container(
                //                           height: 200,
                //                           width: 200,
                //                           child: Image.asset(
                //                               'assets/images/greentick.png'),
                //                           decoration: BoxDecoration(
                //                               borderRadius: BorderRadius.circular(50)),
                //                         ),
                //                         SizedBox(
                //                           height: 15,
                //                         ),
                //                         Text(
                //                           "Successfully Completed",
                //                           style: TextStyle(
                //                               fontSize: 20,
                //                               fontFamily: 'Poppins',
                //                               fontWeight: FontWeight.bold),
                //                         )
                //                       ],
                //                     ),
                //                   ));});
                //             CommonDialogs.showGenericToast( 'Lead successfully completed.', );
                //             Future.delayed(const Duration(milliseconds: 3000), () {
                //
                //               Navigator.pop(context);
                //               Navigator.pop(context);
                //
                //             });
                //
                //           }else{
                //             gt.Get.snackbar(
                //               "bikeze",
                //               " Please Fill all.",
                //               snackPosition: gt.SnackPosition.BOTTOM,
                //               backgroundColor: const Color(0xFF324A59),
                //               colorText: Colors.white,
                //               isDismissible: true,
                //               // dismissDirection: gt.SnackDismissDirection.HORIZONTAL,
                //               forwardAnimationCurve: Curves.easeOutBack,
                //             );
                //             _key.currentState?.reset();
                //
                //           }
                //
                //
                //
                //         }
                //       });
                //     },
                //   ),
                // ),
                const SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  // AnimationController _cont =AnimationController(vsync: vsync)
  final GlobalKey<SlideActionState> _key = GlobalKey();

  void onSearchTextChanged(String text) {
  setState(() {
    estprice=text;
  });
  }
  late SharedPreferences prefs;
 late ProgressDialog loadder;
  String percentage = "0";

  void uploadToServer(File? filee,List<XFile> listfile) async {
    SharedPreferences sharedPreferences =
    await SharedPreferences.getInstance();
    // String? accesstoken = prefs.getString("AccessToken") ?? null;
    String message = "'File Uploading...'";
    // filee.rename(DateTime );
    setState(() {
      loadder = ProgressDialog(context: context);
      loadder.update(value: int.parse(percentage));
      loadder.show(max: 100, msg: 'File Uploading...');

    });
    List<MultipartFile> multipart = [];
    late FormData formData;
//listImage is your list assets.
    List<File> _afterImg = [];

    if(filee==null){
      for (int i = 0; i < listfile.length; i++) {
        multipart.add(await MultipartFile.fromFile(listfile[i].path));
        _afterImg.add(File(listfile[i].path));

      }
       formData = new FormData.fromMap({
        "lead_id": argumentData[6]['leadId'] ?? "4",
        "image[]":multipart,
      });
    }else{
       formData = new FormData.fromMap({
        "lead_id": argumentData[6]['leadId'] ?? "4",
        "image": await MultipartFile.fromFile(filee.path),

      });
       _afterImg.add(File(filee.path));

    }


    try {
      String path =
          "https://manyatechnosys.com/bikeze/checkin_mimage.php";

      print("upload path: $path");

      var dio = new Dio();

      RequestOptions options = new RequestOptions(path: path);

      final response = await dio.post(
        path,
        data: formData,
        options: new Options(
            // headers: {HttpHeaders.authorizationHeader: accesstoken},
            sendTimeout: 600000,
            receiveTimeout: 600000),
        onSendProgress: (int sent, int total) {
          print("$sent $total");
          percentage = ((sent / total) * 100).toStringAsFixed(0);
          loadder.update(value: int.parse(percentage),msg: message);
        },
      );

      if (response.statusCode == 200) {


        CommonDialogs.showGenericToast( 'Uploaded successfully', );
        setState(() {
          upload=true;
          _after=_afterImg;
        });
        sharedPreferences.setBool(argumentData[6]['leadId']+"upload", true);
        loadder.close();
        Navigator.pop(context);

        // mainBloc.add(PushInitial());
        //getTopicDiscussions();
      } else {
        loadder.close();
        print("response failure");
        CommonDialogs.showGenericToast( 'Failed to upload', );


      }
    } catch (e) {
      CommonDialogs.showGenericToast( 'Failed to upload ${e.toString()}',
      );

      print("Upload error : ${e.toString()}");

      loadder.close();
      print(e.toString());
    }
  }


}
