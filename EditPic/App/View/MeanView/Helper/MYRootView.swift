
import SwiftUI

/*
 Здесь реализуется MYRootView, который выполняет две основные функции:
 1. Закрывает клавиатуру при тапе вне активного поля ввода, если это не запрещено вложенными вью.
 2. Отображает один alert на экране, даже если его запрашивают вложенные вью.

 Для этого используются PreferenceKey и наблюдаемые объекты с приватным доступом.
 */

// MARK: - Alert Support

/// Наблюдатель за появлением ошибок.
@MainActor
class MYAlertObserver: ObservableObject {
    fileprivate var showAlert = true
    
    @Published var alertError: MYAlertError?
    
    static let shared = MYAlertObserver()

    private init() {}
}

/// PreferenceKey для передачи ошибок, вызывающих alert, вверх по иерархии View.
private struct MYAlertPreferenceKey: PreferenceKey {
    static var defaultValue = false

    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        let nextValue = nextValue()
        value = value || nextValue
    }
}

extension View {
    /// Передает ошибку для отображения alert на Root уровне.
    func myAlertPresenter(flag: Bool) -> some View {
        return preference(key: MYAlertPreferenceKey.self, value: flag)
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
    @State private var showAlert = false

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
            Text(MYAlertObserver.shared.alertError?.title ?? ""),
            isPresented: Binding(
                get: { showAlert },
                set: {
                    guard !$0 else { return }
                    showAlert = false
                    MYAlertObserver.shared.alertError = nil
                    MYAlertObserver.shared.showAlert = true
                }
            )
        ) {
            HStack {
                if let primaryButton = MYAlertObserver.shared.alertError?.primaryButton {
                    Button(
                        primaryButton.title,
                        role: primaryButton.role,
                        action: primaryButton.action
                    )
                }
                if let secondaryButton = MYAlertObserver.shared.alertError?.secondaryButton {
                    Button(
                        secondaryButton.title,
                        role: secondaryButton.role,
                        action: secondaryButton.action
                    )
                }
            }
        } message: {
            Text(MYAlertObserver.shared.alertError?.message ?? "")
        }
        // Обработка появления ошибки, которая должна вызвать alert.
        .onPreferenceChange(MYAlertPreferenceKey.self) { flag in
            showAlert = MYAlertObserver.shared.showAlert && MYAlertObserver.shared.alertError != nil && flag
            guard showAlert else { return }
            MYAlertObserver.shared.showAlert = false
        }
    }
}
