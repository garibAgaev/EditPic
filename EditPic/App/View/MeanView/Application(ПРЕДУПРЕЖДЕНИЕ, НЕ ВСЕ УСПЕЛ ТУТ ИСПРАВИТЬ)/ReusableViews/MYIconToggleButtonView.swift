import SwiftUI

struct MYIconToggleButtonView: View {
    let iconName: String
    @Binding var isActive: Bool
    let action: () -> Void
    
    @State private var buttonSize: CGFloat = 0.0
    
    var body: some View {
        Button {
            action()
            isActive.toggle()
        } label: {
            let background =
                Color(UIColor.secondarySystemBackground)
                    .clipShape(Circle())
            
            let icon =
                Image(systemName: iconName)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(isActive ? .gray : .blue)
            
            MYScaledOverlayView(
                background: background,
                content: icon,
                scale: .inscribedInCircle
            )
            .aspectRatio(1, contentMode: .fit)
        }
    }
}

#Preview {
    MYIconToggleButtonView(iconName: "square.and.arrow.up", isActive: .constant(false), action: {})
}
