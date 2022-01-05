import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  final IconData image;
  final String text;
  final Function? onTap;

  CustomListTile(this.image, this.text, this.onTap);
  @override
  Widget build(BuildContext context) {
    //ToDO
    return Padding(
      padding: const EdgeInsets.fromLTRB(25.0, 0, 8.0, 0),
      child: Container(
        // decoration: BoxDecoration(
        //     border:
        //         Border(bottom: BorderSide(color: Colors.grey, width: 1))),
        child: Container(
            height: 45,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[

                    Text(
                      text,
                      style:
                          TextStyle(fontSize: 15, color: Colors.black87,fontWeight: FontWeight.w500),
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
    );
  }
}
