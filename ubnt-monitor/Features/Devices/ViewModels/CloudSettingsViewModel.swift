import Foundation
import Combine

/// 云端设置 ViewModel
@MainActor
final class CloudSettingsViewModel: ObservableObject {
    @Published var apiKey: String = ""
    @Published var isTestingConnection = false
    @Published var testResult: TestResult?
    
    private let apiService: UbiquitiAPIServiceProtocol
    
    var canSave: Bool {
        !apiKey.isEmpty
    }
    
    init(apiService: UbiquitiAPIServiceProtocol = UbiquitiAPIService.shared) {
        self.apiService = apiService
        self.apiKey = CloudAPIConfig.apiKey
    }
    
    func save() {
        CloudAPIConfig.apiKey = apiKey
    }
    
    func testConnection() async {
        isTestingConnection = true
        testResult = nil
        
        // 临时保存当前 API Key 用于测试
        let originalKey = CloudAPIConfig.apiKey
        CloudAPIConfig.apiKey = apiKey
        
        defer {
            CloudAPIConfig.apiKey = originalKey
            isTestingConnection = false
        }
        
        do {
            _ = try await apiService.fetchDevices(pageSize: 1, nextToken: nil)
            testResult = .success
        } catch let error as NetworkError {
            testResult = .failure(error.localizedDescription)
        } catch {
            testResult = .failure(error.localizedDescription)
        }
    }
}
