class showMaintenanceServicemodel {
  int? id;
  int? departmentId;
  int? deviceId;
  int? userId;
  String? description;
  String? createdAt;
  String? updatedAt;
  Device? device;
  Device? department;
  Device? user;

  showMaintenanceServicemodel(
      {this.id,
        this.departmentId,
        this.deviceId,
        this.userId,
        this.description,
        this.createdAt,
        this.updatedAt,
        this.device,
        this.department,
        this.user});

  showMaintenanceServicemodel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    departmentId = json['department_id'];
    deviceId = json['device_id'];
    userId = json['user_id'];
    description = json['description'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    device =
    json['device'] != null ? new Device.fromJson(json['device']) : null;
    department = json['department'] != null
        ? new Device.fromJson(json['department'])
        : null;
    user = json['user'] != null ? new Device.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['department_id'] = this.departmentId;
    data['device_id'] = this.deviceId;
    data['user_id'] = this.userId;
    data['description'] = this.description;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.device != null) {
      data['device'] = this.device!.toJson();
    }
    if (this.department != null) {
      data['department'] = this.department!.toJson();
    }
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    return data;
  }
}

class Device {
  int? id;
  String? name;

  Device({this.id, this.name});

  Device.fromJson(Map<String, dynamic> json) {
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




