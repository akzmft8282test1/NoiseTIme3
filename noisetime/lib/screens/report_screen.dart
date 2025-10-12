import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart'; // 차트 라이브러리
import 'package:noisetime/models/noise_sample.dart';
import 'package:noisetime/services/community_service.dart';
import 'package:noisetime/services/statistics_service.dart'; // 새로 만든 통계 서비스
import 'package:noisetime/screens/noise_detail_screen.dart';


class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _statisticsService = StatisticsService();
  late Future<List<Map<String, dynamic>>> _statsFuture;

  @override
  void initState() {
    super.initState();
    // 위젯이 로드될 때 통계 데이터를 미리 불러옵니다.
    _statsFuture = _statisticsService.getDailyNoiseStats();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. 통계 차트 섹션
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text("일일 소음 리포트", style: Theme.of(context).textTheme.titleLarge),
        ),
        SizedBox(
          height: 200,
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _statsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text("통계 로딩 실패: ${snapshot.error}"));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("지난 30일간의 통계 데이터가 없습니다."));
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: DailyStatsChart(stats: snapshot.data!),
              );
            },
          ),
        ),
        const Divider(height: 30),

        // 2. 최근 활동 리스트 섹션
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text("최근 소음 발생 기록", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        const Expanded(
          child: RecentActivityList(),
        ),
      ],
    );
  }
}

// 일일 통계 차트를 그리는 위젯
class DailyStatsChart extends StatelessWidget {
  final List<Map<String, dynamic>> stats;
  const DailyStatsChart({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100, // y축 최대값 (데시벨)
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true, getTitlesWidget: _bottomTitles, reservedSize: 28)), // 간격 조정
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false))),
        gridData: FlGridData(show: true, checkToShowVerticalLine: (value) => false, getDrawingHorizontalLine: (value) => const FlLine(color: Colors.black12, strokeWidth: 1)),
        borderData: FlBorderData(show: false),
        barGroups: stats.asMap().entries.map((entry) {
          final index = entry.key;
          final data = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: (data['avg_db'] as double?) ?? 0.0, 
                color: Theme.of(context).primaryColor,
                width: 16,
              )
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _bottomTitles(double value, TitleMeta meta) {
    final index = value.toInt();
    String text = '';
    // stats 리스트의 범위 안에 있는지 확인합니다.
    if (index >= 0 && index < stats.length) {
      final day = DateTime.parse(stats[index]['report_day']).day;
      text = '$day일';
    }
    // SideTitleWidget 없이 Text 위젯을 직접 반환합니다.
    return Padding(
      padding: const EdgeInsets.only(top: 4.0), // 기존 space: 4 와 유사한 효과
      child: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }
}

// 최근 활동 리스트를 보여주는 위젯 (기존 로직 분리)
class RecentActivityList extends StatelessWidget {
  const RecentActivityList({super.key});

  @override
  Widget build(BuildContext context) {
    final communityService = CommunityService();
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: communityService.getNoiseSamplesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
           return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("최근 활동이 없습니다."));
        }

        final noiseSamples = snapshot.data!;
        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: noiseSamples.length,
          itemBuilder: (context, index) {
            final sampleData = noiseSamples[index];
            final noiseSample = NoiseSample.fromSupabase(sampleData);
            final formattedDate = DateFormat('MM-dd HH:mm').format(noiseSample.timestamp);

            return ListTile(
              dense: true,
              title: Text('${noiseSample.dbLevel.toStringAsFixed(1)} dB 소음 발생'),
              subtitle: Text(formattedDate),
              trailing: const Icon(Icons.chevron_right, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NoiseDetailScreen(noiseSample: noiseSample),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
