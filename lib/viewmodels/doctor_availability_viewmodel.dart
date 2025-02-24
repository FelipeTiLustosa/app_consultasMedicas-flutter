import 'package:flutter/foundation.dart';
import '../services/doctor_availability_service.dart';
import '../models/doctor_availability.dart';

class DoctorAvailabilityViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  List<DoctorAvailability> _availabilities = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<DoctorAvailability> get availabilities => _availabilities;

  // Inicializar o ViewModel
  Future<void> initialize() async {
    _setLoading(true);
    try {
      await DoctorAvailabilityService.init();
      _availabilities = DoctorAvailabilityService.availabilities;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Carregar disponibilidades de um médico específico
  Future<void> loadDoctorAvailabilities(String doctorId) async {
    _setLoading(true);
    try {
      _availabilities = DoctorAvailabilityService.getDoctorAvailabilities(doctorId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Criar nova disponibilidade
  Future<bool> createAvailability({
    required String doctorId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    _setLoading(true);
    try {
      final availability = await DoctorAvailabilityService.createAvailability(
        doctorId: doctorId,
        startTime: startTime,
        endTime: endTime,
      );
      _availabilities.add(availability);
      _error = null;
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

  // Atualizar disponibilidade
  Future<bool> updateAvailability({
    required String availabilityId,
    DateTime? startTime,
    DateTime? endTime,
    bool? isAvailable,
  }) async {
    _setLoading(true);
    try {
      final updatedAvailability = await DoctorAvailabilityService.updateAvailability(
        availabilityId: availabilityId,
        startTime: startTime,
        endTime: endTime,
        isAvailable: isAvailable,
      );

      if (updatedAvailability != null) {
        final index = _availabilities.indexWhere((a) => a.id == availabilityId);
        if (index != -1) {
          _availabilities[index] = updatedAvailability;
        }
        _error = null;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Remover disponibilidade
  Future<bool> removeAvailability(String availabilityId) async {
    _setLoading(true);
    try {
      await DoctorAvailabilityService.removeAvailability(availabilityId);
      _availabilities.removeWhere((a) => a.id == availabilityId);
      _error = null;
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
}