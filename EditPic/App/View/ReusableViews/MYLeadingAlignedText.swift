import SwiftUI

struct MYLeadingAlignedText: View {
    let attributedContent: AttributedString
    var body: some View {
        HStack {
            Text(attributedContent)
                .font(.largeTitle)
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
