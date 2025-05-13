
import SwiftUI

struct MYWelcomeView: View {
    @AppStorage("isLoggedIn") private var isUserLoggedIn = false
    @AppStorage("name") private var storedUserName: String?
    
    @Binding var selectedImage: UIImage?
    
    @State private var showImagePicker = false

    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
            
            MYOrientationStackView(true) {
                if !showImagePicker {
                    userInfoCard
                        .transition(.opacity)
                }
                
                Spacer(minLength: 0)
                
                Button {
                    withAnimation {
                        showImagePicker.toggle()
                    }
                } label: {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .padding()
                }
                
                Spacer(minLength: 0)
            }
            .padding()
        }
        .mySheet(isPresented: $showImagePicker) {
            PhotoPicker(image: $selectedImage)
        }
    }
    
    private var userInfoCard: some View {
        VStack {
            HStack {
                Image(systemName: "photo")
                    .frame(width: 100, height: 100)
                VStack(alignment: .leading) {
                    Text("Ленивый пузатик")
                        .font(.largeTitle)
                    HStack {
                        Text("Вы\(isUserLoggedIn ? "" : " не") авторизованы")
                        Spacer()
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(MYDefaultSetting.cornerRadius)
            .onTapGesture {
                isUserLoggedIn = false
            }
            
            if MYOrientationManager.shared.orientation == .horizontal {
                Spacer()
            }
        }
    }
}



#Preview {
    MYWelcomeView(selectedImage: .constant(UIImage(systemName: "person")))
}
