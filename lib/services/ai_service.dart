import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';
import '../api_config.dart';
class AIService {
  static const String _apiKey = ApiConfig.geminiApiKey;

  Future<String> getMedicalAdvice(String userMessage, String uid, {String languageCode = 'ru', Uint8List? imageBytes}) async {
    try {
      String healthContext = "No health data available.";
      if (languageCode == 'ru') healthContext = "Данных о здоровье пока нет.";
      if (languageCode == 'kk') healthContext = "Денсаулық туралы деректер жоқ.";
      
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('pulse_history')
            .where('uid', isEqualTo: uid)
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

        if (snapshot.docs.isNotEmpty) {
          final data = snapshot.docs.first.data();
          final bpm = data['bpm'];
          final spo2 = data['spo2'];
          final stress = data['stress'];

          if (languageCode == 'en') {
            healthContext = "User's last measurement: Pulse $bpm bpm, SpO2 $spo2%, Stress: $stress.";
          } else if (languageCode == 'kk') {
            healthContext = "Пайдаланушының соңғы өлшемі: Пульс $bpm соққы/мин, SpO2 $spo2%, Стресс: $stress.";
          } else {
            healthContext = "Последний замер пользователя: Пульс $bpm уд/мин, SpO2 $spo2%, Стресс: $stress.";
          }
        }
      } catch (e) {
        print("Error fetching context: $e");
      }

      final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _apiKey);

      String systemPrompt = "";

      if (languageCode == 'en') {
        systemPrompt = '''
        You are PulseCheck, a smart medical assistant.
        Your task is to provide helpful health advice based on the user's data.
        
        USER HEALTH CONTEXT:
        $healthContext
        
        USER QUESTION:
        "$userMessage"
        
        INSTRUCTIONS:
        1. Answer STRICTLY in ENGLISH.
        2. If the pulse is abnormal, advise caution.
        3. Be concise (min 5-6 sentences). Use emojis.
        4. Disclaimer: "(This is not a medical diagnosis, consult a doctor)".
        ''';
      } else if (languageCode == 'kk') {
        systemPrompt = '''
        Сен — PulseCheck, ақылды медициналық көмекшісің.
        Сенің міндетің — пайдаланушы деректеріне негізделген пайдалы денсаулық кеңестерін беру.
        
        ПАЙДАЛАНУШЫ ДЕНСАУЛЫҒЫ:
        $healthContext
        
        ПАЙДАЛАНУШЫ СҰРАҒЫ:
        "$userMessage"
        
        НҰСҚАУЛАР:
        1. ТЕК ҚАЗАҚ ТІЛІНДЕ жауап бер.
        2. Егер пульс қалыпты болмаса, сақ болуды ескерт.
        3. Қысқа жауап бер (3-4 сөйлем). Эмодзи қолдан.
        4. Ескерту қосс: "(Бұл медициналық диагноз емес, дәрігерге қаралыңыз)".
        ''';
      } else {
        systemPrompt = '''
        Ты — умный медицинский ассистент приложения PulseCheck.
        Твоя задача — давать полезные советы по здоровью.
        
        КОНТЕКСТ ЗДОРОВЬЯ ПОЛЬЗОВАТЕЛЯ:
        $healthContext
        
        ВОПРОС ПОЛЬЗОВАТЕЛЯ:
        "$userMessage"
        
        ИНСТРУКЦИЯ:
        1. Отвечай СТРОГО на РУССКОМ языке (или на языке вопроса, если он очевиден).
        2. Если пульс выше/ниже нормы, упомяни это.
        3. Отвечай кратко (3-4 предложения). Используй эмодзи.
        4. Дисклеймер: "(Это не медицинский диагноз, обратитесь к врачу)".
        ''';
      }

      final content = [
        Content.multi([
          TextPart(systemPrompt),
          TextPart("Вопрос пользователя: $userMessage"),
          if (imageBytes != null) DataPart('image/jpeg', imageBytes), 
        ])
      ];
      final response = await model.generateContent(content);

      return response.text ?? (languageCode == 'en' ? 'Thinking...' : 'Ойланып жатырмын...');
    } catch (e) {
      return "AI Error: $e";
    }
  }
}