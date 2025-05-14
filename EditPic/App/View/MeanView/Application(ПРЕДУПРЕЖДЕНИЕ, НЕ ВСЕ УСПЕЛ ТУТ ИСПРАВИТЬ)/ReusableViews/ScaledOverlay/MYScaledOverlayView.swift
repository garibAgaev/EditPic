
import SwiftUI

struct MYScaledOverlayView<MYBackground: View, MYContent: View>: View {
    let background: MYBackground
    let content: MYContent
    var scale: Double
    
    @State private var size: CGSize = .zero
    
    var body: some View {
        background
            .overlay(content
                .scaleEffect(scale, anchor: .center))
    }
    
    init(background: MYBackground, content: MYContent, scale: MYContentScale) {
        self.background = background
        self.content = content
        self.scale = scale.value
    }
}

#Preview {
    MYScaledOverlayView(
        background:
            Color(UIColor.secondarySystemBackground)
            .clipShape(Circle()),
        content:
            Image(systemName: "square.and.arrow.up")
            .resizable()
            .scaledToFit(),
        scale: .inscribedInCircle
    )
}
