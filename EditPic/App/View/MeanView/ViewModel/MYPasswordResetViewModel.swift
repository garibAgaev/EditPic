
import SwiftUI

@MainActor
class MYAuthenticationViewModel: ObservableObject {
    @AppStorage("isLoggedIn") var isLoggedIn = false
    
    func tryChangePassword(email: String) async throws {
        try await checkIfEmailExistsInDatabase(email: email) // ?
        try await checkIfEmailIsValid(email: email) // ?
        try await sendNewPassword(to: email)
    }
    
    func tryRegister(email: String, password: String) async throws {
        try await checkIfEmailIsValid(email: email)
        
        try await sendWelcomeEmail(to: email)
        
        try await registerUser(email: email, password: password)
    }
    
    func handleGoogleSignInResult(_ result: MYSignInResult) async throws {
        switch result {
        case .success(let user):
            try await handleGoogleSignIn(googleUser: user)
        case .noUser:
            try showAlert(
                title: "Пользователь не найден",
                message: "Пользователь с таким email не найден в системе. Попробуйте использовать другой email или зарегистрируйтесь."
            )
        case .failure(let error):
            switch error {
            case .missingRootViewController:
                try showAlert(
                    title: "Ошибка",
                    message: "Не удалось выполнить вход. Попробуйте позже."
                )
            case .signInFailed(underlying: _):
                try showAlert(
                    title: "Ошибка авторизации",
                    message: "Не удалось авторизоваться через Google. Попробуйте еще раз."
                )
            }
        }
    }
    
    func fetchUser(email: String, password: String) async throws {
        do {
            if try await MYPersistenceController.shared.fetchUser(email: email, password: password) != nil {
                loginWithoutRegistration()
                return
            }
            try makeLoginError()
        } catch {
            try makeLoginError()
        }
    }
    
    func showEmptyNameWarning() throws {
        try showAlert(
            title: "Сообщение",
            message: "Имя не должно быть пустым"
        )
    }

    func loginWithoutRegistration() {
        Task { @MainActor in
            isLoggedIn = true
        }
    }
    
    private func handleGoogleSignIn(googleUser: MYGoogleSignInUser) async throws {
        guard let email = googleUser.email else {
            try showAlert(
                title: "Ошибка авторизации",
                message: "Не удалось получить email. Попробуйте авторизоваться через Google еще раз."
            )
            return
        }
        
        let exists = try await doesEmailExist(email)
        if exists {
            loginWithoutRegistration()
            return
        }

        guard let idToken = googleUser.idToken else {
            try showAlert(
                title: "Ошибка авторизации",
                message: "Не удалось получить токен пользователя. Попробуйте авторизоваться еще раз."
            )
            return
        }
        
        try await registerGoogleUser(email: email, idToken: idToken)
    }


    private func doesEmailExist(_ email: String) async throws -> Bool {
        do {
            return try await MYPersistenceController.preview.doesEmailExist(email)
        } catch {
            try showAlert(
                title: "Ошибка авторизации",
                message: "Не удалось проверить данные пользователя. Пожалуйста, повторите попытку позже."
            )
            return false
        }
    }

    private func registerGoogleUser(email: String, idToken: String) async throws {
        do {
            try await MYPersistenceController.preview.addUser(email: email, name: idToken)
            await MainActor.run {
                isLoggedIn = true
            }
        } catch {
            try showAlert(title: "Ошибка регистрации", message: "Произошла ошибка при регистрации пользователя. Пожалуйста, повторите попытку позже."
            )
        }
    }

    private func sendWelcomeEmail(to email: String) async throws {
        do {
            _ = try await MYMailgunAPI.shared.sendEmail(
                to: email,
                subject: "Добро пожаловать!",
                body: "Спасибо за регистрацию!"
            )
        } catch {
            try showAlert(
                title: "Ошибка отправки",
                message: "Сообщение не было отправлено. Повторите попытку позже."
            )
        }
    }

    private func registerUser(email: String, password: String) async throws {
        do {
            try await MYPersistenceController.shared.addUser(email: email, password: password)
            await MainActor.run {
                isLoggedIn = true
            }
        } catch {
            try showAlert(
                title: "Ошибка регистрации",
                message: "К сожалению, мы не смогли завершить регистрацию. Повторите попытку позже."
            )
        }
    }
    
    private func checkIfEmailExistsInDatabase(email: String) async throws {
        var exists = false
        do {
            exists = try await MYPersistenceController.preview.doesEmailExist(email)
        } catch {
            try showAlert(
                title: "Ошибка системы",
                message: "Произошла ошибка при проверке email. Повторите попытку позже."
            )
        }
        if !exists {
            try showAlert(
                title: "Пользователь не найден",
                message: "К сожалению, пользователь с таким email не найден. Пожалуйста, проверьте правильность ввода или зарегистрируйтесь."
            )
        }
    }

    private func checkIfEmailIsValid(email: String) async throws {
        do {
            _ = try await MYMailgunAPI.shared.checkEmailExists(email: email)
        } catch {
            try showAlert(
                title: "Неверный Email",
                message: "Указанный email недействителен или не существует. Пожалуйста, проверьте правильность ввода."
            )
        }
    }
    
    private func sendNewPassword(to email: String) async throws {
        do {
            let password = MYPasswordManager.shared.generateRandomPassword()
            _ = try await MYMailgunAPI.shared.sendEmail(
                to: email,
                subject: "Ваш новый пароль:",
                body: password
            )
        } catch {
            try showAlert(
                title: "Ошибка отправки",
                message: "Сообщение не было отправлено. Повторите попытку позже."
            )
        }
        
        try showAlert(
            title: "Регистрация завершена",
            message: "Добро пожаловать! Ваша регистрация прошла успешно."
        )
    }
    
    private func makeLoginError() throws {
        try showAlert(
            title: "Ошибка входа",
            message: "Не удалось выполнить вход. Проверьте email и пароль, и попробуйте снова."
        )
    }
    
    private func showAlert(title: String, message: String) throws {
        throw MYAlertError(
            title: title,
            message: message,
            primaryButton: MYAlertButton(title: "ОК", role: .cancel)
        )
    }
}

