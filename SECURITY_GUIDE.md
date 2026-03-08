# UBNT Monitor 安全配置指南

本文档描述了如何安全地配置 UBNT Monitor 应用以用于生产环境。

---

## 🔐 关键安全注意事项

### 1. 证书固定（Certificate Pinning）

**⚠️ 生产环境必须配置证书固定！**

当前实现默认拒绝所有未配置证书的连接。你需要获取 UniFi 控制台的证书公钥哈希并添加到信任列表。

#### 获取证书公钥哈希

```bash
# 连接到 UniFi 控制台并获取证书公钥哈希
openssl s_client -connect 192.168.0.1:443 -servername 192.168.0.1 </dev/null 2>/dev/null | \
  openssl x509 -pubkey -noout | \
  openssl pkey -pubin -outform der | \
  openssl dgst -sha256 -binary | \
  base64
```

#### 配置信任证书

在 `LocalURLSession.swift` 中更新信任列表：

```swift
private let trustedPublicKeyHashes: Set<String> = [
    "你的证书公钥哈希1",
    "你的证书公钥哈希2"  // 可选：添加备用证书
]
```

### 2. API Key 存储

- API Key 使用 Keychain 安全存储
- 使用 `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly` 访问级别
- 数据**不会**备份到 iCloud 或 iTunes

### 3. 网络通信安全

- **云端模式**：使用标准 HTTPS，系统证书验证
- **局域网模式**：必须配置证书固定（见上文）

---

## 🛡️ 生产环境检查清单

在发布到生产环境前，请确认以下事项：

### 编译配置
- [ ] 使用 Release 配置编译（非 DEBUG）
- [ ] 确认所有 `#if DEBUG` 代码不会在生产环境执行
- [ ] 禁用或移除所有调试日志

### 证书配置
- [ ] 获取并配置了 UniFi 控制台的证书公钥哈希
- [ ] 测试证书固定是否正常工作（尝试连接应该失败）
- [ ] 准备了证书更新流程（证书过期时需要更新哈希）

### URL 验证
- [ ] 确认局域网模式只接受私有 IP 地址
- [ ] 确认拒绝了所有公网域名和 IP

### 数据保护
- [ ] 确认 API Key 存储在 Keychain
- [ ] 确认没有敏感信息输出到日志
- [ ] 确认没有敏感信息显示在 UI（即使在错误页面）

---

## 🔧 安全功能配置

### 生物识别/密码保护

如需为 API Key 添加生物识别保护，修改 `KeychainManager.save` 调用：

```swift
// 在 CloudAPIConfig.swift 或 LocalAPIConfig.swift 中
KeychainManager.save(
    key: Keys.apiKey,
    value: newValue,
    accessLevel: .whenUnlockedThisDeviceOnlyWithBiometry  // 需要 Face ID/Touch ID
)
```

可用选项：
- `.afterFirstUnlock` - 设备首次解锁后可访问（默认，推荐）
- `.whenUnlocked` - 每次解锁后可访问
- `.whenUnlockedThisDeviceOnlyWithBiometry` - 需要生物识别
- `.whenUnlockedThisDeviceOnlyWithPasscode` - 需要设备密码

---

## ⚠️ 已知限制

### 自签名证书

UniFi 控制台默认使用自签名证书。在生产环境中，你有两个选择：

1. **证书固定**（推荐）：按照上文配置证书固定
2. **使用受信任的证书**：为 UniFi 控制台配置由受信任 CA 签发的证书

### 越狱设备

在越狱设备上：
- Keychain 数据可能被访问
- 内存中的敏感数据可能被提取
- 证书固定可能被绕过

**建议**：使用越狱检测并警告用户，或拒绝在越狱设备上运行。

---

## 🚨 安全事件响应

如果发现安全漏洞：

1. 立即撤销/轮换受影响的 API Key
2. 通知用户更改密码和重新配置
3. 发布安全更新

---

## 📞 安全联系

如发现安全问题，请通过以下方式报告：

- 创建私有 Issue（如使用 GitHub）
- 或直接联系开发团队
