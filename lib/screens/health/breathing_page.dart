import 'dart:async';
import 'dart:math' as math;
import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../services/database_service.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/common_widgets.dart';

class BreathingPage extends StatefulWidget {
  const BreathingPage({Key? key}) : super(key: key);

  @override
  State<BreathingPage> createState() => _BreathingPageState();
}

class _BreathingPageState extends State<BreathingPage> with TickerProviderStateMixin {
  bool _isActive = false;
  int _currentPhaseIndex = 0;
  int _secondsInPhase = 0;
  int _breathCount = 0;
  int _totalSeconds = 0;
  Timer? _timer;

  late final AnimationController _scaleController;
  late final AnimationController _glowController;
  late final AnimationController _particleController;

  bool _toggleLock = false;

  final _dbService = DatabaseService();
  String _selectedMode = 'Расслабление';

  final Map<String, List<int>> _modes = {
    'Анти-паника': [4, 4, 4, 4],
    'Расслабление': [4, 7, 8, 0],
    'Энергия': [2, 0, 2, 0],
  };

  final Map<String, String> _modeDescriptions = {
    'Анти-паника': 'Квадратное дыхание для снятия стресса',
    'Расслабление': 'Классика 4-7-8 для сна и покоя',
    'Энергия': 'Быстрый ритм для бодрости',
  };

  final List<Map<String, dynamic>> _uiPhases = [
    {'label': 'ВДОХ', 'color': AppColors.sky},
    {'label': 'ЗАДЕРЖКА', 'color': AppColors.mint},
    {'label': 'ВЫДОХ', 'color': AppColors.purple},
    {'label': 'ЗАДЕРЖКА', 'color': AppColors.orange},
  ];

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(vsync: this);
    _glowController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _particleController = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
  }

  void _toggleSession() {
    if (_toggleLock) return;
    _toggleLock = true;
    Future.delayed(const Duration(milliseconds: 250), () {
      _toggleLock = false;
    });

    if (_isActive) {
      _stop();
    } else {
      _start();
    }
  }

  void _start() {
    if (_isActive) return;
    if (_timer != null && _timer!.isActive) return;

    setState(() {
      _isActive = true;
      _currentPhaseIndex = 0;
      _secondsInPhase = 0;
      _breathCount = 0;
      _totalSeconds = 0;
    });

    _runPhase();

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (!_isActive) return;

      setState(() {
        _secondsInPhase++;
        _totalSeconds++;

        final durations = _modes[_selectedMode]!;
        if (_secondsInPhase >= durations[_currentPhaseIndex]) {
          _secondsInPhase = 0;
          _currentPhaseIndex = (_currentPhaseIndex + 1) % 4;

          int safeGuard = 0;
          while (_modes[_selectedMode]![_currentPhaseIndex] == 0 && safeGuard < 8) {
            _currentPhaseIndex = (_currentPhaseIndex + 1) % 4;
            safeGuard++;
          }

          if (_currentPhaseIndex == 0) _breathCount++;
          _runPhase();
        }
      });
    });
  }

  void _runPhase() {
    final duration = _modes[_selectedMode]![_currentPhaseIndex];
    final safeDuration = math.max(duration, 1);

    if (_scaleController.duration?.inSeconds != safeDuration) {
      _scaleController.duration = Duration(seconds: safeDuration);
    }

    switch (_currentPhaseIndex) {
      case 0:
        _scaleController.forward(from: 0);
        break;
      case 1:
        _scaleController.value = 1.0;
        _scaleController.stop();
        break;
      case 2:
        _scaleController.reverse(from: 1);
        break;
      case 3:
        _scaleController.value = 0.0;
        _scaleController.stop();
        break;
    }
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;

    _scaleController.stop();
    _scaleController.reset();

    final breaths = _breathCount;
    final seconds = _totalSeconds;

    setState(() {
      _isActive = false;
      _currentPhaseIndex = 0;
      _secondsInPhase = 0;
    });

    if (breaths > 0 && seconds > 10) {
      _dbService.saveBreathingData(
        (breaths * 60 / seconds).round(),
        breaths,
        seconds,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Сессия сохранена!'.tr()), behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final durations = _modes[_selectedMode]!;
    final duration = durations[_currentPhaseIndex];
    final remaining = _isActive ? math.max(duration - _secondsInPhase, 0) : 0;

    final phaseInfo = _uiPhases[_currentPhaseIndex];
    final currentColor = phaseInfo['color'] as Color;
    final currentLabel = _isActive ? (phaseInfo['label'] as String).tr() : 'СТАРТ'.tr();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            buildPageHeader(context, 'Дыхание'.tr()),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: _modes.keys.map((mode) {
                  final isSelected = _selectedMode == mode;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(mode.tr()),
                      selectedColor: AppColors.mint.withOpacity(0.2),
                      checkmarkColor: AppColors.mint,
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.mint : AppColors.textLight,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: _isActive
                          ? null
                          : (_) {
                              setState(() => _selectedMode = mode);
                            },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: isSelected ? AppColors.mint : AppColors.border),
                      ),
                      backgroundColor: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 10),
            Text(
              (_modeDescriptions[_selectedMode] ?? '').tr(),
              style: TextStyle(fontSize: 12, color: AppColors.textLight),
            ),

            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_isActive)
                    _ParticleSystem(
                      controller: _particleController,
                      color: currentColor,
                      isInhaling: _currentPhaseIndex == 0,
                      isExhaling: _currentPhaseIndex == 2,
                    ),

                  Positioned(
                    top: 36,
                    left: 0,
                    right: 0,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Center(
                        key: ValueKey(currentLabel),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              currentLabel,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 4,
                                color: currentColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  AnimatedBuilder(
                    animation: Listenable.merge([_scaleController, _glowController]),
                    builder: (c, _) {
                      final scale = _isActive ? 0.5 + 0.5 * _scaleController.value : 0.6;
                      final glow = _glowController.value;

                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 300 * scale,
                            height: 300 * scale,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: currentColor.withOpacity(0.05 + 0.1 * glow),
                            ),
                          ),
                          Container(
                            width: 240 * scale,
                            height: 240 * scale,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [currentColor.withOpacity(0.3), currentColor.withOpacity(0.05)],
                              ),
                              border: Border.all(color: currentColor.withOpacity(0.5), width: 2),
                              boxShadow: [
                                BoxShadow(color: currentColor.withOpacity(0.2), blurRadius: 20 * scale),
                              ],
                            ),
                            child: Center(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 180),
                                transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                                child: _isActive
                                    ? Text(
                                        remaining.toString(),
                                        key: ValueKey('sec_' + remaining.toString()),
                                        style: const TextStyle(
                                          fontSize: 64,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.textDark,
                                          height: 1.0,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.air_rounded,
                                        key: ValueKey('lungs_icon'),
                                        size: 72,
                                        color: AppColors.textDark,
                                      ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _toggleSession,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isActive ? AppColors.bg : AppColors.mint,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: _isActive ? 0 : 8,
                        side: _isActive ? BorderSide(color: AppColors.border, width: 2) : BorderSide.none,
                      ),
                      child: Text(
                        _isActive ? 'ЗАКОНЧИТЬ'.tr() : 'НАЧАТЬ СЕССИЮ'.tr(),
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          color: _isActive ? AppColors.textMedium : Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => _showHistoryChart(context),
                    child: Text(
                      'Посмотреть историю'.tr(),
                      style: const TextStyle(color: AppColors.textLight, decoration: TextDecoration.underline),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHistoryChart(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _HistoryChartSheet(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scaleController.dispose();
    _glowController.dispose();
    _particleController.dispose();
    super.dispose();
  }
}

class _HistoryChartSheet extends StatefulWidget {
  const _HistoryChartSheet();

  @override
  State<_HistoryChartSheet> createState() => _HistoryChartSheetState();
}

class _HistoryChartSheetState extends State<_HistoryChartSheet> {
  late final Stream<QuerySnapshot> _stream;

  @override
  void initState() {
    super.initState();

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _stream = const Stream.empty();
      return;
    }

    _stream = FirebaseFirestore.instance
        .collection('breathing_history')
        .where('uid', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .limit(250)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        height: 560,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 24),
            Text('Ваша активность'.tr(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 4),
            Text('Время дыхания за последние 7 дней'.tr(), style: TextStyle(fontSize: 14, color: AppColors.textLight)),
            const SizedBox(height: 24),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _stream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return _EmptyState(
                      icon: Icons.error_outline_rounded,
                      title: 'Ошибка загрузки'.tr(),
                      subtitle: 'Проверьте интернет или индексы Firestore.'.tr() + snapshot.error.toString(),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.mint));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return _EmptyState(
                      icon: Icons.bar_chart_rounded,
                      title: 'Нет данных'.tr(),
                      subtitle: 'Сделайте хотя бы 1 сессию дыхания'.tr(),
                    );
                  }

                  final now = DateTime.now();
                  final start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));

                  final minutesByDay = List<double>.filled(7, 0);
                  double totalMinutes = 0;

                  for (final doc in snapshot.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    final ts = data['timestamp'];
                    if (ts == null || ts is! Timestamp) continue;

                    final date = ts.toDate();
                    if (date.isBefore(start)) continue;

                    final durationSec = (data['duration'] as num?)?.toDouble() ?? 0;
                    if (durationSec <= 0) continue;

                    final minutes = durationSec / 60.0;
                    final dayStart = DateTime(date.year, date.month, date.day);
                    final idx = dayStart.difference(start).inDays;
                    if (idx < 0 || idx > 6) continue;

                    minutesByDay[idx] += minutes;
                    totalMinutes += minutes;
                  }

                  final hasAny = minutesByDay.any((m) => m > 0.01);
                  if (!hasAny) {
                    return _EmptyState(
                      icon: Icons.event_busy_rounded,
                      title: 'Нет данных за неделю'.tr(),
                      subtitle: 'Попробуйте сделать дыхательную сессию сегодня'.tr(),
                    );
                  }

                  final maxY = minutesByDay.reduce(math.max);

                  final groups = <BarChartGroupData>[];
                  for (int i = 0; i < 7; i++) {
                    groups.add(
                      BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: minutesByDay[i],
                            width: 16,
                            color: AppColors.mint,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: AppColors.mintSoft, borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.timer_rounded, color: AppColors.mint),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('{} мин'.tr(args: [totalMinutes.toStringAsFixed(1)]), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                              Text('Общее время'.tr(), style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Expanded(
                        child: BarChart(
                          BarChartData(
                            maxY: (maxY <= 1 ? 1 : maxY) * 1.2,
                            barGroups: groups,
                            gridData: FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(
                              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 28,
                                  getTitlesWidget: (value, meta) {
                                    final i = value.toInt();
                                    if (i < 0 || i > 6) return const SizedBox.shrink();
                                    final day = start.add(Duration(days: i));
                                    final names = ['Пн'.tr(), 'Вт'.tr(), 'Ср'.tr(), 'Чт'.tr(), 'Пт'.tr(), 'Сб'.tr(), 'Вс'.tr()];
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        names[day.weekday - 1],
                                        style: TextStyle(color: AppColors.textLight, fontSize: 12, fontWeight: FontWeight.w600),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            barTouchData: BarTouchData(
                              enabled: true,
                              touchTooltipData: BarTouchTooltipData(
                                tooltipPadding: const EdgeInsets.all(8),
                                tooltipMargin: 8,
                                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                  return BarTooltipItem(
                                    '{} мин'.tr(args: [rod.toY.toStringAsFixed(1)]),
                                    const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w800, fontSize: 12),
                                  );
                                },
                              ),
                            ),
                          ),
                          swapAnimationDuration: const Duration(milliseconds: 250),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 56, color: AppColors.textLight.withOpacity(0.35)),
            const SizedBox(height: 14),
            Text(title, style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(subtitle, style: TextStyle(color: AppColors.textLight), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _ParticleSystem extends StatelessWidget {
  final AnimationController controller;
  final Color color;
  final bool isInhaling;
  final bool isExhaling;

  const _ParticleSystem({
    required this.controller,
    required this.color,
    required this.isInhaling,
    required this.isExhaling,
  });

  @override
  Widget build(BuildContext context) {
    if (!isInhaling && !isExhaling) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _ParticlePainter(
            progress: controller.value,
            color: color,
            isInhaling: isInhaling,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final double progress;
  final Color color;
  final bool isInhaling;

  _ParticlePainter({
    required this.progress,
    required this.color,
    required this.isInhaling,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint();

    for (int i = 0; i < 40; i++) {
      final angle = (i * 137.5) * (math.pi / 180);
      final flight = (progress * 5 + i * 0.1) % 1.0;
      final currentRadius = isInhaling ? 220 * (1 - flight) : 60 + 220 * flight;

      final x = center.dx + currentRadius * math.cos(angle);
      final y = center.dy + currentRadius * math.sin(angle);

      double opacity = 0.75;
      if (currentRadius < 70) opacity = (currentRadius / 70).clamp(0.0, 0.75);
      if (currentRadius > 220) opacity = (1 - ((currentRadius - 220) / 60)).clamp(0.0, 0.75);

      paint.color = color.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), 2 + (i % 3).toDouble(), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color || oldDelegate.isInhaling != isInhaling;
  }
}