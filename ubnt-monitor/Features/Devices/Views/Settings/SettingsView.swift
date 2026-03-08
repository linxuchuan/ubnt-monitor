import SwiftUI

/// 统一的设置页面 - 从主界面进入
struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                // 当前模式信息
                currentModeSection
                
                // 模式特定设置
                modeSpecificSettings
                
                // 切换模式
                switchModeSection
                
                // 关于
                aboutSection
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $viewModel.showCloudSettings) {
                CloudSettingsSheet(onComplete: {
                    viewModel.showCloudSettings = false
                })
            }
            .sheet(isPresented: $viewModel.showLocalSettings) {
                LocalSettingsSheet(onComplete: {
                    viewModel.showLocalSettings = false
                })
            }
            .alert("切换连接模式", isPresented: $viewModel.showSwitchModeConfirmation) {
                Button("取消", role: .cancel) { }
                Button("确认切换", role: .destructive) {
                    viewModel.confirmSwitchMode()
                }
            } message: {
                Text("切换模式将清除当前模式的配置信息，是否继续？")
            }
            .onChange(of: viewModel.shouldDismissSettings) { shouldDismiss in
                if shouldDismiss {
                    dismiss()
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private var currentModeSection: some View {
        Section("当前连接模式") {
            if let mode = viewModel.currentMode {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(mode == .cloud ? Color.blue.opacity(0.15) : Color.green.opacity(0.15))
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: mode.icon)
                            .font(.system(size: 20))
                            .foregroundColor(mode == .cloud ? .blue : .green)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(mode.displayName)
                            .font(.headline)
                        Text(mode.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                }
                .padding(.vertical, 4)
            } else {
                Text("未选择模式")
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var modeSpecificSettings: some View {
        Section("\(viewModel.currentMode?.displayName ?? "")配置") {
            if let mode = viewModel.currentMode {
                switch mode {
                case .cloud:
                    cloudSettingsSummary
                case .local:
                    localSettingsSummary
                }
            }
            
            Button("修改配置") {
                viewModel.showCurrentModeSettings()
            }
        }
    }
    
    private var cloudSettingsSummary: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("API Key")
                    .foregroundColor(.secondary)
                Spacer()
                Text(CloudAPIConfig.isConfigured ? "已配置" : "未配置")
                    .foregroundColor(CloudAPIConfig.isConfigured ? .green : .red)
            }
            
            if CloudAPIConfig.isConfigured {
                HStack {
                    Text("Key 预览")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(maskedAPIKey(CloudAPIConfig.apiKey))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var localSettingsSummary: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("路由器地址")
                    .foregroundColor(.secondary)
                Spacer()
                Text(LocalAPIConfig.isConfigured ? LocalAPIConfig.baseURL : "未配置")
                    .foregroundColor(LocalAPIConfig.isConfigured ? .primary : .red)
                    .lineLimit(1)
            }
            
            if LocalAPIConfig.isConfigured {
                HStack {
                    Text("API Key")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(maskedAPIKey(LocalAPIConfig.apiKey))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var switchModeSection: some View {
        Section {
            Button {
                viewModel.startSwitchMode()
            } label: {
                HStack {
                    Image(systemName: "arrow.left.arrow.right.circle")
                        .foregroundColor(.orange)
                    Text("切换连接模式")
                        .foregroundColor(.orange)
                }
            }
        } footer: {
            Text("切换后会清除当前模式的配置，需要重新配置新模式")
                .font(.caption)
        }
    }
    
    private var aboutSection: some View {
        Section("关于") {
            HStack {
                Text("版本")
                Spacer()
                Text("1.1.0")
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("构建")
                Spacer()
                Text("2024.03")
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Helper
    
    private func maskedAPIKey(_ key: String) -> String {
        guard key.count > 8 else { return "***" }
        let prefix = key.prefix(4)
        let suffix = key.suffix(4)
        return "\(prefix)...\(suffix)"
    }
}

// MARK: - 云端设置弹窗

private struct CloudSettingsSheet: View {
    let onComplete: () -> Void
    
    var body: some View {
        NavigationStack {
            CloudSettingsForm {
                onComplete()
            }
        }
    }
}

// MARK: - 局域网设置弹窗

private struct LocalSettingsSheet: View {
    let onComplete: () -> Void
    
    var body: some View {
        NavigationStack {
            LocalSettingsForm {
                onComplete()
            }
        }
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
}
