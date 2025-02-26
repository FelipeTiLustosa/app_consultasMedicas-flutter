import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/appointment.dart';
import '../models/user.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../services/appointment_service.dart';
import '../services/user_service.dart';
import '../views/schedule_appointment_view.dart';

class PatientAppointmentsView extends StatefulWidget {
  const PatientAppointmentsView({super.key});

  @override
  State<PatientAppointmentsView> createState() => _PatientAppointmentsViewState();
}

class _PatientAppointmentsViewState extends State<PatientAppointmentsView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openFile(String filePath) async {
    final url = Uri.parse(filePath);
    try {
      if (!await launchUrl(url)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Não foi possível abrir o arquivo')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao abrir o arquivo')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthViewModel>().currentUser;
    if (currentUser == null || currentUser.isDoctor) {
      return const Center(child: Text('Acesso não autorizado'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Consultas'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Próximas'),
            Tab(text: 'Concluídas'),
            Tab(text: 'Canceladas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAppointmentsList('scheduled', currentUser),
          _buildAppointmentsList('completed', currentUser),
          _buildAppointmentsList('cancelled', currentUser),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showScheduleAppointment(context, currentUser),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAppointmentsList(String status, User patient) {
    final appointments = AppointmentService.getPatientAppointments(patient.id)
        .where((appointment) => appointment.status == status)
        .toList();

    if (appointments.isEmpty) {
      return Center(
        child: Text(
          status == 'scheduled'
              ? 'Nenhuma consulta agendada'
              : status == 'completed'
                  ? 'Nenhuma consulta concluída'
                  : 'Nenhuma consulta cancelada',
        ),
      );
    }

    return ListView.builder(
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: ExpansionTile(
            title: FutureBuilder<User?>(
              future: UserService.getUser(appointment.doctorId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text('Carregando...');
                }
                final doctor = snapshot.data;
                return Text('Médico: ${doctor?.name ?? 'Não encontrado'}');
              },
            ),
            subtitle: Text('Data: ${_dateFormat.format(appointment.dateTime)}'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (appointment.notes != null) ...[                      
                      Text('Observações:', style: Theme.of(context).textTheme.titleSmall),
                      Text(appointment.notes!),
                      const SizedBox(height: 8),
                    ],
                    if (appointment.attachments.isNotEmpty) ...[                      
                      Text('Documentos:', style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        children: appointment.attachments.map((filePath) {
                          return Chip(
                            label: Text(filePath.split('/').last),
                            onDeleted: () => _openFile(filePath),
                          );
                        }).toList(),
                      ),
                    ],
                    if (status == 'scheduled')
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Cancelar Consulta'),
                                  content: const Text('Deseja realmente cancelar esta consulta?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: const Text('Não'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(true),
                                      child: const Text('Sim'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmed == true) {
                                await AppointmentService.cancelAppointment(appointment.id);
                                setState(() {});
                              }
                            },
                            child: const Text('Cancelar Consulta'),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showScheduleAppointment(BuildContext context, User patient) {
    // Navigate to schedule appointment view
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ScheduleAppointmentView(doctor: patient),
      ),
    );
  }
}