import Foundation
import Combine

/// 局域网设置 ViewModel
@MainActor
final class LocalSettingsViewModel: ObservableObject {
    @Published var baseURL: String = ""
    @Published var apiKey: String = ""
    @Published var isTestingConnection = false
    @Published var testResult: TestResult?
    
    var canSave: Bool {
        !baseURL.isEmpty && !apiKey.isEmpty
    }
    
    var canTest: Bool {
        !baseURL.isEmpty && !apiKey.isEmpty
    }
    
    init() {
        self.baseURL = LocalAPIConfig.baseURL
        self.apiKey = LocalAPIConfig.apiKey
    }
    
    func save() {
        // 规范化 URL（去掉末尾的斜杠）
        var normalizedURL = baseURL.trimmingCharacters(in: .whitespaces)
        while normalizedURL.hasSuffix("/") {
            normalizedURL.removeLast()
        }
        
        LocalAPIConfig.baseURL = normalizedURL
        LocalAPIConfig.apiKey = apiKey
    }
    
    func testConnection() async {
        isTestingConnection = true
        testResult = nil
        
        // 规范化 URL
        var normalizedURL = baseURL.trimmingCharacters(in: .whitespaces)
        while normalizedURL.hasSuffix("/") {
            normalizedURL.removeLast()
        }
        
        // 先验证 URL 格式
        guard isValidURL(normalizedURL) else {
            testResult = .failure("无效的 URL 格式，请使用 http://IP:端口 或 https://IP:端口")
            isTestingConnection = false
            return
        }
        
        // 临时保存配置用于测试
        let originalURL = LocalAPIConfig.baseURL
        let originalKey = LocalAPIConfig.apiKey
        
        LocalAPIConfig.baseURL = normalizedURL
        LocalAPIConfig.apiKey = apiKey
        
        defer {
            // 恢复原始配置
            LocalAPIConfig.baseURL = originalURL
            LocalAPIConfig.apiKey = originalKey
            isTestingConnection = false
        }
        
        // 尝试真实连接
        do {
            let info = try await LocalAPIService.shared.getApplicationInfo()
            testResult = .successWithVersion(info.applicationVersion)
        } catch let error as URLError {
            if error.code == .serverCertificateHasBadDate ||
               error.code == .serverCertificateUntrusted ||
               error.code == .serverCertificateHasUnknownRoot {
                testResult = .failure("证书错误：UniFi 使用自签名证书。请确保 URL 正确，或尝试使用 HTTP 代替 HTTPS（不推荐）")
            } else if error.code == .cannotConnectToHost {
                testResult = .failure("无法连接到主机，请检查：\n1. 手机和路由器在同一网络\n2. IP 地址和端口正确\n3. UniFi 控制台已启用 API")
            } else if error.code == .notConnectedToInternet {
                testResult = .failure("无网络连接")
            } else {
                testResult = .failure("连接错误: \(error.localizedDescription)")
            }
        } catch let error as NetworkError {
            switch error {
            case .unauthorized:
                testResult = .failure("认证失败：API Key 无效\n\n请检查：\n1. 使用 X-API-KEY 格式（不是 Bearer Token）\n2. 在 UniFi 控制台创建 API Key\n3. 复制完整的 API Key\n4. 确保没有多余的空格")
            case .notFound:
                testResult = .failure("API 端点未找到，请检查 URL 是否正确\n\n正确格式示例：\nhttps://192.168.0.1")
            default:
                testResult = .failure(error.localizedDescription)
            }
        } catch {
            testResult = .failure("连接失败: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 验证辅助方法
    
    /// 验证 URL 格式和安全性
    private func isValidURL(_ urlString: String) -> Bool {
        // 1. 基础 URL 解析
        guard let url = URL(string: urlString),
              let scheme = url.scheme,
              let host = url.host else {
            return false
        }
        
        // 2. 验证协议（只允许 HTTP/HTTPS）
        guard scheme == "http" || scheme == "https" else {
            return false
        }
        
        // 3. 验证端口（防止非法端口）
        if let port = url.port {
            guard (1...65535).contains(port) else {
                return false
            }
            // 可选：限制为常用端口（80, 443, 8080, 8443）
            // guard [80, 443, 8080, 8443].contains(port) else { return false }
        }
        
        // 4. 验证主机（IP 或本地域名）
        if isValidPrivateIPAddress(host) {
            return true
        }
        
        if isValidLocalDomain(host) {
            return true
        }
        
        // 拒绝公网域名（安全策略：局域网模式只允许内网地址）
        return false
    }
    
    /// 验证私有 IP 地址（RFC 1918）
    /// 允许的私有地址范围：
    /// - 10.0.0.0/8
    /// - 172.16.0.0/12
    /// - 192.168.0.0/16
    /// - 127.0.0.1（本地回环）
    private func isValidPrivateIPAddress(_ ip: String) -> Bool {
        // 验证基本格式
        let parts = ip.split(separator: ".")
        guard parts.count == 4 else { return false }
        
        var numbers: [Int] = []
        for part in parts {
            guard let num = Int(part), num >= 0, num <= 255 else {
                return false
            }
            numbers.append(num)
        }
        
        let first = numbers[0]
        let second = numbers[1]
        
        // 检查私有地址范围
        // 10.0.0.0/8
        if first == 10 {
            return true
        }
        
        // 172.16.0.0/12
        if first == 172 && (16...31).contains(second) {
            return true
        }
        
        // 192.168.0.0/16
        if first == 192 && second == 168 {
            return true
        }
        
        // 127.0.0.0/8 (本地回环)
        if first == 127 {
            return true
        }
        
        // 169.254.0.0/16 (链路本地地址)
        if first == 169 && second == 254 {
            return true
        }
        
        // 拒绝其他公网 IP
        return false
    }
    
    /// 验证本地域名
    /// 只允许 .local 域名和 localhost
    private func isValidLocalDomain(_ domain: String) -> Bool {
        let lowercased = domain.lowercased()
        
        // 允许 localhost
        if lowercased == "localhost" {
            return true
        }
        
        // 允许 .local 域名（Bonjour/mDNS）
        if lowercased.hasSuffix(".local") {
            return true
        }
        
        // 拒绝其他公网域名
        return false
    }
}

// MARK: - 测试结果类型

enum TestResult: Equatable {
    case success
    case successWithVersion(String)
    case failure(String)
}
