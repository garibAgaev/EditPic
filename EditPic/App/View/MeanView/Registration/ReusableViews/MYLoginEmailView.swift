
import SwiftUI

struct MYLoginEmailView: View {
    @Binding var email: String
    @Binding var password: String
    let action: () -> Void

    @AppStorage("isLoggedIn") var isLoggedIn = false
    
    @EnvironmentObject var showAlert: MYAlertManager

    var body: some View {
        VStack {
            VStack {
                MYTextFieldView("Email", text: $email)
                    .keyboardType(.emailAddress)
                
                SecureField("Пароль", text: $password)
                    .simultaneousGesture(
                        TapGesture().onEnded {
                            if password.isEmpty {
                                showAlert.alertError = MYAlertError(
                                    title: "Предупреждение",
                                    message: "Пароль должен содержать минимум \(MYPasswordManager.shared.defaultPasswordCount) символов.",
                                    primaryButton: MYAlertButton(title: "OK", role: .cancel)
                                )
                            }
                        }
                    )
                    .myDismissKeyboardOnTap()
                    .padding()
                    .background(MYDefaultStyle.backgroundColor)
                    .cornerRadius(MYDefaultStyle.cornerRadius)
            }
            .myDismissKeyboardOnTap()
            
            
            let isValid = MYEmailManager.shared.isEmailValid(email)
            && MYPasswordManager.shared.isPasswordValid(password)
            
            MYConditionalButtonView(
                "Продолжить",
                showButton: isValid,
                action: action
            )
        }
    }
    
    init(email: Binding<String>, password: Binding<String>, action: @escaping () -> Void = {}) {
        self._email = email
        self._password = password
        self.action = action
    }
}


#Preview {
    MYLoginEmailView(email: .constant(""), password: .constant(""))
}
