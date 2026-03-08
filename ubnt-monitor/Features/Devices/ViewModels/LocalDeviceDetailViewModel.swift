import Foundation
import Combine

/// 局域网设备详情 ViewModel
@MainActor
final class LocalDeviceDetailViewModel: ObservableObject {
    @Published private(set) var device: LocalDevice
    @Published private(set) var statistics: LocalDeviceStatistics?
    @Published private(set) var isLoading = false
    @Published private(set) var isLoadingStats = false
    @Published var errorMessage: String?
    @Published var showRestartConfirmation = false
    @Published var showRestartSuccess = false
    @Published var showRestartError = false
    
    private let apiService: LocalAPIServiceProtocol
    private let siteId: String
    
    init(device: LocalDevice, siteId: String, apiService: LocalAPIServiceProtocol = LocalAPIService.shared) {
        self.device = device
        self.siteId = siteId
        self.apiService = apiService
    }
    
    // MARK: - 加载设备详情
    
    func loadDeviceDetail() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let detail = try await apiService.getDeviceDetail(siteId: siteId, deviceId: device.id)
            device = detail
        } catch let error as NetworkError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - 加载统计信息
    
    func loadStatistics() async {
        isLoadingStats = true
        
        do {
            let stats = try await apiService.getDeviceStatistics(siteId: siteId, deviceId: device.id)
            statistics = stats
        } catch {
            // 统计信息加载失败不影响主页面
            print("Failed to load statistics: \(error)")
        }
        
        isLoadingStats = false
    }
    
    // MARK: - 执行设备动作
    
    func restartDevice() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await apiService.executeDeviceAction(siteId: siteId, deviceId: device.id, action: .restart)
            showRestartSuccess = true
        } catch let error as NetworkError {
            errorMessage = error.localizedDescription
            showRestartError = true
        } catch {
            errorMessage = error.localizedDescription
            showRestartError = true
        }
        
        isLoading = false
    }
    
    // MARK: - 端口 PoE 供电循环
    
    func powerCyclePort(portIdx: Int) async {
        isLoading = true
        
        do {
            try await apiService.executePortAction(siteId: siteId, deviceId: device.id, portIdx: portIdx, action: .powerCycle)
            // 刷新设备详情
            await loadDeviceDetail()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
