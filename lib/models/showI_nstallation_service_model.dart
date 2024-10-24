class ShowInstallationServiceModel {
  int? id;
  String? department;
  String? device;
  String? user;
  String? date;
  String? hour;
  String? description;
  List<Materials>? materials;

  ShowInstallationServiceModel(
      {this.id,
        this.department,
        this.device,
        this.user,
        this.date,
        this.hour,
        this.description,
        this.materials});

  ShowInstallationServiceModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    department = json['department'];
    device = json['device'];
    user = json['user'];
    date = json['date'];
    hour = json['hour'];
    description = json['description'];
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
    data['department'] = this.department;
    data['device'] = this.device;
    data['user'] = this.user;
    data['date'] = this.date;
    data['hour'] = this.hour;
    data['description'] = this.description;
    if (this.materials != null) {
      data['materials'] = this.materials!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Materials {
  String? name;
  int? quantity;

  Materials({this.name, this.quantity});

  Materials.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    quantity = json['quantity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['quantity'] = this.quantity;
    return data;
  }
}
