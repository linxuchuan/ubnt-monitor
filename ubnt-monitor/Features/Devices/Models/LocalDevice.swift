import Foundation

// MARK: - 局域网设备模型

/// 局域网 UniFi 设备（列表视图）
struct LocalDevice: Codable, Identifiable, Hashable {
    let id: String
    let macAddress: String
    let ipAddress: String?
    let name: String?
    let model: String
    let state: DeviceState
    let supported: Bool
    let firmwareVersion: String?
    let firmwareUpdatable: Bool?
    let features: [String]?
    /// 设备支持的接口类型（列表中返回字符串数组：["ports"], ["radios"], ["ports", "radios"]）
    let interfaceTypes: [String]?
    
    // 详情页面额外字段（获取设备详情时填充）
    var interfaces: LocalDeviceInterfaces?
    let adoptedAt: String?
    let provisionedAt: String?
    let configurationId: String?
    let uplink: LocalDeviceUplink?
    
    // 自定义解码，处理 interfaces 字段的不同类型
    enum CodingKeys: String, CodingKey {
        case id, macAddress, ipAddress, name, model, state, supported
        case firmwareVersion, firmwareUpdatable, features, interfaces
        case adoptedAt, provisionedAt, configurationId, uplink
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        macAddress = try container.decode(String.self, forKey: .macAddress)
        ipAddress = try container.decodeIfPresent(String.self, forKey: .ipAddress)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        model = try container.decode(String.self, forKey: .model)
        state = try container.decode(DeviceState.self, forKey: .state)
        supported = try container.decode(Bool.self, forKey: .supported)
        firmwareVersion = try container.decodeIfPresent(String.self, forKey: .firmwareVersion)
        firmwareUpdatable = try container.decodeIfPresent(Bool.self, forKey: .firmwareUpdatable)
        features = try container.decodeIfPresent([String].self, forKey: .features)
        adoptedAt = try container.decodeIfPresent(String.self, forKey: .adoptedAt)
        provisionedAt = try container.decodeIfPresent(String.self, forKey: .provisionedAt)
        configurationId = try container.decodeIfPresent(String.self, forKey: .configurationId)
        uplink = try container.decodeIfPresent(LocalDeviceUplink.self, forKey: .uplink)
        
        // interfaces 可能是字符串数组（列表）或对象（详情）
        if let types = try? container.decode([String].self, forKey: .interfaces) {
            // 列表响应：interfaces 是字符串数组
            interfaceTypes = types
            interfaces = nil
        } else if let detailInterfaces = try? container.decode(LocalDeviceInterfaces.self, forKey: .interfaces) {
            // 详情响应：interfaces 是对象
            interfaceTypes = nil
            interfaces = detailInterfaces
        } else {
            interfaceTypes = nil
            interfaces = nil
        }
    }
    
    // 便利初始化方法（用于预览和手动创建）
    init(
        id: String,
        macAddress: String,
        ipAddress: String? = nil,
        name: String? = nil,
        model: String,
        state: DeviceState,
        supported: Bool,
        firmwareVersion: String? = nil,
        firmwareUpdatable: Bool? = nil,
        features: [String]? = nil,
        interfaceTypes: [String]? = nil,
        interfaces: LocalDeviceInterfaces? = nil,
        adoptedAt: String? = nil,
        provisionedAt: String? = nil,
        configurationId: String? = nil,
        uplink: LocalDeviceUplink? = nil
    ) {
        self.id = id
        self.macAddress = macAddress
        self.ipAddress = ipAddress
        self.name = name
        self.model = model
        self.state = state
        self.supported = supported
        self.firmwareVersion = firmwareVersion
        self.firmwareUpdatable = firmwareUpdatable
        self.features = features
        self.interfaceTypes = interfaceTypes
        self.interfaces = interfaces
        self.adoptedAt = adoptedAt
        self.provisionedAt = provisionedAt
        self.configurationId = configurationId
        self.uplink = uplink
    }
    
    // 编码方法
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(macAddress, forKey: .macAddress)
        try container.encodeIfPresent(ipAddress, forKey: .ipAddress)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encode(model, forKey: .model)
        try container.encode(state, forKey: .state)
        try container.encode(supported, forKey: .supported)
        try container.encodeIfPresent(firmwareVersion, forKey: .firmwareVersion)
        try container.encodeIfPresent(firmwareUpdatable, forKey: .firmwareUpdatable)
        try container.encodeIfPresent(features, forKey: .features)
        try container.encodeIfPresent(adoptedAt, forKey: .adoptedAt)
        try container.encodeIfPresent(provisionedAt, forKey: .provisionedAt)
        try container.encodeIfPresent(configurationId, forKey: .configurationId)
        try container.encodeIfPresent(uplink, forKey: .uplink)
        
        // 优先编码 interfaces 对象，如果没有则编码 interfaceTypes
        if let interfaces = interfaces {
            try container.encode(interfaces, forKey: .interfaces)
        } else if let interfaceTypes = interfaceTypes {
            try container.encode(interfaceTypes, forKey: .interfaces)
        }
    }
}

// MARK: - 设备状态

enum DeviceState: String, Codable {
    case online = "ONLINE"
    case offline = "OFFLINE"
    case pending = "PENDING"
    case adopting = "ADOPTING"
    case provisioning = "PROVISIONING"
    case unknown = "UNKNOWN"
    
    var displayName: String {
        switch self {
        case .online: return "在线"
        case .offline: return "离线"
        case .pending: return "待 Adoption"
        case .adopting: return "Adoption 中"
        case .provisioning: return "配置中"
        case .unknown: return "未知"
        }
    }
    
    var color: StatusColor {
        switch self {
        case .online: return .green
        case .offline: return .red
        case .pending, .adopting, .provisioning: return .orange
        case .unknown: return .gray
        }
    }
}

// MARK: - 设备接口（详情视图）

struct LocalDeviceInterfaces: Codable, Hashable {
    let ports: [LocalDevicePort]?
    let radios: [LocalDeviceRadio]?
}

/// 设备端口
struct LocalDevicePort: Codable, Identifiable, Hashable {
    let idx: Int
    let state: String?
    let connector: String?
    let maxSpeedMbps: Int?
    let speedMbps: Int?
    let poe: LocalDevicePoE?
    
    var id: Int { idx }
}

/// PoE 配置
struct LocalDevicePoE: Codable, Hashable {
    let standard: String?
    let type: Int?
    let enabled: Bool?
    let state: String?
}

/// 射频信息
struct LocalDeviceRadio: Codable, Identifiable, Hashable {
    let wlanStandard: String?
    let frequencyGHz: Double?
    let channelWidthMHz: Int?
    let channel: Int?
    
    var id: String { "\(frequencyGHz ?? 0)-\(channel ?? 0)" }
}

// MARK: - 上行链路

struct LocalDeviceUplink: Codable, Hashable {
    let deviceId: String?
}

// MARK: - 响应模型

struct LocalDeviceListResponse: Codable {
    let offset: Int
    let limit: Int
    let count: Int
    let totalCount: Int
    let data: [LocalDevice]
}

struct LocalDeviceDetailResponse: Codable {
    let data: LocalDevice
}

// MARK: - 站点模型

struct LocalSite: Codable, Identifiable {
    let id: String
    let internalReference: String?
    let name: String
}

struct LocalSiteListResponse: Codable {
    let offset: Int
    let limit: Int
    let count: Int
    let totalCount: Int
    let data: [LocalSite]
}

// MARK: - 客户端模型

struct LocalClient: Codable, Identifiable {
    let id: String
    let macAddress: String
    let ipAddress: String?
    let name: String?
    let hostname: String?
    let networkId: String?
    let deviceId: String?
    let connectionType: String?
    let signalStrength: Int?
    let rxRateBps: Int64?
    let txRateBps: Int64?
}

struct LocalClientListResponse: Codable {
    let offset: Int
    let limit: Int
    let count: Int
    let totalCount: Int
    let data: [LocalClient]
}

// MARK: - 设备统计

struct LocalDeviceStatistics: Codable {
    let uptimeSec: Int?
    let lastHeartbeatAt: String?
    let nextHeartbeatAt: String?
    let loadAverage1Min: Double?
    let loadAverage5Min: Double?
    let loadAverage15Min: Double?
    let cpuUtilizationPct: Double?
    let memoryUtilizationPct: Double?
    let uplink: LocalStatisticsUplink?
    let interfaces: LocalStatisticsInterfaces?
}

struct LocalStatisticsUplink: Codable {
    let txRateBps: Int64?
    let rxRateBps: Int64?
}

struct LocalStatisticsInterfaces: Codable {
    let radios: [LocalRadioStatistics]?
}

struct LocalRadioStatistics: Codable {
    let frequencyGHz: Double?
    let txRetriesPct: Double?
}
