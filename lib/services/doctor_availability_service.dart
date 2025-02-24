import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/doctor_availability.dart';

class DoctorAvailabilityService {
  static const String _availabilityKey = 'doctor_availability';
  static List<DoctorAvailability> _availabilities = [];

  // Inicializar disponibilidades
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final availabilityData = prefs.getString(_availabilityKey);
    if (availabilityData != null) {
      final List<dynamic> decodedData = jsonDecode(availabilityData);
      _availabilities = decodedData.map((json) => DoctorAvailability.fromJson(json)).toList();
    }
  }

  // Obter todas as disponibilidades
  static List<DoctorAvailability> get availabilities => _availabilities;

  // Obter disponibilidades de um médico específico
  static List<DoctorAvailability> getDoctorAvailabilities(String doctorId) {
    return _availabilities
        .where((availability) => 
            availability.doctorId == doctorId && 
            availability.endTime.isAfter(DateTime.now()) &&
            availability.isAvailable)
        .toList();
  }

  // Criar nova disponibilidade
  static Future<DoctorAvailability> createAvailability({
    required String doctorId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    // Verificar se já existe disponibilidade para este período
    final hasConflict = _availabilities.any((availability) =>
        availability.doctorId == doctorId &&
        availability.isAvailable &&
        ((startTime.isAfter(availability.startTime) &&
            startTime.isBefore(availability.endTime)) ||
            (endTime.isAfter(availability.startTime) &&
                endTime.isBefore(availability.endTime))));

    if (hasConflict) {
      throw Exception('Já existe disponibilidade cadastrada para este período');
    }

    final availability = DoctorAvailability(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      doctorId: doctorId,
      startTime: startTime,
      endTime: endTime,
    );

    _availabilities.add(availability);
    await _saveAvailabilities();
    return availability;
  }

  // Atualizar disponibilidade
  static Future<DoctorAvailability?> updateAvailability({
    required String availabilityId,
    DateTime? startTime,
    DateTime? endTime,
    bool? isAvailable,
  }) async {
    final index = _availabilities.indexWhere((availability) => availability.id == availabilityId);
    if (index != -1) {
      _availabilities[index] = _availabilities[index].copyWith(
        startTime: startTime,
        endTime: endTime,
        isAvailable: isAvailable,
        updatedAt: DateTime.now(),
      );
      await _saveAvailabilities();
      return _availabilities[index];
    }
    return null;
  }

  // Remover disponibilidade
  static Future<void> removeAvailability(String availabilityId) async {
    _availabilities.removeWhere((availability) => availability.id == availabilityId);
    await _saveAvailabilities();
  }

  // Salvar disponibilidades no armazenamento
  static Future<void> _saveAvailabilities() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _availabilityKey,
      jsonEncode(_availabilities.map((availability) => availability.toJson()).toList()),
    );
  }
}