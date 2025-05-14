import SwiftUI

struct MYLeadingAlignedText: View {
    
    @Environment(\.font) private var font
    
    let attributedContent: AttributedString
    var body: some View {
        HStack {
            Text(attributedContent)
                .font(font)
                .bold()
            Spacer()
        }
    }
    
    init(_ attributedContent: AttributedString) {
        self.attributedContent = attributedContent
    }
}

#Preview {
    MYLeadingAlignedText("Восстановление пароля")
}
