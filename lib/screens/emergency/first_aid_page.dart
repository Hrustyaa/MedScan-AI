import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import 'cpr_mode_page.dart';
import 'package:easy_localization/easy_localization.dart';

class FirstAidPage extends StatefulWidget {
  const FirstAidPage({Key? key}) : super(key: key);
  @override
  State<FirstAidPage> createState() => _FirstAidPageState();
}

class _FirstAidPageState extends State<FirstAidPage> {
  int _expandedIndex = -1;
  int? _highlightedIndex;
  String _searchQuery = '';
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final Map<int, Set<int>> _checkedSteps = {};

  List<Map<String, dynamic>> get _guides => [
    {
      'title': 'Остановка сердца (СЛР)'.tr(),
      'icon': Icons.favorite_rounded,
      'color': const Color(0xFFFF3B30),
      'hasCprMode': true,
      'keywords': ['сердце', 'не дышит', 'без сознания', 'пульс', 'реанимация', 'слр', 'остановка', 'упал', 'сердечный приступ', 'инфаркт'],
      'steps': [
        'Убедитесь в безопасности места'.tr(),
        'Проверьте сознание — потрясите за плечи, окликните'.tr(),
        'Вызовите скорую (103/112) или попросите кого-то'.tr(),
        'Проверьте дыхание (не более 10 секунд)'.tr(),
        'Положите пострадавшего на твёрдую поверхность'.tr(),
        'Запустите метроном СЛР (кнопка ниже)'.tr(),
        '30 компрессий грудной клетки (глубина 5-6 см)'.tr(),
        '2 искусственных вдоха «рот в рот»'.tr(),
        'Продолжайте цикл 30:2 до приезда скорой'.tr(),
        'Если есть дефибриллятор — используйте его'.tr(),
      ],
    },
    {
      'title': 'Сильное кровотечение'.tr(),
      'icon': Icons.water_drop_rounded,
      'color': const Color(0xFFFF6B6B),
      'hasCprMode': false,
      'keywords': ['кровь', 'кровотечение', 'рана', 'порез', 'артерия', 'вена', 'жгут', 'бинт'],
      'steps': [
        'Наденьте перчатки (если есть)'.tr(),
        'Прижмите рану чистой тканью (прямое давление)'.tr(),
        'Поднимите конечность выше уровня сердца'.tr(),
        'Наложите давящую повязку'.tr(),
        'При артериальном (фонтан) — жгут ВЫШЕ раны'.tr(),
        'Запишите время наложения жгута на лбу'.tr(),
        'Каждые 30 мин ослабляйте жгут на 30 сек'.tr(),
        'Вызовите скорую (103)'.tr(),
        'Не давайте пить при ранениях живота'.tr(),
      ],
    },
    {
      'title': 'Ожоги'.tr(),
      'icon': Icons.local_fire_department_rounded,
      'color': const Color(0xFFFF9F0A),
      'hasCprMode': false,
      'keywords': ['ожог', 'обжег', 'обожг', 'кипяток', 'пламя', 'огонь', 'пар', 'горяч', 'плита', 'утюг', 'масло'],
      'steps': [
        'Уберите источник ожога'.tr(),
        'Охладите место ожога прохладной водой 15-20 минут'.tr(),
        'НЕ используйте лёд — только прохладная вода!'.tr(),
        'Снимите кольца, часы, браслеты до отёка'.tr(),
        'НЕ прокалывайте пузыри!'.tr(),
        'НЕ наносите масло, сметану, зубную пасту!'.tr(),
        'Наложите стерильную неприлипающую повязку'.tr(),
        'Дайте обезболивающее (Ибупрофен)'.tr(),
        'При ожоге > ладони пострадавшего → скорая (103)'.tr(),
        'Химический ожог — промывайте водой 30+ минут'.tr(),
      ],
    },
    {
      'title': 'Переломы и вывихи'.tr(),
      'icon': Icons.accessibility_new_rounded,
      'color': const Color(0xFF007AFF),
      'hasCprMode': false,
      'keywords': ['перелом', 'сломал', 'кость', 'вывих', 'трещина', 'нога', 'рука', 'палец', 'ребро', 'позвоночник'],
      'steps': [
        'НЕ пытайтесь вправить кость!'.tr(),
        'Обеспечьте неподвижность конечности'.tr(),
        'Зафиксируйте шиной (палка, доска, журнал)'.tr(),
        'Шина должна захватывать 2 сустава'.tr(),
        'Приложите холод через ткань на 15-20 мин'.tr(),
        'Дайте обезболивающее'.tr(),
        'При открытом переломе — накройте рану стерильно'.tr(),
        'НЕ промывайте открытый перелом!'.tr(),
        'Вызовите скорую (103)'.tr(),
        'При подозрении на перелом позвоночника — НЕ двигайте!'.tr(),
      ],
    },
    {
      'title': 'Удушье (инородное тело)'.tr(),
      'icon': Icons.air_rounded,
      'color': const Color(0xFF5856D6),
      'hasCprMode': false,
      'keywords': ['подавился', 'удушье', 'застряло', 'горло', 'не может дышать', 'задыхается', 'кашель', 'еда', 'геймлих'],
      'steps': [
        'Спросите "Ты можешь дышать?"'.tr(),
        'Если кашляет — пусть кашляет сам (не стучите!)'.tr(),
        'Если НЕ дышит: наклоните вперед'.tr(),
        '5 сильных ударов между лопатками'.tr(),
        'Если не помогло: прием Геймлиха'.tr(),
        'Встаньте сзади, кулак на живот над пупком'.tr(),
        'Резкий толчок внутрь и вверх'.tr(),
        'Чередуйте: 5 ударов по спине → 5 толчков'.tr(),
        'При потере сознания — начните СЛР'.tr(),
        'Ребёнок до года: 5 хлопков по спине + 5 нажатий на грудь'.tr(),
      ],
    },
    {
      'title': 'Обморок'.tr(),
      'icon': Icons.person_off_rounded,
      'color': const Color(0xFF34C759),
      'hasCprMode': false,
      'keywords': ['обморок', 'потерял сознание', 'упал в обморок', 'головокружение', 'темнеет в глазах', 'дурно'],
      'steps': [
        'Уложите пострадавшего на спину'.tr(),
        'Поднимите ноги на 30-40 см выше головы'.tr(),
        'Расстегните тесную одежду (воротник, ремень)'.tr(),
        'Обеспечьте приток свежего воздуха'.tr(),
        'Побрызгайте лицо прохладной водой'.tr(),
        'Дайте понюхать нашатырный спирт (если есть)'.tr(),
        'Когда придёт в себя — не вставайте резко!'.tr(),
        'Дайте сладкое питьё (чай с сахаром)'.tr(),
        'Если обморок > 1 минуты → вызовите скорую'.tr(),
        'Если повторяется — обязательно к врачу'.tr(),
      ],
    },
    {
      'title': 'Отравление'.tr(),
      'icon': Icons.science_rounded,
      'color': const Color(0xFF30B0C7),
      'hasCprMode': false,
      'keywords': ['отравление', 'отравился', 'рвота', 'тошнота', 'съел', 'выпил', 'таблетки', 'грибы', 'химия', 'яд'],
      'steps': [
        'Вызовите скорую (103) или токсикологию'.tr(),
        'Выясните ЧТО и КОГДА было принято'.tr(),
        'Сохраните упаковку / остатки вещества'.tr(),
        'При пищевом: вызовите рвоту (если в сознании)'.tr(),
        'Дайте активированный уголь (1 таб на 10 кг веса)'.tr(),
        'НЕ вызывайте рвоту при кислотах / щелочах!'.tr(),
        'НЕ вызывайте рвоту у детей до 5 лет!'.tr(),
        'Обильное питьё (вода, НЕ молоко)'.tr(),
        'Уложите на бок (если рвота)'.tr(),
        'Следите за дыханием до приезда скорой'.tr(),
      ],
    },
    {
      'title': 'Тепловой удар'.tr(),
      'icon': Icons.wb_sunny_rounded,
      'color': const Color(0xFFFFCC02),
      'hasCprMode': false,
      'keywords': ['жара', 'тепловой удар', 'солнечный удар', 'перегрев', 'солнце', 'голова болит', 'температура'],
      'steps': [
        'Переместите пострадавшего в тень / прохладу'.tr(),
        'Уложите с приподнятой головой'.tr(),
        'Снимите лишнюю одежду'.tr(),
        'Положите холод на лоб, шею, подмышки, пах'.tr(),
        'Обмахивайте / включите вентилятор'.tr(),
        'Дайте прохладную воду (пить маленькими глотками)'.tr(),
        'Оберните мокрой простынёй'.tr(),
        'НЕ давайте алкоголь!'.tr(),
        'При потере сознания → скорая (103)'.tr(),
        'Температура > 40°C — это ЭКСТРЕННО!'.tr(),
      ],
    },
    {
      'title': 'Укусы и жала'.tr(),
      'icon': Icons.bug_report_rounded,
      'color': const Color(0xFF8E8E93),
      'hasCprMode': false,
      'keywords': ['укус', 'змея', 'пчела', 'оса', 'клещ', 'собака', 'жало', 'аллергия', 'опухло'],
      'steps': [
        'Определите тип укуса (насекомое / змея / животное)'.tr(),
        'Пчела: удалите жало пинцетом (не сжимайте!)'.tr(),
        'Приложите холод на 10-15 мин'.tr(),
        'Дайте антигистаминное (Супрастин, Цетрин)'.tr(),
        'Змея: НЕ отсасывайте яд! Обездвижьте конечность'.tr(),
        'Клещ: извлеките пинцетом, вращая против часовой'.tr(),
        'Сохраните клеща для анализа'.tr(),
        'Собака: промойте рану мылом 10-15 минут'.tr(),
        'При анафилаксии (отёк, одышка) → скорая НЕМЕДЛЕННО'.tr(),
        'После укуса животного — обязательно прививка от бешенства'.tr(),
      ],
    },
    {
      'title': 'Утопление'.tr(),
      'icon': Icons.pool_rounded,
      'color': const Color(0xFF0A84FF),
      'hasCprMode': true,
      'keywords': ['утопление', 'вода', 'тонет', 'река', 'море', 'бассейн', 'захлебнулся'],
      'steps': [
        'Обеспечьте свою безопасность!'.tr(),
        'Бросьте спасательный круг / верёвку'.tr(),
        'НЕ прыгайте в воду если не умеете плавать'.tr(),
        'На берегу: уложите на спину'.tr(),
        'Освободите дыхательные пути от воды/слизи'.tr(),
        'Проверьте дыхание и пульс'.tr(),
        'Нет дыхания → начните СЛР (30:2)'.tr(),
        'Вызовите скорую (103)'.tr(),
        'Согрейте пострадавшего (одеяло, тёплая одежда)'.tr(),
        'Даже после восстановления дыхания → в больницу!'.tr(),
      ],
    },
    {
      'title': 'Эпилептический припадок'.tr(),
      'icon': Icons.flash_on_rounded,
      'color': const Color(0xFFAF52DE),
      'hasCprMode': false,
      'keywords': ['эпилепсия', 'припадок', 'судороги', 'конвульсии', 'трясёт', 'пена изо рта'],
      'steps': [
        'НЕ удерживайте человека силой!'.tr(),
        'Уберите опасные предметы вокруг'.tr(),
        'Подложите мягкое под голову'.tr(),
        'НЕ вставляйте ничего в рот! (ложки, пальцы)'.tr(),
        'Засеките время начала припадка'.tr(),
        'Поверните на бок после окончания судорог'.tr(),
        'Дождитесь полного прихода в сознание'.tr(),
        'Говорите спокойно, объясните что произошло'.tr(),
        'Припадок > 5 минут → скорая (103)'.tr(),
        'Первый припадок → обязательно к неврологу'.tr(),
      ],
    },
    {
      'title': 'Аллергическая реакция'.tr(),
      'icon': Icons.warning_amber_rounded,
      'color': const Color(0xFFFF2D55),
      'hasCprMode': false,
      'keywords': ['аллергия', 'анафилаксия', 'отёк', 'крапивница', 'сыпь', 'не могу дышать', 'распухло', 'адреналин'],
      'steps': [
        'Определите аллерген, прекратите контакт'.tr(),
        'Лёгкая реакция: дайте антигистаминное'.tr(),
        'Тяжёлая (отёк горла, одышка): СКОРАЯ НЕМЕДЛЕННО'.tr(),
        'Если есть ЭпиПен — введите в наружную часть бедра'.tr(),
        'Уложите с приподнятыми ногами'.tr(),
        'Расстегните одежду, обеспечьте воздух'.tr(),
        'НЕ давайте пить при отёке горла!'.tr(),
        'Следите за дыханием каждую минуту'.tr(),
        'Будьте готовы к СЛР'.tr(),
        'После введения адреналина — всё равно в больницу!'.tr(),
      ],
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _callEmergency() async {
    final Uri callUri = Uri(scheme: 'tel', path: '112');
    try {
      if (await canLaunchUrl(callUri)) {
        await launchUrl(callUri);
      } else {
        await launchUrl(callUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Не удалось открыть телефон. Наберите 112 вручную.'.tr())),
        );
      }
    }
  }

  void _smartSearch(String query) {
    setState(() {
      _searchQuery = query;
      _highlightedIndex = null;
      _expandedIndex = -1;
    });

    if (query.trim().isEmpty) return;

    final q = query.toLowerCase().trim();
    int bestMatch = -1;
    int bestScore = 0;

    for (int i = 0; i < _guides.length; i++) {
      final keywords = _guides[i]['keywords'] as List<String>;
      final titleTranslated = (_guides[i]['title'] as String).toLowerCase();
      int score = 0;

      if (titleTranslated.contains(q)) score += 20;

      for (final kw in keywords) {
        final kwLower = kw.toLowerCase();
        final kwTranslated = kw.tr().toLowerCase();

        if (q.contains(kwLower) || kwLower.contains(q) || 
            q.contains(kwTranslated) || kwTranslated.contains(q)) {
          score += 10;
        }
      }

      if (score > bestScore) {
        bestScore = score;
        bestMatch = i;
      }
    }

    if (bestMatch >= 0 && bestScore > 0) {
      setState(() {
        _highlightedIndex = bestMatch;
        _expandedIndex = bestMatch;
      });
      _scrollToCard(bestMatch);
      HapticFeedback.mediumImpact();
    }
  }

  void _scrollToCard(int index) {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        final offset = index * 80.0;
        _scrollController.animateTo(
          offset.clamp(0, _scrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  List<int> get _filteredIndices {
    if (_searchQuery.isEmpty) return List.generate(_guides.length, (i) => i);

    final q = _searchQuery.toLowerCase();
    List<int> result = [];

    if (_highlightedIndex != null) result.add(_highlightedIndex!);

    for (int i = 0; i < _guides.length; i++) {
      if (i == _highlightedIndex) continue;
      final title = (_guides[i]['title'] as String).toLowerCase();
      final keywords = _guides[i]['keywords'] as List<String>;
      bool match = title.contains(q) || keywords.any((k) => k.contains(q) || q.contains(k));
      if (match) result.add(i);
    }

    return result.isEmpty ? List.generate(_guides.length, (i) => i) : result;
  }

  @override
  Widget build(BuildContext context) {
    final indices = _filteredIndices;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            buildPageHeader(context, 'Первая помощь'.tr()),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _highlightedIndex != null
                        ? (_guides[_highlightedIndex!]['color'] as Color)
                        : AppColors.border,
                    width: _highlightedIndex != null ? 2 : 1,
                  ),
                  boxShadow: [BoxShadow(color: AppColors.textDark.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: Row(
                  children: [
                    Icon(
                      _highlightedIndex != null ? Icons.check_circle_rounded : Icons.search_rounded,
                      color: _highlightedIndex != null
                          ? (_guides[_highlightedIndex!]['color'] as Color)
                          : AppColors.textHint,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: _smartSearch,
                        decoration: InputDecoration(
                          hintText: 'Опишите проблему (напр. "обжёг руку")...'.tr(),
                          hintStyle: TextStyle(color: AppColors.textHint, fontSize: 14),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() { _searchQuery = ''; _highlightedIndex = null; });
                        },
                        child: const Icon(Icons.close_rounded, color: AppColors.textHint),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.heavyImpact();
                  _callEmergency();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFFF3B30), Color(0xFFFF6B6B)]),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFFFF3B30).withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.phone_in_talk_rounded, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ЭКСТРЕННЫЙ ВЫЗОВ'.tr(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1)),
                            const Text('112', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 16),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 120),
                itemCount: indices.length,
                itemBuilder: (context, listIndex) {
                  final guideIndex = indices[listIndex];
                  final guide = _guides[guideIndex];
                  final bool isExpanded = _expandedIndex == guideIndex;
                  final Color cardColor = guide['color'] as Color;

                  return FadeSlideIn(
                    key: ValueKey(guide['title']),
                    delayMs: listIndex * 50,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.fastOutSlowIn,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isExpanded ? cardColor.withOpacity(0.5) : Colors.transparent,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isExpanded ? cardColor.withOpacity(0.1) : AppColors.textDark.withOpacity(0.03),
                              blurRadius: isExpanded ? 20 : 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _expandedIndex = isExpanded ? -1 : guideIndex);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 44, height: 44,
                                        decoration: BoxDecoration(
                                          color: cardColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        child: Icon(guide['icon'] as IconData, color: cardColor),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Text(
                                          guide['title'] as String,
                                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textDark),
                                        ),
                                      ),
                                      AnimatedRotation(
                                        turns: isExpanded ? 0.5 : 0,
                                        duration: const Duration(milliseconds: 400),
                                        curve: Curves.easeOutBack,
                                        child: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textHint),
                                      ),
                                    ],
                                  ),

                                  AnimatedSize(
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.fastOutSlowIn,
                                    child: isExpanded
                                        ? Padding(
                                            padding: const EdgeInsets.only(top: 16),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Divider(height: 1),
                                                const SizedBox(height: 16),

                                                if (guide['hasCprMode'] == true)
                                                  GestureDetector(
                                                    onTap: () => _openCprMode(context),
                                                    child: Container(
                                                      margin: const EdgeInsets.only(bottom: 16),
                                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                                      decoration: BoxDecoration(
                                                        color: cardColor,
                                                        borderRadius: BorderRadius.circular(12),
                                                        boxShadow: [BoxShadow(color: cardColor.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))],
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          const Icon(Icons.monitor_heart_rounded, color: Colors.white, size: 20),
                                                          const SizedBox(width: 8),
                                                          Text('ЗАПУСТИТЬ МЕТРОНОМ СЛР'.tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
                                                        ],
                                                      ),
                                                    ),
                                                  ),

                                                ...List.generate((guide['steps'] as List).length, (i) {
                                                  final step = (guide['steps'] as List)[i];
                                                  final isChecked = _checkedSteps[guideIndex]?.contains(i) ?? false;
                                                  return GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        _checkedSteps.putIfAbsent(guideIndex, () => {});
                                                        if (isChecked) {
                                                          _checkedSteps[guideIndex]!.remove(i);
                                                        } else {
                                                          _checkedSteps[guideIndex]!.add(i);
                                                          HapticFeedback.lightImpact();
                                                        }
                                                      });
                                                    },
                                                    child: AnimatedContainer(
                                                      duration: const Duration(milliseconds: 200),
                                                      margin: const EdgeInsets.only(bottom: 10),
                                                      padding: const EdgeInsets.all(12),
                                                      decoration: BoxDecoration(
                                                        color: isChecked ? cardColor.withOpacity(0.08) : AppColors.bg,
                                                        borderRadius: BorderRadius.circular(12),
                                                        border: Border.all(color: isChecked ? cardColor.withOpacity(0.3) : Colors.transparent),
                                                      ),
                                                      child: Row(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          AnimatedContainer(
                                                            duration: const Duration(milliseconds: 200),
                                                            width: 22, height: 22,
                                                            decoration: BoxDecoration(
                                                              shape: BoxShape.circle,
                                                              color: isChecked ? cardColor : Colors.transparent,
                                                              border: Border.all(color: isChecked ? cardColor : AppColors.textHint, width: 2),
                                                            ),
                                                            child: isChecked
                                                                ? const Icon(Icons.check, size: 14, color: Colors.white)
                                                                : Center(child: Text('${i + 1}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textHint))),
                                                          ),
                                                          const SizedBox(width: 12),
                                                          Expanded(
                                                            child: Text(
                                                              step,
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                height: 1.4,
                                                                color: isChecked ? cardColor : AppColors.textDark,
                                                                decoration: isChecked ? TextDecoration.lineThrough : null,
                                                                decorationColor: cardColor,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                }),
                                              ],
                                            ),
                                          )
                                        : const SizedBox.shrink(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openCprMode(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const CprModePage()));
  }
}