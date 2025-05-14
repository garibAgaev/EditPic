import SwiftUI

struct MYConditionalButtonView: View {
    let litle: String
    let showButton: Bool
    let action: () -> Void
    
    var body: some View {
        if showButton {
            Button(litle, action: action)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .tint(Color.white)
                .clipShape(
                    RoundedRectangle(cornerRadius: MYDefaultStyle.cornerRadius)
                )
        }
    }
    
    init(_ litle: String, showButton: Bool, action: @escaping () -> Void = {}) {
        self.litle = litle
        self.action = action
        self.showButton = showButton
    }
}


#Preview {
    MYConditionalButtonView("", showButton: true)
}
