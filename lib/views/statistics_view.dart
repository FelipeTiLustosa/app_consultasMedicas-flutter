import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math' show max;
import '../viewmodels/statistics_viewmodel.dart';
import '../models/user.dart';

class StatisticsView extends StatelessWidget {
  final User doctor;

  const StatisticsView({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StatisticsViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Estatísticas'),
        ),
        body: _StatisticsContent(doctor: doctor),
      ),
    );
  }
}

class _StatisticsContent extends StatelessWidget {
  final User doctor;

  const _StatisticsContent({required this.doctor});

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<StatisticsViewModel>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(stats),
          const SizedBox(height: 24),
          _buildStatusChart(stats),
          const SizedBox(height: 24),
          _buildHourlyChart(stats),
          const SizedBox(height: 24),
          _buildWeeklyChart(stats),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(StatisticsViewModel stats) {
    final total = stats.getTotalAppointments(doctor.id);
    final completionRate = stats.getCompletionRate(doctor.id);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total de Consultas: $total',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Taxa de Conclusão: ${(completionRate * 100).toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChart(StatisticsViewModel stats) {
    final statusData = stats.getAppointmentsByStatus(doctor.id);
    final total = statusData.values.fold<int>(0, (sum, count) => sum + count);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status das Consultas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: statusData['scheduled']?.toDouble() ?? 0,
                      title: 'Agendadas',
                      color: Colors.blue,
                      radius: 50,
                    ),
                    PieChartSectionData(
                      value: statusData['completed']?.toDouble() ?? 0,
                      title: 'Concluídas',
                      color: Colors.green,
                      radius: 50,
                    ),
                    PieChartSectionData(
                      value: statusData['cancelled']?.toDouble() ?? 0,
                      title: 'Canceladas',
                      color: Colors.red,
                      radius: 50,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHourlyChart(StatisticsViewModel stats) {
    final hourlyData = stats.getAppointmentsByHour(doctor.id);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Consultas por Hora',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: hourlyData.values.fold<int>(0, max).toDouble(),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}h');
                        },
                      ),
                    ),
                  ),
                  barGroups: hourlyData.entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.toDouble(),
                          color: Colors.blue,
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart(StatisticsViewModel stats) {
    final weeklyData = stats.getAppointmentsLast7Days(doctor.id);
    final dateFormat = DateFormat('dd/MM');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Consultas nos Últimos 7 Dias',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  maxY: weeklyData.values.fold<int>(0, max).toDouble(),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final date = weeklyData.keys.elementAt(value.toInt());
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(dateFormat.format(date)),
                          );
                        },
                      ),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: weeklyData.entries.map((entry) {
                        return FlSpot(
                          weeklyData.keys.toList().indexOf(entry.key).toDouble(),
                          entry.value.toDouble(),
                        );
                      }).toList(),
                      isCurved: true,
                      color: Colors.blue,
                      dotData: FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}