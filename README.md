# 🔮 命理AI (Fortune AI)

> 智能命理分析与运势预测 Android App | Apple风格设计 | DeepSeek AI驱动

---

## ✨ 核心功能

### 🏠 首页
- 今日运势评分（综合/事业/爱情/财富/健康）
- 运势评分圆环可视化
- 幸运颜色、数字、方位、吉时
- AI 大师每日建议
- 今日宜忌事项

### 🤖 AI 命理大师
- 集成 **DeepSeek V4 Pro** API
- 八字命理、紫微斗数、西方占星交叉验证
- 流式对话，实时输出
- 快速提问模板

### ☯️ 八字命盘
- 四柱八字自动计算
- 日主与十神分析
- 五行比例动态图表
- 格局分析与用神喜神
- 大运流年推算

### 🎯 更多工具
- 紫微斗数十二宫
- 塔罗占卜
- 情侣八字合婚匹配
- 流年运势详细报告
- 数字命理分析
- 个人中心与设置

---

## 🎨 UI 设计

- **Apple 风格**简洁设计
- 主题色：玄黑 + 深蓝底 + 金色点缀
- 全局圆角按钮与卡片
- 暗色主题，舒适护眼

---

## 🛠 技术栈

| 技术 | 版本 |
|------|------|
| Flutter | 3.29+ |
| Dart | 3.2+ |
| Kotlin | 1.9.22 |
| Android SDK | 34 |
| Gradle | 8.5 |

---

## 📦 构建指南

### 前提条件
1. 安装 [Flutter SDK](https://flutter.dev/docs/get-started/install)
2. 安装 [Android Studio](https://developer.android.com/studio)
3. 配置 Android SDK 和 Android 模拟器

### 构建步骤

```bash
# 1. 克隆项目
git clone https://github.com/WENMINGYU0/Fortune-AI.git
cd Fortune-AI

# 2. 安装依赖
flutter pub get

# 3. 运行调试
flutter run

# 4. 构建 APK
flutter build apk --release

# APK 位于: build/app/outputs/flutter-apk/app-release.apk
```

---

## 📱 下载

从 [Releases](../../releases) 页面下载最新 APK。

---

## 🔑 API 配置

DeepSeek API Key 已内置在 `lib/config/api_config.dart` 中，开箱即用。

---

## 📄 许可证

内部使用项目

---

Built with ❤️ using Flutter
