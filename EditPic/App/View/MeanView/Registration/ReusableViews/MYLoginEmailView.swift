
import SwiftUI

struct MYLoginEmailView: View {
    @Binding var email: String
    @Binding var password: String
    let action: () -> Void

    @AppStorage("isLoggedIn") var isLoggedIn = false
    
    @State private var alertError: MYAlertError?

    var body: some View {
        VStack {
            VStack {
                MYTextFieldView("Email", text: $email)
                    .keyboardType(.emailAddress)
                
                SecureField(
                    "Пароль",
                    text:
                        Binding(
                            get: { password },
                            set: { newValue in
                                if alertError == nil {
                                    alertError = MYAlertError(
                                        title: "Предупреждение",
                                        message: "Пароль должен содержать минимум \(MYPasswordManager.shared.defaultPasswordCount) символов.",
                                        primaryButton: MYAlertButton(title: "OK", role: .cancel)
                                    )
                                }
                                withAnimation {
                                    password = newValue
                                }
                            }
                        )
                )
                .myAlertPresenter(error: alertError)
                .myDismissKeyboardOnTap()
                .padding()
                .background(MYDefaultSetting.backgroundColor)
                .cornerRadius(MYDefaultSetting.cornerRadius)
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
