
import SwiftUI

struct ImageEditorView: View {
    @AppStorage("isLoggedIn") var isLoggedIn = false
    @AppStorage("name") var nameStorage: String?
    
    @State private var start = Rotate()
    @State private var labelConfiguration = MYLabelConfiguration()
    @State private var isSelected = false
    @State private var configure: ConfigureMode? = nil
    @State private var isEditorVisible = false
    
    @ObservedObject var orientationObserver = MYOrientationManager.shared
    @State private var selectedImage: UIImage?
    
    @State private var showImagePicker = false
    @State private var offset = CGFloat.zero
    @State private var offset2 = CGFloat.zero
    @State private var viewHeight = CGFloat.zero
        
    var isSelectedBinding: Binding<Bool> {
        Binding(
            get: { isSelected },
            set: { flag in withAnimation { isSelected = flag } }
        )
    }
    
    var body: some View {
        ZStack {
            if selectedImage != nil {
                (isEditorVisible ? Color.white : Color.black)
                        .ignoresSafeArea()
                        .transition(.opacity)
                ZStack {
                    MYCanvasSpaceEditorView(
                        start: $start,
                        flagCanvas: isEditorVisible && configure == .pensil,
                        flagText: isEditorVisible && configure == .text,
                        labelConfiguration: $labelConfiguration,
                        isSelectedLabel: isSelectedBinding,
                        image: selectedImage
                    )
                    .ignoresSafeArea(.keyboard)
                    .onTapGesture {
                        withAnimation {
                            isSelected = false
                            isEditorVisible.toggle()
                        }
                    }
                    if isEditorVisible {
                        ContentView1(
                            isSelected: isSelectedBinding,
                            start: $start,
                            labelConfiguration: $labelConfiguration
                        )
                    }
                }
                .coordinateSpace(name: "coordinateSpace")
            } else {
                Color.white
                    .ignoresSafeArea()
                GeometryReader { proxy in
                    ZStack {
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.blue)
                        .padding()
                        if !showImagePicker {
                            MYOrientationStackView(true) {
                                VStack {
                                    HStack {
                                        Image(systemName: "photo")
                                            .frame(width: 100, height: 100)
                                        VStack {
                                            HStack {
                                                Text(nameStorage ?? "Ленивый пузатик")
                                                    .font(.largeTitle)
                                                    .bold()
                                                Spacer()
                                            }
                                            HStack {
                                                Text("Вы\(isLoggedIn ? "" : " не") авторизованы")
                                                Spacer()
                                            }
                                        }
                                    }
                                    .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
                                    .background(
                                        GeometryReader { imageGeometry in
                                            Color.white
                                                .onAppear {
                                                    viewHeight = imageGeometry.size.height
                                                }
                                        }
                                    )
                                    .cornerRadius(MYDefaultSetting.cornerRadius)
                                    .onTapGesture {
                                        isLoggedIn = false
                                    }
                                    if orientationObserver.orientation == .horizontal { Spacer() }
                                }
                                Spacer()
                            }
                            .padding()
                            .offset(y: offset)
                            .gesture(
                                DragGesture()
                                    .onChanged { gesture in
                                        offset = max(min(offset2 + gesture.translation.height, proxy.size.height - viewHeight), 0)
                                    }
                                    .onEnded { _ in
                                        offset2 = offset
                                    }
                            )
                        }
                    }
                    .background(Color(uiColor: .systemGroupedBackground))
                    .sheet(isPresented: $showImagePicker) {
                        PhotoPicker(image: $selectedImage)
                    }
                    .onTapGesture {
                        showImagePicker.toggle()
                    }
                }
            }
        }
        .transition(.slide)
    }
    
    func resetEditor() {
        selectedImage = nil
        isEditorVisible = false
        showImagePicker = false
        configure = nil
    }
}

#Preview {
    ImageEditorView()
}
