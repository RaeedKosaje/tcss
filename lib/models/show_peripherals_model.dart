class ShowPeripherals {
  int? id;
  String? monitor;
  String? keyboard;
  String? mouse;
  String? printer;
  String? uPS;
  String? cashBox;
  String? barcode;
  int? deviceId;

  ShowPeripherals(
      {this.id,
        this.monitor,
        this.keyboard,
        this.mouse,
        this.printer,
        this.uPS,
        this.cashBox,
        this.barcode,
        this.deviceId});

  ShowPeripherals.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    monitor = json['Monitor'];
    keyboard = json['Keyboard'];
    mouse = json['Mouse'];
    printer = json['Printer'];
    uPS = json['UPS'];
    cashBox = json['cashBox'];
    barcode = json['Barcode'];
    deviceId = json['device_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['Monitor'] = this.monitor;
    data['Keyboard'] = this.keyboard;
    data['Mouse'] = this.mouse;
    data['Printer'] = this.printer;
    data['UPS'] = this.uPS;
    data['cashBox'] = this.cashBox;
    data['Barcode'] = this.barcode;
    data['device_id'] = this.deviceId;
    return data;
  }
}
