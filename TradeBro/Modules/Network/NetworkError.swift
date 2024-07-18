import Foundation

enum NetworkError: Error {
    case linkError
    case serverError
    case noData
    case requestFailed
    case transportError(Error)
    case invalidResponse
    case validationError(String)
    case invalidChallengeCategory
    case needToFecthFoolballAgain

    var localizedDescription: String {
        switch self {
        case .noData:
            return AppText.NetworkErrorMessages.invalidData.rawValue
        case .requestFailed:
            return AppText.NetworkErrorMessages.requestFailed.rawValue
        case .serverError:
            return AppText.NetworkErrorMessages.responseUnsuccessful.rawValue
        case .linkError:
            return AppText.NetworkErrorMessages.invalidLink.rawValue
        case .transportError(let error):
            return "\(AppText.NetworkErrorMessages.transportError.rawValue)\(error.localizedDescription)"
        case .invalidResponse:
            return AppText.NetworkErrorMessages.invalidResponse.rawValue
        case .validationError(let reason):
            return "\(AppText.NetworkErrorMessages.validationError.rawValue)\(reason)"
        case .invalidChallengeCategory:
            return AppText.NetworkErrorMessages.invalidChallengeCategory.rawValue
        case .needToFecthFoolballAgain:
            return AppText.NetworkErrorMessages.needToFecthFoolballAgain.rawValue
        }
    }
}
