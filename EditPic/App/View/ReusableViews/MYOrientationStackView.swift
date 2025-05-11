import SwiftUI

struct MYOrientationStackView<Content: View>: View {
    let isRight: Bool
    let horizontAlalignment: HorizontalAlignment
    let verticalAlalignment: VerticalAlignment
    let spacing: CGFloat?
    @ViewBuilder let content: () -> Content

    
    @ObservedObject private var orientation = MYOrientationManager.shared

    init(_ isRight: Bool, spacing: CGFloat? = nil, horizontAlalignment: HorizontalAlignment = .center, verticalAlalignment: VerticalAlignment = .center, @ViewBuilder content: @escaping () -> Content) {
        self.isRight = isRight
        self.spacing = spacing
        self.horizontAlalignment = horizontAlalignment
        self.verticalAlalignment = verticalAlalignment
        self.content = content
    }

    var body: some View {
        let orientation = isRight && orientation.orientation == .horizontal || !isRight && orientation.orientation != .horizontal
        if orientation {
            HStack(alignment: verticalAlalignment, spacing: spacing) {
                content()
            }
        } else {
            VStack(alignment: horizontAlalignment, spacing: spacing) {
                content()
            }
        }
    }
}

#Preview {
    MYOrientationStackView(false) {
        
    }
}
