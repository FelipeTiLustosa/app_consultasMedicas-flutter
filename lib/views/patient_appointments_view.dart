import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/appointment.dart';
import '../models/user.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../services/appointment_service.dart';

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
          child: ListTile(
            title: Text('Médico: ${appointment.doctorId}'),
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
                ? IconButton(
                    icon: const Icon(Icons.attach_file),
                    onPressed: () => _addAttachment(appointment),
                  )
                : null,
            onTap: () => _showAppointmentDetails(appointment),
          ),
        );
      },
    );
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
              Text('Médico: ${appointment.doctorId}'),
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

  Future<void> _addAttachment(Appointment appointment) async {
    // In a real app, this would use a file picker and upload to storage
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Anexo'),
        content: const Text('Em uma versão completa, aqui você poderia selecionar um arquivo para anexar à consulta.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );

    if (result != null) {
      await AppointmentService.addAttachment(appointment.id, result);
      setState(() {});
    }
  }

  Future<void> _showScheduleAppointment(BuildContext context, User patient) async {
    // In a real app, this would show a form to select doctor, date, and time
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agendar Consulta'),
        content: const Text('Em uma versão completa, aqui você poderia selecionar um médico e horário disponível para agendar uma consulta.'),
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