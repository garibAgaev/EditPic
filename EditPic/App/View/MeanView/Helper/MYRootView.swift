
import SwiftUI

/*
 Здесь реализуется MYRootView, который выполняет две основные функции:
 1. Закрывает клавиатуру при тапе вне активного поля ввода, если это не запрещено вложенными вью.
 2. Отображает один alert на экране, даже если его запрашивают вложенные вью.

 Для этого используются PreferenceKey и наблюдаемые объекты с приватным доступом.
 */

// MARK: - Alert Support

/// PreferenceKey для передачи ошибок, вызывающих alert, вверх по иерархии View.
private struct MYAlertPreferenceKey: PreferenceKey {
    static var defaultValue: MYAlertError? = nil

    static func reduce(value: inout MYAlertError?, nextValue: () -> MYAlertError?) {
        value = nextValue()
    }
}

extension View {
    /// Передает ошибку для отображения alert на Root уровне.
    func myAlertPresenter(error: MYAlertError?) -> some View {
        preference(key: MYAlertPreferenceKey.self, value: error)
    }
}

// MARK: - Keyboard Dismiss Support

/// Наблюдатель для глобального отслеживания состояния "нажато вне поля ввода".
@MainActor
private class MYKeyboardDismissObserver {
    /// Флаг, что одна из вложенных вью запретила возможность скрытия клавиатуры.
    var keyboardDismissAllowed: Bool = true

    static let shared = MYKeyboardDismissObserver()

    private init() {}
}

extension View {
    /// Уведомляет RootView, что текущая вью поддерживает жест скрытия клавиатуры.
    func myDismissKeyboardOnTap() -> some View {
        simultaneousGesture(
            TapGesture().onEnded {
                MYKeyboardDismissObserver.shared.keyboardDismissAllowed = true
            }
        )
    }
}

// MARK: - Root View

/// Главное обёртывающее вью, обрабатывающее скрытие клавиатуры и показ alert.
struct MYRootView<Content: View>: View {
    @State private var currentAlert: MYAlertError? = nil

    /// Флаг начала тапа по экрану (возможное скрытие клавиатуры).
    @State private var keyboardDismissRequested = false

    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            Color.clear
            content
        }
        .contentShape(Rectangle())
        // Обработка тапа по экрану (начинается запрос на скрытие клавиатуры).
        .simultaneousGesture(
            TapGesture().onEnded {
                keyboardDismissRequested = true
                
                Task {
                    // Небольшая задержка, чтобы дать шанс вложенным вью отреагировать.
                    try? await Task.sleep(nanoseconds: 8_000_000)
                    
                    if keyboardDismissRequested && !MYKeyboardDismissObserver.shared.keyboardDismissAllowed {
                        // Если никто не запретил, скрываем клавиатуру.
                        _ = await MainActor.run {
                            UIApplication.shared.sendAction(
                                #selector(UIResponder.resignFirstResponder),
                                to: nil,
                                from: nil,
                                for: nil
                            )
                        }
                    }
                    
                    // Сброс флагов
                    keyboardDismissRequested = false
                    MYKeyboardDismissObserver.shared.keyboardDismissAllowed = false
                }
            }
        )
        // Alert, если пришла ошибка от вложенной вью.
        .alert(
            Text(currentAlert?.title ?? ""),
            isPresented: Binding(
                get: { currentAlert != nil },
                set: { if !$0 { currentAlert = nil } }
            )
        ) {
            HStack {
                if let primaryButton = currentAlert?.primaryButton {
                    Button(
                        primaryButton.title,
                        role: primaryButton.role,
                        action: primaryButton.action
                    )
                }
                if let secondaryButton = currentAlert?.secondaryButton {
                    Button(
                        secondaryButton.title,
                        role: secondaryButton.role,
                        action: secondaryButton.action
                    )
                }
            }
        } message: {
            Text(currentAlert?.message ?? "")
        }
        // Обработка появления ошибки, которая должна вызвать alert.
        .onPreferenceChange(MYAlertPreferenceKey.self) { error in
            currentAlert = error
        }
        // Предотвращение обработки одной ошибки несколькими представлениями.
        .myAlertPresenter(error: nil)
    }
}
