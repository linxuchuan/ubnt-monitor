import Foundation
import Combine

/// 云端设备列表 ViewModel
/// 仅用于互联网模式（云端 API）
@MainActor
final class DeviceListViewModel: ObservableObject {
    @Published private(set) var devices: [UbiquitiDevice] = []
    @Published private(set) var state: ViewState = .idle
    @Published var errorMessage: String?
    
    private let apiService: UbiquitiAPIServiceProtocol
    
    enum ViewState: Equatable {
        case idle
        case loading
        case loaded
        case error(NetworkError)
        
        static func == (lhs: ViewState, rhs: ViewState) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle), (.loading, .loading), (.loaded, .loaded):
                return true
            case (.error(let lhsError), .error(let rhsError)):
                return lhsError.localizedDescription == rhsError.localizedDescription
            default:
                return false
            }
        }
    }
    
    var isLoading: Bool { 
        if case .loading = state { return true }
        return false
    }
    var hasError: Bool { 
        if case .error = state { return true }
        return false
    }
    
    init(apiService: UbiquitiAPIServiceProtocol = UbiquitiAPIService.shared) {
        self.apiService = apiService
    }
    
    func loadDevices() async {
        guard state != .loading else { return }
        
        state = .loading
        errorMessage = nil
        
        do {
            let fetchedDevices = try await apiService.fetchDevices(pageSize: 50, nextToken: nil)
            devices = fetchedDevices
            state = .loaded
        } catch let error as NetworkError {
            state = .error(error)
            errorMessage = error.localizedDescription
        } catch {
            let networkError = NetworkError.unknown(error)
            state = .error(networkError)
            errorMessage = networkError.localizedDescription
        }
    }
    
    func refresh() async {
        await loadDevices()
    }
}
