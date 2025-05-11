
import SwiftUI

struct ToolbarView: View {
    
    @Binding var configure: ConfigureMode?
    @Binding var showAlert: Bool
    @Binding var alertSource: AlertSource
        
    var body: some View {
        dwdiqdq
    }
    
    @ViewBuilder var dwdiqdq: some View {
        MYOrientationStackView(false) {
            MYIconToggleButtonView(iconName: "square.and.arrow.up", isActive: .constant(false)) {
                if configure != nil {
                    alertSource = .share
                    showAlert = true
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
                alertSource = .trash
                showAlert = true
            }
        }
    }
}

#Preview {
    VStack {
        ToolbarView(configure: .constant(.pensil), showAlert: .constant(true), alertSource: .constant(.share))
        Spacer()
    }
}
