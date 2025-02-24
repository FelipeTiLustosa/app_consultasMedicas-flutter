import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/doctor_availability_viewmodel.dart';
import '../services/auth_service.dart';

class DoctorAvailabilityView extends StatefulWidget {
  const DoctorAvailabilityView({super.key});

  @override
  State<DoctorAvailabilityView> createState() => _DoctorAvailabilityViewState();
}

class _DoctorAvailabilityViewState extends State<DoctorAvailabilityView> {
  DateTime? _selectedStartTime;
  DateTime? _selectedEndTime;
  final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final doctorId = AuthService.currentUser?.id;
      if (doctorId != null) {
        context.read<DoctorAvailabilityViewModel>().loadDoctorAvailabilities(doctorId);
      }
    });
  }

  Future<void> _selectDateTime(bool isStartTime) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        setState(() {
          final dateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
          if (isStartTime) {
            _selectedStartTime = dateTime;
          } else {
            _selectedEndTime = dateTime;
          }
        });
      }
    }
  }

  Future<void> _createAvailability() async {
    if (_selectedStartTime == null || _selectedEndTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione os horários de início e fim')),
      );
      return;
    }

    if (_selectedEndTime!.isBefore(_selectedStartTime!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('O horário de fim deve ser depois do horário de início')),
      );
      return;
    }

    final doctorId = AuthService.currentUser?.id;
    if (doctorId == null) return;

    final success = await context.read<DoctorAvailabilityViewModel>().createAvailability(
      doctorId: doctorId,
      startTime: _selectedStartTime!,
      endTime: _selectedEndTime!,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Disponibilidade cadastrada com sucesso!')),
      );
      setState(() {
        _selectedStartTime = null;
        _selectedEndTime = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Disponibilidade'),
      ),
      body: Consumer<DoctorAvailabilityViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Adicionar Nova Disponibilidade',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          title: Text(_selectedStartTime != null
                              ? 'Início: ${dateFormat.format(_selectedStartTime!)}'
                              : 'Selecionar horário de início'),
                          trailing: const Icon(Icons.access_time),
                          onTap: () => _selectDateTime(true),
                        ),
                        ListTile(
                          title: Text(_selectedEndTime != null
                              ? 'Fim: ${dateFormat.format(_selectedEndTime!)}'
                              : 'Selecionar horário de fim'),
                          trailing: const Icon(Icons.access_time),
                          onTap: () => _selectDateTime(false),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _createAvailability,
                          child: const Text('Adicionar Disponibilidade'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Disponibilidades Cadastradas',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: viewModel.availabilities.isEmpty
                      ? const Center(
                          child: Text('Nenhuma disponibilidade cadastrada'),
                        )
                      : ListView.builder(
                          itemCount: viewModel.availabilities.length,
                          itemBuilder: (context, index) {
                            final availability = viewModel.availabilities[index];
                            return Card(
                              child: ListTile(
                                title: Text(
                                  'Período: ${dateFormat.format(availability.startTime)} - ${dateFormat.format(availability.endTime)}',
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () async {
                                    final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Confirmar Exclusão'),
                                        content: const Text(
                                            'Deseja realmente excluir esta disponibilidade?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(false),
                                            child: const Text('Cancelar'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(true),
                                            child: const Text('Excluir'),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirmed == true) {
                                      await viewModel
                                          .removeAvailability(availability.id);
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ),
                if (viewModel.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      viewModel.error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}