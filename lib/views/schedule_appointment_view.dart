import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/doctor_availability_viewmodel.dart';
import '../viewmodels/appointment_viewmodel.dart';
import '../services/auth_service.dart';
import '../models/doctor_availability.dart';
import '../models/user.dart';

class ScheduleAppointmentView extends StatefulWidget {
  final User doctor;

  const ScheduleAppointmentView({super.key, required this.doctor});

  @override
  State<ScheduleAppointmentView> createState() => _ScheduleAppointmentViewState();
}

class _ScheduleAppointmentViewState extends State<ScheduleAppointmentView> {
  final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<DoctorAvailabilityViewModel>()
          .loadDoctorAvailabilities(widget.doctor.id);
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _scheduleAppointment(DoctorAvailability availability) async {
    final patient = AuthService.currentUser;
    if (patient == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Agendamento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Médico: ${widget.doctor.name}'),
            if (widget.doctor.specialization != null)
              Text('Especialização: ${widget.doctor.specialization}'),
            Text('Data: ${dateFormat.format(availability.startTime)}'),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Observações (opcional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context.read<AppointmentViewModel>().createAppointment(
            doctorId: widget.doctor.id,
            patientId: patient.id,
            dateTime: availability.startTime,
            notes: _notesController.text.isNotEmpty ? _notesController.text : null,
          );

      if (success && mounted) {
        // Atualizar a disponibilidade do médico
        await context.read<DoctorAvailabilityViewModel>().updateAvailability(
              availabilityId: availability.id,
              isAvailable: false,
            );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Consulta agendada com sucesso!')),
        );
        Navigator.of(context).pop(); // Voltar para a tela anterior
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agendar com ${widget.doctor.name}'),
      ),
      body: Consumer<DoctorAvailabilityViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.availabilities.isEmpty) {
            return const Center(
              child: Text('Não há horários disponíveis para agendamento.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: viewModel.availabilities.length,
            itemBuilder: (context, index) {
              final availability = viewModel.availabilities[index];
              return Card(
                child: ListTile(
                  title: Text(
                    'Horário: ${dateFormat.format(availability.startTime)}',
                  ),
                  subtitle: Text(
                    'Duração: ${availability.endTime.difference(availability.startTime).inMinutes} minutos',
                  ),
                  trailing: ElevatedButton(
                    onPressed: () => _scheduleAppointment(availability),
                    child: const Text('Agendar'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}