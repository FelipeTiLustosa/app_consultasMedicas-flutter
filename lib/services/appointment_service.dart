import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/appointment.dart';

class AppointmentService {
  static const String _appointmentsKey = 'appointments';
  static List<Appointment> _appointments = [];

  // Initialize appointments
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final appointmentsData = prefs.getString(_appointmentsKey);
    if (appointmentsData != null) {
      final List<dynamic> decodedData = jsonDecode(appointmentsData);
      _appointments =
          decodedData.map((json) => Appointment.fromJson(json)).toList();
    }
  }

  // Get all appointments
  static List<Appointment> get appointments => _appointments;

  // Get appointments for a specific doctor
  static List<Appointment> getDoctorAppointments(String doctorId) {
    return _appointments
        .where((appointment) => appointment.doctorId == doctorId)
        .toList();
  }

  // Get appointments for a specific patient
  static List<Appointment> getPatientAppointments(String patientId) {
    return _appointments
        .where((appointment) => appointment.patientId == patientId)
        .toList();
  }

  // Create a new appointment
  static Future<Appointment> createAppointment({
    required String doctorId,
    required String patientId,
    required DateTime dateTime,
    String? notes,
  }) async {
    // Check if appointment already exists
    final existingAppointment = _appointments.any((appointment) =>
        appointment.doctorId == doctorId &&
        appointment.dateTime.isAtSameMomentAs(dateTime) &&
        appointment.status != 'cancelled');

    if (existingAppointment) {
      throw Exception('Já existe uma consulta agendada para este horário');
    }

    final appointment = Appointment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      doctorId: doctorId,
      patientId: patientId,
      dateTime: dateTime,
      status: 'scheduled',
      notes: notes,
      attachments: [], // Removing attachments feature
    );

    _appointments.add(appointment);
    await _saveAppointments();
    return appointment;
  }

  // Update appointment
  static Future<Appointment?> updateAppointment({
    required String appointmentId,
    DateTime? dateTime,
    String? status,
    String? notes,
    List<String>? attachments,
  }) async {
    final index = _appointments
        .indexWhere((appointment) => appointment.id == appointmentId);
    if (index != -1) {
      _appointments[index] = _appointments[index].copyWith(
        dateTime: dateTime,
        status: status,
        notes: notes,
        attachments: attachments,
        updatedAt: DateTime.now(),
      );
      await _saveAppointments();
      return _appointments[index];
    }
    return null;
  }

  // Update appointment status
  static Future<void> updateAppointmentStatus(
      String appointmentId, String status) async {
    await updateAppointment(appointmentId: appointmentId, status: status);
  }

  // Cancel appointment
  static Future<void> cancelAppointment(String appointmentId) async {
    final appointment = _appointments.firstWhere(
        (appointment) => appointment.id == appointmentId,
        orElse: () => throw Exception('Consulta não encontrada'));

    if (appointment.status == 'cancelled') {
      throw Exception('Esta consulta já foi cancelada');
    }

    await updateAppointmentStatus(appointmentId, 'cancelled');
  }

  // Save appointments to storage
  static Future<void> _saveAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    final appointmentsJson =
        jsonEncode(_appointments.map((a) => a.toJson()).toList());
    await prefs.setString(_appointmentsKey, appointmentsJson);
  }

  // Check if time slot is available
  static bool isTimeSlotAvailable(String doctorId, DateTime dateTime) {
    return !_appointments.any((appointment) =>
        appointment.doctorId == doctorId &&
        appointment.dateTime.year == dateTime.year &&
        appointment.dateTime.month == dateTime.month &&
        appointment.dateTime.day == dateTime.day &&
        appointment.dateTime.hour == dateTime.hour &&
        appointment.status != 'cancelled');
  }

  // Add attachment to appointment
  static Future<bool> addAttachment(
      String appointmentId, String filePath) async {
    final index = _appointments
        .indexWhere((appointment) => appointment.id == appointmentId);
    if (index != -1) {
      final currentAttachments =
          List<String>.from(_appointments[index].attachments);
      if (!currentAttachments.contains(filePath)) {
        currentAttachments.add(filePath);
        await updateAppointment(
          appointmentId: appointmentId,
          attachments: currentAttachments,
        );
        return true;
      }
    }
    return false;
  }

  // Remove attachment from appointment
  static Future<bool> removeAttachment(
      String appointmentId, String filePath) async {
    final index = _appointments
        .indexWhere((appointment) => appointment.id == appointmentId);
    if (index != -1) {
      final currentAttachments =
          List<String>.from(_appointments[index].attachments);
      if (currentAttachments.remove(filePath)) {
        await updateAppointment(
          appointmentId: appointmentId,
          attachments: currentAttachments,
        );
        return true;
      }
    }
    return false;
  }

  // Get appointments statistics for a doctor
  static Map<String, dynamic> getDoctorStatistics(String doctorId) {
    final doctorAppointments = getDoctorAppointments(doctorId);

    // Total appointments
    final totalAppointments = doctorAppointments.length;

    // Appointments by status
    final Map<String, int> appointmentsByStatus = {
      'scheduled': 0,
      'completed': 0,
      'cancelled': 0,
    };

    for (var appointment in doctorAppointments) {
      appointmentsByStatus[appointment.status] =
          (appointmentsByStatus[appointment.status] ?? 0) + 1;
    }

    // Most common appointment hours
    final Map<int, int> appointmentsByHour = {};
    for (var appointment in doctorAppointments) {
      final hour = appointment.dateTime.hour;
      appointmentsByHour[hour] = (appointmentsByHour[hour] ?? 0) + 1;
    }

    return {
      'totalAppointments': totalAppointments,
      'appointmentsByStatus': appointmentsByStatus,
      'appointmentsByHour': appointmentsByHour,
    };
  }
}