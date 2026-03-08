import SwiftUI

/// 模式选择页面 - 应用启动时的入口
/// 用户选择后，ContentView 会自动导航到 DeviceListView
struct ModeSelectionView: View {
    @StateObject private var viewModel = ModeSelectionViewModel()
    @State private var selectedMode: ConnectionMode?
    @State private var showSettings = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                // 标题区域
                headerView
                
                // 模式选择卡片
                modeSelectionCards
                
                Spacer()
                
                // 底部信息
                footerView
            }
            .padding(.horizontal, 24)
            .padding(.top, 60)
            .padding(.bottom, 32)
        }
        .sheet(isPresented: $showSettings) {
            if let mode = selectedMode {
                ModeSettingsView(mode: mode, onComplete: {
                    showSettings = false
                    viewModel.completeModeSelection(mode)
                })
            }
        }
    }
    
    // MARK: - Subviews
    
    private var headerView: some View {
        VStack(spacing: 16) {
            Image(systemName: "network.badge.shield.half.filled")
                .font(.system(size: 72))
                .foregroundStyle(.blue, .cyan)
            
            Text("UBNT Monitor")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("选择连接方式")
                .font(.title3)
                .foregroundColor(.secondary)
        }
    }
    
    private var modeSelectionCards: some View {
        VStack(spacing: 20) {
            ForEach(ConnectionMode.allCases) { mode in
                ModeCard(
                    mode: mode,
                    isSelected: false
                ) {
                    selectedMode = mode
                    showSettings = true
                }
            }
        }
    }
    
    private var footerView: some View {
        VStack(spacing: 8) {
            if viewModel.isSwitchingMode {
                // 如果是切换模式（不是首次选择），显示取消按钮
                Button("取消") {
                    dismiss()
                }
                .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - 模式卡片

private struct ModeCard: View {
    let mode: ConnectionMode
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                // 图标
                ZStack {
                    Circle()
                        .fill(modeBackgroundColor)
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: mode.icon)
                        .font(.system(size: 28))
                        .foregroundColor(modeForegroundColor)
                }
                
                // 文字内容
                VStack(alignment: .leading, spacing: 6) {
                    Text(mode.displayName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(mode.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // 箭头指示器
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var modeBackgroundColor: Color {
        switch mode {
        case .cloud:
            return .blue.opacity(0.15)
        case .local:
            return .green.opacity(0.15)
        }
    }
    
    private var modeForegroundColor: Color {
        switch mode {
        case .cloud:
            return .blue
        case .local:
            return .green
        }
    }
}

// MARK: - Preview

#Preview("首次启动") {
    ModeSelectionView()
}

#Preview("切换模式") {
    ModeSelectionView()
}
