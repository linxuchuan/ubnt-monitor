import Foundation

struct DeviceDetailResponse: Codable {
    let data: [HostDevices]
    let httpStatusCode: Int
    let traceId: String
    let nextToken: String?
}

struct HostDevices: Codable {
    let hostId: String
    let hostName: String
    let devices: [DeviceDetail]
    let updatedAt: String
}

struct DeviceDetail: Codable, Identifiable {
    let id: String
    let mac: String
    let name: String?
    let model: String
    let shortname: String
    let ip: String
    let productLine: String
    let status: String
    let version: String
    let firmwareStatus: String
    let updateAvailable: String?
    let isConsole: Bool
    let isManaged: Bool
    let startupTime: String?
    let adoptionTime: String?
    let note: String?
    
    // MARK: - Computed Properties
    
    var displayName: String { name ?? model }
    
    var deviceStatus: DeviceStatus {
        DeviceStatus(rawValue: status.lowercased()) ?? .unknown
    }
    
    var hasUpdate: Bool {
        updateAvailable != nil
    }
}
