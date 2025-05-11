
import Foundation

enum MYSignInError: Error {
    case missingRootViewController
    case signInFailed(underlying: Error)
    
    var localizedDescription: String {
        switch self {
        case .missingRootViewController:
            return "Не удалось получить rootViewController"
        case .signInFailed(let error):
            return "Ошибка входа: \(error.localizedDescription)"
        }
    }
}
