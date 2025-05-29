class Worker {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String address;
  String image;

  Worker({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.address,
    required this.image,
  });

  factory Worker.fromJson(Map<String, dynamic> json) {
    return Worker(
      id: json['id'].toString(),
      fullName: json['full_name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      image: json['image'] ?? '',
    );
  }
}
