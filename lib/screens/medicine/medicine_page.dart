import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import '../../services/database_service.dart';
import '../../services/notification_service.dart';
import 'package:easy_localization/easy_localization.dart';

class MedicinePage extends StatefulWidget {
  const MedicinePage({Key? key}) : super(key: key);
  @override
  State<MedicinePage> createState() => _MedicinePageState();
}

class _MedicinePageState extends State<MedicinePage> {
  final _db = DatabaseService();
  final _notif = NotificationService();

  @override
  void initState() {
    super.initState();
    _checkAndRequestPermissions();
  }

  Future<void> _checkAndRequestPermissions() async {
    final enabled = await _notif.areNotificationsEnabled();
    if (!enabled) {
      final granted = await _notif.requestPermissions();
      if (!granted && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ Разрешите уведомления в настройках телефона'.tr()),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  Text(
                    'Мои лекарства'.tr(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _showAddDialog(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.mintSoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.add_rounded,
                          size: 24, color: AppColors.mint),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: StreamBuilder<QuerySnapshot>(
                stream: _db.getMedicinesStream(),
                builder: (context, snapshot) {
                  int total = 0;
                  int taken = 0;
                  if (snapshot.hasData) {
                    total = snapshot.data!.docs.length;
                    taken = snapshot.data!.docs
                        .where((doc) => doc['isTaken'] == true)
                        .length;
                  }
                  double progress = total == 0 ? 0 : taken / total;

                  return SoftCard(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: progress),
                                duration: const Duration(milliseconds: 600),
                                curve: Curves.easeOutCubic,
                                builder: (context, value, _) {
                                  return CircularProgressIndicator(
                                    value: value,
                                    strokeWidth: 5,
                                    backgroundColor: AppColors.border,
                                    valueColor: const AlwaysStoppedAnimation(
                                        AppColors.mint),
                                    strokeCap: StrokeCap.round,
                                  );
                                },
                              ),
                              Text(
                                '${(progress * 100).round()}%',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.mint,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Прогресс на сегодня'.tr(),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '{} из {} приемов'.tr(args: ['$taken', '$total']),
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.textLight),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _db.getMedicinesStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child:
                            CircularProgressIndicator(color: AppColors.mint));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.medication_rounded,
                              size: 60,
                              color: AppColors.textLight.withOpacity(0.3)),
                          const SizedBox(height: 16),
                          Text('Список пуст'.tr(),
                              style: TextStyle(color: AppColors.textLight)),
                          Text('Нажмите + чтобы добавить'.tr(),
                              style: TextStyle(
                                  color: AppColors.textLight, fontSize: 12)),
                        ],
                      ),
                    );
                  }

                  final docs = snapshot.data!.docs;

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final bool isTaken = data['isTaken'] ?? false;
                      final int notifId = data['notificationId'] ?? 0;

                      return FadeSlideIn(
                        key: ValueKey(doc.id),
                        delayMs: index * 100,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Dismissible(
                            key: Key(doc.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: AppColors.coral.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(Icons.delete_rounded,
                                  color: AppColors.coral),
                            ),
                            onDismissed: (_) async {
                              await _notif.cancelNotification(notifId);
                              await _db.deleteMedicine(doc.id);
                            },
                            child: SoftCard(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                _db.toggleMedicineTaken(doc.id, isTaken);
                              },
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  AnimatedContainer(
                                    duration:
                                        const Duration(milliseconds: 300),
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(14),
                                      color: isTaken
                                          ? AppColors.mintSoft
                                          : AppColors.skyLight,
                                    ),
                                    child: AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      child: Icon(
                                        isTaken
                                            ? Icons.check_rounded
                                            : Icons.medication_rounded,
                                        key: ValueKey(isTaken),
                                        color: isTaken
                                            ? AppColors.mint
                                            : AppColors.sky,
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        AnimatedDefaultTextStyle(
                                          duration: const Duration(
                                              milliseconds: 300),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            decoration: isTaken
                                                ? TextDecoration.lineThrough
                                                : null,
                                            color: isTaken
                                                ? AppColors.textLight
                                                : AppColors.textDark,
                                          ),
                                          child: Text(
                                              '${data['name']} ${data['dose']}'),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(
                                                Icons.access_time_rounded,
                                                size: 12,
                                                color: AppColors.textHint),
                                            const SizedBox(width: 4),
                                            Text(
                                              data['time'],
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: AppColors.textHint,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final doseCtrl = TextEditingController();
    TimeOfDay selectedTime = const TimeOfDay(hour: 8, minute: 0);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: EdgeInsets.only(
              top: 24,
              left: 24,
              right: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Добавить лекарство'.tr(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    hintText: 'Название (напр. Аспирин)'.tr(),
                    filled: true,
                    fillColor: AppColors.bg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: doseCtrl,
                  decoration: InputDecoration(
                    hintText: 'Дозировка (напр. 500мг)'.tr(),
                    filled: true,
                    fillColor: AppColors.bg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                GestureDetector(
                  onTap: () async {
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (picked != null) {
                      setState(() => selectedTime = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.bg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Время приема'.tr(),
                            style: TextStyle(color: AppColors.textMedium)),
                        Text(
                          selectedTime.format(context),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.mint,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (nameCtrl.text.isEmpty) return;

                      final hour =
                          selectedTime.hour.toString().padLeft(2, '0');
                      final minute =
                          selectedTime.minute.toString().padLeft(2, '0');
                      final timeStr = "$hour:$minute";

                      final notifId = DateTime.now()
                          .millisecondsSinceEpoch
                          .remainder(100000);

                      try {
                        await _notif.scheduleNotification(
                          notifId,
                          'Время лекарств! 💊'.tr(),
                          'Примите {} {}'.tr(args: [nameCtrl.text, doseCtrl.text]),
                          selectedTime.hour,
                          selectedTime.minute,
                        );

                        await _db.addMedicine(
                          nameCtrl.text,
                          doseCtrl.text,
                          timeStr,
                          notifId,
                        );

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('✅ Напоминание на {} установлено'.tr(args: [timeStr])),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        print("🔥 ОШИБКА: $e");
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('❌ Ошибка: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mint,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'СОХРАНИТЬ'.tr(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}