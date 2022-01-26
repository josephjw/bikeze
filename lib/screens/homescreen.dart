// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:convert';
import 'package:bikeze/models/leadresponse.dart';
import 'package:bikeze/models/profileresponse.dart';
import 'package:bikeze/preference/Constants.dart';
import 'package:bikeze/screens/profilescreen.dart';
import 'package:bikeze/theme/style.dart';
import 'package:bikeze/widgets/dialog.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'detailscreen.dart';

class HomeScreen extends StatefulWidget {
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  var isDark = false;

  String date = DateFormat("dd-MM-yyyy").format(DateTime.now());
  var now = new DateTime.now();
  Timer? timer,timer2;
bool _loading=true,_loading2=true;
  ProfileResponse profileData=ProfileResponse();

  @override
  void initState() {
    super.initState();
    getProfile().whenComplete(() {
      profileData = fetchProfile(mobile) as ProfileResponse;
      lead_count();
    });
    _firebaseMessaging= FirebaseMessaging.instance;
    firebaseCloudMessaging_Listeners();
    leadOld();
    timer = Timer.periodic(Duration(seconds: 3), (Timer t) { leadNew();    lead_count();});
    timer2 = Timer.periodic(Duration(seconds: 7), (Timer t) { leadOld(); profileData = fetchProfile(mobile) as ProfileResponse;});

    // initConnectivity();
  }

  late FirebaseMessaging _firebaseMessaging;
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
        _conec="${result.toString()}";
        print("result"+_conec);
        // CommonDialogs.showGenericToast( 'Failed to get Internet  connectivity.', );
        break;
      default:
        CommonDialogs.showGenericToast( 'Failed to get Internet  connectivity.', );
        break;

    }
  }


  Future<bool> leadNew() async {
    String url = "https://manyatechnosys.com/bikeze/lead_management_new.php";
    var map = new Map<String, String>();

    map['p_id'] = userid;
    var res = await http.Client().post(Uri.parse(url),body: map);
    if (res.statusCode == 200) {
      print("status : ${res.statusCode}");
      var jsonResponse = res.body;
      final json = jsonDecode(jsonResponse).cast<Map<String, dynamic>>();

      print(json);
      List<LeadResponse> leads = json.map<LeadResponse>((json) {
        return LeadResponse.fromJson(json);
      }).toList();
      setState(() {
        show= leads.length!=0;
        _leads=leads;
        _loading=false;
      });
      return true;
    } else {
      throw Exception('failed to load data');
    }
  }

  List<LeadResponse> _oleads =[];
  List<LeadResponse> _leads =[];

  Future<bool> leadOld() async {
    String url = "https://manyatechnosys.com/bikeze/lead_management_old.php";
    var map = new Map<String, String>();

    map['p_id'] = userid;
    var res = await http.Client().post(Uri.parse(url),body: map);
    if (res.statusCode == 200) {
      print("status : ${res.statusCode}");
      var jsonResponse = res.body;
      final json = jsonDecode(jsonResponse).cast<Map<String, dynamic>>();

      print(json);
      List<LeadResponse> leads = json.map<LeadResponse>((json) {
        return LeadResponse.fromJson(json);
      }).toList();
      setState(() {
        _oleads=leads;
        _loading2=false;
      });
      return true;
    } else {
      throw Exception('failed to load data');
    }
  }

  Future<void> dutyOn() async {
    String url = "https://manyatechnosys.com/bikeze/online_offline_partner.php";
    var map = new Map<String, String>();

    map['p_id'] = userid;
    map['status'] = toggle?'1':'2';

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

  Future<void> lead_count() async {
    String url = "https://manyatechnosys.com/bikeze/lead_count.php";
    var map = new Map<String, String>();

    map['p_id'] = userid;

    var res = await http.Client().post(Uri.parse(url),body: map);
    if (res.statusCode == 200) {
      print("status : ${res.statusCode}");
      var jsonResponse = res.body;
      final json = jsonDecode(jsonResponse);
      setState(() {
        leadcnt=json['lead_count'];

      });
      print(jsonResponse);

    } else {
      throw Exception('failed to load data');
    }
  }

  final GlobalKey<ScaffoldState> _key = GlobalKey(); // Create a key

  call() async {}

  String leadcnt='',mobile="",userName = " ",userid='',image="https://external-content.duckduckgo.com/iu/?u=http%3A%2F%2Fwww.designindaba.com%2Fsites%2Fdefault%2Ffiles%2Fvocab%2Ftopics%2F8%2Fgraphic-design-illustration-Image%2520Credite-%2520Leigh%2520Le%2520Roux%2520.jpg&f=1&nofb=1";

  Future getProfile() async {
    final SharedPreferences sharedPreferences =
    await SharedPreferences.getInstance();

    String? name = sharedPreferences.getString(Preferences.user_name);
    String? id = sharedPreferences.getString(Preferences.user_id);
    String? image = sharedPreferences.getString(Preferences.user_image);
    String? mob = sharedPreferences.getString(Preferences.mobile);
    bool? status = sharedPreferences.getBool(Preferences.status);

    // print(obtainedNumber);
    setState(() {

      userName= name!;
      userid=id!;
      this.image=image!;
      mobile=mob!;
      toggle=status!;
    });
  }

  bool toggle =false,show=false;

  // final controller = Get.put(HomeController());


  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print('Handling a background message: ${message.messageId}');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: ListTile(
          title: Text(message.notification!.title!),
          subtitle: Text(message.notification!.body!),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('Ok'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );

  }
  late AndroidNotificationChannel channel;


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


  void firebaseCloudMessaging_Listeners() {
    // if (Platform.isIOS) iOS_Permission();
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      'This channel is used for important notifications.', // description
      importance: Importance.high,
    );
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    _firebaseMessaging.getToken().then((token){
      print("fcm "+token!);
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      // print("msg "+message!.data!.toString()!);

    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null ) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channel.description,
              // TODO add a proper drawable resource to android, for now using
              //      one that already exists in example app.
              icon: 'launch_background',
            ),
          ),
        );
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: Column(children: [
              Row(children: [
                Expanded(child: Container(),),
                Image.asset("assets/images/close.png",height: 14,)
              ],),
              Row(children: [
                Icon(Icons.notifications,color: Colors.black,),
                Text(message.notification!.title!),

              ],),
              Text(message.notification!.body!)

            ],),
            actions: <Widget>[
              FlatButton(
                child: Text('View leads >'),
                onPressed: (){

                  Navigator.of(context).pop();
                  // Get.to(() => DetailScreen(), arguments: [
                  //   {'name': _leads[0].user_name},
                  //   {'package': _leads[0].package},
                  //   {'vehicle': _leads[0].vehicle},
                  //   {'remarks': _leads[0].remarks},
                  //   {'location': _leads[0].location},
                  //   {'mobile': _leads[0].mobile_no},
                  //   {'leadId': _leads[0].lead_id},
                  //   {'date': _leads[0].booking_date},
                  //   {'ebool': _leads[0].est_price_boolval},
                  //   {'ibool': _leads[0].image_boolval}
                  // ]);
                },
              ),
            ],
          ),
        );
        // showDialog(
        //   context: context,
        //   builder: (context) => AlertDialog(
        //     content: ListTile(
        //       title: Text(message.notification!.title!),
        //       subtitle: Text(message.notification!.body!),
        //     ),
        //     actions: <Widget>[
        //       FlatButton(
        //         child: Text('Ok'),
        //         onPressed: () => Navigator.of(context).pop(),
        //       ),
        //     ],
        //   ),
        // );
      }
    });
  }

  // void iOS_Permission() {
  //   _firebaseMessaging.requestNotificationPermissions(
  //       IosNotificationSettings(sound: true, badge: true, alert: true)
  //   );
  //   _firebaseMessaging.onIosSettingsRegistered
  //       .listen((IosNotificationSettings settings)
  //   {
  //     print("Settings registered: $settings");
  //   });
  // }


  @override
  Widget build(BuildContext context) {
    // initConnectivity();
    getProfile();
    return Scaffold(
      backgroundColor: const Color(0XFFfbfafb),
      // endDrawer: CustomDrawer(),
      key: _key,
      body: Column(children: <Widget>[
        const SizedBox(height: 30),
        Container(
          height: 100,
          width:double.infinity,

          //color: Colors.green,
          padding: EdgeInsets.symmetric(horizontal: 10),
          // width: MediaQuery.of(context).size.width,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                const SizedBox(width: 5),
                InkWell(
                  onTap: () {
                    Get.to(() => ProfileScreen());
                  },
                  child:  CircleAvatar(
                    backgroundColor: Color(0xFF324A59),
                    radius: 22,
                    child: CircleAvatar(
                      backgroundColor: Color(0xff324A59),
                      radius: 19,
                      foregroundImage: NetworkImage(
                          profileData.image?? image
                            // "https://external-content.duckduckgo.com/iu/?u=http%3A%2F%2Fwww.designindaba.com%2Fsites%2Fdefault%2Ffiles%2Fvocab%2Ftopics%2F8%2Fgraphic-design-illustration-Image%2520Credite-%2520Leigh%2520Le%2520Roux%2520.jpg&f=1&nofb=1"
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child:  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Hi,",
                          style: TextStyle(
                              color: Colors.grey,
                              fontFamily: 'Poppins',
                              fontSize: 20)),
                      Text(
                        userName ,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          color: Color(0xFF324A59),
                        ),
                      ),
                    ],
                  ),
                ),


                Row(
                  children: [

                    Text(
                      "OFFLINE" ,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: Color(0xFF324A59),
                      ),
                    ),
                    Switch(
                        value: toggle,
                        onChanged: (state) async{
                          final SharedPreferences sharedPreferences =
                              await SharedPreferences.getInstance();
                          setState(() {
                            if(!show) {
                              // controller.ChangeTheme(state);
                              toggle=!toggle;
                              dutyOn();
                              if(!toggle){
                                CommonDialogs.showGenericToast( 'You are offline now.', );
                              }
                              else{
                                CommonDialogs.showGenericToast( 'You are online now.', );
                              }
                              sharedPreferences.setBool(Preferences.status, toggle);
                            }else{
                              // toggle=!toggle;
                              CommonDialogs.showGenericToast( 'Please completed assigned task..', );
                            }
                          });
                        },
                        activeColor: Colors.green,
                        hoverColor: Colors.white,
                      ),

                    Text(
                      "ONLINE" ,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: Color(0xFF324A59),
                      ),
                    ),
                  ],
                ),


              ]),
        ),
        const SizedBox(height: 15),
        Expanded(
            child: Container(
          // height: 800,
          width: MediaQuery.of(context).size.width,
          //color: Colors.black26,
          decoration:  BoxDecoration(
            color: HexColor('#fafafa'),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Scrollbar(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 26),
                    Row(
                      children: [
                        Expanded(
                          child:  Text("LEAD MANAGEMENT",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: HexColor('#2d3238'),
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold)),
                        ),
                        Text("Today Leads : $leadcnt",
                            style: TextStyle(
                                fontSize: 16,
                                color: HexColor('#2d3238'),
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold))

                      ],
                    ),
                    const SizedBox(height: 30),
                     Text("${DateFormat('MMM').format(DateTime(0, now.month)) .toString()} ${now.year.toString()}",
                        style: TextStyle(
                            fontSize: 17,
                            color: HexColor('#2d3238'),
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold)),
                    // FutureBuilder(
                    //   future: leadNew(),
                    //   builder: (BuildContext context, AsyncSnapshot snapshot) {
                    //
                    //     if (snapshot.data==null) {
                    //
                    //       return Container(
                    //           child: Center(child: CircularProgressIndicator()));
                    //     }else{
                    //     return
                    //     }
                    // //     else{
                    // //     return Text("No Older Leads",
                    // //     style: TextStyle(
                    // // fontSize: 14,
                    // // fontFamily: 'Poppins',
                    // // color: Colors.white,
                    // // fontWeight: FontWeight.bold));
                    // //
                    // // }
                    //   }
                    // ),
                   _loading? Container(
                        child: Center(child: CircularProgressIndicator())):
               _leads.length==0?Center(
                 child: Text(
                     " No Leads are Found.",
                     style: TextStyle(
                       fontSize: 12,
                       color: HexColor('#2d3238'),
                       fontFamily: 'Poppins',
                     )),
               ):
               ListView.separated(
                    separatorBuilder: (BuildContext context, int index) =>
                        SizedBox(height: 10),
                    shrinkWrap: true,
                    reverse: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _leads.length,
                    itemBuilder: (BuildContext context, index) {

                      return Center(
                          child: _leads.length==0?Text("No Leads"): InkWell(
                            onTap: () {
                              Get.to(() => DetailScreen(), arguments: [
                                {'name': _leads[index].user_name},
                                {'package': _leads[index].package},
                                {'vehicle': _leads[index].vehicle},
                                {'remarks': _leads[index].remarks},
                                {'location': _leads[index].location},
                                {'mobile': _leads[index].mobile_no},
                                {'leadId': _leads[index].lead_id},
                                {'date': _leads[index].booking_date},
                                {'ebool': _leads[index].est_price_boolval},
                                {'ibool': _leads[index].image_boolval},
                                {'assign': _leads[index].assign}

    ]);
                            },
                            child: Container(
                              height: 110,
                              width: double.infinity,
                              //   color: Colors.white,
                              decoration: BoxDecoration(
                                  color: HexColor('#E15529'),
                                  borderRadius: BorderRadius.circular(12)),
                              child: Column(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                   SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "  ${_leads[index].user_name}",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                      SizedBox(
                                        width: 55,
                                      ),
                                      Text(
                                        "${_leads[index].booking_date}",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontFamily: 'Poppins',
                                           color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 1,
                                      )
                                    ],
                                  ),
                                   SizedBox(height: 2),
                                   Text("   General Service",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontFamily: 'Poppins',
                                          color: Colors.white
                                      )),
                                   SizedBox(
                                    height: 4,
                                  ),
                                  Text(
                                      "   Package Selected:  \u{20B9} ${_leads[index].package}",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontFamily: 'Poppins',
                                          color: Colors.white
                                      )),
                                   SizedBox(height: 2),
                                  Row(
                                    //  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding:
                                          EdgeInsets.fromLTRB(0, 5, 0, 0),
                                          height: 25,
                                          width: 140,
                                          //  color: Colors.yellow,
                                          child: Text(
                                            "   ${_leads[index].vehicle}",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontFamily: 'Poppins',
                                                color: Colors.white
                                            ),
                                          ),
                                        ),
                                         SizedBox(
                                          width: 35,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(
                                              20, 2, 1, 1),
                                          child: SizedBox(
                                            height: 30,
                                            // width: 130,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                String number =
                                                    '${_leads[index].mobile_no}';
                                                FlutterPhoneDirectCaller
                                                    .callNumber(number);
                                              },
                                              child:  Text("CALL NOW",
                                                  style: TextStyle(
                                                    color:Color(
                                                        0xff324759) ,
                                                    fontFamily: 'Poppins',
                                                  )),
                                              style: ElevatedButton.styleFrom(
                                                primary:  Colors.white, // background
                                                onPrimary: Colors
                                                    .white, // foreground
                                              ),
                                            ),
                                          ),
                                        ),
                                         SizedBox(
                                          width: 0.5,
                                        )
                                      ]),
                                   SizedBox(height: 4)
                                ],
                              ),
                            ),
                          ));
                    }),

                    SizedBox(
                      height: 20,
                    ),

                    //  use
                     Text("Older Leads",
                        style: TextStyle(
                            fontSize: 17,
                            fontFamily: 'Poppins',
                            color: HexColor('#2d3238'),
                            fontWeight: FontWeight.bold)),

              //     if (snapshot.hasError)
              //   return Text('Error: ${snapshot.error}');
              // else
              // return
                    _loading2?
                      Container(
                      child: Center(child: CircularProgressIndicator())):

                    _oleads.length==0?Center(
                      child: Text(
                          " No Leads are Found.",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontFamily: 'Poppins',
                          )),
                    ):
                    ListView.separated(
              separatorBuilder: (BuildContext context, int index) =>
                SizedBox(height: 10),
            shrinkWrap: true,
            // reverse: true,
            physics: NeverScrollableScrollPhysics(),

            itemCount: _oleads.length,
            itemBuilder: (BuildContext context, index) {
              // if (      _oleads[index].booking_date != date
              // ) {
                return Center(
                    child: InkWell(
                      onTap: () {
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
                        height: 110,
                        width: 340,
                        //   color: Colors.white,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            spreadRadius: 1,
                            blurRadius: 1,
                          )
                        ]),
                        child: Column(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "  ${_oleads[index].user_name}",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold,
                                      color: HexColor('#64676E')),
                                ),
                                SizedBox(
                                  width: 55,
                                ),
                                Text(
                                  "${_oleads[index].booking_date}",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                      color: HexColor('#64676E'),

                                  ),
                                ),
                                SizedBox(
                                  width: 1,
                                )
                              ],
                            ),
                            const SizedBox(height: 2),
                             Text("   General Service",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'Poppins',
                                  color: HexColor('#64676E')
                                )),
                            const SizedBox(
                              height: 4,
                            ),
                            Text(
                                "   Package Selected:  \u{20B9} ${_oleads[index].package}",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'Poppins',
                                  color: HexColor('#64676E'),
                                ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              //  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: EdgeInsets.fromLTRB(
                                        0, 5, 0, 0),
                                    height: 25,
                                    width: 140,
                                    //  color: Colors.yellow,
                                    child: Text(
                                      "   ${_oleads[index].vehicle}",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontFamily: 'Poppins',
                                          color: HexColor('#64676E')
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 35,
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(
                                          10, 2, 10, 1),
                                      child: SizedBox(
                                        height: 30,
                                        width: 130,
                                        child: ElevatedButton(
                                          onPressed: () {},
                                          child: const Text(
                                              "LEAD CLOSED",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'Poppins',
                                              )),
                                          style:
                                          ElevatedButton.styleFrom(
                                            primary: const Color(
                                                0xff324759), // background
                                            onPrimary: Colors
                                                .white, // foreground
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 0.5,
                                  )
                                ]),
                            const SizedBox(height: 4)
                          ],
                        ),
                      ),
                    ));
              // }
              // else {
              //   return SizedBox.shrink();
              // }
            }),
                    const SizedBox(height: 10),

      // return Text('Result: ${snapshot.data}');


      // FutureBuilder(
                    //   future: leadOld(),
                    //   builder: (BuildContext context, AsyncSnapshot snapshot) {
                    //
                    //     // if (!snapshot.connectionState.) {
                    //     //   return Container(
                    //     //   child: Center(child: CircularProgressIndicator()));
                    //     // }
                    //     switch (snapshot.connectionState) {
                    //       case ConnectionState.waiting: return Container(
                    //           child: Center(child: CircularProgressIndicator()));;
                    //       default:
                    //
                    //     }
                    //   },
                    //
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ))
      ]),
    );
  }
}
