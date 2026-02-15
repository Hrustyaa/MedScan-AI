import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medscan_ai/core/theme/app_colors.dart';
import '../../widgets/common_widgets.dart'; 
import '../../services/ai_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart'; 
class AIChatPage extends StatefulWidget {
  const AIChatPage({Key? key}) : super(key: key);
  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _aiService = AIService();
  
  bool _isTyping = false;
  Uint8List? _selectedImageBytes;

  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Здравствуйте! Я анализирую ваши показатели (пульс, SpO2) и могу дать совет. Что вас беспокоит? 👋'.tr(),
      'isBot': true,
    },
  ];
  
  final _suggestions = [
    'Анализ моего пульса'.tr(),
    'Болит голова'.tr(),
    'Нормальное давление'.tr(),
    'Как снизить стресс?'.tr(),
  ];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _selectedImageBytes = bytes;
      });
    }
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty && _selectedImageBytes == null) return;
    
    final imageToSend = _selectedImageBytes;

    setState(() {
      _messages.add({
        'text': text.isEmpty ? 'Отправлено фото'.tr() : text, 
        'isBot': false,
        'image': imageToSend
      });
      _isTyping = true;
      _selectedImageBytes = null;
    });
    _textController.clear();
    _scrollToBottom();

    final uid = FirebaseAuth.instance.currentUser?.uid;
    
    if (uid == null) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add({'text': 'Ошибка авторизации'.tr(), 'isBot': true});
        });
        _scrollToBottom();
      }
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final userData = userDoc.data() ?? {};

      final age = userData['age'] ?? 25;
      final weight = userData['weight'] ?? 70;
      final height = userData['height'] ?? 175;
      final bloodGroup = userData['blood_group'] ?? '--';
      final pressure = userData['pressure'] ?? '120/80';
      final conditions = userData['conditions'] ?? 'Нет'.tr();

      String healthPrompt = "ДАННЫЕ ПАЦИЕНТА: Возраст: $age, Вес: $weight кг, Рост: $height см, Группа крови: $bloodGroup, Давление: $pressure, Болезни: $conditions. Учитывай это в ответе. ВОПРОС: $text";

      String lang = 'ru'; 
      try {
        lang = context.locale.languageCode; 
      } catch (_) {}

      String responseText = await _aiService.getMedicalAdvice(
        healthPrompt, 
        uid, 
        languageCode: lang,
        imageBytes: imageToSend,
      );
      
      if (!mounted) return;
      setState(() {
        _messages.add({
          'text': responseText,
          'isBot': true,
        });
        _isTyping = false;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add({'text': 'Ошибка соединения'.tr(), 'isBot': true});
      });
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isTab = !Navigator.canPop(context);

    final body = SafeArea(
      bottom: false,
      child: Column(
        children: [
          FadeSlideIn(
            delayMs: 0,
            offset: const Offset(0, -20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: AppColors.textDark.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2)),
                ],
              ),
              child: Row(
                children: [
                  if (!isTab) backButton(context),
                  if (!isTab) const SizedBox(width: 16),
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(colors: [AppColors.mint, AppColors.sky]),
                      boxShadow: [BoxShadow(color: AppColors.mint.withOpacity(0.2), blurRadius: 8)],
                    ),
                    child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AI Доктор'.tr(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          PulsingDot(color: AppColors.mint),
                          const SizedBox(width: 6),
                          Text('Анализ базы данных...'.tr(), style: TextStyle(color: AppColors.textLight, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          Expanded(
            child: Container(
              color: AppColors.bg,
              child: ListView.builder(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (c, i) {
                  if (i == _messages.length && _isTyping) {
                    return FadeSlideIn(
                      key: const ValueKey('typing'),
                      delayMs: 0,
                      offset: const Offset(-10, 0),
                      child: _buildTyping(),
                    );
                  }
                  
                  final msg = _messages[i];
                  final isBot = msg['isBot'] as bool;
                  
                  final imageBytes = msg['image'] as Uint8List?; 
                  final text = msg['text'] as String;
                  
                  return FadeSlideIn(
                    key: ValueKey(msg),
                    delayMs: 0,
                    offset: Offset(isBot ? -20 : 20, 10),
                    child: Align(
                      alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        decoration: BoxDecoration(
                          color: isBot ? Colors.white : AppColors.mint,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(20), topRight: const Radius.circular(20),
                            bottomLeft: Radius.circular(isBot ? 4 : 20), bottomRight: Radius.circular(isBot ? 20 : 4),
                          ),
                          border: isBot ? Border.all(color: AppColors.border.withOpacity(0.5)) : null,
                          boxShadow: [
                            BoxShadow(
                              color: isBot ? Colors.black.withOpacity(0.02) : AppColors.mint.withOpacity(0.2), 
                              blurRadius: 8, 
                              offset: const Offset(0, 2)
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (imageBytes != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.memory(imageBytes, fit: BoxFit.cover),
                                ),
                              ),
                            
                            if (text.isNotEmpty)
                              Text(
                                text,
                                style: TextStyle(
                                  color: isBot ? AppColors.textDark : Colors.white, 
                                  fontSize: 15, 
                                  height: 1.4
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          if (_messages.length <= 2)
            FadeSlideIn(
              delayMs: 400,
              offset: const Offset(0, 20),
              child: Container(
                height: 40,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _suggestions.length,
                  itemBuilder: (c, i) => Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () => _sendMessage(_suggestions[i]),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.mint.withOpacity(0.3)),
                          boxShadow: [BoxShadow(color: AppColors.mint.withOpacity(0.05), blurRadius: 4)],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _suggestions[i], 
                          style: const TextStyle(color: AppColors.mint, fontSize: 13, fontWeight: FontWeight.w600)
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          
          FadeSlideIn(
            delayMs: 200,
            offset: const Offset(0, 20),
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 16, 16, isTab ? 100 : 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: AppColors.textDark.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, -5))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_selectedImageBytes != null)
                    Container(
                      height: 70,
                      margin: const EdgeInsets.only(bottom: 12),
                      alignment: Alignment.centerLeft,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(_selectedImageBytes!, height: 70, width: 70, fit: BoxFit.cover),
                          ),
                          Positioned(
                            top: -8,
                            right: -8,
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedImageBytes = null),
                              child: const CircleAvatar(
                                radius: 10,
                                backgroundColor: Colors.red,
                                child: Icon(Icons.close, size: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.bg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Icon(
                            Icons.add_photo_alternate_rounded, 
                            color: _selectedImageBytes != null ? AppColors.mint : AppColors.textLight, 
                            size: 24
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.bg,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: TextField(
                            controller: _textController,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              hintText: 'Спросите о здоровье...'.tr(), 
                              hintStyle: TextStyle(color: AppColors.textHint), 
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            style: const TextStyle(color: AppColors.textDark),
                            onSubmitted: _sendMessage,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => _sendMessage(_textController.text),
                        child: Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(colors: [AppColors.mint, AppColors.sky]),
                            boxShadow: [BoxShadow(color: AppColors.mint.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))],
                          ),
                          child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    if (isTab) return body;
    
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: body,
    );
  }

  Widget _buildTyping() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20),
            bottomRight: Radius.circular(20), bottomLeft: Radius.circular(4),
          ),
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4)],
        ),
        child: const _TypingIndicator(),
      ),
    );
  }
  
  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            double delay = i * 0.2;
            double val = ((_controller.value - delay) % 1.0);
            if (val < 0) val += 1.0;
            double bounce = val < 0.5 ? val * 2 : (1 - val) * 2;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 6, height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.mint.withOpacity(0.4 + 0.6 * bounce),
              ),
              transform: Matrix4.translationValues(0, -3 * bounce, 0),
            );
          },
        );
      }),
    );
  }
}