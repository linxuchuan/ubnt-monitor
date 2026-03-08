# 贡献指南

感谢你对 UBNT Monitor 项目的兴趣！🎉

本文档将指导你如何参与到项目中。无论你是修复 bug、添加新功能，还是改进文档，你的贡献都将受到欢迎。

---

## 📋 目录

- [行为准则](#行为准则)
- [如何贡献](#如何贡献)
  - [报告 Bug](#报告-bug)
  - [建议新功能](#建议新功能)
  - [提交代码](#提交代码)
- [开发环境](#开发环境)
- [代码规范](#代码规范)
- [提交规范](#提交规范)
- [审查流程](#审查流程)

---

## 📜 行为准则

本项目采用 [Contributor Covenant](https://www.contributor-covenant.org/version/2/1/code_of_conduct/) 行为准则。参与项目即表示你同意遵守。

### 我们的承诺

我们致力于为所有人提供友好、安全和受欢迎的体验，无论其：
- 年龄、体型、身体或精神能力
- 种族、民族、国籍
- 性别认同和表达
- 经验水平
- 教育背景
- 社会经济地位

不可接受的参与者行为将被处理。请查看 [CODE_OF_CONDUCT.md](./CODE_OF_CONDUCT.md) 了解详情。

---

## 🚀 如何贡献

### 报告 Bug

在创建 Bug 报告前，请先：

1. 查看 [Issues](https://github.com/linxuchuan/ubnt-monitor/issues) 确认问题未被报告
2. 确认你使用的是最新版本

创建 Issue 时请包含：

- **清晰的标题** - 简洁描述问题
- **详细描述** - 解释问题是什么
- **复现步骤** - 如何一步步复现问题
- **期望行为** - 你期望发生什么
- **实际行为** - 实际发生了什么
- **环境信息**:
  - iOS 版本
  - 设备型号
  - 应用版本
  - 连接模式（云端/局域网）
- **截图** - 如有助于理解问题
- **日志** - 如有错误日志请附上

### 建议新功能

我们欢迎功能建议！请创建 Issue 并：

- 使用标题 `[Feature Request] 简短描述`
- 清晰描述功能和用例
- 解释为什么这个功能对大多数用户有用
- 如有类似应用的功能参考，可附上链接

### 提交代码

#### 1. Fork 仓库

```bash
# 点击 GitHub 页面的 Fork 按钮
# 然后克隆你的 fork
git clone https://github.com/linxuchuan/ubnt-monitor.git
cd ubnt-monitor
```

#### 2. 添加上游仓库

```bash
git remote add upstream https://github.com/linxuchuan/ubnt-monitor.git
```

#### 3. 创建分支

```bash
# 从 main 分支创建新分支
git checkout -b feature/your-feature-name

# 或者修复 bug
git checkout -b fix/bug-description
```

分支命名规范：
- `feature/` - 新功能
- `fix/` - Bug 修复
- `docs/` - 文档更新
- `refactor/` - 代码重构
- `security/` - 安全修复

#### 4. 开发和提交

```bash
# 修改代码后
git add .
git commit -m "feat: 添加新功能描述"
git push origin feature/your-feature-name
```

#### 5. 创建 Pull Request

1. 访问你的 fork 页面
2. 点击 "Compare & pull request"
3. 填写 PR 描述模板
4. 等待审查

---

## 🛠️ 开发环境

### 系统要求

- macOS 14.0 或更高版本
- Xcode 15.0 或更高版本
- iOS 15.0+ 模拟器或真机

### 设置开发环境

```bash
# 克隆仓库
git clone https://github.com/yourusername/ubnt-monitor.git
cd ubnt-monitor

# 打开项目
open ubnt-monitor.xcodeproj

# 编译运行
# Cmd+R 在 Xcode 中运行
```

### 项目结构

熟悉项目结构有助于贡献：

```
ubnt-monitor/
├── App/                    # 应用入口
├── Core/                   # 核心层
│   ├── Networking/         # 网络服务
│   ├── Security/           # 安全存储
│   └── Extensions/         # 扩展
├── Features/               # 功能模块
│   └── Devices/            # 设备管理
│       ├── Models/         # 数据模型
│       ├── ViewModels/     # 视图模型
│       └── Views/          # 视图
└── Resources/              # 资源文件
```

详细架构请查看 [PROJECT_STRUCTURE.md](./PROJECT_STRUCTURE.md)

---

## 📝 代码规范

### Swift 风格指南

我们遵循 [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/) 和以下规则：

#### 命名规范

```swift
// ✅ 正确
struct DeviceManager { }
func fetchDevices() async throws -> [Device]
let isLoading: Bool

// ❌ 错误
struct deviceManager { }
func FetchDevices() -> [Device]
let loading: Bool
```

#### 代码组织

```swift
import SwiftUI

// MARK: - View
struct DeviceListView: View {
    // MARK: Properties
    @StateObject private var viewModel = DeviceListViewModel()
    
    // MARK: Body
    var body: some View {
        // ...
    }
    
    // MARK: Subviews
    private var listView: some View {
        // ...
    }
}

// MARK: - Preview
#Preview {
    DeviceListView()
}
```

#### 访问控制

```swift
// 默认使用最小权限
private let apiKey: String
internal var devices: [Device]
public func fetchDevices()
```

#### 错误处理

```swift
// ✅ 使用 Swift 错误处理
do {
    let devices = try await apiService.fetchDevices()
} catch {
    // 处理错误
}

// ✅ 使用 Result 类型
func fetchDevices() async -> Result<[Device], Error>
```

### SwiftUI 规范

```swift
// ✅ 使用 @StateObject 持有 ViewModel
@StateObject private var viewModel = DeviceListViewModel()

// ✅ 使用 @MainActor 标记 ViewModel
@MainActor
final class DeviceListViewModel: ObservableObject {
    @Published private(set) var devices: [Device] = []
}

// ✅ 使用 private(set) 保护状态
@Published private(set) var isLoading = false
```

### 安全规范

⚠️ **安全是最重要的**

```swift
// ✅ 敏感信息存储在 Keychain
KeychainManager.save(key: "apiKey", value: apiKey)

// ❌ 永远不要这样做
UserDefaults.standard.set(apiKey, forKey: "apiKey")

// ✅ 使用 #if DEBUG 保护调试代码
#if DEBUG
print("Debug info")
#endif

// ❌ 不要在生产代码中记录敏感信息
print("API Key: \(apiKey)")
```

---

## 💬 提交规范

我们使用 [Conventional Commits](https://www.conventionalcommits.org/) 规范。

### 提交格式

```
<type>(<scope>): <subject>

<body>

<footer>
```

### 类型 (Type)

| 类型 | 说明 |
|------|------|
| `feat` | 新功能 |
| `fix` | Bug 修复 |
| `docs` | 文档更新 |
| `style` | 代码格式（不影响功能） |
| `refactor` | 代码重构 |
| `perf` | 性能优化 |
| `test` | 测试相关 |
| `chore` | 构建/工具/依赖更新 |
| `security` | 安全修复 |

### 示例

```bash
# 新功能
feat(devices): 添加设备重启功能

# Bug 修复
fix(network): 修复超时处理问题

# 文档
docs(readme): 更新安装说明

# 安全
security(keychain): 添加生物识别保护
```

---

## 🔍 审查流程

### 提交 PR 前自查清单

- [ ] 代码可以编译通过
- [ ] 在模拟器和真机上测试过
- [ ] 没有明显的性能问题
- [ ] 没有包含敏感信息
- [ ] 更新了相关文档
- [ ] 遵循代码规范

### PR 描述模板

```markdown
## 描述
简要描述这个 PR 做了什么

## 类型
- [ ] Bug 修复
- [ ] 新功能
- [ ] 文档更新
- [ ] 代码重构
- [ ] 性能优化
- [ ] 安全修复

## 测试
- [ ] 在 iOS 15 测试通过
- [ ] 在 iOS 16 测试通过
- [ ] 在 iOS 17 测试通过

## 截图
（如适用，添加截图）

## 其他信息
任何 reviewer 需要知道的信息
```

### 审查标准

维护者会审查：

1. **功能正确性** - 代码是否实现了预期功能
2. **代码质量** - 是否遵循规范，是否易于维护
3. **安全性** - 是否有安全隐患
4. **性能** - 是否有性能问题
5. **测试** - 是否有足够的测试覆盖

### 合并

- PR 需要至少 1 个 approve 才能合并
- 所有 CI 检查必须通过
- 合并前请 rebase 到最新的 main 分支

---

## 🎯 需要帮助？

如果你有任何问题：

1. 查看 [Issues](https://github.com/linxuchuan/ubnt-monitor/issues) 寻找答案
2. 创建新的 Issue 提问

---

## 🎉 感谢

再次感谢你的贡献！没有你，这个项目不可能变得更好。

---

**Happy Coding!** 🚀
