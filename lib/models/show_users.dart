class ShowUsers {
  int? id;
  String? name;
  int? roleId;
  String? createdAt;
  String? updatedAt;

  ShowUsers({this.id, this.name, this.roleId, this.createdAt, this.updatedAt});

  ShowUsers.fromJson(Map<String, dynamic> json) {
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
