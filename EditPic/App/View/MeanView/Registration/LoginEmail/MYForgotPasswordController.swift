
import SwiftUI

struct MYForgotPasswordController: View {
    
    @Binding var email: String
    @StateObject private var viewModel = MYAuthenticationViewModel()
    @EnvironmentObject var alertManager: MYAlertManager
    
    var body: some View {
        VStack {
            MYTextFieldView("Введите ваш email", text: $email)
                .keyboardType(.emailAddress)
            
            MYConditionalButtonView("Продолжить", showButton: MYEmailManager.shared.isEmailValid(email)) {
                Task {
                    do {
                        try await viewModel.tryChangePassword(email: email)
                    } catch {
                        
                        alertManager.alertError = (error as? MYAlertError)
                    }
                }
            }
        }
        .navigationTitle("Восстановление пароля")
        .padding()
    }
}

#Preview {
    MYForgotPasswordController(email: .constant(""))
}
