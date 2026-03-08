import Foundation

// MARK: - 调试用的宽松设备模型
// ⚠️ 警告：此文件仅在 DEBUG 模式下使用，不要用于生产环境数据处理

#if DEBUG

/// 用于调试的宽松设备模型，所有字段都是 Optional
struct LocalDeviceDebug: Codable {
    let id: String?
    let macAddress: String?
    let ipAddress: String?
    let name: String?
    let model: String?
    let state: String?
    let supported: Bool?
    let firmwareVersion: String?
    let firmwareUpdatable: Bool?
    let features: [String]?
    let interfaceTypes: [String]?
    
    /// 打印所有字段（注意：可能包含敏感信息，仅用于调试）
    func dump() -> String {
        var result = "LocalDeviceDebug:\n"
        result += "  id: \(id.map { maskSensitive($0) } ?? "nil")\n"
        result += "  macAddress: \(macAddress.map { maskMAC($0) } ?? "nil")\n"
        result += "  ipAddress: \(ipAddress.map { maskIP($0) } ?? "nil")\n"
        result += "  name: \(name ?? "nil")\n"
        result += "  model: \(model ?? "nil")\n"
        result += "  state: \(state ?? "nil")\n"
        result += "  supported: \(supported.map { String($0) } ?? "nil")\n"
        result += "  firmwareVersion: \(firmwareVersion ?? "nil")\n"
        result += "  interfaceTypes: \(interfaceTypes?.joined(separator: ", ") ?? "nil")\n"
        return result
    }
    
    /// 脱敏处理 ID
    private func maskSensitive(_ string: String) -> String {
        guard string.count > 8 else { return "***" }
        return String(string.prefix(4)) + "***" + String(string.suffix(4))
    }
    
    /// 脱敏处理 MAC 地址
    private func maskMAC(_ mac: String) -> String {
        let parts = mac.split(separator: ":")
        guard parts.count >= 3 else { return mac }
        return "\(parts[0]):\(parts[1]):\(parts[2]):**:**:**"
    }
    
    /// 脱敏处理 IP 地址
    private func maskIP(_ ip: String) -> String {
        let parts = ip.split(separator: ".")
        guard parts.count == 4 else { return ip }
        return "\(parts[0]).\(parts[1]).***.***"
    }
}

struct LocalDeviceListResponseDebug: Codable {
    let offset: Int?
    let limit: Int?
    let count: Int?
    let totalCount: Int?
    let data: [LocalDeviceDebug]?
}

// MARK: - 调试用的宽松站点模型

struct LocalSiteDebug: Codable {
    let id: String?
    let internalReference: String?
    let name: String?
}

struct LocalSiteListResponseDebug: Codable {
    let offset: Int?
    let limit: Int?
    let count: Int?
    let totalCount: Int?
    let data: [LocalSiteDebug]?
}

#endif
