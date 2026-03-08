import Foundation

/// 局域网 API 配置
enum LocalAPIConfig {
    /// 路由器地址 URL（例如: http://192.168.1.1:8080）
    static var baseURL: String {
        get { KeychainManager.retrieve(key: Keys.baseURL) ?? "" }
        set { _ = KeychainManager.save(key: Keys.baseURL, value: newValue) }
    }
    
    /// API Key
    static var apiKey: String {
        get { KeychainManager.retrieve(key: Keys.apiKey) ?? "" }
        set { _ = KeychainManager.save(key: Keys.apiKey, value: newValue) }
    }
    
    /// 检查配置是否有效
    static var isConfigured: Bool {
        !baseURL.isEmpty && !apiKey.isEmpty
    }
    
    /// 清除配置
    static func clear() {
        _ = KeychainManager.delete(key: Keys.baseURL)
        _ = KeychainManager.delete(key: Keys.apiKey)
    }
    
    /// 从 URL 解析主机和端口
    static func parseURL(_ urlString: String) -> (host: String, port: Int, useHTTPS: Bool)? {
        guard let url = URL(string: urlString),
              let host = url.host else {
            return nil
        }
        
        let useHTTPS = url.scheme == "https"
        let port = url.port ?? (useHTTPS ? 443 : 80)
        
        return (host, port, useHTTPS)
    }
    
    enum Keys {
        static let baseURL = "com.ubnt.monitor.local.baseURL"
        static let apiKey = "com.ubnt.monitor.local.apiKey"
    }
}
