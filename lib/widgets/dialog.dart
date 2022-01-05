import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:fluttertoast/fluttertoast.dart';

import 'IntroButton.dart';

class CommonDialogs {
  static Future<void> showLoadingDialog(BuildContext context,
      GlobalKey key) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(
                  key: key,
                  backgroundColor: Colors.white,
                  children: <Widget>[
                    Container(
                        width: double.infinity,
                        height: 60.0,
                        child: Center(
                          child: Row(children: [
                            Padding(padding: const EdgeInsets.all(10.0)),
                            CircularProgressIndicator(),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              "Loading...",
                              style: TextStyle(
                                  color: Theme
                                      .of(context)
                                      .accentColor),
                            )
                          ]),
                        )),
                  ]));
        });
  }

  static void showGenericDialogue(BuildContext context, String title,
      String description) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) =>
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(10.0),
            ),
            title: Text(title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme
                      .of(context)
                      .primaryColor,
                  fontSize: 14,
                )),
            content: Text(
              '$description',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black),
            ),
            actions: [
              IntroButton(
                buttonText: 'OK',
                onClick: () {
                  Navigator.pop(context);
                  //Navigator.of(context).pop();
                },
              )
            ],
          ),
    );
  }



   static void showGenericToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0);
     }
}
