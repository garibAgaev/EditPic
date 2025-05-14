
import SwiftUI

struct MYEditorToolbarView: View {
    
    @Binding var configure: ConfigureMode?
        
    @EnvironmentObject var showAlert: MYAlertManager
    
    var body: some View {
        MYOrientationStackView(false) {
            MYIconToggleButtonView(iconName: "square.and.arrow.up", isActive: .constant(false)) {
                if configure != nil {
                    showAlert.alertError = MYAlertError(
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
                showAlert.alertError = MYAlertError(
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
        }
    }
}

#Preview {
    VStack {
        MYEditorToolbarView(configure: .constant(.pensil))
        Spacer()
    }
}
