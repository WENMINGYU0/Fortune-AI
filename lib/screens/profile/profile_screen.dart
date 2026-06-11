import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/user_profile.dart';
import '../../services/storage_service.dart';
import '../../widgets/fortune_widgets.dart';

/// 个人中心
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _storage = StorageService();
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _monthCtrl = TextEditingController();
  final _dayCtrl = TextEditingController();
  final _hourCtrl = TextEditingController();
  String _gender = '男';
  bool _isLunar = false;

  @override
  void initState() {
    super.initState();
    final profile = _storage.getProfile();
    if (profile != null) {
      _nameCtrl.text = profile.name;
      _gender = profile.gender;
      _yearCtrl.text = profile.birthYear.toString();
      _monthCtrl.text = profile.birthMonth.toString();
      _dayCtrl.text = profile.birthDay.toString();
      _hourCtrl.text = profile.birthHour.toString();
      _isLunar = profile.isLunar;
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final profile = UserProfile(
      name: _nameCtrl.text.trim(),
      gender: _gender,
      birthYear: int.tryParse(_yearCtrl.text) ?? 1990,
      birthMonth: int.tryParse(_monthCtrl.text) ?? 1,
      birthDay: int.tryParse(_dayCtrl.text) ?? 1,
      birthHour: int.tryParse(_hourCtrl.text) ?? 0,
      isLunar: _isLunar,
    );

    _storage.saveProfile(profile);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('信息保存成功'),
        backgroundColor: FortuneTheme.goldPrimary,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('个人中心')),
      body: Container(
        decoration: const BoxDecoration(gradient: FortuneTheme.bgGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 头像区域
                Center(
                  child: Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      gradient: FortuneTheme.goldGradient,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(Icons.person, size: 40, color: FortuneTheme.mysticBlack),
                  ),
                ),
                const SizedBox(height: 24),
                // 姓名
                _buildLabel('姓名'),
                _buildTextField(_nameCtrl, '请输入姓名', validator: (v) => v?.trim().isEmpty == true ? '请输入姓名' : null),
                const SizedBox(height: 16),
                // 性别
                _buildLabel('性别'),
                _buildGenderSelector(),
                const SizedBox(height: 16),
                // 出生日期
                _buildLabel('出生日期'),
                Row(
                  children: [
                    Expanded(flex: 2, child: _buildTextField(_yearCtrl, '年份', type: TextInputType.number)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildTextField(_monthCtrl, '月', type: TextInputType.number)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildTextField(_dayCtrl, '日', type: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 16),
                // 出生时辰
                _buildLabel('出生时辰（0-23时）'),
                _buildTextField(_hourCtrl, '时辰', type: TextInputType.number),
                const SizedBox(height: 16),
                // 农历/公历
                Row(
                  children: [
                    const Text('使用农历', style: TextStyle(color: FortuneTheme.textWhite, fontSize: 14)),
                    const Spacer(),
                    Switch(
                      value: _isLunar,
                      onChanged: (v) => setState(() => _isLunar = v),
                      activeColor: FortuneTheme.goldPrimary,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // 保存按钮
                SizedBox(
                  width: double.infinity,
                  child: FortuneButton(text: '保存信息', onPressed: _save),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: const TextStyle(color: FortuneTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint,
      {TextInputType type = TextInputType.text, String? Function(String?)? validator}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      style: const TextStyle(color: FortuneTheme.textWhite, fontSize: 15),
      decoration: InputDecoration(hintText: hint),
      validator: validator,
    );
  }

  Widget _buildGenderSelector() {
    return Row(
      children: ['男', '女'].map((g) {
        final selected = _gender == g;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _gender = g),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              margin: EdgeInsets.only(right: g == '男' ? 8 : 0),
              decoration: BoxDecoration(
                color: selected ? FortuneTheme.goldPrimary : FortuneTheme.cardSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      g == '男' ? Icons.male : Icons.female,
                      color: selected ? FortuneTheme.mysticBlack : FortuneTheme.silverGray,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      g,
                      style: TextStyle(
                        color: selected ? FortuneTheme.mysticBlack : FortuneTheme.silverGray,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _yearCtrl.dispose();
    _monthCtrl.dispose();
    _dayCtrl.dispose();
    _hourCtrl.dispose();
    super.dispose();
  }
}

/// 设置页面
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: Container(
        decoration: const BoxDecoration(gradient: FortuneTheme.bgGradient),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSection('通用'),
            _buildTile(Icons.notifications_outlined, '推送通知', trailing: '已开启'),
            _buildTile(Icons.dark_mode_outlined, '深色模式', trailing: '跟随系统'),
            _buildTile(Icons.language, '语言', trailing: '简体中文'),
            const SizedBox(height: 20),
            _buildSection('数据'),
            _buildTile(Icons.storage_outlined, '清除缓存', trailing: '0.0 MB'),
            _buildTile(Icons.history, '对话记录', trailing: ''),
            const SizedBox(height: 20),
            _buildSection('关于'),
            _buildTile(Icons.info_outline, '版本信息', trailing: 'v1.0.0'),
            _buildTile(Icons.description_outlined, '用户协议', trailing: ''),
            _buildTile(Icons.privacy_tip_outlined, '隐私政策', trailing: ''),
            const SizedBox(height: 40),
            Center(
              child: Text('Fortune AI © 2026',
                  style: TextStyle(color: FortuneTheme.silverGray.withOpacity(0.5), fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(title, style: const TextStyle(
        color: FortuneTheme.goldPrimary, fontSize: 13, fontWeight: FontWeight.w600,
      )),
    );
  }

  Widget _buildTile(IconData icon, String title, {String trailing = ''}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: FortuneTheme.cardDecoration(
        color: FortuneTheme.cardSurface,
        radius: FortuneTheme.radiusMD,
      ),
      child: ListTile(
        leading: Icon(icon, color: FortuneTheme.goldPrimary, size: 20),
        title: Text(title,
            style: const TextStyle(color: FortuneTheme.textWhite, fontSize: 14)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailing.isNotEmpty)
              Text(trailing,
                  style: const TextStyle(color: FortuneTheme.silverGray, fontSize: 12)),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: FortuneTheme.silverGray, size: 18),
          ],
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(FortuneTheme.radiusMD)),
      ),
    );
  }
}
