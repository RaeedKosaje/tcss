class showMaintenanceServicemodel {
  int? id;
  String? department;
  String? device;
  String? user;
  String? date;
  String? hour;
  String? description;

  showMaintenanceServicemodel(
      {this.id,
        this.department,
        this.device,
        this.user,
        this.date,
        this.hour,
        this.description});

  showMaintenanceServicemodel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    department = json['department'];
    device = json['device'];
    user = json['user'];
    date = json['date'];
    hour = json['hour'];
    description = json['description'];
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
    return data;
  }
}
