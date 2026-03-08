import Foundation

protocol UbiquitiAPIServiceProtocol {
    func fetchDevices(pageSize: Int, nextToken: String?) async throws -> [UbiquitiDevice]
    func fetchDeviceDetails(hostIds: [String], pageSize: Int, nextToken: String?) async throws -> [HostDevices]
}

final class UbiquitiAPIService: UbiquitiAPIServiceProtocol, @unchecked Sendable {
    nonisolated static let shared = UbiquitiAPIService()
    
    private init() {}
    
    // MARK: - Public Methods
    
    func fetchDevices(pageSize: Int = 10, nextToken: String? = nil) async throws -> [UbiquitiDevice] {
        try validateAPIKey()
        
        let url = try buildURL(endpoint: "/hosts", pageSize: pageSize, nextToken: nextToken)
        let data = try await performRequest(url: url)
        
        return try decodeResponse(UbiquitiDeviceListResponse.self, from: data).data
    }
    
    func fetchDeviceDetails(
        hostIds: [String] = [],
        pageSize: Int = 50,
        nextToken: String? = nil
    ) async throws -> [HostDevices] {
        try validateAPIKey()
        
        var urlComponents = try buildURLComponents(endpoint: "/devices", pageSize: pageSize, nextToken: nextToken)
        
        if !hostIds.isEmpty {
            let hostIdItems = hostIds.map { URLQueryItem(name: "hostIds[]", value: $0) }
            urlComponents.queryItems?.append(contentsOf: hostIdItems)
        }
        
        guard let url = urlComponents.url else {
            throw NetworkError.invalidURL
        }
        
        let data = try await performRequest(url: url)
        return try decodeResponse(DeviceDetailResponse.self, from: data).data
    }
    
    // MARK: - Private Methods
    
    private func validateAPIKey() throws {
        guard !APIConfig.apiKey.isEmpty else {
            throw NetworkError.apiKeyMissing
        }
    }
    
    private func buildURL(endpoint: String, pageSize: Int, nextToken: String?) throws -> URL {
        var components = try buildURLComponents(endpoint: endpoint, pageSize: pageSize, nextToken: nextToken)
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        return url
    }
    
    private func buildURLComponents(endpoint: String, pageSize: Int, nextToken: String?) throws -> URLComponents {
        guard var components = URLComponents(string: APIConfig.baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }
        
        var queryItems = [URLQueryItem(name: "pageSize", value: "\(pageSize)")]
        if let nextToken = nextToken {
            queryItems.append(URLQueryItem(name: "nextToken", value: nextToken))
        }
        components.queryItems = queryItems
        
        return components
    }
    
    private func performRequest(url: URL) async throws -> Data {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(APIConfig.apiKey, forHTTPHeaderField: "X-API-Key")
        
        #if DEBUG
        print("📡 Request: \(url.absoluteString)")
        #endif
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        #if DEBUG
        print("📥 Response Status: \(httpResponse.statusCode)")
        #endif
        
        try handleHTTPStatus(httpResponse.statusCode)
        
        return data
    }
    
    private func handleHTTPStatus(_ statusCode: Int) throws {
        switch statusCode {
        case 200...299:
            return
        case 401:
            throw NetworkError.unauthorized
        case 403:
            throw NetworkError.forbidden
        case 404:
            throw NetworkError.notFound
        case 429:
            throw NetworkError.rateLimited
        case 500...599:
            throw NetworkError.serverError(statusCode)
        default:
            throw NetworkError.serverError(statusCode)
        }
    }
    
    private func decodeResponse<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}
