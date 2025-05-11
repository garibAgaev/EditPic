
import Foundation

class MYEmailManager {
    static let shared = MYEmailManager()
    
    func isEmailValid(_ email: String) -> Bool {
        email.contains(/^(?=.{1,254}$)(?=.{1,64}@)[a-zA-Z0-9!#$%&'*+\/=?^_`{|}~-]+(?:\.[a-zA-Z0-9!#$%&'*+\/=?^_`{|}~-]+)*@(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$/)
    }
    
    private init() {}
}
