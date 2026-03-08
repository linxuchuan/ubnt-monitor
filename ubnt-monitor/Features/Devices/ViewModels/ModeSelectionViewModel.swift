import Foundation
import Combine

@MainActor
final class ModeSelectionViewModel: ObservableObject {
    var currentMode: ConnectionMode? {
        ConnectionModeConfig.currentMode
    }
    
    var hasCurrentMode: Bool {
        ConnectionModeConfig.hasSelectedMode
    }
    
    /// 是否是切换模式（而不是首次选择）
    var isSwitchingMode: Bool {
        // 如果有当前模式，说明是从设置页面来切换的
        ConnectionModeConfig.hasSelectedMode
    }
    
    /// 完成模式选择
    /// 只设置模式，不处理导航。导航由 ContentView 根据模式状态自动处理
    func completeModeSelection(_ mode: ConnectionMode) {
        ConnectionModeConfig.currentMode = mode
        // 发送通知，让 ContentView 刷新并显示 DeviceListView
        NotificationCenter.default.post(name: .modeDidChange, object: nil)
    }
    
    /// 检查是否需要显示模式选择
    static var shouldShowModeSelection: Bool {
        !ConnectionModeConfig.hasSelectedMode
    }
}
