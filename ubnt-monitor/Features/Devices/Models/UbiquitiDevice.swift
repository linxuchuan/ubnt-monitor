import Foundation

struct UbiquitiDevice: Codable, Identifiable, Hashable {
    let id: String
    let hardwareId: String?
    let type: String?
    let ipAddress: String?
    let owner: Bool?
    let isBlocked: Bool?
    let registrationTime: String?
    let lastConnectionStateChange: String?
    let latestBackupTime: String?
    let reportedState: ReportedState?
    
    // MARK: - Computed Properties
    
    var name: String? { reportedState?.name }
    var version: String? { reportedState?.version }
    var state: String? { reportedState?.state }
    var mac: String? { reportedState?.mac }
    var hostname: String? { reportedState?.hostname }
    var displayName: String { hostname ?? name ?? id }
    
    var status: DeviceStatus {
        if isBlocked == true { return .blocked }
        return DeviceStatus(rawValue: state ?? "unknown") ?? .unknown
    }
}

// MARK: - Device Status

enum DeviceStatus: String, Codable {
    case connected
    case disconnected
    case blocked
    case unknown
    case adopting
    case provisioning
    
    var displayName: String {
        switch self {
        case .connected: return "Connected"
        case .disconnected: return "Disconnected"
        case .blocked: return "Blocked"
        case .unknown: return "Unknown"
        case .adopting: return "Adopting"
        case .provisioning: return "Provisioning"
        }
    }
    
    var color: StatusColor {
        switch self {
        case .connected: return .green
        case .disconnected: return .red
        case .blocked: return .red
        case .unknown: return .gray
        case .adopting, .provisioning: return .orange
        }
    }
}

enum StatusColor {
    case green, red, orange, gray
}

// MARK: - Response Models

struct UbiquitiDeviceListResponse: Codable {
    let data: [UbiquitiDevice]
    let httpStatusCode: Int
    let traceId: String
    let nextToken: String?
}

struct UbiquitiAPIError: Codable, LocalizedError {
    let code: String
    let httpStatusCode: Int
    let message: String
    let traceId: String
    
    var errorDescription: String? {
        return "\(code): \(message)"
    }
}
