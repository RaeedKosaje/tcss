class UserModel {
  Data? data;
  int? status;
  String? message;

  UserModel({this.data, this.status, this.message});

  UserModel.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    status = json['status'];
    message = json['message'];
  }
}

class Data {
  User? user;
  String? tokenType;
  String? accessToken;

  Data({
    this.user,
    this.tokenType,
    this.accessToken,
  });

  Data.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    tokenType = json['token_type'];
    accessToken = json['access_token'];
  }
}

class User {
  int? id;
  String? name;
  int? roleId;
  String? createdAt;
  String? updatedAt;

  User({this.id, this.name, this.roleId, this.createdAt, this.updatedAt});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    roleId = json['role_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['role_id'] = this.roleId;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
