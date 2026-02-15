import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import '../../core/theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import '../../services/emergency_service.dart';
import 'package:easy_localization/easy_localization.dart';

class SOSPage extends StatefulWidget {
  const SOSPage({Key? key}) : super(key: key);
  @override
  State<SOSPage> createState() => _SOSPageState();
}

class _SOSPageState extends State<SOSPage> with TickerProviderStateMixin {
  bool _isActivating = false;
  bool _isActivated = false;
  int _countdown = 5;
  Timer? _timer;
  late AnimationController _pulseController;
  late AnimationController _successController;

  CameraController? _cameraController;
  bool _isTorchBlinking = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
    _successController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _cameraController = CameraController(cameras[0], ResolutionPreset.low, enableAudio: false);
        await _cameraController?.initialize();
      }
    } catch (_) {}
  }

  void _startCountdown() {
    HapticFeedback.heavyImpact();
    setState(() {
      _isActivating = true;
      _countdown = 5;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      setState(() {
        _countdown--;
        if (_countdown <= 0) {
          _activateSOS();
        }
      });
    });
  }

  void _activateSOS() {
    _timer?.cancel();
    setState(() {
      _isActivating = false;
      _isActivated = true;
    });
    _successController.forward();
    _startMorseCode();
  }

  Future<void> _startMorseCode() async {
    if (_cameraController == null || _isTorchBlinking) return;
    _isTorchBlinking = true;

    final pattern = [
      200, 200, 200, 200, 200, 600,
      600, 200, 600, 200, 600, 600,
      200, 200, 200, 200, 200, 2000
    ];

    int index = 0;
    while (_isTorchBlinking && mounted) {
      if (index >= pattern.length) index = 0;

      bool shouldBeOn = index % 2 == 0;
      int duration = pattern[index];

      try {
        if (shouldBeOn) {
          await _cameraController?.setFlashMode(FlashMode.torch);
        } else {
          await _cameraController?.setFlashMode(FlashMode.off);
        }
      } catch (_) {}

      await Future.delayed(Duration(milliseconds: duration));
      index++;
    }

    try {
      await _cameraController?.setFlashMode(FlashMode.off);
    } catch (_) {}
  }

  void _cancel() {
    _timer?.cancel();
    _successController.reset();
    _isTorchBlinking = false;
    _cameraController?.setFlashMode(FlashMode.off);

    setState(() {
      _isActivating = false;
      _isActivated = false;
      _countdown = 5;
    });
  }

  void _call(String number) {
    HapticFeedback.mediumImpact();
    EmergencyUtils.callEmergency(number: number);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            buildPageHeader(context, 'Экстренная помощь'.tr()),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isActivated) ...[
                    ScaleTransition(
                      scale: CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
                      child: Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle, color: AppColors.mintSoft,
                          boxShadow: [BoxShadow(color: AppColors.mint.withOpacity(0.2), blurRadius: 20)],
                        ),
                        child: const Icon(Icons.light_mode_rounded, color: AppColors.mint, size: 48),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('SOS СИГНАЛ АКТИВЕН'.tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.mint, letterSpacing: 2)),
                    const SizedBox(height: 8),
                    Text('Работает световой маяк'.tr(), style: TextStyle(color: AppColors.textLight)),
                    const SizedBox(height: 30),
                    TextButton(onPressed: _cancel, child: Text('Остановить'.tr(), style: TextStyle(color: AppColors.textLight))),
                  ] else ...[
                    SizedBox(
                      width: 250, height: 250,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (_isActivating) ...[
                            for (int i = 0; i < 3; i++)
                              AnimatedBuilder(
                                animation: _pulseController,
                                builder: (c, _) {
                                  double offset = i * 0.33;
                                  double val = ((_pulseController.value + offset) % 1.0);
                                  return Container(
                                    width: 250 * (0.65 + 0.35 * val),
                                    height: 250 * (0.65 + 0.35 * val),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: AppColors.coral.withOpacity(0.3 * (1 - val)), width: 2),
                                    ),
                                  );
                                },
                              ),
                          ],
                          GestureDetector(
                            onLongPress: _startCountdown,
                            onTap: () {
                              if (_isActivating) {
                                _cancel();
                              } else {
                                _startCountdown();
                              }
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: _isActivating ? 170 : 160,
                              height: _isActivating ? 170 : 160,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const RadialGradient(colors: [Color(0xFFFF6B6B), Color(0xFFFF4444)]),
                                boxShadow: [BoxShadow(color: AppColors.coral.withOpacity(0.4), blurRadius: 30, spreadRadius: 5)],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_isActivating) ...[
                                    AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 200),
                                      transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                                      child: Text('$_countdown', key: ValueKey(_countdown), style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w900, color: Colors.white)),
                                    ),
                                    Text('ОТМЕНА'.tr(), style: const TextStyle(fontSize: 10, color: Colors.white70, letterSpacing: 2)),
                                  ] else
                                    Text('SOS'.tr(), style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 3)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(_isActivating ? 'Нажмите для отмены'.tr() : 'Нажмите для активации маяка'.tr(), style: TextStyle(color: AppColors.textLight, fontSize: 14)),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text('Экстренные номера (Нажмите для вызова)'.tr(), style: TextStyle(color: AppColors.textLight, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _emergencyChip('112', 'Единый'.tr()),
                      _emergencyChip('103', 'Скорая'.tr()),
                      _emergencyChip('101', 'Пожарная'.tr()),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _emergencyChip(String number, String label) {
    return GestureDetector(
      onTap: () => _call(number),
      child: SoftCard(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          children: [
            Text(number, style: const TextStyle(color: AppColors.coral, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: AppColors.textLight, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _isTorchBlinking = false;
    _cameraController?.setFlashMode(FlashMode.off);
    _cameraController?.dispose();
    _pulseController.dispose();
    _successController.dispose();
    super.dispose();
  }
}