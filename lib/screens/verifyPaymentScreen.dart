import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:bikeze/permissions/permission_utils.dart';
import 'package:bikeze/preference/Constants.dart';
import 'package:bikeze/screens/fullscreenImage.dart';
import 'package:bikeze/theme/style.dart';
import 'package:bikeze/widgets/dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart' as gt;
import 'package:get/get_navigation/src/routes/default_transitions.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker2/multi_image_picker2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slidable_button/slidable_button.dart';
import 'package:maps_launcher/maps_launcher.dart';

import 'package:http/http.dart' as http;
import 'package:sn_progress_dialog/progress_dialog.dart';

class VerifyPaymentScreen extends StatefulWidget {
  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<VerifyPaymentScreen> {
  dynamic argumentData = gt.Get.arguments;

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
      status="",
      qrimage="https://external-content.duckduckgo.com/iu/?u=http%3A%2F%2Fwww.pngall.com%2Fwp-content%2Fuploads%2F2%2FQR-Code-PNG-Image-HD.png&f=1&nofb=1";

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


  List<String> imags=[];
  Future<void> getimage() async {
    String url = "https://manyatechnosys.com/bikeze/checkoutview_image.php";
    var map = new Map<String, String>();

    map['lead_id'] = argumentData[0]['leadId'];
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
  getImagefromCamera() async {


    final XFile? photo = await picker.pickImage(
        source: ImageSource.camera, maxHeight: 500, maxWidth: 500);
    if(photo!=null){
      uploadToServer(File(photo.path),[]);

    }
  }

  Future<void> paymentVerify() async {
    String url = "https://manyatechnosys.com/bikeze/verify_payment.php";
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
          qrimage=json['qrimage'];
        });

      }catch(e){
        print(e);

      }
      // userid
      print("veri response"+jsonResponse);
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
                  height: 5,
                ),

                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: () {
                      gt.Get.back();
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
                      //      title: "",
                      //      content: Center(
                      //          child: Row(
                      //            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      //            children: [
                      //              ElevatedButton.icon(
                      //                onPressed: () {
                      //                  getImagefromCamera();
                      //                },
                      //                icon: const Icon(
                      //                  Icons.camera,
                      //                ),
                      //                label: const Text("Camera"),
                      //                style: ElevatedButton.styleFrom(
                      //                    primary: const Color(0xff324A59)),
                      //              ),
                      //              ElevatedButton.icon(
                      //                onPressed: () {
                      //                  getImageFromGallery();
                      //                  // loadAssets();
                      //                },
                      //                icon: const Icon(
                      //                  Icons.image,
                      //                ),
                      //                label: const Text("Image"),
                      //                style: ElevatedButton.styleFrom(
                      //                    primary: const Color(
                      //                        0xff324A59) //elevated btton background color
                      //                ),
                      //              ),
                      //            ],
                      //          )));
                    }else{

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
                              color: upload ? Color(0xff324A59):Color(0xFFAAAAAA),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  // SizedBox(
                                  //   height: 18,
                                  // ),
                                  Text(
                                    "Service Completed ",
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w300,
                                        fontFamily: 'Poppins',
                                        color: Color(0xFFAAAAAA)),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text("Check out",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w300,
                                        fontFamily: 'Poppins',
                                      ))
                                ],
                              ),
                            ),

                            Icon(
                              FontAwesomeIcons.solidCheckCircle,
                              color: upload  ? Color(0xff324759):Color(0xFFAAAAAA),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                          ],
                        )),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),

                Container(
                  child: SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: ()async {
                        if(upload){
                          gt.Get.defaultDialog(
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
                                      onPressed: ()async {
                                        SharedPreferences sharedPreferences =
                                        await SharedPreferences.getInstance();
                                        sharedPreferences.setBool(argumentData[0]['leadId']+"pay", true);
                                        Navigator.pop(context);
                                        Navigator.pop(context);

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
                                        gt.Get.back();
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
                        }else{
                          CommonDialogs.showGenericToast( 'Please Select Image ...', );

                        }
                        // SharedPreferences sharedPreferences =
                        // await SharedPreferences.getInstance();
                        //  sharedPreferences.setBool(argumentData[0]['leadId']+"pay", true);
                        //  Navigator.pop(context);
                        // Get.back();


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
                upload?
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Check-out Images :",
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

                                    gt.Get.to(()=>FullscreenImage(fileimage:_after.isNotEmpty? _after[index]?.path:null,qrimage:imags.isNotEmpty? imags[index]:null,));
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
                                        color:  Colors.grey[200],
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
                  height: 25,
                ),
                qrimage!=""?
                InkWell(
                  onTap: (){
                    gt.Get.to(()=>FullscreenImage(qrimage: qrimage,));
                  },

                  child: Container(
                    height: 180,
                    width: 200,
                    //color: Colors.yellow,
                    child: Image.network(
                        qrimage),
                  ),
                ):Container(),
                Text(
                  "Scan & Pay now at",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontFamily: 'Poppins', fontSize: 12),
                ),

                SizedBox(height: 60,)
              ],
            )
                :Expanded(
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
                        gt.Get.back();
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


  List<Asset> images = <Asset>[];

  List<File> _after =[];


  bool esti_status = false,verifypay = false,upload = false;
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
    List<File> _afterImg = [];

    late FormData formData;
//listImage is your list assets.

    if(filee==null){
      for (int i = 0; i < listfile.length; i++) {
        multipart.add(await MultipartFile.fromFile(listfile[i].path));
        _afterImg.add(File(listfile[i].path));

      }
      formData = new FormData.fromMap({
        "lead_id": argumentData[0]['leadId'] ?? "4",
        "image[]":multipart,
      });
    }else{
      formData = new FormData.fromMap({
        "lead_id": argumentData[0]['leadId'] ?? "4",
        "image": await MultipartFile.fromFile(filee.path),
      });
    }

    print("image len "+multipart.length.toString());

    try {
      String path =
          "https://manyatechnosys.com/bikeze/after_image.php";

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
        print('multiimage '+response.toString());


        CommonDialogs.showGenericToast( 'Uploaded successfully', );
        setState(() {
          upload=true;
          _after=_afterImg;

        });
        sharedPreferences.setBool(argumentData[0]['leadId']+"upload", true);
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
