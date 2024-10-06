class Showmaterial {
  int? id;
  String? code;
  String? name;
  int? quantity;
  int? price;
  String? createdAt;
  String? updatedAt;

  Showmaterial(
      {this.id,
        this.code,
        this.name,
        this.quantity,
        this.price,
        this.createdAt,
        this.updatedAt});

  Showmaterial.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    name = json['name'];
    quantity = json['quantity'];
    price = json['price'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['code'] = this.code;
    data['name'] = this.name;
    data['quantity'] = this.quantity;
    data['price'] = this.price;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
