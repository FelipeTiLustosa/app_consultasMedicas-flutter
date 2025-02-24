class DoctorAvailability {
  final String id;
  final String doctorId;
  final DateTime startTime;
  final DateTime endTime;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime? updatedAt;

  DoctorAvailability({
    required this.id,
    required this.doctorId,
    required this.startTime,
    required this.endTime,
    this.isAvailable = true,
    DateTime? createdAt,
    this.updatedAt,
  }) : this.createdAt = createdAt ?? DateTime.now();

  factory DoctorAvailability.fromJson(Map<String, dynamic> json) {
    return DoctorAvailability(
      id: json['id'],
      doctorId: json['doctorId'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      isAvailable: json['isAvailable'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctorId': doctorId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'isAvailable': isAvailable,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  DoctorAvailability copyWith({
    String? id,
    String? doctorId,
    DateTime? startTime,
    DateTime? endTime,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DoctorAvailability(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}