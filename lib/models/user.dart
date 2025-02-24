class User {
  final String id;
  final String email;
  final String name;
  final bool isDoctor;
  final String? specialization; // Only for doctors
  final DateTime birthDate;
  final String phoneNumber;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.isDoctor,
    this.specialization,
    required this.birthDate,
    required this.phoneNumber,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      isDoctor: json['isDoctor'],
      specialization: json['specialization'],
      birthDate: DateTime.parse(json['birthDate']),
      phoneNumber: json['phoneNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'isDoctor': isDoctor,
      'specialization': specialization,
      'birthDate': birthDate.toIso8601String(),
      'phoneNumber': phoneNumber,
    };
  }
}