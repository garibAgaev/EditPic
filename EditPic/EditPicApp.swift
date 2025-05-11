
import SwiftUI

@main
struct EditPicApp: App {
    let persistenceController = MYPersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MYRootView {
                MYMeanController()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
        }
    }
}
