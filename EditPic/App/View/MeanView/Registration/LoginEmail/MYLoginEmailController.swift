
import SwiftUI

struct MYLoginEmailController: View {
    
    @StateObject private var viewModel = MYAuthenticationViewModel()
    @EnvironmentObject private var alertManager: MYAlertManager
    @State private var email: String = ""
    @State private var forgotEmail: String = ""
    @State private var password: String = ""
    @State private var showForgotPassword = false
    
    var body: some View {
        VStack {
            MYLoginEmailView(email: $email, password: $password) {
                Task {
                    do {
                        try await viewModel.fetchUser(email: email, password: password)
                    } catch {
                        alertManager.alertError = (error as? MYAlertError)
                    }
                }
            }
            .padding()
            
            Button("Забыли пароль?") {
                showForgotPassword = true
            }
            .tint(Color.secondary)
        }
        .mySheet(isPresented: $showForgotPassword) {
            email = forgotEmail
        } content: {
            MYForgotPasswordController(email: $forgotEmail)
        }
        .navigationTitle("Вход")
    }
    
}

#Preview {
    MYLoginEmailController()
}
