
import SwiftUI

struct MYScaledOverlayView<MYBackground: View, MYContent: View>: View {
    let background: MYBackground
    let content: MYContent
    var scale: Double
    @State private var baseSize: CGSize = .zero

    var body: some View {
        ZStack {
            background
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .preference(
                                key: MYSizePreferenceKey.self,
                                value: geometry.size
                            )
                    }
                )

            content
                .frame(
                    width: baseSize.width * scale,
                    height: baseSize.height * scale
                )
        }
        .onPreferenceChange(MYSizePreferenceKey.self) { newSize in
            baseSize = newSize
        }
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
