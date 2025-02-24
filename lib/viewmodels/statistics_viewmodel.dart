import 'package:flutter/foundation.dart';
import '../services/statistics_service.dart';

class StatisticsViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get total appointments count
  int getTotalAppointments(String doctorId) {
    return StatisticsService.getTotalAppointments(doctorId);
  }

  // Get appointments by status
  Map<String, int> getAppointmentsByStatus(String doctorId) {
    return StatisticsService.getAppointmentsByStatus(doctorId);
  }

  // Get appointments by hour
  Map<int, int> getAppointmentsByHour(String doctorId) {
    return StatisticsService.getAppointmentsByHour(doctorId);
  }

  // Get appointments for last 7 days
  Map<DateTime, int> getAppointmentsLast7Days(String doctorId) {
    return StatisticsService.getAppointmentsLast7Days(doctorId);
  }

  // Get completion rate
  double getCompletionRate(String doctorId) {
    return StatisticsService.getCompletionRate(doctorId);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }
}