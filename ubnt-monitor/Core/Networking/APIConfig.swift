import Foundation

/// API 配置（兼容层，建议直接使用 CloudAPIConfig 或 LocalAPIConfig）
@available(*, deprecated, message: "使用 CloudAPIConfig 或 LocalAPIConfig 替代")
enum APIConfig {
    static let baseURL = CloudAPIConfig.baseURL
    
    static var apiKey: String {
        get { CloudAPIConfig.apiKey }
        set { CloudAPIConfig.apiKey = newValue }
    }
}
