import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/appointment.dart';
import '../models/user.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../services/appointment_service.dart';

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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showStatistics(context, currentUser),
        child: const Icon(Icons.analytics),
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
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Text('Paciente: ${appointment.patientId}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Data: ${_dateFormat.format(appointment.dateTime)}'),
                if (appointment.notes != null)
                  Text('Observações: ${appointment.notes}'),
                Text('Anexos: ${appointment.attachments.length}'),
              ],
            ),
            trailing: status == 'scheduled'
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check),
                        onPressed: () => _completeAppointment(appointment),
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel),
                        onPressed: () => _cancelAppointment(appointment),
                      ),
                    ],
                  )
                : null,
            onTap: () => _showAppointmentDetails(appointment),
          ),
        );
      },
    );
  }

  Future<void> _completeAppointment(Appointment appointment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Conclusão'),
        content: const Text('Deseja marcar esta consulta como concluída?'),
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

    if (confirmed == true) {
      await AppointmentService.updateAppointmentStatus(appointment.id, 'completed');
      setState(() {});
    }
  }

  Future<void> _cancelAppointment(Appointment appointment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Cancelamento'),
        content: const Text('Deseja cancelar esta consulta?'),
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
  }

  void _showAppointmentDetails(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detalhes da Consulta'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Paciente: ${appointment.patientId}'),
              Text('Data: ${_dateFormat.format(appointment.dateTime)}'),
              Text('Status: ${appointment.status}'),
              if (appointment.notes != null)
                Text('Observações: ${appointment.notes}'),
              const SizedBox(height: 16),
              if (appointment.attachments.isNotEmpty) ...[  
                const Text('Anexos:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...appointment.attachments.map((path) => Text('- $path')),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _showStatistics(BuildContext context, User doctor) {
    final stats = AppointmentService.getDoctorStatistics(doctor.id);
    final mostCommonHour = stats['appointmentsByHour'].entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Estatísticas'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total de consultas: ${stats['totalAppointments']}'),
            const SizedBox(height: 8),
            Text('Agendadas: ${stats['appointmentsByStatus']['scheduled']}'),
            Text('Concluídas: ${stats['appointmentsByStatus']['completed']}'),
            Text('Canceladas: ${stats['appointmentsByStatus']['cancelled']}'),
            const SizedBox(height: 8),
            Text('Horário mais comum: ${mostCommonHour}:00'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}