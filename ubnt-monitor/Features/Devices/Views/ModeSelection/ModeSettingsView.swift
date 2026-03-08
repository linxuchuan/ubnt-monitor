import SwiftUI

/// 模式设置页面 - 根据选择的模式显示对应的配置表单
struct ModeSettingsView: View {
    let mode: ConnectionMode
    let onComplete: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Group {
                switch mode {
                case .cloud:
                    CloudSettingsForm(onComplete: onComplete)
                        .navigationTitle("\(mode.displayName)设置")
                case .local:
                    LocalSettingsForm(onComplete: onComplete)
                        .navigationTitle("\(mode.displayName)设置")
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("云端设置") {
    ModeSettingsView(mode: .cloud) {}
}

#Preview("局域网设置") {
    ModeSettingsView(mode: .local) {}
}
