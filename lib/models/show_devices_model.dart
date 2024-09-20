class ShowDevices {
  int? id;
  String? name;
  String? type;
  String? description;
  String? note;
  int? departmentId;
  String? createdAt;
  String? updatedAt;
  Department? department;

  ShowDevices(
      {this.id,
        this.name,
        this.type,
        this.description,
        this.note,
        this.departmentId,
        this.createdAt,
        this.updatedAt,
        this.department});

  ShowDevices.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    type = json['type'];
    description = json['description'];
    note = json['Note'];
    departmentId = json['department_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    department = json['department'] != null
        ? new Department.fromJson(json['department'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['type'] = this.type;
    data['description'] = this.description;
    data['Note'] = this.note;
    data['department_id'] = this.departmentId;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.department != null) {
      data['department'] = this.department!.toJson();
    }
    return data;
  }
}

class Department {
  int? id;
  String? name;

  Department({this.id, this.name});

  Department.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    return data;
  }
}
