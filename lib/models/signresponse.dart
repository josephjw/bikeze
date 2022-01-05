// To parse this JSON data, do
//
//     final signinResponse = signinResponseFromJson(jsonString);

import 'dart:convert';

SigninResponse signinResponseFromJson(String str) =>
    SigninResponse.fromJson(json.decode(str));

String signinResponseToJson(SigninResponse data) => json.encode(data.toJson());

class SigninResponse {
  SigninResponse({
    this.otp,
  });

  String? otp;

  factory SigninResponse.fromJson(Map<String, dynamic> json) => SigninResponse(
        otp: json["otp"],
      );

  Map<String, dynamic> toJson() => {
        "otp": otp,
      };
}
