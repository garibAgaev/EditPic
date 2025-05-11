
import Foundation

enum MYSignInResult {
    case success(MYGoogleSignInUser)
    case failure(MYSignInError)
    case noUser
}
