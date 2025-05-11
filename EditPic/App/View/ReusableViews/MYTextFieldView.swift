
import SwiftUI

struct MYTextFieldView: View {
    let titleKey: LocalizedStringKey
    @Binding var text: String
    let opacity: Double
    
    var body: some View {
        TextField(
            titleKey,
            text:
                Binding(
                    get: { text },
                    set: { newValue in
                        withAnimation {
                            text = newValue
                        }
                    }
                )
        )
        .myDismissKeyboardOnTap()
        .padding()
        .autocapitalization(.none)
        .background(Color(.secondarySystemBackground).opacity(opacity))
        .clipShape(
            RoundedRectangle(cornerRadius: MYDefaultSetting.cornerRadius)
        )
    }
    
    init(_ titleKey: LocalizedStringKey, text: Binding<String>, opacity: Double = 1) {
        self.titleKey = titleKey
        self._text = text
        self.opacity = opacity
    }
}

#Preview {
    MYTextFieldView("sddfsf", text: .constant(""))
}
