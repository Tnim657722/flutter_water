class UserModel {
  final String id;
  final String username;
  final String password;
  final String role; // 'admin' | 'customer'
  final String fullName;
  final String phone;
  final String address;

  const UserModel({
    required this.id,
    required this.username,
    required this.password,
    required this.role,
    required this.fullName,
    required this.phone,
    required this.address,
  });

  bool get isAdmin => role == 'admin';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      password: json['password'] as String,
      role: json['role'] as String,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'password': password,
    'role': role,
    'full_name': fullName,
    'phone': phone,
    'address': address,
  };
}
