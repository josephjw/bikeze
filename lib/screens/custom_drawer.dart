import 'package:bikezopartner/models/drawer_item_model.dart';
import 'package:bikezopartner/preference/Constants.dart';
import 'package:bikezopartner/screens/loginscreen.dart';
import 'package:bikezopartner/screens/privacyPolicyScreen.dart';
import 'package:bikezopartner/screens/widget/custom_drawer_tile.dart';
import 'package:bikezopartner/theme/style.dart';
import 'package:bikezopartner/widgets/dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
// import 'package:get/get_navigation/src/snackbar/snack.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomDrawer extends StatefulWidget {
  CustomDrawer() : super();
  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String profname = "", dppath = '';

  @override
  void initState() {
    super.initState();
    getProfile();
  }

  String userName = " ", userid = '';

  Future getProfile() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();

    String? name = sharedPreferences.getString(Preferences.user_name);
    String? id = sharedPreferences.getString(Preferences.user_id);

    // print(obtainedNumber);
    setState(() {
      profname = name!;
      userid = id!;
    });
  }

  @override
  Widget build(BuildContext ctxt) {
    drawerItemList.clear();
    getData();

    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            // DrawerHeader(
            //     child: Container(
            //       color: Colors.white,
            //       child: Row(
            //     children: <Widget>[
            //       GestureDetector(
            //         child: Container(
            //             height: 100,
            //             width: 100,
            //             decoration: BoxDecoration(
            //               color: Colors.white,
            //               border: Border.all(
            //                 color: Colors.transparent,
            //                 width: 5,
            //               ),
            //               borderRadius: BorderRadius.all(
            //                 Radius.circular(80),
            //               ),
            //             ),
            //             child: CircleAvatar(
            //               radius: 30.0,
            //               backgroundImage: NetworkImage(
            //                   "https://external-content.duckduckgo.com/iu/?u=http%3A%2F%2Fwww.designindaba.com%2Fsites%2Fdefault%2Ffiles%2Fvocab%2Ftopics%2F8%2Fgraphic-design-illustration-Image%2520Credite-%2520Leigh%2520Le%2520Roux%2520.jpg&f=1&nofb=1"),
            //               backgroundColor: Colors.transparent,
            //             )),
            //         onTap: () {
            //           Navigator.pop(context);
            //
            //           // ExtendedNavigator.root.push(Routes.myAccountScreen);
            //         },
            //       ),
            //       Expanded(
            //         child: InkWell(
            //           onTap: (){Navigator.pop(context);
            //             },
            //           child: Column(
            //             mainAxisAlignment: MainAxisAlignment.center,
            //             crossAxisAlignment: CrossAxisAlignment.end,
            //             children: [
            //
            //               Text(
            //                 '$profname',
            //
            //               )
            //             ],
            //           ),
            //         ),
            //       )
            //     ],
            //   ),
            // )),
            Container(
                child: ListView.builder(
                    itemCount:
                        drawerItemList == null ? 0 : drawerItemList.length,
                    physics: NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, i) {
                      return InkWell(
                        onTap: () {
                          switch (i) {
                            case 0:
                              Navigator.pop(context);
                              Get.to(() => PrivacyPolScreen(), arguments: [
                                {'type': "policy"},
                              ]);
                              break;

                            case 1:
                              // Navigator.pop(context);
                              Navigator.pop(context);
                              Get.to(() => PrivacyPolScreen(), arguments: [
                                {'type': "terms"},
                              ]);
                              break;

                            case 2:
                              logout();
                              break;
                            default:
                          }
                        },
                        child: CustomListTile(
                          drawerItemList[i].image,
                          drawerItemList[i].title,
                          null,
                        ),
                      );
                    })),
            Spacer(),
            InkWell(
              onTap: () {
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
                    ],
                  ),
                );
              },
              child: CustomListTile(
                Icons.add,
                "LOGOUT",
                null,
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(25.0, 0, 8.0, 0),
              child: Container(
                  height: 45,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "CONTACT TECH SUPPORT",
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500),
                          ),
                          Text(
                            "+91 95131 82023",
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),

                      // Icon(
                      //   Icons.chevron_right,
                      //   color: Colors.grey,
                      // )
                    ],
                  )),
            ),
            const SizedBox(height: 35),
          ],
        ),
      ),
    );
  }

  Future logout() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.clear();
    Navigator.pop(context);
    Navigator.pop(context);
    Get.to(() => LoginScreen());
    Get.snackbar(
      "Bikezo.in",
      "Successfully Signed Out",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF324A59),
      colorText: Colors.white,
      isDismissible: true,
      // dismissDirection: SnackDismissDirection.HORIZONTAL,
      forwardAnimationCurve: Curves.easeOutBack,
    );
  }

  List<DrawerItemModel> drawerItemList = [];

  void getData() {
    drawerItemList.add(new DrawerItemModel(
        title: 'PRIVACY POLICY', image: Icons.privacy_tip_outlined));
    drawerItemList.add(new DrawerItemModel(
        title: 'TERMS & CONDITION ', image: Icons.privacy_tip_outlined));
    // drawerItemList.add(
    //     new DrawerItemModel(title: 'LOGOUT', image: Icons.logout));
    // drawerItemList.add(
    //     new DrawerItemModel(title: 'CONTACT TECH SUPPORT', image: Icons.logout));
  }

  final _loading = GlobalKey<FormState>();
}
