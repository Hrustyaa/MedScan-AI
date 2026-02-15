import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:camera/camera.dart';
import '../notifications/notifications_page.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import '../../services/database_service.dart';
import '../health/pulse_scanner_page.dart';
import '../health/breathing_page.dart';
import '../medicine/medicine_page.dart';
import '../emergency/first_aid_page.dart';
import '../emergency/sos_page.dart';
import '../chat/ai_chat_page.dart';
import 'package:easy_localization/easy_localization.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox();

    final now = DateTime.now();
    final months = [
      'января'.tr(), 'февраля'.tr(), 'марта'.tr(), 'апреля'.tr(), 'мая'.tr(), 'июня'.tr(),
      'июля'.tr(), 'августа'.tr(), 'сентября'.tr(), 'октября'.tr(), 'ноября'.tr(), 'декабря'.tr()
    ];
    final dateStr = '${now.day} ${months[now.month - 1]}';

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeSlideIn(
              delayMs: 0,
              offset: const Offset(0, -20),
              child: StreamBuilder<DocumentSnapshot>(
                stream: DatabaseService().getUserStream(user.uid),
                builder: (context, snapshot) {
                  String displayName = user.displayName ?? 'Гость'.tr();
                  if (snapshot.hasData && snapshot.data!.exists) {
                    final data = snapshot.data!.data() as Map<String, dynamic>?;
                    displayName = data?['name'] ?? displayName;
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'СЕГОДНЯ, {}'.tr(args: [dateStr.toUpperCase()]),
                            style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w700,
                              letterSpacing: 1.5, color: AppColors.textLight,
                            ),
                          ),
                          const SizedBox(height: 4),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              'Привет, {}'.tr(args: [displayName]),
                              key: ValueKey(displayName),
                              style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w800,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const NotificationButton(),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 20),
            
            FadeSlideIn(
              delayMs: 100, 
              offset: const Offset(-20, 0),
              child: _buildHealthDashboard()
            ),
            
            const SizedBox(height: 20),
            
            FadeSlideIn(
              delayMs: 200, 
              offset: const Offset(20, 0),
              child: _buildAIPromoCard(context)
            ),
            
            const SizedBox(height: 24),
            
            FadeSlideIn(
              delayMs: 300,
              child: Text('Инструменты'.tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            ),
            const SizedBox(height: 12),
            
            _buildActionGrid(context),
            
            const SizedBox(height: 24),
            
            FadeSlideIn(
              delayMs: 500, 
              offset: const Offset(0, 30),
              child: _buildSOSCard(context)
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthDashboard() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox();

    return StreamBuilder<QuerySnapshot>(
      stream: DatabaseService().getPulseHistory(user.uid, limit: 1),
      builder: (context, snapshot) {
        int lastPulse = 0;
        int spo2 = 0;
        String stress = "--";
        String status = 'Сделайте замер'.tr();
        double healthScore = 0.0;

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          final data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
          lastPulse = (data['bpm'] as num?)?.toInt() ?? 0;
          spo2 = (data['spo2'] as num?)?.toInt() ?? 98;
          stress = data['stress'] as String? ?? "Low";  

          if (lastPulse > 55 && lastPulse < 100) {
            status = 'В норме'.tr();
            healthScore = 0.95;
          } else {
            status = 'Внимание'.tr();
            healthScore = 0.70;
          }
        }

        return SoftCard(
          onTap: () {},
          padding: EdgeInsets.zero,
          borderRadius: 32,
          color: Colors.transparent,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              gradient: const LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [Color(0xFF2C3E50), Color(0xFF000000)],
              ),
              boxShadow: [BoxShadow(color: AppColors.textDark.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Сердечный ритм'.tr(), style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(status, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                    ]),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                      child: Row(children: [
                        const Icon(Icons.check_circle_rounded, color: AppColors.mint, size: 14),
                        const SizedBox(width: 4),
                        Text('Active'.tr(), style: const TextStyle(color: AppColors.mint, fontSize: 10, fontWeight: FontWeight.bold)),
                      ]),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(children: [
                  SizedBox(width: 70, height: 70, child: Stack(alignment: Alignment.center, children: [
                    CircularProgressIndicator(value: 1.0, color: Colors.white.withOpacity(0.1), strokeWidth: 6),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: healthScore > 0 ? healthScore : 0.05),
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) => CircularProgressIndicator(
                        value: value, 
                        color: lastPulse > 100 ? AppColors.coral : AppColors.mint, 
                        strokeCap: StrokeCap.round, strokeWidth: 6
                      ),
                    ),
                    const Icon(Icons.favorite_rounded, color: Colors.white, size: 28),
                  ])),
                  const SizedBox(width: 20),
                  Expanded(child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    _dashboardStat('Пульс'.tr(), lastPulse > 0 ? '$lastPulse' : '--', 'bpm'.tr()),
                    _dashboardStat('SpO2', spo2 > 0 ? '$spo2' : '--', '%'),
                    _dashboardStat('Стресс'.tr(), stress.tr(), ''), 
                  ])),
                ]),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _dashboardStat(String label, String value, String unit) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10, fontWeight: FontWeight.w600)),
      const SizedBox(height: 4),
      Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(value, key: ValueKey(value), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
        ),
        if (unit.isNotEmpty) Padding(padding: const EdgeInsets.only(bottom: 2, left: 2), child: Text(unit, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10))),
      ]),
    ]);
  }

  Widget _buildAIPromoCard(BuildContext context) {
    return SoftCard(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AIChatPage()));
      },
      padding: EdgeInsets.zero,
      borderRadius: 24,
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(colors: [Color(0xFF7F00FF), Color(0xFFE100FF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          boxShadow: [BoxShadow(color: const Color(0xFF7F00FF).withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 8))],
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('AI Диагностика'.tr(), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('Загрузите фото для анализа симптомов'.tr(), style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12, height: 1.2)),
          ])),
          const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 16),
        ]),
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    final actions = [
      {'title': 'Пульс', 'icon': Icons.favorite_rounded, 'color': AppColors.coral, 'bg': const Color(0xFFFFE0E0)},
      {'title': 'Дыхание', 'icon': Icons.air_rounded, 'color': AppColors.sky, 'bg': const Color(0xFFE0F2FE)},
      {'title': 'Таблетки', 'icon': Icons.medication_rounded, 'color': AppColors.mint, 'bg': const Color(0xFFE8FFF7)},
      {'title': 'Помощь', 'icon': Icons.medical_information_rounded, 'color': AppColors.purple, 'bg': const Color(0xFFF3EEFF)},
    ];

    return GridView.builder(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.5, crossAxisSpacing: 16, mainAxisSpacing: 16),
      itemBuilder: (context, index) {
        final item = actions[index];
        return FadeSlideIn(
          delayMs: 300 + (index * 50),
          child: SoftCard(
            onTap: () {
              if (index == 0) _openPulseScanner(context);
              if (index == 1) Navigator.push(context, MaterialPageRoute(builder: (_) => const BreathingPage()));
              if (index == 2) Navigator.push(context, MaterialPageRoute(builder: (_) => const MedicinePage()));
              if (index == 3) Navigator.push(context, MaterialPageRoute(builder: (_) => const FirstAidPage()));
            },
            padding: const EdgeInsets.all(16),
            borderRadius: 20,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: item['bg'] as Color, borderRadius: BorderRadius.circular(10)), child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: 24)),
              Text((item['title'] as String).tr(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
            ]),
          ),
        );
      },
    );
  }

  Widget _buildSOSCard(BuildContext context) {
    return SoftCard(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SOSPage())),
      padding: EdgeInsets.zero,
      borderRadius: 24,
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(colors: [Color(0xFFFF8E53), Color(0xFFFF6B6B)]),
          boxShadow: [BoxShadow(color: AppColors.coral.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 8))],
        ),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle), child: const Icon(Icons.warning_rounded, color: Colors.white, size: 24)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('SOS СИГНАЛ'.tr(), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1)),
            Text('Экстренный вызов помощи'.tr(), style: const TextStyle(color: Colors.white, fontSize: 12)),
          ])),
          const Icon(Icons.chevron_right_rounded, color: Colors.white),
        ]),
      ),
    );
  }

  void _openPulseScanner(BuildContext context) async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty && context.mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => PulseScannerPage(camera: cameras.first)));
      } else {
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Камера не найдена'.tr())));
      }
    } catch (e) {
      debugPrint("Camera Error: $e");
    }
  }
}

class NotificationButton extends StatefulWidget {
  const NotificationButton({Key? key}) : super(key: key);
  @override
  State<NotificationButton> createState() => _NotificationButtonState();
}

class _NotificationButtonState extends State<NotificationButton> with SingleTickerProviderStateMixin {
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsPage())),
      child: AnimatedBuilder(
        animation: _glowController,
        builder: (context, _) {
          return Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [AppColors.mint, AppColors.sky]),
              boxShadow: [BoxShadow(color: AppColors.mint.withOpacity(0.2 + 0.15 * _glowController.value), blurRadius: 12 + 6 * _glowController.value)],
            ),
            child: Stack(alignment: Alignment.center, children: [
              const Icon(Icons.notifications_rounded, size: 20, color: Colors.white),
              Positioned(top: 10, right: 12, child: Container(width: 8, height: 8, decoration: BoxDecoration(color: AppColors.coral, shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5)))),
            ]),
          );
        },
      ),
    );
  }
}