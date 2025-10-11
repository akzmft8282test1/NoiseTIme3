
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';

import 'package:noisetime/services/noise_service.dart'; // NoiseService 가져오기
import 'group_screen.dart';
import 'report_screen.dart';

// HomeScreen은 변경사항 없음
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    NoiseMeasurementScreen(),
    ReportScreen(),
    GroupScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _checkPermissions() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('소음 측정을 위해 마이크 권한이 필요합니다.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NoiseTime'),
        elevation: 0,
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: '리포트'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '그룹 관리'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}


// NoiseMeasurementScreen 수정
class NoiseMeasurementScreen extends StatefulWidget {
  const NoiseMeasurementScreen({super.key});

  @override
  NoiseMeasurementScreenState createState() => NoiseMeasurementScreenState();
}

class NoiseMeasurementScreenState extends State<NoiseMeasurementScreen> {
  bool _isRecording = false;
  StreamSubscription<NoiseReading>? _noiseSubscription;
  NoiseMeter? _noiseMeter;
  List<FlSpot> _noiseData = [];
  double _xValue = 0;
  Timer? _debounce;

  // NoiseService 인스턴스 생성
  final NoiseService _noiseService = NoiseService();

  @override
  void dispose() {
    _noiseSubscription?.cancel();
    _debounce?.cancel();
    super.dispose();
  }

  void onData(NoiseReading noiseReading) {
    if (mounted) {
      setState(() {
        _noiseData.add(FlSpot(_xValue++, noiseReading.meanDecibel));
        if (_noiseData.length > 100) {
          _noiseData.removeAt(0);
        }
      });
    }

    // 특정 데시벨(예: 65dB)을 넘으면 데이터를 저장
    if (noiseReading.meanDecibel > 65) { 
      // Debounce: 10초에 한 번만 저장 로직을 호출
      if (_debounce?.isActive ?? false) return;
      _debounce = Timer(const Duration(seconds: 10), () {});
      _saveNoiseData(noiseReading.meanDecibel);
    }
  }

  // 데이터 저장 로직을 NoiseService를 사용하도록 변경
  Future<void> _saveNoiseData(double decibel) async {
    try {
      await _noiseService.addNoiseSample(decibel);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('기준 초과 소음 (${decibel.toStringAsFixed(1)} dB)이 기록되었습니다.'),
            backgroundColor: Colors.amber[800], // 좀 더 잘 보이는 색으로 변경
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('데이터 저장 실패: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }


  void _start() {
    // 권한 확인 로직 추가
    Permission.microphone.request().then((status) {
      if (status == PermissionStatus.granted) {
        _noiseMeter = NoiseMeter();
        _noiseSubscription = _noiseMeter!.noise.listen(onData);
        if (mounted) {
          setState(() {
            _isRecording = true;
            _noiseData = [];
            _xValue = 0;
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('마이크 권한이 거부되었습니다. 측정을 시작할 수 없습니다.')),
        );
      }
    });
  }

  void _stop() {
    _noiseSubscription?.cancel();
    if (mounted) {
      setState(() => _isRecording = false);
    }
  }

  Widget _buildChart() {
    // 차트 UI는 변경 없음
    return LineChart(
      LineChartData(
        minX: _noiseData.isNotEmpty ? _noiseData.first.x : 0,
        maxX: _noiseData.isNotEmpty ? _noiseData.last.x : 0,
        minY: 30,
        maxY: 100,
        titlesData: const FlTitlesData(show: false),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: _noiseData,
            isCurved: true,
            color: Theme.of(context).primaryColor,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor.withAlpha(77),
                  Theme.of(context).primaryColor.withAlpha(0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
      duration: Duration.zero,
    );
  }


  @override
  Widget build(BuildContext context) {
    final latestDb = _noiseData.isNotEmpty ? _noiseData.last.y : 0.0;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _noiseData.length > 1
                  ? _buildChart()
                  : const Center(child: Text('측정을 시작해주세요')),
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _isRecording ? '측정 중...' : '소음 측정 준비 완료!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  '${latestDb.toStringAsFixed(2)} dB',
                  style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: _isRecording ? _stop : _start,
        child: Icon(_isRecording ? Icons.stop : Icons.mic),
      ),
    );
  }
}
