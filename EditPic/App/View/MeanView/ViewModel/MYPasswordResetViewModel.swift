
import SwiftUI

@MainActor
class MYAuthenticationViewModel: ObservableObject {
    @AppStorage("isLoggedIn") var isLoggedIn = false

    @Published var showAlert = false
    
    func tryChangePassword(email: String) {
        Task {
            if await !checkIfEmailExistsInDatabase(email: email) { return }
            if await !checkIfEmailIsValid(email: email) { return }
            await sendNewPassword(to: email)
        }
    }
    
    func tryRegister(email: String, password: String) {
        Task {
            guard await checkIfEmailIsValid(email: email) else { return }

            let emailSent = await sendWelcomeEmail(to: email)
            guard emailSent else { return }

            await registerUser(email: email, password: password)
        }
    }
    
    func handleGoogleSignInResult(_ result: MYSignInResult) {
        switch result {
        case .success(let user):
            handleGoogleSignIn(googleUser: user)
        case .noUser:
            showAlert(
                title: "Пользователь не найден",
                message: "Пользователь с таким email не найден в системе. Попробуйте использовать другой email или зарегистрируйтесь."
            )
        case .failure(let error):
            switch error {
            case .missingRootViewController:
                showAlert(
                    title: "Ошибка",
                    message: "Не удалось выполнить вход. Попробуйте позже."
                )
            case .signInFailed(underlying: _):
                showAlert(
                    title: "Ошибка авторизации",
                    message: "Не удалось авторизоваться через Google. Попробуйте еще раз."
                )
            }
        }
    }
    
    func fetchUser(email: String, password: String) {
        Task {
            do {
                if try await MYPersistenceController.shared.fetchUser(email: email, password: password) != nil {
                    isLoggedIn = true
                    return
                }
                makeLoginError()
            } catch {
                makeLoginError()
            }
        }
    }
    
    func showEmptyNameWarning() {
        showAlert(
            title: "Сообщение",
            message: "Имя не должно быть пустым"
        )
    }

    func loginWithoutRegistration() {
        Task { @MainActor in
            isLoggedIn = true
        }
    }
    
    private func handleGoogleSignIn(googleUser: MYGoogleSignInUser) {
        Task {
            guard let email = googleUser.email else {
                showAlert(
                    title: "Ошибка авторизации",
                    message: "Не удалось получить email. Попробуйте авторизоваться через Google еще раз."
                )
                return
            }

            let exists = await doesEmailExist(email)
            if exists {
                await MainActor.run { isLoggedIn = true }
                return
            }

            guard let idToken = googleUser.idToken else {
                showAlert(
                    title: "Ошибка авторизации",
                    message: "Не удалось получить токен пользователя. Попробуйте авторизоваться еще раз."
                )
                return
            }

            await registerGoogleUser(email: email, idToken: idToken)
        }
    }


    private func doesEmailExist(_ email: String) async -> Bool {
        do {
            return try await MYPersistenceController.preview.doesEmailExist(email)
        } catch {
            showAlert(
                title: "Ошибка авторизации",
                message: "Не удалось проверить данные пользователя. Пожалуйста, повторите попытку позже."
            )
            return false
        }
    }

    private func registerGoogleUser(email: String, idToken: String) async {
        do {
            try await MYPersistenceController.preview.addUser(email: email, name: idToken)
            await MainActor.run {
                isLoggedIn = true
            }
        } catch {
            showAlert(title: "Ошибка регистрации", message: "Произошла ошибка при регистрации пользователя. Пожалуйста, повторите попытку позже."
            )
        }
    }

    private func sendWelcomeEmail(to email: String) async -> Bool {
        do {
            _ = try await MYMailgunAPI.shared.sendEmail(
                to: email,
                subject: "Добро пожаловать!",
                body: "Спасибо за регистрацию!"
            )
            return true
        } catch {
            showAlert(
                title: "Ошибка отправки",
                message: "Сообщение не было отправлено. Повторите попытку позже."
            )
            return false
        }
    }

    private func registerUser(email: String, password: String) async {
        do {
            try await MYPersistenceController.shared.addUser(email: email, password: password)
            await MainActor.run {
                isLoggedIn = true
            }
        } catch {
            showAlert(
                title: "Ошибка регистрации",
                message: "К сожалению, мы не смогли завершить регистрацию. Повторите попытку позже."
            )
        }
    }
    
    private func checkIfEmailExistsInDatabase(email: String) async -> Bool {
        do {
            let exists = try await MYPersistenceController.preview.doesEmailExist(email)
            if !exists {
                showAlert(
                    title: "Пользователь не найден",
                    message: "К сожалению, пользователь с таким email не найден. Пожалуйста, проверьте правильность ввода или зарегистрируйтесь."
                )
                return false
            }
            return true
        } catch {
            showAlert(
                title: "Ошибка системы",
                message: "Произошла ошибка при проверке email. Повторите попытку позже."
            )
            return false
        }
    }
    
    private func checkIfEmailIsValid(email: String) async -> Bool {
        do {
            _ = try await MYMailgunAPI.shared.checkEmailExists(email: email)
            return true
        } catch {
            showAlert(
                title: "Неверный Email",
                message: "Указанный email недействителен или не существует. Пожалуйста, проверьте правильность ввода."
            )
            return false
        }
    }
    
    private func sendNewPassword(to email: String) async {
        do {
            let password = MYPasswordManager.shared.generateRandomPassword()
            _ = try await MYMailgunAPI.shared.sendEmail(
                to: email,
                subject: "Ваш новый пароль:",
                body: password
            )
            showAlert(
                title: "Регистрация завершена",
                message: "Добро пожаловать! Ваша регистрация прошла успешно."
            )
        } catch {
            showAlert(
                title: "Ошибка отправки",
                message: "Сообщение не было отправлено. Повторите попытку позже."
            )
        }
    }
    
    private func makeLoginError() {
        showAlert(
            title: "Ошибка входа",
            message: "Не удалось выполнить вход. Проверьте email и пароль, и попробуйте снова."
        )
    }
    
    @MainActor
    private func showAlert(title: String, message: String) {
        showAlert = true
        MYAlertManager.shared.alertError = MYAlertError(
            title: title,
            message: message,
            primaryButton: MYAlertButton(title: "ОК", role: .cancel)
        )
    }
}

