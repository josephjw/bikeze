import 'package:flutter/material.dart';

class IntroButton extends StatefulWidget {
  final Function onClick;
  final String buttonText;

  const IntroButton({  required this.onClick, required this.buttonText}) : super();

  @override
  _IntroButtonState createState() => _IntroButtonState();
}

class _IntroButtonState extends State<IntroButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 0.0, right: 0.0),
      child: RaisedButton(
          elevation: 2.0,
          color: Theme.of(context).buttonColor,
          shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(20.0),
          ),
          child: Container(
              height: 30,
              padding: EdgeInsets.only(left: 20,right: 20),

              child: Center(
                child: Text(widget.buttonText,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    )),
              )),
          onPressed:()=> widget.onClick ),
    );
  }
}
