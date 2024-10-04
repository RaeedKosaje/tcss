class Hardwarekey {
  int? id;
  String? type;
  String? sereal;
  String? exDate;
  String? description;
  int? deviceId;

  Hardwarekey(
      {this.id,
        this.type,
        this.sereal,
        this.exDate,
        this.description,
        this.deviceId});

  Hardwarekey.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    sereal = json['sereal'];
    exDate = json['exDate'];
    description = json['description'];
    deviceId = json['device_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['type'] = this.type;
    data['sereal'] = this.sereal;
    data['exDate'] = this.exDate;
    data['description'] = this.description;
    data['device_id'] = this.deviceId;
    return data;
  }
}
