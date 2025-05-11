
import Foundation

enum MYMailgunAPIError: Error {
    case authorizationFailed
    case jsonParsingError
    case invalidResponse
    case serverError
    case responseParseError
}
