class UserModel {
  final int? id; 
  final String name;
  final String email;
  final String password;
  final String? phone;
  final String role;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    this.phone,
    required this.role,
  });

  // Konversi Map (dari DB) ke UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      password: map['password'],
      phone: map['phone'],
      role: map['role'],
    );
  }

  // Konversi UserModel ke Map (untuk DB)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'role': role,
    };
  }
}