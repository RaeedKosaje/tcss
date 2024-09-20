class showFloors {
  int? id;
  String? name;
  String? tokenType;
  String? accessToken;


  showFloors({this.id, this.name,  this.tokenType, this.accessToken,});

  showFloors.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    tokenType = json['token_type'];
    accessToken = json['access_token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;


    return data;
  }
}

