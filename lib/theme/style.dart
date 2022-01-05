import 'package:flutter/material.dart';

ThemeData appTheme() {
  return ThemeData(
    primaryColor: MyColors.primaryColor,
    accentColor: Colors.white,
    hintColor: Colors.grey.shade300,
    dividerColor: Colors.grey.shade300,
    buttonColor: MyColors.primaryColor,
    canvasColor: Colors.white,

  );
}

class MyColors {
  static Color teamcolor = HexColor('#C4C4C4',);
  static Color color1 = HexColor('#56CCF2',);
  static Color color2 = HexColor('#BB6BD9',);
  static Color orange_state= HexColor('#F2994A');
  static Color cancel_red= HexColor('#EB5757');
  static Color yellow =HexColor('#F2C94C');
  static Color gray4 =HexColor('#BDBDBD');
  static Color gray5 =HexColor('#E0E0E0');


  static Color primaryColor = HexColor('#001B42',);
  static Color primaryColorWithOpacity = Color(int.parse("0x001B42")).withOpacity(0.6);
  static Color primaryColorWithLessOpacity = Color(int.parse("0x001B42"))
      .withOpacity(0.2);
  static Color textPrimary = HexColor("#333333");
  static Color textSecondary = HexColor("#ffffff");
  static Color orangeColor = HexColor("#FF6B00");
  static Color secondaryColor = HexColor("#04CE5E");
  static Color white = Colors.white;
  static Color black = Colors.black;
  static Color grey = Colors.grey;
  static Color grey1 = HexColor("#828282");
  static Color bg_hospital = HexColor("#E8D9C2");

  static Color Transparent = Colors.transparent;
  static Color SecondaryColor = HexColor("#001B42");
  static Color titleColor = HexColor("#C1C1CA");
  static Color textColor82 = HexColor("#828282");
  static Color boxColor = HexColor("#EEF7FF");
  static Color gray2text= HexColor('#4F4F4F');
  static Color chatHighlight= HexColor('#ccffff');
  static Color chatownerCol= HexColor('#ccffff');
  static Color chatcolbr= HexColor('#f2ade7');


  static Color errorColor = HexColor("#FB1818");
  static Color dividerColor = HexColor("#646465");
  static Color divColor = HexColor("#BDBDBD");
  static Color signUpColor = HexColor("#1565D8");
  static Color textColor = HexColor("#5E5D5D");
  static Color appBarColor = HexColor("#F4F5F9");
  static Color appBarColor1 = HexColor("#F2F2F2");
  static Color darkBlue= HexColor('#152850');

  static Color textLightGrey = HexColor("#707070");
  static Color bgLightGrey = HexColor("#DEDEDE");
  static Color textSecondary_50 = HexColor("#804A4848");
  static Color text_header = HexColor("#4A4848");
  static Color bgGrey = HexColor("#F8F8F8");
  static Color greyText = HexColor("#001B4282");
  static Color greyText999 = HexColor("#999999");
  static Color emptySCreenText = HexColor("#1089FF");
  static Color glossyGrey = HexColor("#AFADA9");

  static Color bgDashed = HexColor("#FFD2D2");
  static Color green2=HexColor('#27AE60');


  static Color dividerColor_70 = HexColor("#7070A3");
  static Color light_divider = HexColor("#C6C6C6");
  static Color blue = HexColor("#1089FF");
  static Color bgOtpBox = HexColor("#1A19BCD2");
  static Color box_bg_color = HexColor("#F8FFFE");
  static Color green = Colors.greenAccent;
}

class CustomTextStyle {
  static TextStyle whiteBold16(BuildContext context) {
    return TextStyle(
        fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white);
  }

  static TextStyle buttonText(BuildContext context,bool isLined,bool isSeleted,double fontSize) {
    return TextStyle(fontSize: fontSize,
        color: isLined?isSeleted?MyColors.blue:MyColors.textLightGrey:Colors.white,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.67);
  }

  static TextStyle errorTitle(BuildContext context) {
    return TextStyle(fontSize: 18.0, color: MyColors.primaryColor);
  }
  static TextStyle textTitle(BuildContext context) {
    return TextStyle(fontSize: 14.0, color: Colors.black,);
  }

  static TextStyle textSmall(BuildContext context) {
    return TextStyle(fontSize: 14.0,);
  }

  static TextStyle textHeader(BuildContext context) {
    return TextStyle(fontSize: 18.0, color: Colors.black);
  }

  static TextStyle textSubheader(BuildContext context) {
    return TextStyle(fontSize: 16.0, color: Colors.black);
  }

  static TextStyle textBlack12(BuildContext context) {
    return TextStyle(fontSize: 12.0, color: Colors.black);
  }

  static TextStyle textBoldBlack(BuildContext context) {
    return TextStyle(
        fontSize: 24.0, color: Colors.black, fontWeight: FontWeight.bold);
  }

  static TextStyle textBoldBlack18(BuildContext context) {
    return TextStyle(
        fontSize: 18.0, color: Colors.black, fontWeight: FontWeight.bold);
  }

}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}
