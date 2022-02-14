
import 'dart:io';

import 'package:flutter/material.dart';

class FullscreenImage extends StatefulWidget {
  final String? qrimage;
  final String? fileimage;

  const FullscreenImage({Key? key, this.qrimage, this.fileimage}) : super(key: key);

  @override
  _FullscreenImageState createState() => _FullscreenImageState();
}

class _FullscreenImageState extends State<FullscreenImage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child:

          Container(
            // height: 400,
            width: double.infinity,
            //color: Colors.yellow,
            child:widget.qrimage!=null? Image.network(widget.qrimage ??
                "https://external-content.duckduckgo.com/iu/?u=http%3A%2F%2Fwww.pngall.com%2Fwp-content%2Fuploads%2F2%2FQR-Code-PNG-Image-HD.png&f=1&nofb=1")
            :
              Image.file(File(widget.fileimage ?? ""))

          ),)


          ,
        ],
      ),
    );


  }
}
