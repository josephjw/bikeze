import 'dart:convert';

ProfileRequest signinRequestFromJson(String str) =>
    ProfileRequest.fromJson(json.decode(str));

String signinRequestToJson(ProfileRequest data) => json.encode(data.toJson());

class ProfileRequest {
  ProfileRequest({
    this.mobile,
  });

  String? mobile;

  factory ProfileRequest.fromJson(Map<String, dynamic> json) => ProfileRequest(
        mobile: json["mobile"],
      );

  Map<String, dynamic> toJson() => {
        "mobile": mobile,
      };
}
