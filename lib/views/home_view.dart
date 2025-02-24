import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/appointment_viewmodel.dart';
import '../models/appointment.dart';
import 'login_view.dart';
import 'doctor_appointments_view.dart';
import 'doctor_patients_view.dart';
import 'doctor_availability_view.dart';
import 'statistics_view.dart';
import 'patient_appointments_view.dart';
import 'schedule_appointment_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  Widget _buildMenuCard(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 4.0,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48.0, color: Theme.of(context).primaryColor),
            const SizedBox(height: 16.0),
            Text(
              title,
              style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Initialize appointments when the view is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppointmentViewModel>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final user = authVM.currentUser;

    if (user == null) {
      return const LoginView();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(user.isDoctor ? 'Painel do Médico' : 'Painel do Paciente'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              await authVM.logout();
              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginView()),
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          children: [
            if (user.isDoctor) ...[              
              _buildMenuCard(
                context,
                'Consultas',
                Icons.calendar_today,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DoctorAppointmentsView(),
                  ),
                ),
              ),
              _buildMenuCard(
                context,
                'Pacientes',
                Icons.people,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DoctorPatientsView(),
                  ),
                ),
              ),
              _buildMenuCard(
                context,
                'Disponibilidade',
                Icons.access_time,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DoctorAvailabilityView(),
                  ),
                ),
              ),
              _buildMenuCard(
                context,
                'Estatísticas',
                Icons.bar_chart,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StatisticsView(doctor: user),
                  ),
                ),
              ),
            ] else ...[              
              _buildMenuCard(
                context,
                'Minhas Consultas',
                Icons.calendar_today,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PatientAppointmentsView(),
                  ),
                ),
              ),
              _buildMenuCard(
                context,
                'Agendar Consulta',
                Icons.add_circle_outline,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ScheduleAppointmentView(doctor: user),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback onCancel;

  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data: ${appointment.dateTime.day}/${appointment.dateTime.month}/${appointment.dateTime.year}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Horário: ${appointment.dateTime.hour}:00'),
            Text('Status: ${appointment.status}'),
            if (appointment.notes != null) Text('Observações: ${appointment.notes}'),
            const SizedBox(height: 8),
            if (appointment.status == 'scheduled')
              ElevatedButton(
                onPressed: onCancel,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Cancelar Consulta'),
              ),
          ],
        ),
      ),
    );
  }
}