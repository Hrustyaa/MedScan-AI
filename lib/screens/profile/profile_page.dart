import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import '../../services/database_service.dart';
import '../../services/notification_service.dart';
import 'package:easy_localization/easy_localization.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  
  @override
  Widget build(BuildContext context) {
    final authUser = FirebaseAuth.instance.currentUser;
    if (authUser == null) {
      return const Center(child: CircularProgressIndicator(color: AppColors.mint));
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: DatabaseService().getUserStream(authUser.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData && snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.mint));
        }

        final userData = snapshot.data?.data() as Map<String, dynamic>? ?? {};
        final displayName = userData['name'] ?? authUser.displayName ?? 'Гость'.tr();
        final email = userData['email'] ?? authUser.email ?? 'No email';
        final age = userData['age'] ?? 25;
        final weight = userData['weight'] ?? 70;
        final height = userData['height'] ?? 175;
        final notificationsEnabled = userData['notifications'] ?? true;
        final bloodGroup = userData['blood_group'] ?? '--';
        final pressure = userData['pressure'] ?? '120/80';
        final conditions = userData['conditions'] ?? 'Нет'.tr();
        return SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeSlideIn(
                  key: UniqueKey(),
                  delayMs: 0,
                  offset: const Offset(0, -20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ЛИЧНЫЙ КАБИНЕТ'.tr(),
                        style: TextStyle(
                          fontSize: 10, letterSpacing: 3,
                          color: AppColors.mint.withOpacity(0.7), fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('Мой профиль'.tr(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                FadeSlideIn(
                  key: UniqueKey(),
                  delayMs: 100,
                  child: SoftCard(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          width: 64, height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(colors: [AppColors.mint, AppColors.sky]),
                            boxShadow: [BoxShadow(color: AppColors.mint.withOpacity(0.3), blurRadius: 12)],
                          ),
                          child: Center(
                            child: Text(
                              displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 300),
                                      child: Text(
                                        displayName,
                                        key: ValueKey(displayName),
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () => _showEditDialog(context, 'Имя'.tr(), 'name', displayName, isNumber: false),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(8)),
                                      child: const Icon(Icons.edit_rounded, size: 14, color: AppColors.mint),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(email, style: TextStyle(fontSize: 13, color: AppColors.textLight)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                FadeSlideIn(key: UniqueKey(), delayMs: 150, child: Text('Мои параметры'.tr(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark))),
                const SizedBox(height: 12),
                FadeSlideIn(
                  key: UniqueKey(),
                  delayMs: 200,
                  child: Row(
                    children: [
                      Expanded(child: SoftCard(onTap: () => _showEditDialog(context, 'Возраст'.tr(), 'age', age.toString()), padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8), child: _bioContent('Возраст'.tr(), '$age', 'лет'.tr(), Icons.cake_rounded, AppColors.orange))),
                      const SizedBox(width: 12),
                      Expanded(child: SoftCard(onTap: () => _showEditDialog(context, 'Вес'.tr(), 'weight', weight.toString()), padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8), child: _bioContent('Вес'.tr(), '$weight', 'кг'.tr(), Icons.monitor_weight_rounded, AppColors.sky))),
                      const SizedBox(width: 12),
                      Expanded(child: SoftCard(onTap: () => _showEditDialog(context, 'Рост'.tr(), 'height', height.toString()), padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8), child: _bioContent('Рост'.tr(), '$height', 'см'.tr(), Icons.height_rounded, AppColors.purple))),
                    ],
                  ),
                ),
                
                const SizedBox(height: 12),

                FadeSlideIn(
                  key: UniqueKey(),
                  delayMs: 250,
                  child: Row(
                    children: [
                      Expanded(child: SoftCard(onTap: () => _showEditDialog(context, 'Группа крови'.tr(), 'blood_group', bloodGroup, isNumber: false), padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8), child: _bioContent('Группа'.tr(), bloodGroup, '', Icons.bloodtype_rounded, AppColors.coral))),
                      const SizedBox(width: 12),
                      Expanded(child: SoftCard(onTap: () => _showEditDialog(context, 'Давление'.tr(), 'pressure', pressure, isNumber: false), padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8), child: _bioContent('Давление'.tr(), pressure, '', Icons.speed_rounded, AppColors.mint))),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                FadeSlideIn(
                  key: UniqueKey(),
                  delayMs: 300,
                  child: SoftCard(
                    onTap: () => _showEditDialog(context, 'Болезни'.tr(), 'conditions', conditions, isNumber: false),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.medical_services_rounded, color: AppColors.orange, size: 24),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Особенности здоровья / Болезни'.tr(), style: TextStyle(fontSize: 11, color: AppColors.textLight)),
                              Text(conditions, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),

                FadeSlideIn(key: UniqueKey(), delayMs: 250, child: Text('Статистика'.tr(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark))),
                const SizedBox(height: 12),

                StreamBuilder<QuerySnapshot>(
                  stream: DatabaseService().getPulseHistory(authUser.uid),
                  builder: (context, snapshot) {
                    int total = 0;
                    int avg = 0;
                    if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                      total = snapshot.data!.docs.length;
                      int sum = 0;
                      for (var doc in snapshot.data!.docs) {
                        sum += (doc['bpm'] as num).toInt();
                      }
                      avg = (sum / total).round();
                    }
                    
                    return FadeSlideIn(
                      key: UniqueKey(),
                      delayMs: 300,
                      child: Row(
                        children: [
                          Expanded(child: _statCard('Всего замеров'.tr(), '$total', AppColors.mint)),
                          const SizedBox(width: 12),
                          Expanded(child: _statCard('Средний пульс'.tr(), avg > 0 ? '$avg' : '--', AppColors.coral)),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                FadeSlideIn(
                  key: UniqueKey(),
                  delayMs: 350,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Последние измерения'.tr(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                      GestureDetector(
                        onTap: () => _showFullHistory(context, authUser.uid),
                        child: Text('См. все'.tr(), style: TextStyle(color: AppColors.mint, fontSize: 13, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                StreamBuilder<QuerySnapshot>(
                  stream: DatabaseService().getPulseHistory(authUser.uid, limit: 3),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return FadeSlideIn(
                        key: UniqueKey(),
                        delayMs: 400,
                        child: SoftCard(
                          padding: const EdgeInsets.all(30),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.history_rounded, size: 40, color: AppColors.textLight.withOpacity(0.5)),
                                const SizedBox(height: 10),
                                Text('Пока нет данных'.tr(), style: TextStyle(color: AppColors.textLight)),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    final docs = snapshot.data!.docs;
                    
                    return Column(
                      children: docs.asMap().entries.map((entry) {
                        final index = entry.key;
                        final doc = entry.value;
                        final data = doc.data() as Map<String, dynamic>;
                        final bpm = data['bpm'] ?? 0;
                        final date = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
                        final dateStr = "${date.day}.${date.month}  ${date.hour}:${date.minute.toString().padLeft(2, '0')}";

                        return FadeSlideIn(
                          key: ValueKey(doc.id),
                          delayMs: 400 + (index * 100),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: SoftCard(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 40, height: 40,
                                        decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(12)),
                                        child: const Icon(Icons.favorite_rounded, color: AppColors.coral, size: 20),
                                      ),
                                      const SizedBox(width: 14),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('$bpm BPM', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textDark)),
                                          const SizedBox(height: 2),
                                          Text(dateStr, style: TextStyle(fontSize: 11, color: AppColors.textLight)),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Icon(Icons.chevron_right_rounded, color: AppColors.textHint, size: 20),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),

                const SizedBox(height: 24),

                FadeSlideIn(key: UniqueKey(), delayMs: 650, child: Text('Настройки'.tr(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark))),
                const SizedBox(height: 12),

                FadeSlideIn(
                  key: UniqueKey(),
                  delayMs: 700,
                  child: SoftCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: AppColors.sky.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.notifications_rounded, size: 18, color: AppColors.sky),
                        ),
                        
                        const SizedBox(width: 14),
                        Expanded(child: Text('Уведомления'.tr(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark))),
                        Switch(
                          value: notificationsEnabled, 
                          activeColor: AppColors.mint,
                          onChanged: (val) async {
                            await DatabaseService().updateUserData({'notifications': val});
                            if (!val) {
                              await NotificationService().cancelAllNotifications();
                              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Все уведомления отключены'.tr()), backgroundColor: AppColors.coral));
                            } else {
                              await NotificationService().requestPermissions();
                              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Уведомления включены'.tr()), backgroundColor: AppColors.mint));
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 10),
                FadeSlideIn(
                  key: UniqueKey(),
                  delayMs: 720,
                  child: _buildLanguageSetting(context),
                ),

                const SizedBox(height: 10),
                FadeSlideIn(
                  key: UniqueKey(),
                  delayMs: 750,
                  child: GestureDetector(
                    onTap: () => _showPrivacyDialog(context),
                    child: _settingsItem(Icons.shield_rounded, 'Конфиденциальность'.tr(), AppColors.mint),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                FadeSlideIn(
                  key: UniqueKey(),
                  delayMs: 800,
                  child: GestureDetector(
                    onTap: () => _showLogoutDialog(context),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.coralLight.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.coral.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.logout_rounded, color: AppColors.coral),
                          const SizedBox(width: 12),
                          Expanded(child: Text('Выйти из аккаунта'.tr(), style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.coral))),
                          const Icon(Icons.chevron_right_rounded, color: AppColors.coral),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, String title, String field, String currentVal, {bool isNumber = true}) {
    final controller = TextEditingController(text: currentVal);
    
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Container();
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: FadeTransition(
            opacity: anim1,
            child: AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text('Изменить {}'.tr(args: [title]), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              content: TextField(
                controller: controller,
                keyboardType: isNumber ? TextInputType.number : TextInputType.text,
                inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : [],
                autofocus: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.bg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  hintText: 'Новое значение'.tr(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Отмена'.tr(), style: const TextStyle(color: AppColors.textLight)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (controller.text.isNotEmpty) {
                      dynamic value = isNumber ? int.parse(controller.text) : controller.text;
                      await DatabaseService().updateUserData({field: value});
                      if (field == 'name') {
                        await FirebaseAuth.instance.currentUser?.updateDisplayName(value.toString());
                      }
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.mint, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: Text('Сохранить'.tr(), style: const TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFullHistory(BuildContext context, String uid) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppColors.bg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              Text('История измерений'.tr(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              const SizedBox(height: 20),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: DatabaseService().getPulseHistory(uid),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    final docs = snapshot.data!.docs;
                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        final bpm = data['bpm'] ?? 0;
                        final min = data['min'] ?? 0;
                        final max = data['max'] ?? 0;
                        final date = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
                        final dateStr = "${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SoftCard(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(color: AppColors.mintSoft, borderRadius: BorderRadius.circular(10)),
                                  child: Text('$bpm', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.mint)),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(dateStr, style: const TextStyle(fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 4),
                                      Text('${'Мин'.tr()}: $min  ${'Макс'.tr()}: $max', style: TextStyle(color: AppColors.textLight, fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ],
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
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => Container(),
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text('Конфиденциальность'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Text('Ваши данные хранятся локально и в защищенном облаке.\n\nМы используем камеру только для анализа кровотока в пальце.'.tr(), style: const TextStyle(fontSize: 14)),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text('Понятно'.tr(), style: const TextStyle(color: AppColors.mint))),
            ],
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => Container(),
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Text('Выход'.tr(), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
            content: Text('Вы уверены, что хотите выйти из аккаунта?'.tr(), style: const TextStyle(color: AppColors.textMedium)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Отмена'.tr(), style: const TextStyle(color: AppColors.textLight)),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await FirebaseAuth.instance.signOut();
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.coral, elevation: 0),
                child: Text('Выйти'.tr(), style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _bioContent(String label, String value, String unit, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(value, key: ValueKey(value), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark)),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 2, left: 2),
              child: Text(unit, style: TextStyle(fontSize: 10, color: AppColors.textLight)),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 10, color: AppColors.textLight)),
      ],
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return SoftCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.analytics_rounded, size: 16, color: color),
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(value, key: ValueKey(value), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textDark)),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, color: AppColors.textLight, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _settingsItem(IconData icon, String label, Color color) {
    return SoftCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark))),
          Icon(Icons.chevron_right_rounded, color: AppColors.textHint, size: 20),
        ],
      ),
    );
  }

  Widget _buildLanguageSetting(BuildContext context) {
    final Map<String, String> languageNames = {
      'en': 'English',
      'ru': 'Русский',
      'kk': 'Қазақша',
    };
    
    final currentLang = context.locale.languageCode;
    
    return SoftCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.language_rounded,
              size: 18,
              color: AppColors.purple,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Язык'.tr(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
          DropdownButton<String>(
            value: currentLang,
            underline: const SizedBox(),
            borderRadius: BorderRadius.circular(12),
            items: languageNames.entries.map((entry) {
              return DropdownMenuItem<String>(
                value: entry.key,
                child: Text(
                  entry.value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: currentLang == entry.key
                        ? FontWeight.w700
                        : FontWeight.w400,
                    color: currentLang == entry.key
                        ? AppColors.mint
                        : AppColors.textMedium,
                  ),
                ),
              );
            }).toList(),
            onChanged: (String? newLang) {
              if (newLang != null && newLang != currentLang) {
                context.setLocale(Locale(newLang));
                DatabaseService().updateUserData({
                  'language': newLang,
                });
              }
            },
          ),
        ],
      ),
    );
  }
}