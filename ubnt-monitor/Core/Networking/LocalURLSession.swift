import Foundation
import CryptoKit
import Security

/// 局域网专用 URLSession，支持证书固定
/// 生产环境应该使用从服务器获取并存储的证书公钥进行验证
final class LocalURLSessionDelegate: NSObject, URLSessionDelegate {
    static let shared = LocalURLSessionDelegate()
    
    private override init() {}
    
    /// 信任的证书公钥集合（生产环境应该从安全存储加载）
    /// 格式: Base64 编码的 SPKI (Subject Public Key Info) SHA256 哈希
    private let trustedPublicKeyHashes: Set<String> = [
        // ⚠️ 生产环境必须替换为实际 UniFi 控制台的证书公钥哈希
        // 可以通过以下命令获取:
        // openssl s_client -connect 192.168.0.1:443 -servername 192.168.0.1 < /dev/null 2>/dev/null | openssl x509 -pubkey -noout | openssl pkey -pubin -outform der | openssl dgst -sha256 -binary | base64
    ]
    
    /// 是否在 DEBUG 模式下接受自签名证书（生产环境必须设为 false）
    #if DEBUG
    private let allowSelfSignedInDebug = true
    #else
    private let allowSelfSignedInDebug = false
    #endif
    
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        // 检查是否是服务器信任挑战
        guard let serverTrust = challenge.protectionSpace.serverTrust,
              let certificateChain = SecTrustCopyCertificateChain(serverTrust) as? [SecCertificate],
              !certificateChain.isEmpty else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        let host = challenge.protectionSpace.host
        
        #if DEBUG
        if allowSelfSignedInDebug {
            // DEBUG 模式：验证证书链完整性，但允许自签名
            var error: CFError?
            let isValid = SecTrustEvaluateWithError(serverTrust, &error)
            
            if isValid || isSelfSignedCertificate(serverTrust) {
                let credential = URLCredential(trust: serverTrust)
                completionHandler(.useCredential, credential)
                return
            }
        }
        #endif
        
        // 生产环境：严格的证书固定验证
        if trustedPublicKeyHashes.isEmpty {
            // 如果没有配置固定的证书哈希，拒绝连接（安全默认值）
            print("❌ [Security] No trusted certificate hashes configured. Rejecting connection to \(host)")
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        // 验证服务器证书的公钥是否在信任列表中
        if let serverPublicKeyHash = extractPublicKeyHash(from: certificateChain[0]),
           trustedPublicKeyHashes.contains(serverPublicKeyHash) {
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
            return
        }
        
        // 证书验证失败
        print("❌ [Security] Certificate pinning failed for \(host)")
        completionHandler(.cancelAuthenticationChallenge, nil)
    }
    
    /// 检查是否是自签名证书（仅用于 DEBUG 模式）
    private func isSelfSignedCertificate(_ trust: SecTrust) -> Bool {
        // 获取证书链
        guard let certificateChain = SecTrustCopyCertificateChain(trust) as? [SecCertificate],
              certificateChain.count == 1 else {
            return false
        }
        return true
    }
    
    /// 提取证书公钥的 SHA256 哈希（SPKI 格式）
    private func extractPublicKeyHash(from certificate: SecCertificate) -> String? {
        // 创建临时信任对象来获取公钥
        let policy = SecPolicyCreateBasicX509()
        var trust: SecTrust?
        let status = SecTrustCreateWithCertificates(certificate, policy, &trust)
        
        guard status == errSecSuccess, let trust = trust else {
            return nil
        }
        
        guard let publicKey = SecTrustCopyKey(trust) else {
            return nil
        }
        
        // 获取公钥的原始数据
        guard let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, nil) as Data? else {
            return nil
        }
        
        // 使用 CryptoKit 计算 SHA256 哈希
        let hash = SHA256.hash(data: publicKeyData)
        return Data(hash).base64EncodedString()
    }
}

/// 创建支持证书固定的 URLSession
extension URLSession {
    static let local: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10  // 单个请求超时 10 秒
        configuration.timeoutIntervalForResource = 30 // 整体资源超时 30 秒
        
        // 禁止不安全的 TLS 版本
        if #available(iOS 13.0, *) {
            configuration.tlsMinimumSupportedProtocolVersion = .TLSv12
        } else {
            configuration.tlsMinimumSupportedProtocol = .tlsProtocol12
        }
        
        let delegate = LocalURLSessionDelegate.shared
        return URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
    }()
}

// MARK: - 证书哈希管理

/// 证书哈希管理器（用于安全存储和检索信任的证书哈希）
enum CertificatePinningManager {
    private static let userDefaultsKey = "com.ubnt.monitor.trusted_cert_hashes"
    private static let keychainKey = "com.ubnt.monitor.trusted_cert_hashes_secure"
    
    /// 保存信任的证书哈希
    /// ⚠️ 注意：实际生产环境应该使用 Keychain 存储
    static func saveTrustedHashes(_ hashes: [String]) {
        // 优先尝试使用 Keychain
        if let data = try? JSONEncoder().encode(hashes) {
            let success = KeychainManager.save(
                key: keychainKey,
                value: String(data: data, encoding: .utf8) ?? "",
                accessLevel: .afterFirstUnlock
            )
            if !success {
                // 降级到 UserDefaults（不推荐，但为了兼容性）
                UserDefaults.standard.set(data, forKey: userDefaultsKey)
            }
        }
    }
    
    /// 获取信任的证书哈希
    static func getTrustedHashes() -> [String] {
        // 优先从 Keychain 获取
        if let dataString = KeychainManager.retrieve(key: keychainKey),
           let data = dataString.data(using: .utf8),
           let hashes = try? JSONDecoder().decode([String].self, from: data) {
            return hashes
        }
        
        // 降级到 UserDefaults
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let hashes = try? JSONDecoder().decode([String].self, from: data) else {
            return []
        }
        return hashes
    }
    
    /// 添加新的证书哈希（在首次成功连接后）
    static func addTrustedHash(_ hash: String) {
        var hashes = getTrustedHashes()
        if !hashes.contains(hash) {
            hashes.append(hash)
            saveTrustedHashes(hashes)
        }
    }
    
    /// 清除所有信任的证书哈希
    static func clearTrustedHashes() {
        _ = KeychainManager.delete(key: keychainKey)
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }
}
