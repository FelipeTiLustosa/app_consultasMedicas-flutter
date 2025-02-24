import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/appointment.dart';
import '../models/user.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../services/appointment_service.dart';
import '../services/user_service.dart';
import './statistics_view.dart';

class DoctorAppointmentsView extends StatefulWidget {
  const DoctorAppointmentsView({super.key});

  @override
  State<DoctorAppointmentsView> createState() => _DoctorAppointmentsViewState();
}

class _DoctorAppointmentsViewState extends State<DoctorAppointmentsView> with SingleTickerProviderStateMixin {
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

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthViewModel>().currentUser;
    if (currentUser == null || !currentUser.isDoctor) {
      return const Center(child: Text('Acesso não autorizado'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Consultas'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Agendadas'),
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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => _createAppointment(context, currentUser),
            heroTag: 'createAppointment',
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () => _showStatistics(context, currentUser),
            heroTag: 'showStatistics',
            child: const Icon(Icons.analytics),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList(String status, User doctor) {
    final appointments = AppointmentService.getDoctorAppointments(doctor.id)
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
        return _buildAppointmentItem(appointment);
      },
    );
  }

  Widget _buildAppointmentItem(Appointment appointment) {
    return FutureBuilder<User?>(
      future: UserService.getUser(appointment.patientId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (!snapshot.hasData) {
          return const Text('Erro ao carregar dados do paciente');
        }

        final patient = snapshot.data!;
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Text(patient.name),
            subtitle: Text(_dateFormat.format(appointment.dateTime)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (appointment.status == 'scheduled') ...[                  
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _editAppointment(context, appointment),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel),
                    onPressed: () => _cancelAppointment(context, appointment),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _editAppointment(BuildContext context, Appointment appointment) async {
    // Implement edit appointment logic
  }

  Future<void> _cancelAppointment(BuildContext context, Appointment appointment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Cancelamento'),
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
    ) ?? false;

    if (confirmed) {
      await AppointmentService.cancelAppointment(appointment.id);
      setState(() {});
    }
  }

  Future<void> _createAppointment(BuildContext context, User doctor) async {
    // Implement create appointment logic
  }

  void _showStatistics(BuildContext context, User doctor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StatisticsView(doctor: doctor),
      ),
    );
  }
}