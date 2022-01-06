// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bikezopartner/widgets/dialog.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:bikezopartner/preference/Constants.dart';
import 'package:bikezopartner/preference/shared_preference_helper.dart';
import 'package:bikezopartner/screens/custom_drawer.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

import 'package:bikezopartner/controllers/homecontroller.dart';
import 'package:bikezopartner/models/leadresponse.dart';
import 'package:bikezopartner/screens/detailscreen.dart';
import 'package:bikezopartner/screens/profilescreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  var isDark = false;

  String date = DateFormat("dd-MM-yyyy").format(DateTime.now());
  var now = new DateTime.now();

  @override
  void initState() {
    super.initState();
    getProfile();
    _firebaseMessaging= FirebaseMessaging.instance;
    firebaseCloudMessaging_Listeners();
    initConnectivity();
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


  Future<List<LeadResponse>> leadNew() async {
    String url = "https://manyatechnosys.com/bikezo/lead_management_new.php";
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
      });
      return leads;
    } else {
      throw Exception('failed to load data');
    }
  }

  Future<List<LeadResponse>> leadOld() async {
    String url = "https://manyatechnosys.com/bikezo/lead_management_old.php";
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
      return leads;
    } else {
      throw Exception('failed to load data');
    }
  }

  Future<void> dutyOn() async {
    String url = "https://manyatechnosys.com/bikezo/online_offline_partner.php";
    var map = new Map<String, String>();

    map['p_id'] = userid;
    map['status'] = toggle?'1':'0';

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

  final GlobalKey<ScaffoldState> _key = GlobalKey(); // Create a key

  call() async {}

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

  bool toggle =false,show=false;

  final controller = Get.put(HomeController());


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
    initConnectivity();
    getProfile();
    return Scaffold(
      backgroundColor: const Color(0XFFfbfafb),
      endDrawer: CustomDrawer(),
      key: _key,
      body: Column(children: <Widget>[
        const SizedBox(height: 30),
        Container(
          height: 100,
          //color: Colors.green,
          padding: EdgeInsets.symmetric(horizontal: 10),
          width: MediaQuery.of(context).size.width,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                const SizedBox(width: 5),
                InkWell(
                  onTap: () {
                    Get.to(() => ProfileScreen());
                  },
                  child: const CircleAvatar(
                    backgroundColor: Color(0xFF324A59),
                    radius: 22,
                    child: CircleAvatar(
                      backgroundColor: Color(0xff324A59),
                      radius: 19,
                      foregroundImage: NetworkImage(
                          "https://external-content.duckduckgo.com/iu/?u=http%3A%2F%2Fwww.designindaba.com%2Fsites%2Fdefault%2Ffiles%2Fvocab%2Ftopics%2F8%2Fgraphic-design-illustration-Image%2520Credite-%2520Leigh%2520Le%2520Roux%2520.jpg&f=1&nofb=1"),
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
                          fontSize: 20,
                          color: Color(0xFF324A59),
                        ),
                      ),
                    ],
                  ),
                ),


                GetBuilder<HomeController>(
                  builder: (_) => Switch(
                    value: controller.isDark,
                    onChanged: (state) {
                      setState(() {
                        if(!show) {
                          controller.ChangeTheme(state);
                          toggle=!toggle;
                          dutyOn();
                        }else{
                          // toggle=!toggle;
                          CommonDialogs.showGenericToast( 'Please completed assigned task..', );
                        }
                      });
                    },
                    activeColor: Colors.green,
                    hoverColor: Colors.white,
                  ),
                ),
                InkWell(
                  onTap: (){
                    _key.currentState!.openEndDrawer();
                    // Scaffold.of(context).openDrawer();
                  },
                  child: const Icon(
                    Icons.menu,
                  ),
                )
              ]),
        ),
        const SizedBox(height: 15),
        Expanded(
            child: Container(
          // height: 800,
          width: MediaQuery.of(context).size.width,
          //color: Colors.black26,
          decoration: const BoxDecoration(
            color: Color(0XFF324b5a),
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
                    const Text("LEAD MANAGEMENT",
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 30),
                     Text("${DateFormat('MMM').format(DateTime(0, now.month)) .toString()} ${now.year.toString()}",
                        style: TextStyle(
                            fontSize: 17,
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold)),
                    FutureBuilder(
                      future: leadNew(),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {

                        if (snapshot.data == null) {

                          return Container(
                              child: Center(child: CircularProgressIndicator()));
                        }
                        return ListView.separated(
                            separatorBuilder: (BuildContext context, int index) =>
                                SizedBox(height: 10),
                            shrinkWrap: true,
                            reverse: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: snapshot.data.length,
                            itemBuilder: (BuildContext context, index) {

                              return Center(
                                  child: snapshot.data.length==0?Text("No Leads"): InkWell(
                                onTap: () {
                                  Get.to(() => DetailScreen(), arguments: [
                                    {'name': snapshot.data[index].user_name},
                                    {'package': snapshot.data[index].package},
                                    {'vehicle': snapshot.data[index].vehicle},
                                    {'remarks': snapshot.data[index].remarks},
                                    {'location': snapshot.data[index].location},
                                    {'mobile': snapshot.data[index].mobile_no},
                                    {'leadId': snapshot.data[index].lead_id},
                                    {'date': snapshot.data[index].booking_date}



                                  ]);
                                },
                                child: Container(
                                  height: 110,
                                  width: double.infinity,
                                  //   color: Colors.white,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12)),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "  ${snapshot.data[index].user_name}",
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xff324A59)),
                                          ),
                                          SizedBox(
                                            width: 55,
                                          ),
                                          Text(
                                            "${snapshot.data[index].booking_date}",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontFamily: 'Poppins',
                                            ),
                                          ),
                                          SizedBox(
                                            width: 1,
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      const Text("   General Service",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontFamily: 'Poppins',
                                          )),
                                      const SizedBox(
                                        height: 4,
                                      ),
                                      Text(
                                          "   Package Selected:  \u{20B9} ${snapshot.data[index].package}",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontFamily: 'Poppins',
                                          )),
                                      const SizedBox(height: 2),
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
                                                "   ${snapshot.data[index].vehicle}",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontFamily: 'Poppins',
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
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
                                                        '${snapshot.data[index].mobile_no}';
                                                    FlutterPhoneDirectCaller
                                                        .callNumber(number);
                                                  },
                                                  child: const Text("CALL NOW",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontFamily: 'Poppins',
                                                      )),
                                                  style: ElevatedButton.styleFrom(
                                                    primary: const Color(
                                                        0xff324759), // background
                                                    onPrimary: Colors
                                                        .white, // foreground
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
                            });
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),

                    //  use
                    const Text("Older Leads",
                        style: TextStyle(
                            fontSize: 17,
                            fontFamily: 'Poppins',
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    FutureBuilder(
                      future: leadOld(),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.data == null) {
                          return Container(
                              child: Center(child: CircularProgressIndicator()));
                        }
                        return ListView.separated(
                            separatorBuilder: (BuildContext context, int index) =>
                                SizedBox(height: 10),
                            shrinkWrap: true,
                            // reverse: true,
                            physics: NeverScrollableScrollPhysics(),

                            itemCount: snapshot.data.length,
                            itemBuilder: (BuildContext context, index) {
                              if (snapshot.data[index].booking_date != date) {
                                return Center(
                                    child: InkWell(
                                  onTap: () {
                                    // Get.to(() => DetailScreen(), arguments: [
                                    //   {'name': snapshot.data[index].user_name},
                                    //   {'package': snapshot.data[index].package},
                                    //   {'vehicle': snapshot.data[index].vehicle},
                                    //   {'remarks': snapshot.data[index].remarks},
                                    //   {'leadId': snapshot.data[index].lead_id}
                                    // ]);
                                  },
                                  child: Container(
                                    height: 110,
                                    width: 340,
                                    //   color: Colors.white,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12)),
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
                                              "  ${snapshot.data[index].user_name}",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xff324A59)),
                                            ),
                                            SizedBox(
                                              width: 55,
                                            ),
                                            Text(
                                              "${snapshot.data[index].booking_date}",
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontFamily: 'Poppins',
                                              ),
                                            ),
                                            SizedBox(
                                              width: 1,
                                            )
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        const Text("   General Service",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontFamily: 'Poppins',
                                            )),
                                        const SizedBox(
                                          height: 4,
                                        ),
                                        Text(
                                            "   Package Selected:  \u{20B9} ${snapshot.data[index].package}",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontFamily: 'Poppins',
                                            )),
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
                                                  "   ${snapshot.data[index].vehicle}",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontFamily: 'Poppins',
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 35,
                                              ),
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    20, 2, 1, 1),
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
                                              const SizedBox(
                                                width: 0.5,
                                              )
                                            ]),
                                        const SizedBox(height: 4)
                                      ],
                                    ),
                                  ),
                                ));
                              } else {
                                return SizedBox.shrink();
                              }
                            });
                      },
                    ),
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