// To parse this JSON data, do
//
//     final otpResponse = otpResponseFromJson(jsonString);

import 'dart:convert';

OtpResponse otpResponseFromJson(String str) =>
    OtpResponse.fromJson(json.decode(str));

String otpResponseToJson(OtpResponse data) => json.encode(data.toJson());

class OtpResponse {
  OtpResponse({
    this.pId,
    this.gName,
    this.gCat,
    this.ownerName,
    this.email,
    this.mobileNo,
    this.city,
    this.locality,
    this.gImage,
    this.mobileOtp,
    this.pStatus,
  });

  String? pId;
  String? gName;
  String? gCat;
  String? ownerName;
  String? email;
  String? mobileNo;
  String? city;
  String? locality;
  String? gImage;
  String? mobileOtp;
  String? pStatus;

  factory OtpResponse.fromJson(Map<String, dynamic> json) => OtpResponse(
        pId: json["p_id"],
        gName: json["g_name"],
        gCat: json["g_cat"],
        ownerName: json["owner_name"],
        email: json["email"],
        mobileNo: json["mobile_no"],
        city: json["city"],
        locality: json["locality"],
        gImage: json["g_image"],
        mobileOtp: json["mobile_otp"],
        pStatus: json["p_status"],
      );

  Map<String, dynamic> toJson() => {
        "p_id": pId,
        "g_name": gName,
        "g_cat": gCat,
        "owner_name": ownerName,
        "email": email,
        "mobile_no": mobileNo,
        "city": city,
        "locality": locality,
        "g_image": gImage,
        "mobile_otp": mobileOtp,
        "p_status": pStatus,
      };
}
