
import SwiftUI

struct ImageEditorView: View {
    @AppStorage("isLoggedIn") var isLoggedIn = false
    @AppStorage("name") var nameStorage: String?
    
    @State private var start = MYRotationState()
    @State private var labelConfiguration = MYLabelConfiguration()
    @State private var isSelected = false
    @State private var configure: ConfigureMode? = nil
    @State private var isEditorVisible = false
    
    @State private var selectedImage: UIImage?
    
    var body: some View {
        ZStack {
            if selectedImage != nil {
                (isEditorVisible ? Color.white : Color.black)
                        .ignoresSafeArea()
                        .transition(.opacity)
                ZStack {
                    MYCanvasSpaceEditorView(
                        start: $start,
                        flagCanvas: .constant(isEditorVisible && configure == .pensil),
                        flagText: .constant(isEditorVisible && configure == .text),
                        labelConfiguration: $labelConfiguration,
                        isSelectedLabel: $isSelected,
                        image: $selectedImage
                    )
                    .ignoresSafeArea(.keyboard)
                    .onTapGesture {
                        withAnimation {
                            if configure != nil {
                                configure = nil
                                isSelected = false
                            } else {
                                isEditorVisible.toggle()
                            }
                        }
                    }
                    if isEditorVisible {
                        MYEditorView(
                            isLabelSelected: $isSelected,
                            rotationState: $start,
                            labelConfiguration: $labelConfiguration,
                            editMode: $configure
                        )
                    }
                }
                .coordinateSpace(name: "coordinateSpace")
            } else {
                MYWelcomeView(selectedImage: $selectedImage)
            }
        }
        .transition(.slide)
    }
}

#Preview {
    ImageEditorView()
}
