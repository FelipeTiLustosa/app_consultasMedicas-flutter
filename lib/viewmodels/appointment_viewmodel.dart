import 'package:flutter/foundation.dart';
import '../services/appointment_service.dart';
import '../models/appointment.dart';

class AppointmentViewModel extends ChangeNotifier {
  List<Appointment> _appointments = [];
  bool _isLoading = false;
  String? _error;

  List<Appointment> get appointments => _appointments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> initialize() async {
    _setLoading(true);
    try {
      await AppointmentService.init();
      _appointments = AppointmentService.appointments;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  List<Appointment> getDoctorAppointments(String doctorId) {
    return AppointmentService.getDoctorAppointments(doctorId);
  }

  List<Appointment> getPatientAppointments(String patientId) {
    return AppointmentService.getPatientAppointments(patientId);
  }

  Future<bool> createAppointment({
    required String doctorId,
    required String patientId,
    required DateTime dateTime,
    String? notes,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      if (!AppointmentService.isTimeSlotAvailable(doctorId, dateTime)) {
        _error = 'This time slot is not available';
        notifyListeners();
        return false;
      }

      final appointment = await AppointmentService.createAppointment(
        doctorId: doctorId,
        patientId: patientId,
        dateTime: dateTime,
        notes: notes,
      );

      _appointments.add(appointment);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> cancelAppointment(String appointmentId) async {
    _setLoading(true);
    _error = null;

    try {
      await AppointmentService.cancelAppointment(appointmentId);
      _appointments = AppointmentService.appointments;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> loadDoctorAppointments(String doctorId) async {
    _setLoading(true);
    try {
      _appointments = AppointmentService.getDoctorAppointments(doctorId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateAppointmentStatus({
    required String appointmentId,
    required String status,
  }) async {
    _setLoading(true);
    try {
      await AppointmentService.updateAppointmentStatus(appointmentId, status);
      _appointments = AppointmentService.appointments;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }
}