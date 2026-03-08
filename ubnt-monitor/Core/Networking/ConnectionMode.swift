import Foundation

/// 连接模式枚举
enum ConnectionMode: String, Codable, CaseIterable, Identifiable {
    case cloud = "cloud"
    case local = "local"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .cloud:
            return "互联网版本"
        case .local:
            return "局域网版本"
        }
    }
    
    var description: String {
        switch self {
        case .cloud:
            return "通过 Ubiquiti 云端 API 管理设备，适合远程管理"
        case .local:
            return "直接连接路由器管理，可查看更多详细信息"
        }
    }
    
    var icon: String {
        switch self {
        case .cloud:
            return "cloud.fill"
        case .local:
            return "network"
        }
    }
    
    var color: String {
        switch self {
        case .cloud:
            return "blue"
        case .local:
            return "green"
        }
    }
}

// MARK: - 连接模式配置管理

enum ConnectionModeConfig {
    private static let modeKey = "com.ubnt.monitor.connectionMode"
    
    /// 当前选中的连接模式
    static var currentMode: ConnectionMode? {
        get {
            guard let rawValue = UserDefaults.standard.string(forKey: modeKey),
                  let mode = ConnectionMode(rawValue: rawValue) else {
                return nil
            }
            return mode
        }
        set {
            if let mode = newValue {
                UserDefaults.standard.set(mode.rawValue, forKey: modeKey)
            } else {
                UserDefaults.standard.removeObject(forKey: modeKey)
            }
        }
    }
    
    /// 是否已选择模式
    static var hasSelectedMode: Bool {
        currentMode != nil
    }
    
    /// 清除模式选择
    static func clearMode() {
        UserDefaults.standard.removeObject(forKey: modeKey)
        // 发送通知，让 ContentView 刷新
        NotificationCenter.default.post(name: .modeDidChange, object: nil)
    }
}
