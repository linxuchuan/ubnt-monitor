import Foundation
import Security
import LocalAuthentication

/// Keychain 访问控制级别
enum KeychainAccessLevel {
    /// 设备解锁后可访问（推荐用于大多数场景）
    case afterFirstUnlock
    /// 仅当设备解锁时可访问
    case whenUnlocked
    /// 需要生物识别验证
    case whenUnlockedThisDeviceOnlyWithBiometry
    /// 需要密码验证
    case whenUnlockedThisDeviceOnlyWithPasscode
    
    var secAttrAccessible: CFString {
        switch self {
        case .afterFirstUnlock:
            return kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        case .whenUnlocked:
            return kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        case .whenUnlockedThisDeviceOnlyWithBiometry:
            return kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        case .whenUnlockedThisDeviceOnlyWithPasscode:
            return kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        }
    }
}

/// Keychain 管理器
/// 安全地存储敏感信息，使用适当的访问控制和防备份属性
enum KeychainManager {
    static let service = "com.ubnt.monitor"
    
    /// 保存数据到 Keychain
    /// - Parameters:
    ///   - key: 存储键名
    ///   - value: 要存储的字符串值
    ///   - accessLevel: 访问控制级别，默认为 afterFirstUnlock
    /// - Returns: 是否保存成功
    @discardableResult
    static func save(
        key: String,
        value: String,
        accessLevel: KeychainAccessLevel = .afterFirstUnlock
    ) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }
        
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            // 设置访问控制：设备首次解锁后可访问，不备份到 iCloud/iTunes
            kSecAttrAccessible as String: accessLevel.secAttrAccessible
        ]
        
        // 添加生物识别或密码验证（如果需要）
        if accessLevel == .whenUnlockedThisDeviceOnlyWithBiometry ||
           accessLevel == .whenUnlockedThisDeviceOnlyWithPasscode {
            var error: Unmanaged<CFError>?
            let flags: SecAccessControlCreateFlags = accessLevel == .whenUnlockedThisDeviceOnlyWithBiometry
                ? [.biometryCurrentSet, .privateKeyUsage]
                : [.devicePasscode, .privateKeyUsage]
            
            guard let accessControl = SecAccessControlCreateWithFlags(
                kCFAllocatorDefault,
                accessLevel.secAttrAccessible,
                flags,
                &error
            ) else {
                print("❌ [Keychain] Failed to create access control: \(error?.takeRetainedValue().localizedDescription ?? "unknown")")
                return false
            }
            
            query[kSecAttrAccessControl as String] = accessControl
        }
        
        // 先删除已存在的项目
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        #if DEBUG
        if status != errSecSuccess {
            print("❌ [Keychain] Save failed with status: \(status)")
        }
        #endif
        
        return status == errSecSuccess
    }
    
    /// 从 Keychain 检索数据
    /// - Parameter key: 存储键名
    /// - Returns: 存储的字符串值，如果不存在则返回 nil
    static func retrieve(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return value
    }
    
    /// 从 Keychain 删除数据
    /// - Parameter key: 存储键名
    /// - Returns: 是否删除成功（如果项目不存在也返回 true）
    @discardableResult
    static func delete(key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
    
    /// 检查某个键是否存在
    /// - Parameter key: 存储键名
    /// - Returns: 是否存在
    static func exists(key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: true  // 只返回属性，不返回数据
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        return status == errSecSuccess
    }
    
    /// 清除该服务下的所有 Keychain 项目
    /// ⚠️ 谨慎使用：这会删除所有存储的 API Key 和配置
    @discardableResult
    static func clearAll() -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}

// MARK: - 安全工具

/// 安全字符串处理工具
enum SecureString {
    /// 安全地清除字符串内容（帮助减少内存中的敏感数据残留）
    /// 注意：Swift String 是不可变的，这只能减少风险不能完全消除
    static func clear(_ string: inout String) {
        string = String(repeating: "0", count: string.count)
        string = ""
    }
    
    /// 返回脱敏后的字符串（用于日志显示）
    static func masked(_ string: String, visiblePrefix: Int = 0, visibleSuffix: Int = 0) -> String {
        guard !string.isEmpty else { return "" }
        
        let prefix = String(string.prefix(visiblePrefix))
        let suffix = String(string.suffix(visibleSuffix))
        let maskCount = max(0, string.count - visiblePrefix - visibleSuffix)
        let mask = String(repeating: "•", count: min(maskCount, 10))
        
        return prefix + mask + suffix
    }
}
