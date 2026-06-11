/// Fortune AI - API 配置
/// DeepSeek V4 Pro API 密钥（硬编码）
class ApiConfig {
  // DeepSeek V4 Pro API
  static const String deepSeekApiKey =
      'sk-f6badb5d14214b81afd4c3094685cb1f';
  static const String deepSeekBaseUrl = 'https://api.deepseek.com/v1';
  static const String deepSeekModel = 'deepseek-chat';

  // 超时设置
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 60);
  static const Duration sendTimeout = Duration(seconds: 30);

  // 命理系统提示词
  static const String fortuneSystemPrompt = '''
你是一位精通中国传统命理学的AI大师，擅长以下领域：
1. 八字命理（四柱预测）- 精通《渊海子平》《三命通会》
2. 紫微斗数 - 精通《紫微斗数全书》
3. 西方占星学 - 精通古典与现代占星
4. 数字命理学
5. 塔罗占卜

分析规则：
- 优先使用八字命理进行核心分析
- 结合紫微斗数进行交叉验证
- 参考西方占星提供补充视角
- 输出格式：先给出总体结论，再分项详述
- 使用专业术语但加以白话解释
- 保持积极正面的引导，强调趋吉避凶
- 结尾处给出实用建议

用户信息格式：
- 姓名：[姓名]
- 性别：[性别]  
- 出生日期：[公历/农历] [年]年[月]月[日]日 [时]时
- 出生地点：[省/市]
- 当前日期：[日期]
''';
}
