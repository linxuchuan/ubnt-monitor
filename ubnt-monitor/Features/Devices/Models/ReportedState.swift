import Foundation

struct ReportedState: Codable, Hashable {
    let name: String?
    let version: String?
    let state: String?
    let mac: String?
    let hostname: String?
    let ip: String?
}
