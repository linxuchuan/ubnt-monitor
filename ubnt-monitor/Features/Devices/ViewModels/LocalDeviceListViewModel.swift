import Foundation
import Combine

/// 局域网设备列表 ViewModel
@MainActor
final class LocalDeviceListViewModel: ObservableObject {
    @Published private(set) var sites: [LocalSite] = []
    @Published private(set) var devices: [LocalDevice] = []
    @Published private(set) var state: ViewState = .idle
    @Published private(set) var selectedSiteId: String?
    @Published var errorMessage: String?
    @Published var showTestResult = false
    @Published var testResultMessage = ""
    @Published var isLoading = false
    @Published var showSitePicker = false
    
    private let apiService: LocalAPIServiceProtocol
    
    enum ViewState: Equatable {
        case idle
        case loading
        case loaded
        case error(NetworkError)
        case noSites
        
        static func == (lhs: ViewState, rhs: ViewState) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle), (.loading, .loading), (.loaded, .loaded), (.noSites, .noSites):
                return true
            case (.error(let lhsError), .error(let rhsError)):
                return lhsError.localizedDescription == rhsError.localizedDescription
            default:
                return false
            }
        }
    }
    
    var isLoadingDevices: Bool { 
        if case .loading = state { return true }
        return false
    }
    
    init(apiService: LocalAPIServiceProtocol = LocalAPIService.shared) {
        self.apiService = apiService
    }
    
    // MARK: - 加载站点列表
    
    func loadSites() async {
        guard state != .loading else {
            #if DEBUG
            print("⚠️ [Local VM] loadSites() skipped, already loading")
            #endif
            return
        }
        
        #if DEBUG
        print("📱 [Local VM] Starting loadSites()...")
        print("🔗 [Local VM] Base URL: \(LocalAPIConfig.baseURL)")
        print("🔑 [Local VM] API Key set: \(!LocalAPIConfig.apiKey.isEmpty)")
        #endif
        
        state = .loading
        errorMessage = nil
        
        do {
            #if DEBUG
            print("📡 [Local VM] Fetching sites...")
            #endif
            
            let fetchedSites = try await apiService.getSites()
            
            #if DEBUG
            print("✅ [Local VM] Got \(fetchedSites.count) sites")
            for site in fetchedSites {
                print("   - Site: \(site.name) (ID: \(site.id))")
            }
            #endif
            
            sites = fetchedSites
            
            if fetchedSites.isEmpty {
                #if DEBUG
                print("⚠️ [Local VM] No sites found")
                #endif
                state = .noSites
                errorMessage = "没有找到站点"
            } else {
                // 自动选择第一个站点
                if let firstSite = fetchedSites.first {
                    selectedSiteId = firstSite.id
                    #if DEBUG
                    print("🎯 [Local VM] Auto-selected site: \(firstSite.name)")
                    print("📡 [Local VM] Now loading devices for site: \(firstSite.id)")
                    #endif
                    
                    // 直接在这里加载设备，不再检查 state
                    await loadDevicesInternal(siteId: firstSite.id)
                }
            }
        } catch let error as NetworkError {
            #if DEBUG
            print("❌ [Local VM] NetworkError: \(error)")
            #endif
            state = .error(error)
            switch error {
            case .unauthorized:
                errorMessage = "API Key 无效或已过期\n\n请检查：\n1. API Key 使用 X-API-KEY 格式\n2. 在 UniFi 控制台重新生成 API Key\n3. 在设置中更新 API Key"
            case .notFound:
                errorMessage = "API 端点未找到\n\n请检查 URL 格式是否正确\n示例: https://192.168.0.1"
            case .decodingError:
                errorMessage = "数据解析失败\n\n请检查：\n1. UniFi 控制器版本是否支持 API\n2. 查看 Xcode 控制台获取详细错误信息"
            default:
                errorMessage = error.localizedDescription
            }
        } catch {
            #if DEBUG
            print("❌ [Local VM] Unknown error: \(error)")
            #endif
            let networkError = NetworkError.unknown(error)
            state = .error(networkError)
            errorMessage = networkError.localizedDescription
        }
    }
    
    // MARK: - 加载设备列表（公开方法）
    
    func loadDevices(siteId: String? = nil) async {
        let targetSiteId = siteId ?? selectedSiteId
        
        guard let targetSiteId = targetSiteId else {
            #if DEBUG
            print("⚠️ [Local VM] No siteId, loading sites first")
            #endif
            await loadSites()
            return
        }
        
        await loadDevicesInternal(siteId: targetSiteId)
    }
    
    // MARK: - 加载设备列表（内部方法）
    
    private func loadDevicesInternal(siteId: String) async {
        #if DEBUG
        print("📡 [Local VM] Loading devices for site: \(siteId)")
        #endif
        
        selectedSiteId = siteId
        // 注意：这里不检查 state，因为可能从 loadSites() 调用，此时 state 还是 .loading
        errorMessage = nil
        
        do {
            let fetchedDevices = try await apiService.getDevices(siteId: siteId)
            
            #if DEBUG
            print("✅ [Local VM] Got \(fetchedDevices.count) devices")
            for device in fetchedDevices.prefix(5) {
                print("   - Device: \(device.name ?? device.model) (State: \(device.state))")
            }
            if fetchedDevices.count > 5 {
                print("   ... and \(fetchedDevices.count - 5) more")
            }
            #endif
            
            devices = fetchedDevices
            state = .loaded
            
            #if DEBUG
            print("✅ [Local VM] State changed to loaded")
            #endif
        } catch let error as NetworkError {
            #if DEBUG
            print("❌ [Local VM] Failed to load devices: \(error)")
            #endif
            state = .error(error)
            switch error {
            case .decodingError:
                errorMessage = "设备数据解析失败\n\n请查看 Xcode 控制台获取详细错误信息\n可能原因：\n1. UniFi 版本不兼容\n2. 数据格式不匹配"
            default:
                errorMessage = error.localizedDescription
            }
        } catch {
            #if DEBUG
            print("❌ [Local VM] Failed to load devices: \(error)")
            #endif
            let networkError = NetworkError.unknown(error)
            state = .error(networkError)
            errorMessage = networkError.localizedDescription
        }
    }
    
    func refresh() async {
        #if DEBUG
        print("🔄 [Local VM] Refreshing...")
        #endif
        // 重置状态以确保可以重新加载
        state = .idle
        await loadDevices()
    }
    
    /// 强制重置状态（用于卡在 loading 时）
    func resetState() {
        #if DEBUG
        print("🔄 [Local VM] Force reset state from \(state) to idle")
        #endif
        state = .idle
        errorMessage = nil
    }
    
    // MARK: - 选择站点
    
    func selectSite(_ site: LocalSite) {
        selectedSiteId = site.id
        Task {
            await loadDevices(siteId: site.id)
        }
    }
    
    // MARK: - 测试连接
    
    func testConnection() async {
        // 简单的配置验证
        if LocalAPIConfig.baseURL.isEmpty {
            testResultMessage = "❌ 路由器地址未设置"
            showTestResult = true
            return
        }
        if LocalAPIConfig.apiKey.isEmpty {
            testResultMessage = "❌ API Key 未设置"
            showTestResult = true
            return
        }
        
        isLoading = true
        
        #if DEBUG
        print("🧪 [Local VM] Testing connection...")
        print("🔗 URL: \(LocalAPIConfig.baseURL)")
        #endif
        
        do {
            let info = try await apiService.getApplicationInfo()
            testResultMessage = "✅ 连接成功！\n应用版本: \(info.applicationVersion)"
            
            #if DEBUG
            print("✅ [Local VM] Connection test passed, version: \(info.applicationVersion)")
            #endif
            
            // 如果连接成功，刷新站点和设备
            await loadSites()
        } catch let error as NetworkError {
            #if DEBUG
            print("❌ [Local VM] Connection test failed: \(error)")
            #endif
            testResultMessage = "❌ 连接失败\n\(error.localizedDescription)"
        } catch {
            #if DEBUG
            print("❌ [Local VM] Connection test failed: \(error)")
            #endif
            testResultMessage = "❌ 连接失败\n\(error.localizedDescription)"
        }
        
        isLoading = false
        showTestResult = true
    }
}
