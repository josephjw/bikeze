// To parse this JSON data, do
//
//     final profileResponse = profileResponseFromJson(jsonString);

import 'dart:convert';

ProfileResponse profileResponseFromJson(String str) =>
    ProfileResponse.fromJson(json.decode(str));

String profileResponseToJson(ProfileResponse data) =>
    json.encode(data.toJson());

class ProfileResponse {
  ProfileResponse({
    this.p_id,
    this.g_name,
    this.g_cat,
    this.owner_name,
    this.email,
    this.mobile_no,
    this.city,
    this.locality,
    this.g_image,
    this.mobile_otp,
    this.p_status,
    this.image,
  });

  String? p_id;
  String? g_name;
  String? g_cat;
  String? owner_name;
  String? email;
  String? mobile_no;
  String? city;
  String? locality;
  String? g_image;
  String? mobile_otp;
  String? p_status;
  String? image;

  factory ProfileResponse.fromJson(Map<String, dynamic> json) =>
      ProfileResponse(
        p_id: json["p_id"],
        g_name: json["g_name"],
        g_cat: json["g_cat"],
        owner_name: json["owner_name"],
        email: json["email"],
        mobile_no: json["mobile_no"],
        city: json["city"],
        locality: json["locality"],
        g_image: json["g_image"],
        mobile_otp: json["mobile_otp"],
        p_status: json["p_status"],
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "p_id": p_id,
        "g_name": g_name,
        "g_cat": g_cat,
        "owner_name": owner_name,
        "email": email,
        "mobile_no": mobile_no,
        "city": city,
        "locality": locality,
        "g_image": g_image,
        "mobile_otp": mobile_otp,
        "p_status": p_status,
        "image": image,
      };
}
