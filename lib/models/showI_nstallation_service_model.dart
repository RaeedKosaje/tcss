class ShowInstallationServiceModel {
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
  List<Materials>? materials;

  ShowInstallationServiceModel(
      {this.id,
        this.departmentId,
        this.deviceId,
        this.userId,
        this.description,
        this.createdAt,
        this.updatedAt,
        this.device,
        this.department,
        this.user,
        this.materials});

  ShowInstallationServiceModel.fromJson(Map<String, dynamic> json) {
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
    if (json['materials'] != null) {
      materials = <Materials>[];
      json['materials'].forEach((v) {
        materials!.add(new Materials.fromJson(v));
      });
    }
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
    if (this.materials != null) {
      data['materials'] = this.materials!.map((v) => v.toJson()).toList();
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

class Materials {
  String? name;
  Pivot? pivot;

  Materials({this.name, this.pivot});

  Materials.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    pivot = json['pivot'] != null ? new Pivot.fromJson(json['pivot']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    if (this.pivot != null) {
      data['pivot'] = this.pivot!.toJson();
    }
    return data;
  }
}

class Pivot {
  int? installationServiceId;
  int? materialId;
  int? quantity;

  Pivot({this.installationServiceId, this.materialId, this.quantity});

  Pivot.fromJson(Map<String, dynamic> json) {
    installationServiceId = json['installation_service_id'];
    materialId = json['material_id'];
    quantity = json['quantity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['installation_service_id'] = this.installationServiceId;
    data['material_id'] = this.materialId;
    data['quantity'] = this.quantity;
    return data;
  }
}
