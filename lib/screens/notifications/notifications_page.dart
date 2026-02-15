import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import '../../services/database_service.dart';
import '../../services/ai_service.dart';
import 'package:easy_localization/easy_localization.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final _db = DatabaseService();
  final _ai = AIService();

  String? _dailyTip;
  bool _loadingTip = true;
  bool _tipError = false;
  bool _isInit = false; 
  @override
  void initState() {
    super.initState();
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      _loadDailyTip();
      _isInit = true;
    }
  } 

  Future<void> _loadDailyTip() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (mounted) setState(() { _loadingTip = false; _tipError = true; });
      return;
    }

    try {
      String currentLocale = 'ru';
      try {
        currentLocale = context.locale.languageCode;
      } catch (e) {
        print("Locale error: $e");
      }

      final pulseSnapshot = await FirebaseFirestore.instance
          .collection('pulse_history')
          .where('uid', isEqualTo: uid)
          .orderBy('timestamp', descending: true)
          .limit(3)
          .get();

      String contextInfo = '';
      
      String labelPulse = currentLocale == 'en' ? 'Last pulse' : (currentLocale == 'kk' ? 'Соңғы пульс' : 'Последний пульс');
      String labelStress = currentLocale == 'en' ? 'stress' : (currentLocale == 'kk' ? 'стресс' : 'стресс');
      String labelChangeUp = currentLocale == 'en' ? 'Pulse rose by' : (currentLocale == 'kk' ? 'Пульс көтерілді' : 'Пульс вырос на');
      String labelChangeDown = currentLocale == 'en' ? 'Pulse fell by' : (currentLocale == 'kk' ? 'Пульс төмендеді' : 'Пульс снизился на');
      String labelAge = currentLocale == 'en' ? 'Age' : (currentLocale == 'kk' ? 'Жасы' : 'Возраст');
      String labelWeight = currentLocale == 'en' ? 'weight' : (currentLocale == 'kk' ? 'салмағы' : 'вес');

      if (pulseSnapshot.docs.isNotEmpty) {
        final last = pulseSnapshot.docs.first.data();
        final bpm = last['bpm'] ?? 0;
        final spo2 = last['spo2'] ?? 0;
        final stress = last['stress'] ?? '...';
        
        contextInfo = '$labelPulse: $bpm BPM, SpO2: $spo2%, $labelStress: $stress.';
        
        if (pulseSnapshot.docs.length > 1) {
          final prevBpm = pulseSnapshot.docs[1].data()['bpm'] ?? 0;
          if (bpm > prevBpm + 10) {
            contextInfo += ' $labelChangeUp ${bpm - prevBpm}.';
          } else if (bpm < prevBpm - 10) {
            contextInfo += ' $labelChangeDown ${prevBpm - bpm}.';
          }
        }
      }

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        contextInfo += ' $labelAge: ${userData['age'] ?? 25}, $labelWeight: ${userData['weight'] ?? 70} kg.';
      }

      String finalPrompt;
      if (currentLocale == 'kk') {
        finalPrompt = "СЕН КЕҢЕСШІСІҢ. ТЕК ҚАЗАҚ ТІЛІНДЕ ЖАУАП БЕР. Денсаулыққа қатысты 2 сөйлемнен тұратын кеңес жаз. Деректер: $contextInfo";
      } else if (currentLocale == 'en') {
        finalPrompt = "YOU ARE A HEALTH ADVISOR. ANSWER ONLY IN ENGLISH. Provide a 2-sentence health tip based on this data: $contextInfo";
      } else {
        finalPrompt = "Дай ОДИН короткий полезный совет здоровья на сегодня (2-3 предложения). Данные: $contextInfo. Отвечай на русском.";
      }

      final tip = await _ai.getMedicalAdvice(
        finalPrompt, 
        uid, 
        languageCode: currentLocale 
      );

      if (mounted) {
        setState(() {
          _dailyTip = tip;
          _loadingTip = false;
          _tipError = false;
        });
      }
    } catch (e) {
      print("Error: $e");
      if (mounted) {
        setState(() {
          _loadingTip = false;
          _tipError = true;
          _dailyTip = 'Пейте достаточно воды — это помогает сердцу.'.tr();
        });
      }
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) return 'Доброй ночи'.tr();
    if (hour < 12) return 'Доброе утро'.tr();
    if (hour < 18) return 'Добрый день'.tr();
    return 'Добрый вечер'.tr();
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inMinutes < 1) return 'Только что'.tr();
    if (diff.inMinutes < 60) return '{} мин назад'.tr(args: ['${diff.inMinutes}']);
    if (diff.inHours < 24) return '{} ч назад'.tr(args: ['${diff.inHours}']);
    if (diff.inDays < 7) return '{} дн назад'.tr(args: ['${diff.inDays}']);
    return '${date.day}.${date.month}';
  }

  @override
  Widget build(BuildContext context) {  
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  backButton(context),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Уведомления'.tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                        Text(_getGreeting(), style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeSlideIn(
                      delayMs: 0,
                      child: _buildAITipCard(),
                    ),

                    const SizedBox(height: 24),

                    if (uid != null) ...[
                      FadeSlideIn(
                        delayMs: 100,
                        child: Row(
                          children: [
                            const Icon(Icons.medication_rounded, size: 18, color: AppColors.mint),
                            const SizedBox(width: 8),
                            Text('Лекарства на сегодня'.tr(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildMedicineReminders(),
                      const SizedBox(height: 24),
                    ],

                    if (uid != null) ...[
                      FadeSlideIn(
                        delayMs: 200,
                        child: Row(
                          children: [
                            const Icon(Icons.favorite_rounded, size: 18, color: AppColors.coral),
                            const SizedBox(width: 8),
                            Text('Здоровье'.tr(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildHealthInsights(uid),
                    ],

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAITipCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667eea).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Совет дня от AI'.tr(),
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              if (!_loadingTip && !_tipError)
                GestureDetector(
                  onTap: () {
                    setState(() { _loadingTip = true; _tipError = false; });
                    _loadDailyTip();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.refresh_rounded, color: Colors.white70, size: 16),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          if (_loadingTip)
            Row(
              children: [
                const SizedBox(
                  width: 16, height: 16,
                  child: CircularProgressIndicator(color: Colors.white70, strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                Text('Анализирую ваши данные...'.tr(), style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
              ],
            )
          else
            Text(
              _dailyTip ?? 'Не удалось загрузить совет'.tr(),
              style: TextStyle(
                color: Colors.white.withOpacity(0.95),
                fontSize: 14,
                height: 1.6,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMedicineReminders() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.getMedicinesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(color: AppColors.mint),
          ));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return FadeSlideIn(
            delayMs: 150,
            child: SoftCard(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.mintSoft,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.medication_rounded, color: AppColors.mint, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Нет лекарств'.tr(), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textDark)),
                        const SizedBox(height: 2),
                        Text('Добавьте лекарства в разделе "Таблетки"'.tr(), style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final docs = snapshot.data!.docs;
        final now = DateTime.now();
        final currentMinutes = now.hour * 60 + now.minute;

        final sorted = docs.toList()..sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final aTaken = aData['isTaken'] ?? false;
          final bTaken = bData['isTaken'] ?? false;
          
          if (aTaken != bTaken) return aTaken ? 1 : -1;
          
          return (aData['time'] as String).compareTo(bData['time'] as String);
        });

        return Column(
          children: sorted.asMap().entries.map((entry) {
            final index = entry.key;
            final doc = entry.value;
            final data = doc.data() as Map<String, dynamic>;
            final name = data['name'] ?? '';
            final dose = data['dose'] ?? '';
            final time = data['time'] as String? ?? '08:00';
            final isTaken = data['isTaken'] ?? false;

            final parts = time.split(':');
            final medMinutes = (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts[1]) ?? 0);
            
            bool isOverdue = !isTaken && medMinutes < currentMinutes;
            bool isUpcoming = !isTaken && medMinutes >= currentMinutes && medMinutes <= currentMinutes + 60;

            Color statusColor;
            String statusText;
            IconData statusIcon;

            if (isTaken) {
              statusColor = AppColors.mint;
              statusText = 'Принято ✓'.tr();
              statusIcon = Icons.check_circle_rounded;
            } else if (isOverdue) {
              statusColor = AppColors.coral;
              statusText = 'Пропущено!'.tr();
              statusIcon = Icons.warning_rounded;
            } else if (isUpcoming) {
              statusColor = AppColors.orange;
              statusText = 'Скоро'.tr();
              statusIcon = Icons.schedule_rounded;
            } else {
              statusColor = AppColors.sky;
              statusText = 'Позже'.tr();
              statusIcon = Icons.access_time_rounded;
            }

            return FadeSlideIn(
              delayMs: 150 + (index * 80),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SoftCard(
                  onTap: () {
                    _db.toggleMedicineTaken(doc.id, isTaken);
                  },
                  borderColor: isOverdue ? AppColors.coral.withOpacity(0.3) : null,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 48, height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: statusColor.withOpacity(0.1),
                        ),
                        child: Icon(
                          isTaken ? Icons.check_rounded : Icons.medication_rounded,
                          color: statusColor,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$name $dose',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                decoration: isTaken ? TextDecoration.lineThrough : null,
                                color: isTaken ? AppColors.textLight : AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(statusIcon, size: 12, color: statusColor),
                                const SizedBox(width: 4),
                                Text(time, style: TextStyle(fontSize: 12, color: AppColors.textHint, fontWeight: FontWeight.w600)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    statusText,
                                    style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isTaken ? AppColors.mint : Colors.transparent,
                          border: Border.all(
                            color: isTaken ? AppColors.mint : AppColors.border,
                            width: 2,
                          ),
                        ),
                        child: isTaken
                            ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildHealthInsights(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: DatabaseService().getPulseHistory(uid, limit: 5),
      builder: (context, snapshot) {
        final List<Map<String, dynamic>> insights = [];

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          insights.add({
            'title': 'Сделайте первый замер'.tr(),
            'body': 'Измерьте пульс чтобы получать персональные рекомендации.'.tr(),
            'icon': Icons.favorite_rounded,
            'color': AppColors.coral,
            'isNew': true,
            'time': 'Сейчас'.tr(),
          });
        } else {
          final docs = snapshot.data!.docs;
          final lastData = docs.first.data() as Map<String, dynamic>;
          final lastBpm = (lastData['bpm'] as num?)?.toInt() ?? 0;
          final lastSpo2 = (lastData['spo2'] as num?)?.toInt() ?? 0;
          final lastStress = lastData['stress'] as String? ?? '';
          final lastDate = (lastData['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();

          final hoursSinceLast = DateTime.now().difference(lastDate).inHours;
          if (hoursSinceLast > 24) {
            insights.add({
              'title': 'Напоминание о замере'.tr(),
              'body': 'Вы не измеряли пульс {}. Рекомендуем сделать замер.'.tr(
                args: [
                  hoursSinceLast > 48 
                    ? "{} дня".tr(args: ['${hoursSinceLast ~/ 24}']) 
                    : "более суток".tr()
                ],
              ),
              'icon': Icons.favorite_rounded,
              'color': AppColors.coral,
              'isNew': true,
              'time': _getTimeAgo(lastDate),
            });
          } else {
            insights.add({
              'title': 'Последний замер'.tr(),
              'body': 'Ваш пульс {} BPM · SpO2 {}% · Стресс: {}'.tr(
                args: [
                  '$lastBpm', 
                  '$lastSpo2', 
                  lastStress.tr() 
                ]
              ),
              'icon': Icons.favorite_rounded,
              'color': lastBpm > 100 ? AppColors.coral : AppColors.mint,
              'isNew': hoursSinceLast < 2,
              'time': _getTimeAgo(lastDate),
            });
          }

          if (lastBpm > 100) {
            insights.add({
              'title': 'Повышенный пульс'.tr(),
              'body': 'Ваш пульс {} BPM выше нормы. Отдохните, выпейте воды и повторите замер через 15 минут.'.tr(
                args: ['$lastBpm']
              ),
              'icon': Icons.warning_rounded,
              'color': AppColors.orange,
              'isNew': true,
              'time': 'Важно'.tr(),
            });
          }

          if (lastSpo2 > 0 && lastSpo2 < 95) {
            insights.add({
              'title': 'Низкий уровень кислорода'.tr(),
              'body': 'SpO2 {}% ниже нормы (95-100%). Проветрите помещение и сделайте глубокие вдохи.'.tr(
                args: ['$lastSpo2']
              ),
              'icon': Icons.air_rounded,
              'color': AppColors.coral,
              'isNew': true,
              'time': 'Внимание'.tr(),
            });
          }

          if (lastStress == 'Высокий') {
            insights.add({
              'title': 'Высокий уровень стресса'.tr(),
              'body': 'Попробуйте дыхательные упражнения: вдох 4 сек, задержка 7 сек, выдох 8 сек.'.tr(),
              'icon': Icons.self_improvement_rounded,
              'color': AppColors.purple,
              'isNew': true,
              'time': 'Совет'.tr(),
            });
          }

          if (docs.length >= 3) {
            int sum = 0;
            for (var doc in docs) {
              sum += ((doc.data() as Map<String, dynamic>)['bpm'] as num).toInt();
            }
            final avg = sum ~/ docs.length;

            insights.add({
              'title': 'Статистика за {} замеров'.tr(args: ['${docs.length}']),
              'body': '{} {} '.tr(args: [
                'Средний пульс: {} BPM.'.tr(args: ['$avg']),
                avg < 80 
                  ? "Отличный показатель! 💪".tr() 
                  : avg < 100 
                    ? "В пределах нормы.".tr() 
                    : "Рекомендуем следить за показателями.".tr()
              ]),
              'icon': Icons.analytics_rounded,
              'color': AppColors.sky,
              'isNew': false,
              'time': 'Аналитика'.tr(),
            });
          }

          if (lastBpm >= 55 && lastBpm <= 100 && lastSpo2 >= 95 && lastStress != 'Высокий' && hoursSinceLast < 24) {
            insights.add({
              'title': 'Всё в порядке! 💚'.tr(),
              'body': 'Ваши показатели в норме. Продолжайте следить за здоровьем и делайте замеры регулярно.'.tr(),
              'icon': Icons.check_circle_rounded,
              'color': AppColors.mint,
              'isNew': false,
              'time': 'Статус'.tr(),
            });
          }
        }

        return Column(
          children: insights.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;

            return FadeSlideIn(
              delayMs: 250 + (index * 80),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SoftCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(
                              color: (item['color'] as Color).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: 24),
                          ),
                          if (item['isNew'] as bool)
                            Positioned(
                              top: 0, right: 0,
                              child: Container(
                                width: 12, height: 12,
                                decoration: BoxDecoration(
                                  color: AppColors.coral,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    item['title'] as String,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(item['time'] as String, style: TextStyle(fontSize: 11, color: AppColors.textLight)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['body'] as String,
                              style: const TextStyle(fontSize: 12, color: AppColors.textMedium, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}