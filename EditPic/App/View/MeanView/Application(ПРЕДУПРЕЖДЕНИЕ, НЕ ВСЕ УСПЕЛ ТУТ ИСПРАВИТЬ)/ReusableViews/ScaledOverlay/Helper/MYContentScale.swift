import Foundation

enum MYContentScale {
    case half
    case inscribedInCircle
    case full
    case custom(Double)
    
    var value: Double {
        switch self {
        case .half:
            return 0.5
        case .inscribedInCircle:
            return 0.5 * sqrt(2)
        case .full:
            return 1.0
        case .custom(let value):
            return value
        }
    }
}
