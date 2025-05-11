import SwiftUI

struct MYLoginView: View {
    var text: String
    var image: Image?
    
    var body: some View {
        HStack {
            if let image {
                image
                    .resizable()
                    .scaledToFit()
                    .font(.system(.body, weight: .bold))
                    .tint(Color.secondary)
                    .frame(maxWidth: 24, maxHeight: 24)
            }
            Spacer()
            Text(text)
                .bold()
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .tint(Color.primary)
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: MYDefaultSetting.cornerRadius)
                .stroke(Color.gray, lineWidth: 1)
        )
        .clipShape(
            RoundedRectangle(cornerRadius: MYDefaultSetting.cornerRadius)
        )
    }
}


#Preview {
    MYLoginView(text: "Login")
}
