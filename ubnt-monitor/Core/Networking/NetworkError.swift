import Foundation

enum NetworkError: LocalizedError, Equatable {
    case invalidURL
    case invalidResponse
    case unauthorized
    case forbidden
    case notFound
    case rateLimited
    case serverError(Int)
    case serverErrorWithMessage(String)
    case decodingError(Error)
    case apiKeyMissing
    case configurationMissing(field: String)
    case unknown(Error)
    
    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.invalidResponse, .invalidResponse),
             (.unauthorized, .unauthorized),
             (.forbidden, .forbidden),
             (.notFound, .notFound),
             (.rateLimited, .rateLimited),
             (.apiKeyMissing, .apiKeyMissing):
            return true
        case (.serverError(let lhsCode), .serverError(let rhsCode)):
            return lhsCode == rhsCode
        case (.serverErrorWithMessage(let lhsMsg), .serverErrorWithMessage(let rhsMsg)):
            return lhsMsg == rhsMsg
        case (.configurationMissing(let lhsField), .configurationMissing(let rhsField)):
            return lhsField == rhsField
        case (.decodingError, .decodingError),
             (.unknown, .unknown):
            // Error 类型无法比较，视为不相等
            return false
        default:
            return false
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .unauthorized:
            return "Unauthorized. Please check your API key."
        case .forbidden:
            return "Forbidden. Your API key may not have sufficient permissions."
        case .notFound:
            return "Not Found. The requested resource does not exist."
        case .rateLimited:
            return "Rate Limit Exceeded. Please wait before retrying."
        case .serverError(let code):
            return "Server Error (\(code)). An unexpected error occurred."
        case .serverErrorWithMessage(let message):
            return "Server Error: \(message)"
        case .decodingError:
            return "Failed to parse response data."
        case .apiKeyMissing:
            return "API Key is not set. Please configure it in settings."
        case .configurationMissing(let field):
            return "\(field) 未设置，请先在设置中配置。"
        case .unknown(let error):
            return error.localizedDescription
        }
    }
    
    var isRetryable: Bool {
        switch self {
        case .rateLimited, .serverError:
            return true
        default:
            return false
        }
    }
}
