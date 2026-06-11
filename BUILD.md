# 命理AI - 构建指南

## 📱 如何构建 APK

### 方法一：使用 Flutter SDK（推荐）

1. 安装 [Flutter SDK](https://docs.flutter.dev/get-started/install)
2. 配置 Android SDK（Android Studio 自带）
3. 克隆本仓库：`git clone https://github.com/WENMINGYU0/Fortune-AI.git`
4. 进入项目目录：`cd Fortune-AI`
5. 安装依赖：`flutter pub get`
6. 连接手机或启动模拟器：`flutter devices`
7. 构建 APK：`flutter build apk --release`
8. APK 位置：`build/app/outputs/flutter-apk/app-release.apk`

### 方法二：使用 GitHub Actions 自动构建

> 本仓库已配置 GitHub Actions，推送 `main` 分支后自动构建。

查看 Actions 页面获取最新构建产物：
`https://github.com/WENMINGYU0/Fortune-AI/actions`

## 🎨 项目结构

```
Fortune-AI/
├── lib/
│   ├── config/       # API配置、主题
│   ├── models/       # 数据模型
│   ├── screens/      # 页面
│   ├── services/     # AI服务、命理计算
│   ├── widgets/      # 公共组件
│   └── main.dart    # 入口
├── android/         # Android 原生配置
├── ios/            # iOS 配置
└── index.html      # HTML5 预览版（可独立运行）
```

## 🔑 DeepSeek API Key

API Key 已内置在 `lib/config/api_config.dart` 中，开箱即用。

## 🌐 HTML5 版本

`index.html` 是功能完整的 HTML5 版本，可直接在浏览器中打开预览，也可以打包为 PWA。

## 📦 依赖

- Flutter 3.29+
- Dart 3.2+
- http: ^1.1.2
- shared_preferences: ^2.2.2
- intl: ^0.19.0
- google_fonts: ^6.1.0
- flutter_svg: ^2.0.9
- shimmer: ^3.0.0
- lottie: ^2.7.0
