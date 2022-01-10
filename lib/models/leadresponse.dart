// To parse this JSON data, do
//
//     final leadResponse = leadResponseFromJson(jsonString);

import 'dart:convert';

import 'dart:ffi';

List<LeadResponse> leadResponseFromJson(String str) => List<LeadResponse>.from(
    json.decode(str).map((x) => LeadResponse.fromJson(x)));

String leadResponseToJson(List<LeadResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class LeadResponse {
  LeadResponse({
    this.lead_id,
    this.package,
    this.user_name,
    this.booking_date,
    this.vehicle,
    this.mobile_no,
    this.location,
    this.payment,
    this.assign,
    this.remarks,
    this.est_price_boolval,
    this.image_boolval
  });

  String? lead_id;
  String? package;
  String? user_name;
  String? booking_date;
  String? vehicle;
  String? mobile_no;
  String? location;
  String? payment;
  String? assign;
  String? remarks;
  bool? est_price_boolval;
  bool? image_boolval;

  factory LeadResponse.fromJson(Map<String, dynamic> json) => LeadResponse(

        lead_id: json["lead_id"],
        package: json["package"],
        user_name: json["user_name"],
        booking_date: json["booking_date"],
        vehicle: json["vehicle"],
        mobile_no: json["mobile_no"],
        location: json["location"],
        payment: json["payment"],
        assign: json["assign"],
        remarks: json["remarks"],
    est_price_boolval: json["est_price_boolval"].toString()=="true",
    image_boolval:  json["image_boolval"].toString()=="true",

  );

  Map<String, dynamic> toJson() => {
        "lead_id": lead_id,
        "package": package,
        "user_name": user_name,
        "booking_date": booking_date,
        "vehicle": vehicle,
        "mobile_no": mobile_no,
        "location": location,
        "payment": payment,
        "assign": assign,
        "remarks": remarks,
    "est_price_boolval": remarks,
    "image_boolval": remarks,

  };
}
