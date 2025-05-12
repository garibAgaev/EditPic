
import SwiftUI

struct MYForgotPasswordController: View {
    
    @Binding var email: String
    @StateObject private var viewModel = MYAuthenticationViewModel()
    
    var body: some View {
        VStack {
            MYTextFieldView("Введите ваш email", text: $email)
                .keyboardType(.emailAddress)
            
            MYConditionalButtonView("Продолжить", showButton: MYEmailManager.shared.isEmailValid(email)) {
                viewModel.tryChangePassword(email: email)
            }
        }
        .navigationTitle("Восстановление пароля")
        .myAlertPresenter(flag: viewModel.showAlert)
        .padding()
    }
}

#Preview {
    MYForgotPasswordController(email: .constant(""))
}
