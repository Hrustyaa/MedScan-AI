import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import 'package:easy_localization/easy_localization.dart';

class Doctor {
  final String id;
  final String name;
  final String specialty;
  final String bio;
  final double rating;
  final int reviewCount;
  final String experience;
  final String distance;
  final String avatar;
  final bool available;
  final String nextSlot;
  final int price;
  final List<String> services;
  final List<String> education;
  final List<Map<String, dynamic>> reviews;
  final Map<String, List<String>> schedule;
  final Color accentColor;

  const Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.bio,
    required this.rating,
    required this.reviewCount,
    required this.experience,
    required this.distance,
    required this.avatar,
    required this.available,
    required this.nextSlot,
    required this.price,
    required this.services,
    required this.education,
    required this.reviews,
    required this.schedule,
    required this.accentColor,
  });
}

final List<Doctor> _allDoctors = [
  Doctor(
    id: 'doc_1',
    name: 'Др. Иванова А.С.',
    specialty: 'Кардиолог',
    bio: 'Ведущий кардиолог с 15-летним опытом. Специализируется на диагностике и лечении аритмий, ишемической болезни сердца и реабилитации после инфаркта.',
    rating: 4.9, reviewCount: 247, experience: '15 лет', distance: '1.2 км',
    avatar: '👩‍⚕️', available: true, nextSlot: 'Сегодня, 14:30', price: 3500,
    services: ['ЭКГ', 'ЭхоКГ', 'Холтер', 'Консультация', 'Тест с нагрузкой'],
    education: ['МГУ им. Сеченова, 2009', 'Ординатура НМИЦ Кардиологии', 'PhD — Аритмология'],
    reviews: [
      {'name': 'Мария К.', 'text': 'Прекрасный врач! Всё объяснила, назначила правильное лечение.', 'rating': 5, 'date': '2 дня назад'},
      {'name': 'Алексей В.', 'text': 'Внимательная, профессиональная. Рекомендую!', 'rating': 5, 'date': '1 неделю назад'},
      {'name': 'Елена С.', 'text': 'Помогла разобраться с аритмией, спасибо!', 'rating': 4, 'date': '2 недели назад'},
    ],
    schedule: {
      'Пн': ['09:00', '10:30', '14:00', '15:30'],
      'Вт': ['10:00', '11:30', '16:00'],
      'Ср': ['09:00', '10:30', '14:00'],
      'Чт': ['10:00', '11:30', '15:00', '16:30'],
      'Пт': ['09:00', '10:30'],
    },
    accentColor: AppColors.coral,
  ),
  Doctor(
    id: 'doc_2',
    name: 'Др. Петров В.М.',
    specialty: 'Терапевт',
    bio: 'Врач-терапевт высшей категории. Занимается общей диагностикой, профилактикой хронических заболеваний и ведением пациентов с коморбидной патологией.',
    rating: 4.7, reviewCount: 183, experience: '12 лет', distance: '2.5 км',
    avatar: '👨‍⚕️', available: true, nextSlot: 'Завтра, 09:00', price: 2500,
    services: ['Общий осмотр', 'Анализы', 'УЗИ', 'Вакцинация', 'Справки'],
    education: ['РНИМУ им. Пирогова, 2012', 'Ординатура ГКБ №1'],
    reviews: [
      {'name': 'Ольга Д.', 'text': 'Очень грамотный терапевт, всё по делу.', 'rating': 5, 'date': '3 дня назад'},
      {'name': 'Игорь П.', 'text': 'Быстро поставил диагноз, помог с лечением.', 'rating': 4, 'date': '1 неделю назад'},
    ],
    schedule: {
      'Пн': ['08:00', '09:30', '11:00', '14:00', '15:30'],
      'Вт': ['09:00', '10:30', '14:00', '15:30', '17:00'],
      'Ср': ['08:00', '09:30', '11:00'],
      'Чт': ['09:00', '10:30', '14:00', '15:30'],
      'Пт': ['08:00', '09:30', '11:00', '14:00'],
    },
    accentColor: AppColors.mint,
  ),
  Doctor(
    id: 'doc_3',
    name: 'Др. Сидорова Е.Н.',
    specialty: 'Невролог',
    bio: 'Невролог с 20-летним стажем. Эксперт в лечении мигрени, болей в спине, неврозов и восстановлении после инсультов. Автор 30+ научных публикаций.',
    rating: 4.8, reviewCount: 312, experience: '20 лет', distance: '3.1 км',
    avatar: '👩‍⚕️', available: false, nextSlot: 'Среда, 10:00', price: 4000,
    services: ['МРТ расшифровка', 'ЭЭГ', 'Блокады', 'Мануальная терапия', 'Ботулинотерапия'],
    education: ['МГУ им. Сеченова, 2004', 'Докторская — РАМН', 'Стажировка Charité, Берлин'],
    reviews: [
      {'name': 'Наталья М.', 'text': 'Наконец-то избавилась от мигрени! Спасибо огромное!', 'rating': 5, 'date': '1 день назад'},
      {'name': 'Сергей Л.', 'text': 'Лучший невролог в городе, без преувеличения.', 'rating': 5, 'date': '5 дней назад'},
      {'name': 'Анна Р.', 'text': 'Помогла маме после инсульта, очень благодарны.', 'rating': 5, 'date': '2 недели назад'},
    ],
    schedule: {
      'Ср': ['10:00', '11:30', '14:00'],
      'Чт': ['09:00', '10:30', '14:00', '15:30'],
      'Пт': ['10:00', '11:30'],
    },
    accentColor: AppColors.purple,
  ),
  Doctor(
    id: 'doc_4',
    name: 'Др. Козлов И.П.',
    specialty: 'Хирург',
    bio: 'Хирург-ортопед. Выполняет артроскопические операции, лечение травм, эндопротезирование суставов. Спортивная медицина.',
    rating: 4.6, reviewCount: 98, experience: '8 лет', distance: '4.0 км',
    avatar: '👨‍⚕️', available: true, nextSlot: 'Сегодня, 16:00', price: 5000,
    services: ['Артроскопия', 'Консультация', 'PRP-терапия', 'Фиксация переломов', 'Реабилитация'],
    education: ['РНИМУ им. Пирогова, 2016', 'Ординатура ЦИТО'],
    reviews: [
      {'name': 'Дмитрий К.', 'text': 'Сделал операцию на колене, всё прошло отлично!', 'rating': 5, 'date': '1 неделю назад'},
      {'name': 'Виктор Б.', 'text': 'Хороший хирург, руки золотые.', 'rating': 4, 'date': '3 недели назад'},
    ],
    schedule: {
      'Пн': ['14:00', '15:30', '17:00'],
      'Вт': ['09:00', '10:30'],
      'Чт': ['14:00', '15:30', '17:00'],
      'Пт': ['09:00', '10:30', '14:00'],
    },
    accentColor: AppColors.sky,
  ),
  Doctor(
    id: 'doc_5',
    name: 'Др. Новикова М.А.',
    specialty: 'Кардиолог',
    bio: 'Кардиолог-аритмолог с международным опытом. Специализируется на имплантации кардиостимуляторов и абляции аритмий.',
    rating: 4.9, reviewCount: 176, experience: '18 лет', distance: '1.8 км',
    avatar: '👩‍⚕️', available: true, nextSlot: 'Сегодня, 11:00', price: 4500,
    services: ['ЭКГ', 'Имплантация КС', 'Абляция', 'Суточный мониторинг', 'Стресс-тест'],
    education: ['МГМУ им. Сеченова, 2006', 'Fellowship Mayo Clinic, USA', 'Член ESC'],
    reviews: [
      {'name': 'Татьяна Ш.', 'text': 'Спасла жизнь моему мужу! Вечно благодарны.', 'rating': 5, 'date': '4 дня назад'},
      {'name': 'Павел Н.', 'text': 'Настоящий профессионал мирового уровня.', 'rating': 5, 'date': '1 неделю назад'},
      {'name': 'Людмила А.', 'text': 'Объяснила всё простым языком, очень терпеливая.', 'rating': 5, 'date': '2 недели назад'},
    ],
    schedule: {
      'Пн': ['09:00', '10:30', '14:00'],
      'Вт': ['11:00', '14:00', '15:30'],
      'Ср': ['09:00', '10:30', '14:00', '15:30'],
      'Пт': ['09:00', '10:30'],
    },
    accentColor: AppColors.coral,
  ),
  Doctor(
    id: 'doc_6',
    name: 'Др. Волков Д.С.',
    specialty: 'Терапевт',
    bio: 'Семейный врач с комплексным подходом. Ведение беременности, детей и пожилых пациентов. Выезд на дом.',
    rating: 4.8, reviewCount: 215, experience: '14 лет', distance: '0.8 км',
    avatar: '👨‍⚕️', available: true, nextSlot: 'Сегодня, 17:00', price: 2000,
    services: ['Приём на дому', 'Общий осмотр', 'Рецепты', 'Направления', 'Чекап'],
    education: ['Казанский ГМУ, 2010', 'Повышение квалификации РМАПО'],
    reviews: [
      {'name': 'Семья Ивановых', 'text': 'Наш семейный доктор уже 5 лет, доверяем на 100%.', 'rating': 5, 'date': '2 дня назад'},
    ],
    schedule: {
      'Пн': ['08:00', '09:30', '11:00', '14:00', '15:30', '17:00'],
      'Вт': ['08:00', '09:30', '11:00', '14:00', '15:30'],
      'Ср': ['08:00', '09:30', '11:00'],
      'Чт': ['14:00', '15:30', '17:00'],
      'Пт': ['08:00', '09:30', '11:00', '14:00', '15:30', '17:00'],
    },
    accentColor: AppColors.mint,
  ),
];

class DoctorsPage extends StatefulWidget {
  const DoctorsPage({Key? key}) : super(key: key);
  @override
  State<DoctorsPage> createState() => _DoctorsPageState();
}

class _DoctorsPageState extends State<DoctorsPage> {
  String _selectedSpecialty = 'Все';
  String _searchQuery = '';
  final _searchController = TextEditingController();

  final _specialties = ['Все', 'Терапевт', 'Кардиолог', 'Невролог', 'Хирург'];

  List<Doctor> get _filtered {
    var list = _allDoctors.toList();
    if (_selectedSpecialty != 'Все') {
      list = list.where((d) => d.specialty == _selectedSpecialty).toList();
    }
    if (_searchQuery.isNotEmpty) {
      list = list.where((d) =>
          d.name.tr().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          d.specialty.tr().toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    return list;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeSlideIn(delayMs: 0, child: Text('КАТАЛОГ'.tr(), style: TextStyle(fontSize: 10, letterSpacing: 3, color: AppColors.mint.withOpacity(0.7), fontWeight: FontWeight.w700))),
                const SizedBox(height: 4),
                FadeSlideIn(delayMs: 100, child: Text('Наши врачи'.tr(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textDark))),
              ],
            ),
          ),
          const SizedBox(height: 16),

          FadeSlideIn(
            delayMs: 200,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border), boxShadow: [BoxShadow(color: AppColors.textDark.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))]),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded, color: AppColors.textHint, size: 20),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(controller: _searchController, onChanged: (v) => setState(() => _searchQuery = v), decoration: InputDecoration(hintText: 'Поиск по имени или специальности...'.tr(), hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14), border: InputBorder.none), style: const TextStyle(color: AppColors.textDark))),
                    if (_searchQuery.isNotEmpty) GestureDetector(onTap: () { _searchController.clear(); setState(() => _searchQuery = ''); }, child: const Icon(Icons.close_rounded, color: AppColors.textHint, size: 18)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          FadeSlideIn(
            delayMs: 300,
            child: SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal, physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20), itemCount: _specialties.length,
                itemBuilder: (c, i) {
                  final sel = _selectedSpecialty == _specialties[i];
                  final count = _specialties[i] == 'Все' ? _allDoctors.length : _allDoctors.where((d) => d.specialty == _specialties[i]).length;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedSpecialty = _specialties[i]),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250), curve: Curves.easeOutCubic,
                      margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(color: sel ? AppColors.mint : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: sel ? AppColors.mint : AppColors.border), boxShadow: sel ? [BoxShadow(color: AppColors.mint.withOpacity(0.2), blurRadius: 8)] : []),
                      alignment: Alignment.center,
                      child: Row(children: [Text(_specialties[i].tr(), style: TextStyle(color: sel ? Colors.white : AppColors.textMedium, fontSize: 12, fontWeight: sel ? FontWeight.w700 : FontWeight.w500)), const SizedBox(width: 6), Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1), decoration: BoxDecoration(color: sel ? Colors.white.withOpacity(0.25) : AppColors.bg, borderRadius: BorderRadius.circular(8)), child: Text('$count', style: TextStyle(color: sel ? Colors.white : AppColors.textLight, fontSize: 10, fontWeight: FontWeight.w700)))]),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _filtered.isEmpty
                  ? Center(key: const ValueKey('empty'), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.search_off_rounded, size: 60, color: AppColors.textLight.withOpacity(0.3)), const SizedBox(height: 16), Text('Врачи не найдены'.tr(), style: const TextStyle(color: AppColors.textLight)), const SizedBox(height: 4), Text('Попробуйте другой запрос'.tr(), style: const TextStyle(color: AppColors.textHint, fontSize: 12))]))
                  : ListView.builder(
                      key: ValueKey(_selectedSpecialty + _searchQuery),
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 120),
                      itemCount: _filtered.length,
                      itemBuilder: (context, i) {
                        final doc = _filtered[i];
                        return FadeSlideIn(
                          delayMs: i * 80,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _DoctorCard(doctor: doc, onTap: () => _openDoctorProfile(context, doc)),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _openDoctorProfile(BuildContext context, Doctor doctor) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) => _DoctorProfilePage(doctor: doctor),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut), child: child);
        },
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback onTap;
  const _DoctorCard({required this.doctor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Hero(
                tag: 'avatar_${doctor.id}',
                child: Material(
                  type: MaterialType.transparency,
                  child: Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: LinearGradient(colors: [doctor.accentColor.withOpacity(0.15), doctor.accentColor.withOpacity(0.05)])),
                    child: Center(child: Text(doctor.avatar, style: const TextStyle(fontSize: 28))),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(doctor.name.tr(), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                  const SizedBox(height: 3),
                  Row(children: [
                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: doctor.accentColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                      child: Text(doctor.specialty.tr(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: doctor.accentColor))),
                    const SizedBox(width: 8),
                    Text(doctor.experience.tr(), style: TextStyle(fontSize: 11, color: AppColors.textLight))
                  ]),
                  const SizedBox(height: 6),
                  Row(children: [const Icon(Icons.star_rounded, color: AppColors.orange, size: 14), const SizedBox(width: 3), Text('${doctor.rating}', style: const TextStyle(color: AppColors.orange, fontSize: 12, fontWeight: FontWeight.w700)), Text(' (${doctor.reviewCount})', style: const TextStyle(color: AppColors.textHint, fontSize: 11)), const SizedBox(width: 10), const Icon(Icons.location_on_rounded, color: AppColors.textHint, size: 12), const SizedBox(width: 2), Text(doctor.distance.tr(), style: const TextStyle(color: AppColors.textHint, fontSize: 11))]),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(children: [
            Icon(Icons.schedule_rounded, size: 14, color: doctor.available ? AppColors.mint : AppColors.textHint),
            const SizedBox(width: 6),
            Expanded(child: Text(doctor.available ? doctor.nextSlot.tr() : 'Нет свободных окон'.tr(), style: TextStyle(fontSize: 12, color: doctor.available ? AppColors.textMedium : AppColors.textLight, fontWeight: FontWeight.w500))),
            Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: doctor.available ? AppColors.mint : AppColors.bg, boxShadow: doctor.available ? [BoxShadow(color: AppColors.mint.withOpacity(0.2), blurRadius: 8)] : []),
              child: Text(doctor.available ? 'Записаться'.tr() : 'Нет мест'.tr(), style: TextStyle(color: doctor.available ? Colors.white : AppColors.textLight, fontSize: 12, fontWeight: FontWeight.w700))),
          ]),
        ],
      ),
    );
  }
}

class _DoctorProfilePage extends StatefulWidget {
  final Doctor doctor;
  const _DoctorProfilePage({required this.doctor});
  @override
  State<_DoctorProfilePage> createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<_DoctorProfilePage> with SingleTickerProviderStateMixin {
  String? _selectedDay;
  String? _selectedTime;
  bool _booked = false;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..forward();
    if (widget.doctor.schedule.isNotEmpty) {
      _selectedDay = widget.doctor.schedule.keys.first;
    }
  }

  @override
  void dispose() { _fadeController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final doc = widget.doctor;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 280, pinned: true, backgroundColor: Colors.white,
            leading: GestureDetector(onTap: () => Navigator.pop(context), child: Container(margin: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)]), child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.textDark))),
            flexibleSpace: FlexibleSpaceBar(
              background: Material(
                type: MaterialType.transparency,
                child: Container(
                  decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [doc.accentColor.withOpacity(0.15), doc.accentColor.withOpacity(0.05), AppColors.bg])),
                  child: SafeArea(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          const SizedBox(height: 10),
                          Hero(tag: 'avatar_${doc.id}', child: Material(type: MaterialType.transparency, child: Container(width: 90, height: 90, decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), gradient: LinearGradient(colors: [doc.accentColor.withOpacity(0.2), doc.accentColor.withOpacity(0.05)]), boxShadow: [BoxShadow(color: doc.accentColor.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 8))]), child: Center(child: Text(doc.avatar, style: const TextStyle(fontSize: 44)))))),
                          const SizedBox(height: 16),
                          FadeTransition(opacity: _fadeController, child: Text(doc.name.tr(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textDark))),
                          const SizedBox(height: 6),
                          FadeTransition(opacity: _fadeController, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: doc.accentColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(doc.specialty.tr(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: doc.accentColor)))),
                          const SizedBox(height: 10),
                        ]),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeController,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    _statChip(Icons.star_rounded, '${doc.rating}', AppColors.orange),
                    _statChip(Icons.chat_rounded, '{} отзывов'.tr(args: ['${doc.reviewCount}']), AppColors.sky),
                    _statChip(Icons.work_rounded, doc.experience.tr(), AppColors.mint),
                    _statChip(Icons.location_on_rounded, doc.distance.tr(), AppColors.purple),
                    _statChip(Icons.payments_rounded, '{} ₽'.tr(args: ['${doc.price}']), AppColors.coral),
                  ]),
                  const SizedBox(height: 24),

                  Text('О враче'.tr(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                  const SizedBox(height: 8),
                  Text(doc.bio.tr(), style: const TextStyle(fontSize: 14, color: AppColors.textMedium, height: 1.6)),
                  const SizedBox(height: 24),

                  Text('Услуги'.tr(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                  const SizedBox(height: 12),
                  Wrap(spacing: 8, runSpacing: 8, children: doc.services.map((s) => Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), decoration: BoxDecoration(color: doc.accentColor.withOpacity(0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: doc.accentColor.withOpacity(0.15))), child: Text(s.tr(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: doc.accentColor)))).toList()),
                  const SizedBox(height: 24),

                  Text('Образование'.tr(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                  const SizedBox(height: 12),
                  ...doc.education.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(children: [
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: doc.accentColor, shape: BoxShape.circle)),
                      const SizedBox(width: 12),
                      Expanded(child: Text(e.tr(), style: const TextStyle(fontSize: 13, color: AppColors.textMedium))),
                    ]),
                  )),
                  const SizedBox(height: 24),

                  if (doc.available && doc.schedule.isNotEmpty) ...[
                    Text('Запись на приём'.tr(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                    const SizedBox(height: 12),
                    SizedBox(height: 44, child: ListView(
                      scrollDirection: Axis.horizontal, physics: const BouncingScrollPhysics(),
                      children: doc.schedule.keys.map((day) {
                        final sel = _selectedDay == day;
                        return GestureDetector(
                          onTap: () => setState(() { _selectedDay = day; _selectedTime = null; }),
                          child: AnimatedContainer(duration: const Duration(milliseconds: 200), margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), decoration: BoxDecoration(color: sel ? doc.accentColor : Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: sel ? doc.accentColor : AppColors.border), boxShadow: sel ? [BoxShadow(color: doc.accentColor.withOpacity(0.2), blurRadius: 8)] : []),
                            child: Text(day.tr(), style: TextStyle(color: sel ? Colors.white : AppColors.textMedium, fontWeight: FontWeight.w700, fontSize: 14))),
                        );
                      }).toList(),
                    )),
                    const SizedBox(height: 12),
                    if (_selectedDay != null && doc.schedule[_selectedDay] != null)
                      Wrap(spacing: 8, runSpacing: 8, children: doc.schedule[_selectedDay]!.map((time) {
                        final sel = _selectedTime == time;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedTime = time),
                          child: AnimatedContainer(duration: const Duration(milliseconds: 200), padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10), decoration: BoxDecoration(color: sel ? doc.accentColor.withOpacity(0.15) : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: sel ? doc.accentColor : AppColors.border, width: sel ? 2 : 1)), child: Text(time, style: TextStyle(color: sel ? doc.accentColor : AppColors.textMedium, fontWeight: sel ? FontWeight.w700 : FontWeight.w500, fontSize: 14))),
                        );
                      }).toList()),
                    const SizedBox(height: 24),
                  ],

                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Отзывы'.tr(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                    Row(children: [
                      const Icon(Icons.star_rounded, color: AppColors.orange, size: 16),
                      const SizedBox(width: 4),
                      Text('${doc.rating}', style: const TextStyle(color: AppColors.orange, fontWeight: FontWeight.w700)),
                    ]),
                  ]),
                  const SizedBox(height: 12),

                  ...doc.reviews.map((r) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SoftCard(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text((r['name'] as String).tr(), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textDark)),
                        Text((r['date'] as String).tr(), style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
                      ]),
                      const SizedBox(height: 4),
                      Row(children: List.generate(5, (i) => Icon(Icons.star_rounded, size: 14, color: i < (r['rating'] as int) ? AppColors.orange : AppColors.border))),
                      const SizedBox(height: 8),
                      Text((r['text'] as String).tr(), style: const TextStyle(fontSize: 13, color: AppColors.textMedium, height: 1.4)),
                    ])),
                  )),
                  const SizedBox(height: 24),

                  if (doc.available)
                    SizedBox(width: double.infinity, height: 56, child: ElevatedButton(
                      onPressed: _booked ? null : () {
                        if (_selectedDay == null || _selectedTime == null) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Выберите день и время'.tr()), backgroundColor: AppColors.orange, behavior: SnackBarBehavior.floating));
                          return;
                        }
                        HapticFeedback.heavyImpact();
                        setState(() => _booked = true);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Запись подтверждена! {} в {}'.tr(args: [_selectedDay!.tr(), _selectedTime!])),
                          backgroundColor: AppColors.mint, behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), margin: const EdgeInsets.all(20),
                        ));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _booked ? AppColors.mintSoft : doc.accentColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        elevation: _booked ? 0 : 4, shadowColor: doc.accentColor.withOpacity(0.3),
                      ),
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(_booked ? Icons.check_circle_rounded : Icons.calendar_today_rounded, color: _booked ? AppColors.mint : Colors.white, size: 20),
                        const SizedBox(width: 10),
                        Text(_booked ? 'Записано ✓'.tr() : 'Записаться на приём — {} ₽'.tr(args: ['${doc.price}']), style: TextStyle(color: _booked ? AppColors.mint : Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                      ]),
                    )),
                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(IconData icon, String text, Color color) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(10)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 14, color: color), const SizedBox(width: 4), Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color))]));
  }
}