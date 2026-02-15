import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:huzur_islamda/domain/domain.dart';
import 'package:logging/logging.dart';

import '../../app/app.dart';

class AssistantService {
  AssistantService() : _log = Logger('AssistantService');

  final Logger _log;

  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1/models';
  static const String _model = 'gemini-2.5-flash';
  final String? _apiKey = dotenv.env['GEMINI_API_KEY_DEV'];

  Future<Result<String>> sendMessage({
    required String message,
    required String senderName,
    required String senderAge,
    required String senderGender,
    List<String>? previousMessages,
    String? postContent,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/$_model:generateContent');
      if (_apiKey == null) {
        return Result.error(
          Exception('API key not found in environment variables'),
        );
      }
      String? historyText;
      if (previousMessages != null && previousMessages.isNotEmpty) {
        final buffer = StringBuffer();
        for (var i = 0; i < previousMessages.length; i++) {
          buffer.writeln('${i + 1}. ${previousMessages[i]}');
        }
        historyText = buffer.toString().trimRight();
      }

      String userContext =
          """
KİMLİK BİLGİLERİ:
- İsim: $senderName
- Yaş: $senderAge
- Cinsiyet: $senderGender
""";

      String systemRole =
          """
SENİN ROLÜN:
Sen, kullanıcıların manevi sorularına Kur'an ve Sünnet ışığında rehberlik eden, nazik, şefkatli ve bilgili bir "İslami Asistan"sın. Adın "Yapay Zeka" değil, bir "Yol Arkadaşı" gibi davran.

İLETİŞİM TONU VE KURALLAR:
1. ÜSLUP: Her zaman yapıcı, umut verici (Müjdeleyici) ve nazik ol. Asla yargılayıcı, sert veya korkutucu bir dil kullanma.
2. KİŞİSELLEŞTİRME: Kullanıcının yaşına ($senderAge) dikkat et. Eğer kullanıcı çocuksa (0-12) masal tadında ve çok basit anlat. Gençse samimi ve mantıksal yaklaş. Yetişkinse daha derinlikli ve edebi konuş.
3. KAYNAK GÜVENİLİRLİĞİ:
   - Cevaplarında Ayet varsa: (Sure Adı, Ayet No) formatında belirt.
   - Hadis varsa: (Buhari, Müslim vb.) kaynağını belirt. Kaynağı olmayan veya zayıf rivayetleri kullanma.
   - Asla kendi kafandan ayet veya hadis uydurma. Bilmiyorsan "Bu konuda emin değilim" de.
4. HASSASİYET VE FETVA:
   - Sen bir Müftü değilsin. Kesin haram/helal hükümleri verirken "Genel görüş şöyledir ancak kesin hüküm için bir uzmana danışmalısınız" şerhini düş.
   - Psikolojik bunalım veya intihar eğilimi sezersen, manevi destek ver ama mutlaka profesyonel yardıma yönlendir.
5. FORMAT:
   - Cevapların akıcı, okunabilir ve kısa olsun.
   - Gerektiğinde madde işaretleri (bullet points) kullan.
   - Uzun paragraflar yazma, mobil ekranda okunacağını unutma.
   - Kullanıcının ismini ($senderName) her cümlede tekrar etme, sadece gerektiğinde samimiyet için kullan.

AMACIN:
Kullanıcının Allah ile olan bağını güçlendirmek, ibadetleri sevdirmek ve günlük hayatın stresine karşı manevi bir sığınak olmak.
""";

      final promptParts = <Map<String, String>>[
        {'text': '$systemRole\n\n$userContext'},
        if (historyText != null && historyText.isNotEmpty)
          {'text': 'ÖNCEKİ KONUŞMALAR (Bağlam):\n$historyText'},
        if (postContent != null && postContent.isNotEmpty)
          {
            'text':
                'KULLANICININ ÜZERİNE KONUŞMAK İSTEDİĞİ İÇERİK (Bu içerik hakkında soru soruyor):\n$postContent',
          },
        {
          'text':
              'KULLANICININ YENİ MESAJI (Bu mesaja cevap vereceksin):\n$message',
        },
      ];

      final body = jsonEncode(<String, dynamic>{
        'contents': [
          {'parts': promptParts},
        ],
      });

      _log.info('Sending message to Gemini model $_model');

      final response = await http.post(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'X-goog-api-key': _apiKey,
        },
        body: body,
      );

      if (response.statusCode != 200) {
        _log.severe(
          'Gemini API error: ${response.statusCode} - ${response.body}',
        );
        return Result.error(const AssistantUnexpectedError());
      }

      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;

      final candidates = data['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) {
        _log.warning('Gemini API returned no candidates');
        return Result.error(Exception('Asistan yanıtı alınamadı (boş cevap).'));
      }

      final content =
          candidates.first['content'] as Map<String, dynamic>? ?? const {};
      final parts = content['parts'] as List<dynamic>? ?? const [];

      // token usage logging(only for debug)
      // TODO: remove this after debugging
      final usageMetadata =
          data['usageMetadata'] as Map<String, dynamic>? ?? const {};
      if (usageMetadata.isNotEmpty) {
        final promptTokens = usageMetadata['promptTokenCount'];
        final candidatesTokens = usageMetadata['candidatesTokenCount'];
        final totalTokens = usageMetadata['totalTokenCount'];
        _log.info(
          'Gemini token kullanımı - prompt: $promptTokens, cevap: $candidatesTokens, toplam: $totalTokens',
        );
      }

      final String? text = parts.isNotEmpty
          ? parts.first['text'] as String?
          : null;

      if (text == null || text.trim().isEmpty) {
        _log.warning('Gemini API returned empty text');
        return Result.error(Exception('Asistan yanıtı alınamadı (metin yok).'));
      }

      _log.info('Gemini response received successfully');
      return Result.ok(text.trim());
    } on http.ClientException catch (e) {
      _log.severe('Network error while calling Gemini API: $e');
      return Result.error(Exception('Ağ hatası: ${e.message}'));
    } catch (e) {
      _log.severe('Unexpected error while calling Gemini API: $e');
      return Result.error(
        Exception('Asistan yanıtı alınırken bir hata oluştu: $e'),
      );
    }
  }
}
