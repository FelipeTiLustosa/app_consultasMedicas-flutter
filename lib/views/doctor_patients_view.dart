import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/appointment_viewmodel.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import '../models/appointment.dart';

class DoctorPatientsView extends StatefulWidget {
  const DoctorPatientsView({super.key});

  @override
  State<DoctorPatientsView> createState() => _DoctorPatientsViewState();
}

class _DoctorPatientsViewState extends State<DoctorPatientsView> {
  final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
  Map<String, User> _patients = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAppointments();
    });
  }

  Future<void> _loadAppointments() async {
    final doctorId = AuthService.currentUser?.id;
    if (doctorId != null) {
      await context.read<AppointmentViewModel>().loadDoctorAppointments(doctorId);
    }
  }

  Future<void> _showAppointmentDetails(Appointment appointment, User patient) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detalhes da Consulta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Paciente: ${patient.name}'),
            Text('Data: ${dateFormat.format(appointment.dateTime)}'),
            Text('Status: ${_getStatusText(appointment.status)}'),
            if (appointment.notes != null) ...[              
              const SizedBox(height: 8),
              const Text('Observações:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(appointment.notes!),
            ],
          ],
        ),
        actions: [
          if (appointment.status == 'scheduled') ...[            
            TextButton(
              onPressed: () async {
                await context.read<AppointmentViewModel>().updateAppointmentStatus(
                  appointmentId: appointment.id,
                  status: 'cancelled',
                );
                if (mounted) {
                  Navigator.of(context).pop();
                  _loadAppointments();
                }
              },
              child: const Text('Cancelar Consulta'),
            ),
            TextButton(
              onPressed: () async {
                await context.read<AppointmentViewModel>().updateAppointmentStatus(
                  appointmentId: appointment.id,
                  status: 'completed',
                );
                if (mounted) {
                  Navigator.of(context).pop();
                  _loadAppointments();
                }
              },
              child: const Text('Marcar como Realizada'),
            ),
          ],
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'scheduled':
        return 'Agendada';
      case 'completed':
        return 'Realizada';
      case 'cancelled':
        return 'Cancelada';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Pacientes'),
      ),
      body: Consumer<AppointmentViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final appointments = viewModel.appointments;
          if (appointments.isEmpty) {
            return const Center(
              child: Text('Nenhuma consulta encontrada'),
            );
          }

          // Agrupar consultas por paciente
          final patientAppointments = <String, List<Appointment>>{};
          for (var appointment in appointments) {
            if (!patientAppointments.containsKey(appointment.patientId)) {
              patientAppointments[appointment.patientId] = [];
            }
            patientAppointments[appointment.patientId]!.add(appointment);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: patientAppointments.length,
            itemBuilder: (context, index) {
              final patientId = patientAppointments.keys.elementAt(index);
              final patientAppointmentList = patientAppointments[patientId]!;
              final lastAppointment = patientAppointmentList.reduce(
                (a, b) => a.dateTime.isAfter(b.dateTime) ? a : b,
              );

              return Card(
                child: ExpansionTile(
                  title: Text(lastAppointment.patientId),
                  subtitle: Text(
                    'Última consulta: ${dateFormat.format(lastAppointment.dateTime)}',
                  ),
                  children: patientAppointmentList.map((appointment) {
                    return ListTile(
                      title: Text(
                        'Data: ${dateFormat.format(appointment.dateTime)}',
                      ),
                      subtitle: Text('Status: ${_getStatusText(appointment.status)}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.info_outline),
                        onPressed: () => _showAppointmentDetails(
                          appointment,
                          User(
                            id: appointment.patientId,
                            email: '',
                            name: appointment.patientId,
                            isDoctor: false,
                            birthDate: DateTime.now(),
                            phoneNumber: '',
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}