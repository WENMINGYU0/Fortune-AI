import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/fortune_models.dart';

/// DeepSeek AI 服务
class DeepSeekService {
  static final DeepSeekService _instance = DeepSeekService._();
  factory DeepSeekService() => _instance;
  DeepSeekService._();

  final http.Client _client = http.Client();

  // 流式对话
  Stream<String> chatStream({
    required String query,
    String? context,
    List<Map<String, String>> history = const [],
  }) async* {
    final messages = <Map<String, String>>[
      {'role': 'system', 'content': context ?? ApiConfig.fortuneSystemPrompt},
      ...history,
      {'role': 'user', 'content': query},
    ];

    try {
      final request = http.Request(
        'POST',
        Uri.parse('${ApiConfig.deepSeekBaseUrl}/chat/completions'),
      );
      request.headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${ApiConfig.deepSeekApiKey}',
        'Accept': 'text/event-stream',
      });
      request.body = jsonEncode({
        'model': ApiConfig.deepSeekModel,
        'messages': messages,
        'stream': true,
        'temperature': 0.7,
        'max_tokens': 4096,
      });

      final response = await _client.send(request).timeout(
            ApiConfig.receiveTimeout,
          );

      await for (final chunk in response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())) {
        if (chunk.startsWith('data: ') && chunk.length > 6) {
          final data = chunk.substring(6);
          if (data == '[DONE]') break;
          try {
            final jsonData = jsonDecode(data);
            final content = jsonData['choices']?[0]?['delta']?['content'];
            if (content != null && content.isNotEmpty) {
              yield content;
            }
          } catch (_) {}
        }
      }
    } catch (e) {
      yield '[错误] 连接AI服务失败，请检查网络后重试。';
    }
  }

  // 非流式对话
  Future<String> chat({
    required String query,
    String? context,
  }) async {
    final messages = <Map<String, String>>[
      {'role': 'system', 'content': context ?? ApiConfig.fortuneSystemPrompt},
      {'role': 'user', 'content': query},
    ];

    try {
      final response = await _client
          .post(
            Uri.parse('${ApiConfig.deepSeekBaseUrl}/chat/completions'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${ApiConfig.deepSeekApiKey}',
            },
            body: jsonEncode({
              'model': ApiConfig.deepSeekModel,
              'messages': messages,
              'temperature': 0.7,
              'max_tokens': 4096,
            }),
          )
          .timeout(ApiConfig.receiveTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices']?[0]?['message']?['content'] ?? '暂无回复';
      }
      return 'AI服务返回异常（${response.statusCode}）';
    } catch (e) {
      return '连接AI服务失败，请检查网络。';
    }
  }

  // 生成今日运势
  Future<DailyFortune> generateDailyFortune(UserProfile profile) async {
    final prompt = '''
请基于以下用户信息，生成今日运势分析：
- 姓名：${profile.name}
- 性别：${profile.gender}
- 出生日期：${profile.birthYear}年${profile.birthMonth}月${profile.birthDay}日 ${profile.birthHour}时
- 当前日期：${DateTime.now().toLocal().toString().substring(0, 10)}

请严格按照JSON格式返回（不要包含其他文字）：
{
  "overall": <0-100整数的综合运势>,
  "career": <0-100整数的事业运势>,
  "love": <0-100整数的爱情运势>,
  "wealth": <0-100整数的财富运势>,
  "health": <0-100整数的健康运势>,
  "luckyColor": "<幸运颜色>",
  "luckyNumber": "<幸运数字>",
  "luckyDirection": "<幸运方位>",
  "luckyTime": "<吉时>",
  "aiAdvice": "<100字以内的AI运势建议>",
  "suitable": ["<宜事项1>", "<宜事项2>", "<宜事项3>"],
  "unsuitable": ["<忌事项1>", "<忌事项2>", "<忌事项3>"],
  "zodiacClash": "<今日冲煞说明>"
}''';

    try {
      final result = await chat(query: prompt, context: ApiConfig.fortuneSystemPrompt);
      final jsonStart = result.indexOf('{');
      final jsonEnd = result.lastIndexOf('}') + 1;
      if (jsonStart >= 0 && jsonEnd > jsonStart) {
        return DailyFortune.fromJson(jsonDecode(result.substring(jsonStart, jsonEnd)));
      }
    } catch (_) {}
    return _defaultFortune();
  }

  // 默认运势
  DailyFortune _defaultFortune() => DailyFortune(
        date: DateTime.now(),
        overall: 75,
        career: 72,
        love: 78,
        wealth: 70,
        health: 80,
        luckyColor: '金色',
        luckyNumber: '6',
        luckyDirection: '东南',
        luckyTime: '上午9-11时',
        aiAdvice: '今日运势平稳，宜保持积极心态，把握机会。',
        suitable: ['学习进修', '与人合作', '理财规划'],
        unsuitable: ['冲动决策', '熬夜工作', '大额投资'],
        zodiacClash: '无特殊冲煞',
      );

  void dispose() {
    _client.close();
  }
}
