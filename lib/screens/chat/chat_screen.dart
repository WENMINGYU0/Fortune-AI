import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../config/api_config.dart';
import '../../models/user_profile.dart';
import '../../models/fortune_models.dart';
import '../../services/deepseek_service.dart';
import '../../services/bazi_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/fortune_widgets.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _deepSeek = DeepSeekService();
  final _bazi = BaziService();
  final _storage = StorageService();
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = <ChatMessage>[];
  bool _isThinking = false;
  String _streamingContent = '';

  static const _quickPrompts = [
    '我今天的运势如何？',
    '分析一下我的八字命盘',
    '我适合什么职业方向？',
    '近期的感情运势怎么样？',
    '我的财运什么时候最好？',
  ];

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    final profile = _storage.getProfile();
    _messages.add(ChatMessage(
      id: 'welcome',
      content: profile != null
          ? '${profile.name}，你好！我是你的专属命理AI大师。\n\n我精通八字命理、紫微斗数、西方占星和数字命理。\n\n你可以问我任何关于运势、命盘、感情、事业等方面的问题，我会从多个角度为你综合分析。'
          : '你好！我是你的命理AI大师。\n\n请先在"个人中心"完善你的出生信息，这样我可以为你提供更精准的分析。\n\n你也可以直接问我问题，我会尽力为你解答。',
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  Future<void> _sendMessage(String query) async {
    if (query.trim().isEmpty || _isThinking) return;

    final profile = _storage.getProfile();
    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: query,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMsg);
      _isThinking = true;
      _streamingContent = '';
      _messages.add(ChatMessage(
        id: 'streaming',
        content: '',
        isUser: false,
        timestamp: DateTime.now(),
        type: ChatMessageType.loading,
      ));
    });

    _controller.clear();
    _scrollToBottom();

    // 构建带用户信息的上下文
    String? context;
    if (profile != null) {
      final bazi = _bazi.calculateBazi(profile);
      context = '''
${ApiConfig.fortuneSystemPrompt}

当前用户信息：
- 姓名：${profile.name}
- 性别：${profile.gender}
- 出生日期：${profile.birthYear}年${profile.birthMonth}月${profile.birthDay}日 ${profile.birthHour}时
- 出生地点：${profile.birthPlace}

用户八字：
- 年柱：${bazi.yearPillar} 月柱：${bazi.monthPillar} 日柱：${bazi.dayPillar} 时柱：${bazi.hourPillar}
- 日主：${bazi.dayMaster}
''';
    }

    final stream = _deepSeek.chatStream(query: query, context: context);
    String fullContent = '';

    try {
      await for (final chunk in stream) {
        fullContent += chunk;
        setState(() {
          _streamingContent = fullContent;
          final lastMsg = _messages.last;
          if (lastMsg.type == ChatMessageType.loading) {
            _messages[_messages.length - 1] = ChatMessage(
              id: lastMsg.id,
              content: fullContent,
              isUser: false,
              timestamp: lastMsg.timestamp,
            );
          } else {
            _messages[_messages.length - 1] = ChatMessage(
              id: lastMsg.id,
              content: fullContent,
              isUser: false,
              timestamp: lastMsg.timestamp,
            );
          }
        });
        _scrollToBottom();
      }
    } catch (_) {
      setState(() {
        _messages[_messages.length - 1] = ChatMessage(
          id: 'error_${DateTime.now().millisecondsSinceEpoch}',
          content: '抱歉，连接AI服务时出现异常，请稍后重试。',
          isUser: false,
          timestamp: DateTime.now(),
          type: ChatMessageType.error,
        );
      });
    } finally {
      setState(() => _isThinking = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: FortuneTheme.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              // 顶部标题栏
              _buildAppBar(),
              // 消息列表
              Expanded(child: _buildMessageList()),
              // 快捷提问
              if (_messages.length <= 1) _buildQuickPrompts(),
              // 输入框
              _buildInputBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              gradient: FortuneTheme.goldGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text('命', style: TextStyle(color: FortuneTheme.mysticBlack, fontWeight: FontWeight.w700, fontSize: 18)),
            ),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('AI 命理大师', style: TextStyle(color: FortuneTheme.textWhite, fontSize: 16, fontWeight: FontWeight.w600)),
              Text('八字·紫微·占星 | 在线', style: TextStyle(color: FortuneTheme.silverGray, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        if (msg.type == ChatMessageType.loading) {
          return _buildTypingIndicator();
        }
        return ChatBubble(content: msg.content, isUser: msg.isUser);
      },
    );
  }

  Widget _buildTypingIndicator() {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 20, height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: FortuneTheme.goldPrimary),
            ),
            SizedBox(width: 12),
            Text('AI大师正在推演命理...',
                style: TextStyle(color: FortuneTheme.silverGray, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickPrompts() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _quickPrompts
            .map((p) => GestureDetector(
                  onTap: () => _sendMessage(p),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: FortuneTheme.cardSurface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: FortuneTheme.goldPrimary.withOpacity(0.2)),
                    ),
                    child: Text(p,
                        style: const TextStyle(color: FortuneTheme.goldLight, fontSize: 12)),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: FortuneTheme.deepBlue,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: FortuneTheme.cardSurface,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: FortuneTheme.textWhite, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: '输入你的命理问题...',
                  hintStyle: TextStyle(color: FortuneTheme.silverGray, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                ),
                onSubmitted: _sendMessage,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _sendMessage(_controller.text),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                gradient: FortuneTheme.goldGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.send_rounded, color: FortuneTheme.mysticBlack, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
