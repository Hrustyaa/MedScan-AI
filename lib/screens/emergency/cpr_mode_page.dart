import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
class CprModePage extends StatefulWidget {
  const CprModePage({Key? key}) : super(key: key);

  @override
  State<CprModePage> createState() => _CprModePageState();
}

class _CprModePageState extends State<CprModePage> with TickerProviderStateMixin {
  Timer? _beatTimer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;
  int _compressionCount = 0;
  int _cycleCount = 0;
  bool _isBreathPhase = false;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOutBack),
    );
  }

  void _startCpr() {
    setState(() {
      _isRunning = true;
      _compressionCount = 0;
      _cycleCount = 0;
      _isBreathPhase = false;
    });

    _beatTimer = Timer.periodic(const Duration(milliseconds: 545), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_isBreathPhase) return;

      HapticFeedback.heavyImpact();
      _pulseController.forward(from: 0).then((_) {
        if (mounted) _pulseController.reverse();
      });

      setState(() {
        _compressionCount++;

        if (_compressionCount >= 30) {
          _compressionCount = 0;
          _isBreathPhase = true;
          _cycleCount++;

          Future.delayed(const Duration(seconds: 4), () {
            if (mounted && _isRunning) {
              setState(() => _isBreathPhase = false);
            }
          });
        }
      });
    });
  }

  void _stopCpr() {
    _beatTimer?.cancel();
    setState(() => _isRunning = false);
  }

  @override
  void dispose() {
    _beatTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.92,
        decoration: const BoxDecoration(
          color: Color(0xFF121214),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),

            AnimatedOpacity(
              opacity: _isRunning ? 1.0 : 0.7,
              duration: const Duration(milliseconds: 500),
              child: Text('РЕЖИМ СЛР'.tr(), style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 2)),
            ),
            const SizedBox(height: 4),
            Text(
              '110 ударов/мин • Глубина 5-6 см'.tr(),
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
            ),

            const Spacer(),

            AnimatedBuilder(
              animation: _pulseAnim,
              builder: (context, _) {
                return Transform.scale(
                  scale: _isRunning ? _pulseAnim.value : 1.0,
                  child: Container(
                    width: 220, height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isBreathPhase
                          ? const Color(0xFF0A84FF).withOpacity(0.2)
                          : const Color(0xFFFF3B30).withOpacity(_isRunning ? 0.3 : 0.1),
                      border: Border.all(
                        color: _isBreathPhase ? const Color(0xFF0A84FF) : const Color(0xFFFF3B30),
                        width: 4,
                      ),
                      boxShadow: _isRunning ? [
                        BoxShadow(
                          color: (_isBreathPhase ? const Color(0xFF0A84FF) : const Color(0xFFFF3B30)).withOpacity(0.4),
                          blurRadius: 50,
                          spreadRadius: 10,
                        ),
                      ] : [],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isBreathPhase ? Icons.air_rounded : Icons.favorite_rounded,
                            size: 64,
                            color: _isBreathPhase ? const Color(0xFF0A84FF) : const Color(0xFFFF3B30),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _isBreathPhase ? 'ВДОХ'.tr() : (_isRunning ? 'ЖМИТЕ'.tr() : 'СТАРТ'.tr()),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.95),
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 50),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _cprStat('Нажатий'.tr(), '$_compressionCount/30'),
                _cprStat('Циклов'.tr(), '$_cycleCount'),
                _cprStat('Фаза'.tr(), _isBreathPhase ? '2 вдоха'.tr() : 'Компрессия'.tr()),
              ],
            ),

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _isBreathPhase
                      ? 'Сделайте 2 вдоха «рот в рот» за 4 секунды'.tr()
                      : _isRunning
                          ? 'Нажимайте на грудину В ТАКТ с вибрацией'.tr()
                          : 'Телефон будет вибрировать в ритме 110 уд/мин'.tr(),
                  key: ValueKey(_isBreathPhase.toString() + _isRunning.toString()),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13, height: 1.4),
                ),
              ),
            ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              child: Row(
                children: [
                  Expanded(
                    child: _GlassButton(
                      text: 'ЗАКРЫТЬ'.tr(),
                      onTap: () {
                        _stopCpr();
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        _isRunning ? _stopCpr() : _startCpr();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _isRunning
                                ? [const Color(0xFFFF9F0A), const Color(0xFFFF3B30)]
                                : [const Color(0xFFFF3B30), const Color(0xFFFF6B6B)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF3B30).withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            )
                          ],
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(_isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 26),
                              const SizedBox(width: 8),
                              Text(
                                _isRunning ? 'ПАУЗА'.tr() : 'НАЧАТЬ СЛР'.tr(),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 1),
                              ),
                            ],
                          ),
                        ),
                      ),
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

  Widget _cprStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700, fontFamily: 'monospace')),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
      ],
    );
  }
}

class _GlassButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _GlassButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Center(
          child: Text(text, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700, fontSize: 14)),
        ),
      ),
    );
  }
}