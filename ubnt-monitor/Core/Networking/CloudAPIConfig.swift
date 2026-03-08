import Foundation

/// 云端 API 配置
enum CloudAPIConfig {
    static let baseURL = "https://api.ui.com/v1"
    
    /// 云端 API Key
    static var apiKey: String {
        get { KeychainManager.retrieve(key: Keys.apiKey) ?? "" }
        set { _ = KeychainManager.save(key: Keys.apiKey, value: newValue) }
    }
    
    /// 检查配置是否有效
    static var isConfigured: Bool {
        !apiKey.isEmpty
    }
    
    /// 清除配置
    static func clear() {
        _ = KeychainManager.delete(key: Keys.apiKey)
    }
    
    enum Keys {
        static let apiKey = "com.ubnt.monitor.cloud.apiKey"
    }
}
