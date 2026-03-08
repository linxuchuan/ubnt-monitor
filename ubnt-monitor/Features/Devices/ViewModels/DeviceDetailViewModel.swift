import Foundation
import Combine

@MainActor
final class DeviceDetailViewModel: ObservableObject {
    @Published private(set) var deviceDetails: [DeviceDetail] = []
    @Published private(set) var state: ViewState = .idle
    @Published var errorMessage: String?
    
    private let apiService: UbiquitiAPIServiceProtocol
    private let hostId: String
    
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
    var deviceCount: Int { deviceDetails.count }
    
    init(hostId: String, apiService: UbiquitiAPIServiceProtocol = UbiquitiAPIService.shared) {
        self.hostId = hostId
        self.apiService = apiService
    }
    
    func loadDeviceDetails() async {
        guard state != .loading else { return }
        
        state = .loading
        errorMessage = nil
        
        do {
            let hostDevices = try await apiService.fetchDeviceDetails(hostIds: [hostId], pageSize: 50, nextToken: nil)
            deviceDetails = hostDevices.flatMap { $0.devices }
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
        await loadDeviceDetails()
    }
}
