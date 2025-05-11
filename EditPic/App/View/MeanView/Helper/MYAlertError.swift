
import SwiftUI

struct MYAlertError: Equatable, Identifiable {
    let id = UUID()

    let title: String
    let message: String
    let primaryButton: MYAlertButton
    let secondaryButton: MYAlertButton?
    
    init(
        title: String,
        message: String,
        primaryButton: MYAlertButton,
        secondaryButton: MYAlertButton? = nil
    ) {
        self.title = title
        self.message = message
        self.primaryButton = primaryButton
        self.secondaryButton = secondaryButton
    }
    
    nonisolated
    static func == (lhs: MYAlertError, rhs: MYAlertError) -> Bool {
        lhs.id == rhs.id
    }
}
