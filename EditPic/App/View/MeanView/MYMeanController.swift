
import SwiftUI

struct MYMeanController: View {
    
    @AppStorage("isLoggedIn") private var isLoggedIn = false
        
    var body: some View {
        Group {
            if isLoggedIn {
                ImageEditorView()
            } else {
                MYRegistrationMethod()
            }
        }
        .onAppear {
            isLoggedIn = false
        }
    }
}


#Preview {
    MYMeanController()
}
