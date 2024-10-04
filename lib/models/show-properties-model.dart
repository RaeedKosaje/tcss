class ShowProperties {
  int? id;
  String? cPU;
  String? motherboard;
  String? rAM;
  String? hard;
  String? graphics;
  String? powerSupply;
  String? oS;
  String? nIC;
  int? deviceId;
  String? createdAt;
  String? updatedAt;

  ShowProperties(
      {this.id,
        this.cPU,
        this.motherboard,
        this.rAM,
        this.hard,
        this.graphics,
        this.powerSupply,
        this.oS,
        this.nIC,
        this.deviceId,
        this.createdAt,
        this.updatedAt});

  ShowProperties.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    cPU = json['CPU'];
    motherboard = json['Motherboard'];
    rAM = json['RAM'];
    hard = json['Hard'];
    graphics = json['Graphics'];
    powerSupply = json['powerSupply'];
    oS = json['OS'];
    nIC = json['NIC'];
    deviceId = json['device_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['CPU'] = this.cPU;
    data['Motherboard'] = this.motherboard;
    data['RAM'] = this.rAM;
    data['Hard'] = this.hard;
    data['Graphics'] = this.graphics;
    data['powerSupply'] = this.powerSupply;
    data['OS'] = this.oS;
    data['NIC'] = this.nIC;
    data['device_id'] = this.deviceId;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
