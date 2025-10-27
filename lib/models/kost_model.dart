class KostModel {
  final int? id;
  final int userId; 
  final String name;
  final String? address;
  final int pricePerMonth;
  final String? gender; 

  KostModel({
    this.id,
    required this.userId,
    required this.name,
    this.address,
    required this.pricePerMonth,
    this.gender,
  });

  factory KostModel.fromMap(Map<String, dynamic> map) {
    return KostModel(
      id: map['id'],
      userId: map['user_id'],
      name: map['name'],
      address: map['address'],
      pricePerMonth: map['price_per_month'],
      gender: map['gender'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'address': address,
      'price_per_month': pricePerMonth,
      'gender': gender,
    };
  }
}