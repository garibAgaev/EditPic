
import Foundation
import GoogleSignIn
import GoogleSignInSwift

final class MYGoogleSignInHelper {
    static let shared = MYGoogleSignInHelper()
    
    func signIn(completion: @escaping (MYSignInResult) -> Void) {
        guard let rootViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?
            .windows.first(where: { $0.isKeyWindow })?.rootViewController else {
            completion(.failure(.missingRootViewController))
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
            if let error = error {
                completion(.failure(.signInFailed(underlying: error)))
                return
            }
            
            guard let user = result?.user else {
                completion(.noUser)
                return
            }
            
            let userInfo = MYGoogleSignInUser(
                email: user.profile?.email,
                name: user.profile?.name,
                idToken: user.idToken?.tokenString
            )
            
            completion(.success(userInfo))
        }
    }
    
    private init() {}
}
