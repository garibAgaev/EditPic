

import Foundation

class MYPasswordManager {
    static let shared = MYPasswordManager()
    
    let defaultPasswordCount = 6
    
    func isPasswordValid(_ password: String) -> Bool {
        password.count >= defaultPasswordCount
    }
    
    func generateRandomPassword() -> String {
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let password: [Character] = (0..<4 * defaultPasswordCount)
            .compactMap { _ in
                characters.randomElement()
            }
        return String(password)
    }
    
    private init() {}
}
