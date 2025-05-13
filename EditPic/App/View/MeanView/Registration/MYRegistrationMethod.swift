
import SwiftUI

struct MYRegistrationMethod: View {
        
    @StateObject private var viewModel = MYAuthenticationViewModel()
    
    @State private var isUserLoggedIn = true
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                VStack {
                    if isUserLoggedIn {
                        Button {
                            viewModel.loginWithoutRegistration()
                        } label: {
                            MYLoginView(
                                text: "Продолжить без регистрации",
                                image: Image("")
                            )
                        }
                        NavigationLink {
                            MYLoginEmailController()
                        } label: {
                            MYLoginView(
                                text: "Войдите с email",
                                image: Image(systemName: "person")
                            )
                        }
                    } else {
                        MYTextFieldView("Введите имя", text: $name)
                        MYLoginEmailView(email: $email, password: $password) {
                            if name.isEmpty {
                                viewModel.showEmptyNameWarning()
                            } else {
                                viewModel.tryRegister(email: email, password: password)
                            }
                        }
                    }
                    Button {
                        MYGoogleSignInHelper.shared.signIn { result in
                            DispatchQueue.main.async {
                                viewModel.handleGoogleSignInResult(result)
                            }
                        }
                    } label: {
                        MYLoginView(
                            text: "Продолжить с google",
                            image: Image("ios_neutral_rd_na")
                        )
                    }
                }
                .padding()
                Spacer()
                Button {
                    withAnimation {
                        isUserLoggedIn.toggle()
                    }
                } label: {
                    Text(isUserLoggedIn ? "Еще нет аккаунта?" : "Уже есть аккаунт?")
                }
                .padding()
                .tint(Color.secondary)
                .frame(maxWidth: .infinity)
                .background {
                    MYDefaultSetting.backgroundColor
                        .ignoresSafeArea()
                }
            }
            .myAlertPresenter(error: viewModel.alertError)
            .navigationTitle(Text(isUserLoggedIn ? "Вход" : "Регистрация"))
        }
    }
    
    
}

#Preview {
    MYRegistrationMethod()
}
