# UBNT Monitor 配置指南

## 连接模式

本应用支持两种连接模式，**首次启动时需要选择**。

### 1. 互联网版本（云端模式）
通过 Ubiquiti 官方云端 API 访问您的设备。

**特点：**
- 适合远程管理，随时随地访问
- 需要 Ubiquiti 官网申请的 API Key
- 功能相对基础（查看设备状态）

**配置步骤：**
1. 访问 [Ubiquiti 官网](https://account.ui.com) 登录账户
2. 进入 **Settings** > **API Keys** 创建新的 API Key
3. 在应用中选择 **互联网版本**
4. 输入 API Key 并测试连接

**配置项：**
- API Key

### 2. 局域网版本 ⭐ 新增
直接连接 UniFi 控制器（如 UDM、UDM Pro、CloudKey）进行管理。

**特点：**
- 可查看更详细的设备信息（端口、射频、CPU/内存使用率）
- 支持设备操作（重启、端口 PoE 循环）
- 需要与路由器在同一网络内
- **功能已完整实现**

**配置步骤：**

1. **确保手机/平板与路由器连接同一 WiFi**

2. **在 UniFi 控制台获取 API Key**
   - 打开浏览器访问 `https://192.168.0.1`（你的路由器 IP）
   - 登录 UniFi 控制台
   - 进入 **Settings（设置）** > **Integrations（集成）**
   - 点击 **Create API Key（创建 API Key）**
   - 输入名称（如 "UBNT Monitor"）
   - 复制生成的 API Key（**重要**：复制完整的 Key，包含所有字符）
   - 保存好这个 Key，关闭后无法再次查看

3. **在应用中选择局域网版本**

4. **填写配置信息**
   - **URL**: 路由器地址
     - 格式：`https://192.168.0.1`（不需要端口号，不需要末尾斜杠）
     - 示例：`https://192.168.1.1`、`https://unifi.local`
   - **API Key**: 粘贴刚才复制的 API Key

5. **点击测试连接**
   - 如果显示 "证书错误"，是正常的（UniFi 使用自签名证书）
   - 如果显示 "连接成功"，说明配置正确

6. **保存并进入**
   - 选择站点
   - 查看设备列表

**配置项：**
- URL（包含协议、IP/域名、端口）
- API Key

---

## 局域网版本功能详情

### 支持的设备操作
- 查看设备列表（按站点）
- 查看设备详情（固件、端口、射频）
- 查看实时统计（CPU、内存、运行时间、流量）
- 重启设备
- 查看端口状态和 PoE 信息
- 查看射频配置（信道、频段）

### API 端点
局域网版本使用 UniFi Network API (v1)：
- `GET /v1/info` - 应用信息
- `GET /v1/sites` - 站点列表
- `GET /v1/sites/{siteId}/devices` - 设备列表
- `GET /v1/sites/{siteId}/devices/{deviceId}` - 设备详情
- `GET /v1/sites/{siteId}/devices/{deviceId}/statistics/latest` - 实时统计
- `POST /v1/sites/{siteId}/devices/{deviceId}/actions` - 设备操作

---

## 修改配置

如需修改当前模式的配置：
1. 在设备列表页面点击右上角的 **设置** 按钮
2. 点击 **修改配置**
3. 更新配置并保存

---

## 切换连接模式

如需在云端模式和局域网模式之间切换：

1. 在设备列表页面点击右上角的 **设置** 按钮
2. 滚动到页面底部，点击 **切换连接模式**
3. 阅读警告信息后点击 **确认切换**
4. **注意**：这会清除当前模式的所有配置
5. 应用会回到模式选择页面
6. 选择新模式并完成配置

---

## 支持的设备类型

### Unifi OS 设备 (Dream Machine 系列)
- Dream Machine Pro / SE
- Dream Machine
- Dream Wall
- Cloud Key Gen2 Plus

### 要求
- UniFi Network 应用版本 7.0 或更高
- 已启用 API 访问功能

---

## 故障排除

### 互联网版本

**API Key 无效**
- 确认 API Key 已正确复制（无多余空格）
- 检查 API Key 是否已在官网启用
- 确认账户有权限访问目标设备

**连接超时**
- 检查网络连接
- 确认设备已上线且与账户关联

### 局域网版本

**无法连接**
- 确认 URL 格式正确（如 `https://192.168.0.1`）
- 确认 API Key 在 UniFi 控制台中已启用
- 确认手机和路由器在同一网络

**证书错误**
- UniFi 使用自签名证书，iOS 可能需要信任证书
- 或尝试使用 HTTP（不推荐长期使用）

**401 未授权**
- API Key 无效或已过期
- 在 UniFi 控制台重新生成 API Key
- 确保使用 `X-API-KEY` header 格式（不是 Bearer Token）

**找不到站点**
- 确认 UniFi 控制器已配置站点
- 检查 API Key 是否有访问权限

---

## 安全建议

1. 不要在公共网络中使用局域网模式
2. 建议使用 VPN 连接到家庭网络后再使用
3. 定期更新设备固件
4. 使用强密码和双因素认证
5. API Key 请妥善保管，不要分享给他人

---

## 配置存储位置

| 配置项 | 存储位置 | 说明 |
|--------|----------|------|
| 连接模式 | UserDefaults | 明文存储 |
| 云端 API Key | Keychain | 加密存储 |
| 局域网 URL | Keychain | 加密存储 |
| 局域网 API Key | Keychain | 加密存储 |
