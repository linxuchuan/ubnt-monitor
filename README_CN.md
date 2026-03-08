# UBNT Monitor

<p align="center">
  <img src="https://img.shields.io/badge/iOS-15.0+-blue.svg" alt="iOS 15.0+">
  <img src="https://img.shields.io/badge/Swift-5.9-orange.svg" alt="Swift 5.9">
  <img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License: MIT">
</p>

<p align="center">
  <b>一款开源的 Ubiquiti (UniFi) 网络设备监控 iOS 应用</b><br>
  支持云端 API 和本地局域网直连
</p>

---

## 📱 功能介绍

UBNT Monitor 让你可以随时随地监控和管理你的 UniFi 网络设备：

- 🔍 **设备监控** - 查看所有在线/离线设备
- 📊 **详细信息** - 固件版本、端口状态、WiFi 射频
- ⚡ **远程操作** - 重启设备、PoE 端口电源循环
- 🌐 **双模式** - 云端远程管理 + 局域网本地管理
- 🔒 **安全可靠** - Keychain 安全存储、证书固定

---

## 📸 应用截图

> 截图即将添加

---

## 🚀 快速开始

### 系统要求

- iOS 15.0 或更高版本
- iPhone / iPad

### 安装方式

**方式一：App Store（推荐）**

> 即将上架

**方式二：自行编译**

```bash
git clone https://github.com/linxuchuan/ubnt-monitor.git
cd ubnt-monitor
open ubnt-monitor.xcodeproj
# 在 Xcode 中编译运行
```

---

## ⚙️ 配置说明

### 云端模式

适合需要远程管理的场景。

1. 访问 [account.ui.com](https://account.ui.com) 获取 API Key
2. 在应用中选择「互联网版本」
3. 输入 API Key 完成配置

### 局域网模式 ⭐ 推荐

功能更完整，可查看详细设备信息。

1. 确保手机与 UniFi 设备同一 WiFi
2. 登录 UniFi 控制台（如 https://192.168.0.1）
3. 设置 → 集成 → 创建 API Key
4. 在应用中选择「局域网版本」
5. 输入 URL 和 API Key

详细配置请查看 [CONFIGURATION_GUIDE.md](./CONFIGURATION_GUIDE.md)

---

## 🏗️ 技术栈

- **UI 框架**: SwiftUI
- **架构**: MVVM
- **网络**: URLSession + async/await
- **安全**: Keychain + Certificate Pinning
- **最低版本**: iOS 15.0

---

## 🤝 参与贡献

我们欢迎所有形式的贡献！

- 🐛 提交 Bug 报告
- 💡 建议新功能
- 🔧 提交代码改进
- 📝 改进文档

查看 [CONTRIBUTING.md](./CONTRIBUTING.md) 了解如何参与。

---

## 📄 许可证

本项目基于 [MIT 许可证](./LICENSE) 开源。

---

## 💡 关于作者

> **声明**：作者本人并非专业的 Swift/iOS 开发者，而是一名 Java 前后端开发工程师。本项目主要是在 [Kimi Code](https://kimi.moonshot.cn/) 的辅助下完成的。
> 
> 如果你发现代码中有不符合 Swift 最佳实践的地方，或者有任何改进建议，**非常欢迎提交 PR 或 Issue**！你的帮助将使这个项目变得更好。

---

## 🙏 致谢

- [Ubiquiti Networks](https://www.ui.com/) - 提供优秀的网络设备
- [Kimi Code](https://kimi.moonshot.cn/) - AI 编程助手
- 所有贡献者

---

**Made with ❤️ by UBNT Monitor Contributors**
