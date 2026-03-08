import Foundation

/// 局域网 API 服务协议
protocol LocalAPIServiceProtocol {
    func getApplicationInfo() async throws -> LocalApplicationInfo
    func getSites() async throws -> [LocalSite]
    func getDevices(siteId: String) async throws -> [LocalDevice]
    func getDeviceDetail(siteId: String, deviceId: String) async throws -> LocalDevice
    func getDeviceStatistics(siteId: String, deviceId: String) async throws -> LocalDeviceStatistics
    func getClients(siteId: String) async throws -> [LocalClient]
    func executeDeviceAction(siteId: String, deviceId: String, action: DeviceAction) async throws
    func executePortAction(siteId: String, deviceId: String, portIdx: Int, action: PortAction) async throws
}

/// 设备动作
enum DeviceAction: String {
    case restart = "RESTART"
}

/// 端口动作
enum PortAction: String {
    case powerCycle = "POWER_CYCLE"
}

/// 应用信息
struct LocalApplicationInfo: Codable {
    let applicationVersion: String
}

/// 局域网 API 服务实现
final class LocalAPIService: LocalAPIServiceProtocol, @unchecked Sendable {
    nonisolated static let shared = LocalAPIService()
    
    private init() {}
    
    // MARK: - Base URL
    
    private var baseURL: String {
        let url = LocalAPIConfig.baseURL
        // 确保不以斜杠结尾，因为端点以 / 开头
        return url.hasSuffix("/") ? String(url.dropLast()) : url
    }
    
    private var apiPath: String {
        "/proxy/network/integration/v1"
    }
    
    // MARK: - Public Methods
    
    func getApplicationInfo() async throws -> LocalApplicationInfo {
        let url = try buildURL(endpoint: "/info")
        let (data, _) = try await performRequest(url: url, method: "GET")
        return try decode(LocalApplicationInfo.self, from: data)
    }
    
    func getSites() async throws -> [LocalSite] {
        let url = try buildURL(endpoint: "/sites")
        let (data, _) = try await performRequest(url: url, method: "GET")
        
        #if DEBUG
        // 先尝试用调试模型解码，查看数据结构
        if let debugResponse = try? JSONDecoder().decode(LocalSiteListResponseDebug.self, from: data) {
            print("🔍 [Local API] Sites debug decode successful")
            print("   Total count: \(debugResponse.totalCount ?? -1)")
            print("   Data count: \(debugResponse.data?.count ?? -1)")
            if let firstSite = debugResponse.data?.first {
                print("   First site: id=\(firstSite.id ?? "nil"), name=\(firstSite.name ?? "nil")")
            }
        }
        #endif
        
        let response = try decode(LocalSiteListResponse.self, from: data)
        return response.data
    }
    
    func getDevices(siteId: String) async throws -> [LocalDevice] {
        let url = try buildURL(endpoint: "/sites/\(siteId)/devices")
        let (data, _) = try await performRequest(url: url, method: "GET")
        
        #if DEBUG
        // 先尝试用调试模型解码，查看数据结构
        if let debugResponse = try? JSONDecoder().decode(LocalDeviceListResponseDebug.self, from: data) {
            print("🔍 [Local API] Debug decode successful")
            print("   Total count: \(debugResponse.totalCount ?? -1)")
            print("   Data count: \(debugResponse.data?.count ?? -1)")
            if let firstDevice = debugResponse.data?.first {
                print("   First device:\n\(firstDevice.dump())")
            }
            // 检查 interfaces 字段类型
            if let rawJSON = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let dataArray = rawJSON["data"] as? [[String: Any]],
               let firstDevice = dataArray.first,
               let interfaces = firstDevice["interfaces"] {
                print("   interfaces type: \(type(of: interfaces))")
                print("   interfaces value: \(interfaces)")
            }
        }
        #endif
        
        let response = try decode(LocalDeviceListResponse.self, from: data)
        return response.data
    }
    
    func getDeviceDetail(siteId: String, deviceId: String) async throws -> LocalDevice {
        let url = try buildURL(endpoint: "/sites/\(siteId)/devices/\(deviceId)")
        let (data, _) = try await performRequest(url: url, method: "GET")
        return try decode(LocalDevice.self, from: data)
    }
    
    func getDeviceStatistics(siteId: String, deviceId: String) async throws -> LocalDeviceStatistics {
        let url = try buildURL(endpoint: "/sites/\(siteId)/devices/\(deviceId)/statistics/latest")
        let (data, _) = try await performRequest(url: url, method: "GET")
        return try decode(LocalDeviceStatistics.self, from: data)
    }
    
    func getClients(siteId: String) async throws -> [LocalClient] {
        let url = try buildURL(endpoint: "/sites/\(siteId)/clients")
        let (data, _) = try await performRequest(url: url, method: "GET")
        let response = try decode(LocalClientListResponse.self, from: data)
        return response.data
    }
    
    func executeDeviceAction(siteId: String, deviceId: String, action: DeviceAction) async throws {
        let url = try buildURL(endpoint: "/sites/\(siteId)/devices/\(deviceId)/actions")
        let body = ["action": action.rawValue]
        let bodyData = try JSONSerialization.data(withJSONObject: body)
        let (_, response) = try await performRequest(url: url, method: "POST", body: bodyData)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
    }
    
    func executePortAction(siteId: String, deviceId: String, portIdx: Int, action: PortAction) async throws {
        let url = try buildURL(endpoint: "/sites/\(siteId)/devices/\(deviceId)/interfaces/ports/\(portIdx)/actions")
        let body = ["action": action.rawValue]
        let bodyData = try JSONSerialization.data(withJSONObject: body)
        let (_, response) = try await performRequest(url: url, method: "POST", body: bodyData)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
    }
    
    // MARK: - Private Methods
    
    private func buildURL(endpoint: String) throws -> URL {
        let urlString = "\(baseURL)\(apiPath)\(endpoint)"
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        return url
    }
    
    private func performRequest(url: URL, method: String, body: Data? = nil) async throws -> (Data, URLResponse) {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 添加 API Key 认证（局域网版本使用 X-API-KEY header）
        let apiKey = LocalAPIConfig.apiKey
        guard !apiKey.isEmpty else {
            throw NetworkError.configurationMissing(field: "API Key")
        }
        
        // UniFi 局域网 API 使用 X-API-KEY header
        request.setValue(apiKey, forHTTPHeaderField: "X-API-KEY")
        
        #if DEBUG
        // ⚠️ 安全注意：不要在生产环境记录任何 API Key 信息
        // 只记录 Key 是否存在，不记录任何内容
        print("🔑 [Local API] API Key configured: \(!apiKey.isEmpty)")
        #endif
        
        if let body = body {
            request.httpBody = body
        }
        
        #if DEBUG
        print("📡 [Local API] Request: \(method) \(url.absoluteString)")
        #endif
        
        let (data, response) = try await URLSession.local.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        #if DEBUG
        print("📥 [Local API] Response Status: \(httpResponse.statusCode)")
        if let responseString = String(data: data, encoding: .utf8) {
            print("📄 [Local API] Response Body: \(responseString.prefix(500))")
        }
        #endif
        
        try handleHTTPStatus(httpResponse.statusCode, data: data)
        
        return (data, response)
    }
    
    private func handleHTTPStatus(_ statusCode: Int, data: Data) throws {
        switch statusCode {
        case 200...299:
            return
        case 401:
            // 尝试解析 401 错误的详细信息
            if let errorString = String(data: data, encoding: .utf8) {
                #if DEBUG
                print("❌ [Local API] 401 Response: \(errorString)")
                #endif
            }
            throw NetworkError.unauthorized
        case 403:
            throw NetworkError.forbidden
        case 404:
            throw NetworkError.notFound
        case 500...599:
            // 尝试解析错误信息
            if let error = try? JSONDecoder().decode(LocalAPIError.self, from: data) {
                throw NetworkError.serverErrorWithMessage(error.message)
            }
            throw NetworkError.serverError(statusCode)
        default:
            throw NetworkError.serverError(statusCode)
        }
    }
    
    private func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        do {
            let decoder = JSONDecoder()
            // 处理未知枚举值
            decoder.keyDecodingStrategy = .useDefaultKeys
            return try decoder.decode(T.self, from: data)
        } catch let DecodingError.keyNotFound(key, context) {
            #if DEBUG
            print("❌ [Local API] Missing key: \(key.stringValue)")
            print("   Path: \(context.codingPath.map { $0.stringValue })")
            print("   Debug: \(context.debugDescription)")
            #endif
            throw NetworkError.decodingError(DecodingError.keyNotFound(key, context))
        } catch let DecodingError.typeMismatch(type, context) {
            #if DEBUG
            print("❌ [Local API] Type mismatch: expected \(type), got \(context.debugDescription)")
            print("   Path: \(context.codingPath.map { $0.stringValue })")
            if let string = String(data: data, encoding: .utf8) {
                print("📄 [Local API] Raw Data (first 2000 chars): \(string.prefix(2000))")
            }
            #endif
            throw NetworkError.decodingError(DecodingError.typeMismatch(type, context))
        } catch let DecodingError.valueNotFound(type, context) {
            #if DEBUG
            print("❌ [Local API] Value not found: \(type) at \(context.codingPath.map { $0.stringValue })")
            #endif
            throw NetworkError.decodingError(DecodingError.valueNotFound(type, context))
        } catch let DecodingError.dataCorrupted(context) {
            #if DEBUG
            print("❌ [Local API] Data corrupted: \(context.debugDescription)")
            print("   Path: \(context.codingPath.map { $0.stringValue })")
            if let string = String(data: data, encoding: .utf8) {
                print("📄 [Local API] Raw Data: \(string)")
            }
            #endif
            throw NetworkError.decodingError(DecodingError.dataCorrupted(context))
        } catch {
            #if DEBUG
            print("❌ [Local API] Decoding Error: \(error)")
            if let string = String(data: data, encoding: .utf8) {
                print("📄 [Local API] Raw Data (first 3000 chars): \(string.prefix(3000))")
            }
            #endif
            throw NetworkError.decodingError(error)
        }
    }
}

// MARK: - 局域网 API 错误

struct LocalAPIError: Codable {
    let statusCode: Int?
    let statusName: String?
    let code: String?
    let message: String
    let timestamp: String?
    let requestPath: String?
    let requestId: String?
}
