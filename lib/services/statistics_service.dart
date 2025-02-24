import '../models/appointment.dart';
import '../services/appointment_service.dart';

class StatisticsService {
  // Get total number of appointments for a doctor
  static int getTotalAppointments(String doctorId) {
    return AppointmentService.getDoctorAppointments(doctorId).length;
  }

  // Get number of appointments by status for a doctor
  static Map<String, int> getAppointmentsByStatus(String doctorId) {
    final appointments = AppointmentService.getDoctorAppointments(doctorId);
    return {
      'scheduled': appointments.where((a) => a.status == 'scheduled').length,
      'completed': appointments.where((a) => a.status == 'completed').length,
      'cancelled': appointments.where((a) => a.status == 'cancelled').length,
    };
  }

  // Get appointments distribution by hour of day
  static Map<int, int> getAppointmentsByHour(String doctorId) {
    final appointments = AppointmentService.getDoctorAppointments(doctorId);
    final Map<int, int> hourDistribution = {};

    for (var appointment in appointments) {
      final hour = appointment.dateTime.hour;
      hourDistribution[hour] = (hourDistribution[hour] ?? 0) + 1;
    }

    return hourDistribution;
  }

  // Get appointments count for last 7 days
  static Map<DateTime, int> getAppointmentsLast7Days(String doctorId) {
    final appointments = AppointmentService.getDoctorAppointments(doctorId);
    final Map<DateTime, int> dailyCount = {};
    final now = DateTime.now();

    // Initialize all 7 days with 0
    for (int i = 6; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day - i);
      dailyCount[date] = 0;
    }

    // Count appointments for each day
    for (var appointment in appointments) {
      final date = DateTime(appointment.dateTime.year,
          appointment.dateTime.month, appointment.dateTime.day);
      if (date.isAfter(now.subtract(Duration(days: 7))) &&
          date.isBefore(now.add(Duration(days: 1)))) {
        dailyCount[date] = (dailyCount[date] ?? 0) + 1;
      }
    }

    return dailyCount;
  }

  // Get completion rate (completed appointments / total appointments)
  static double getCompletionRate(String doctorId) {
    final appointments = AppointmentService.getDoctorAppointments(doctorId);
    if (appointments.isEmpty) return 0.0;

    final completedCount =
        appointments.where((a) => a.status == 'completed').length;
    return completedCount / appointments.length;
  }
}