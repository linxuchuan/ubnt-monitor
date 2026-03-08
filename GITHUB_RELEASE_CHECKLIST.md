# GitHub 发布检查清单

在将项目发布到 GitHub 之前，请完成以下检查。

---

## ✅ 发布前检查

### 仓库设置

- [ ] **创建仓库**
  - [ ] 在 GitHub 创建新仓库
  - [ ] 选择公开 (Public) 或私有 (Private)
  - [ ] 添加描述："iOS app for monitoring Ubiquiti UniFi devices"
  - [ ] 添加话题标签：ios, swift, swiftui, ubiquiti, unifi, networking

- [ ] **初始化仓库**
  ```bash
  git init
  git add .
  git commit -m "Initial commit"
  git branch -M main
  git remote add origin https://github.com/linxuchuan/ubnt-monitor.git
  git push -u origin main
  ```

### 内容检查

- [ ] **README.md**
  - [ ] 更新仓库链接（搜索替换 `yourusername`）
  - [ ] 更新邮箱地址
  - [ ] 添加实际截图（可选）
  - [ ] 确认徽章链接正确

- [ ] **LICENSE**
  - [ ] 更新版权年份
  - [ ] 更新作者名称

- [ ] **文档**
  - [ ] 所有 Markdown 文件格式正确
  - [ ] 链接可以正常跳转
  - [ ] 没有敏感信息泄露

### 代码检查

- [ ] **敏感信息**
  - [ ] 没有硬编码的 API Key
  - [ ] 没有个人配置信息
  - [ ] 没有公司/个人信息

- [ ] **编译检查**
  - [ ] 代码可以正常编译
  - [ ] 没有编译警告
  - [ ] 在模拟器运行正常

- [ ] **Git 清理**
  - [ ] `.gitignore` 配置正确
  - [ ] 没有提交不应该提交的文件
  - [ ] 清理 `.DS_Store` 文件

---

## 🚀 发布流程

### 1. 首次发布

```bash
# 创建版本标签
git tag -a v1.0.0 -m "Initial release"

# 推送标签到 GitHub
git push origin v1.0.0
```

### 2. 创建 GitHub Release

1. 访问 `https://github.com/linxuchuan/ubnt-monitor/releases`
2. 点击 "Create a new release"
3. 选择标签 `v1.0.0`
4. 填写发布标题："v1.0.0 - Initial Release"
5. 填写发布说明（参考下方模板）
6. 点击 "Publish release"

### 发布说明模板

```markdown
## What's New

### Features
- Dual mode support (Cloud API & Local LAN)
- Device list and detail views
- Device management (restart, PoE control)
- Secure credential storage

### Security
- Certificate pinning for local connections
- Keychain secure storage
- Private IP validation

### Notes
- Requires iOS 15.0+
- UniFi Network 7.0+ recommended for local mode

## Downloads
- App Store: (Coming soon)
- Build from source: See README.md
```

---

## 📋 发布后的任务

### 社区建设

- [ ] 启用 GitHub Discussions
  - Settings → Discussions → Enable

- [ ] 配置分支保护（可选）
  - Settings → Branches → Add rule
  - 保护 `main` 分支
  - 要求 PR 审查

- [ ] 添加社交预览图
  - Settings → Social preview
  - 上传 1280×640 的仓库图片

### 推广（可选）

- [ ] 在 Reddit r/Ubiquiti 分享
- [ ] 在 Ubiquiti 社区论坛发布
- [ ] 在 Twitter/X 宣布
- [ ] 更新个人项目列表

---

## 🔍 发布后检查

访问以下链接确认一切正常：

- [ ] `https://github.com/linxuchuan/ubnt-monitor` - 主页显示正常
- [ ] `https://github.com/linxuchuan/ubnt-monitor#readme` - README 渲染正常
- [ ] `https://github.com/linxuchuan/ubnt-monitor/blob/main/LICENSE` - 许可证显示正常
- [ ] Issues 和 PR 模板可用

---

## 📞 联系方式更新

在所有文档中更新你的联系方式：

搜索并替换以下内容：
- `yourusername` → 你的 GitHub 用户名
- 不要包含个人邮箱，使用 GitHub Issues 进行联系
- `original-owner` → 原始仓库所有者（如果是 fork）

---

## ⚠️ 重要提醒

### 不要提交的内容

- ❌ API Key 或密码
- ❌ 个人配置文件
- ❌ Xcode 用户数据 (`xcuserdata`)
- ❌ 构建产物 (`build/`, `DerivedData/`)
- ❌ 敏感证书或密钥

### 必须包含的内容

- ✅ `.gitignore` 文件
- ✅ `LICENSE` 文件
- ✅ 完整的 `README.md`
- ✅ 贡献指南
- ✅ 行为准则

---

## 🎯 后续维护

发布后定期维护：

- 回复 Issues（目标：48 小时内）
- 审查 PR
- 更新依赖和修复安全漏洞
- 定期发布新版本

---

**祝发布顺利！** 🚀
