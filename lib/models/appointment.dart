class Appointment {
  final String id;
  final String doctorId;
  final String patientId;
  final DateTime dateTime;
  final String status; // 'scheduled', 'completed', 'cancelled'
  final String? notes;
  final List<String> attachments; // List of file paths
  final DateTime createdAt;
  final DateTime? updatedAt;

  Appointment({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.dateTime,
    required this.status,
    this.notes,
    this.attachments = const [],
    DateTime? createdAt,
    this.updatedAt,
  }) : this.createdAt = createdAt ?? DateTime.now();

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      doctorId: json['doctorId'],
      patientId: json['patientId'],
      dateTime: DateTime.parse(json['dateTime']),
      status: json['status'],
      notes: json['notes'],
      attachments: List<String>.from(json['attachments'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctorId': doctorId,
      'patientId': patientId,
      'dateTime': dateTime.toIso8601String(),
      'status': status,
      'notes': notes,
      'attachments': attachments,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Appointment copyWith({
    String? id,
    String? doctorId,
    String? patientId,
    DateTime? dateTime,
    String? status,
    String? notes,
    List<String>? attachments,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Appointment(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      patientId: patientId ?? this.patientId,
      dateTime: dateTime ?? this.dateTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      attachments: attachments ?? this.attachments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}