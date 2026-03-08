import Foundation
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var showCloudSettings = false
    @Published var showLocalSettings = false
    @Published var showSwitchModeConfirmation = false
    @Published var shouldDismissSettings = false
    
    var currentMode: ConnectionMode? {
        ConnectionModeConfig.currentMode
    }
    
    /// 显示当前模式的设置页面
    func showCurrentModeSettings() {
        guard let mode = currentMode else { return }
        
        switch mode {
        case .cloud:
            showCloudSettings = true
        case .local:
            showLocalSettings = true
        }
    }
    
    /// 开始切换模式流程
    func startSwitchMode() {
        showSwitchModeConfirmation = true
    }
    
    /// 确认切换模式
    func confirmSwitchMode() {
        // 清除当前模式的配置
        if let mode = currentMode {
            switch mode {
            case .cloud:
                CloudAPIConfig.clear()
            case .local:
                LocalAPIConfig.clear()
            }
        }
        
        // 清除模式选择
        ConnectionModeConfig.clearMode()
        
        // 关闭设置页面，回到 ContentView，它会自动显示 ModeSelectionView
        shouldDismissSettings = true
    }
}
