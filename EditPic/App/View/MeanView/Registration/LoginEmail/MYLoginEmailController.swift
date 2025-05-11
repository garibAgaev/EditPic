
import SwiftUI

struct MYLoginEmailController: View {
    
    @StateObject private var viewModel = MYAuthenticationViewModel()
    @State private var email: String = ""
    @State private var forgotEmail: String = ""
    @State private var password: String = ""
    @State private var showForgotPassword = false
    
    var body: some View {
        VStack {
            MYLoginEmailView(email: $email, password: $password) {
                viewModel.fetchUser(email: email, password: password)
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
        .myAlertPresenter(error: viewModel.alertError)
        .navigationTitle("Вход")
    }
    
}

#Preview {
    MYLoginEmailController()
}
