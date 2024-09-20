class ShowDepartments {
  int? id;
  String? name;
  String? note;
  int? floorId;
  String? createdAt;
  String? updatedAt;
  Floor? floor;

  ShowDepartments(
      {this.id,
        this.name,
        this.note,
        this.floorId,
        this.createdAt,
        this.updatedAt,
        this.floor});

  ShowDepartments.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    note = json['Note'];
    floorId = json['floor_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    floor = json['floor'] != null ? new Floor.fromJson(json['floor']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['Note'] = this.note;
    data['floor_id'] = this.floorId;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.floor != null) {
      data['floor'] = this.floor!.toJson();
    }
    return data;
  }
}

class Floor {
  int? id;
  String? name;
  String? note;


  Floor({this.id, this.name,this.note});

  Floor.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    note = json['note'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['note'] = this.note;
    return data;
  }
}
