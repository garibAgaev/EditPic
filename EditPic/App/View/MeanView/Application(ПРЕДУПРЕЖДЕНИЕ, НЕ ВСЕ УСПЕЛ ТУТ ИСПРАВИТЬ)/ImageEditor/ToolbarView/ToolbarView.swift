
import SwiftUI

struct ToolbarView: View {
    
    @Binding var configure: ConfigureMode?
        
    @State private var showAlert: MYAlertError?
    
    var body: some View {
        dwdiqdq
    }
    
    @ViewBuilder var dwdiqdq: some View {
        MYOrientationStackView(false) {
            MYIconToggleButtonView(iconName: "square.and.arrow.up", isActive: .constant(false)) {
                showAlert = MYAlertError(
                    title: "Предупреждение",
                    message: "Вы уверены, что хотите удалить?",
                    primaryButton: MYAlertButton(
                        title: "Нет",
                        role: .cancel,
                        action: {}
                    ),
                    secondaryButton: MYAlertButton(
                        title: "Да",
                        role: .destructive,
                        action: {}
                    )
                )
            }
            
            Spacer()
            
            MYIconToggleButtonView(iconName: "t.circle.fill", isActive: .constant(configure == .text)) {
                withAnimation {
                    configure = configure == .text ? nil : .text
                }
            }
            MYIconToggleButtonView(iconName: "pencil.tip.crop.circle.fill", isActive: .constant(configure == .pensil)) {
                withAnimation {
                    configure = configure == .pensil ? nil : .pensil
                }
            }
            MYIconToggleButtonView(iconName: "slider.horizontal.2.gobackward", isActive: .constant(configure == .rotate)) {
                withAnimation {
                    configure = configure == .rotate ? nil : .rotate
                }
            }
            
            Spacer()
            
            MYIconToggleButtonView(iconName: "trash.fill", isActive: .constant(false)) {
                if configure != nil {
                    showAlert = MYAlertError(
                        title: "Предупреждение",
                        message: "Вы уверены, что хотите прервать редактирвоание?",
                        primaryButton: MYAlertButton(
                            title: "Нет",
                            role: .cancel,
                        ),
                        secondaryButton: MYAlertButton(
                            title: "Да",
                            role: .destructive,
                            action: {
                                configure = nil
                            }
                        )
                    )
                } else {
                    
                }
            }
        }
        .myAlertPresenter(error: showAlert)
    }
}

#Preview {
    VStack {
        ToolbarView(configure: .constant(.pensil))
        Spacer()
    }
}
