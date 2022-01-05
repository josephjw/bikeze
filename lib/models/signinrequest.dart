import 'dart:convert';

SigninRequest signinRequestFromJson(String str) =>
    SigninRequest.fromJson(json.decode(str));

String signinRequestToJson(SigninRequest data) => json.encode(data.toJson());

class SigninRequest {
  SigninRequest({
    this.mobile,
  });

  String? mobile;

  factory SigninRequest.fromJson(Map<String, dynamic> json) => SigninRequest(
        mobile: json["mobile"],
      );

  Map<String, dynamic> toJson() => {
        "mobile": mobile,
      };
}
