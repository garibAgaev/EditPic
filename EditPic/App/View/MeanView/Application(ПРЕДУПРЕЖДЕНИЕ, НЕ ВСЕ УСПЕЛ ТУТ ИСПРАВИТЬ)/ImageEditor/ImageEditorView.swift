
import SwiftUI

struct ImageEditorView: View {
    @AppStorage("isLoggedIn") var isLoggedIn = false
    @AppStorage("name") var nameStorage: String?
    @ObservedObject var orientationObserver = MYOrientationManager.shared
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var labelConfiguration = MYLabelConfiguration()
    @State private var configure: ConfigureMode? = nil
    @State private var isEditorVisible = false
    @State private var showAlert = false
    @State private var alertSource: AlertSource = .share
    @State private var selectedLabelOption: LabelEditOption? = nil
    @State private var providerText = ""
    @State private var start = Rotate()
    @State private var offset = CGFloat.zero
    @State private var offset2 = CGFloat.zero
    @State private var viewHeight = CGFloat.zero
    
    @State private var length = 0.0
    
    var body: some View {
        ZStack {
            if selectedImage != nil {
                (isEditorVisible ? Color.white : Color.black)
                    .ignoresSafeArea()
                    .transition(.opacity)
            }
            if selectedImage != nil {
                ZStack {
                    MYCanvasSpaceEditorView(
                        start: $start,
                        flagCanvas: .constant(isEditorVisible && configure == .pensil),
                        flagText: .constant(isEditorVisible && configure == .text),
                        labelConfiguration: $labelConfiguration,
                        isSelectedLabel:
                            Binding(
                                get: { selectedLabelOption != nil },
                                set: { flag in
                                    withAnimation {
                                        selectedLabelOption = flag ? .text : nil
                                    }
                                }
                            ),
                        image: $selectedImage
                    )
                    .ignoresSafeArea(.keyboard)
                    .onTapGesture {
                        withAnimation {
                            if selectedLabelOption != nil {
                                selectedLabelOption = nil
                            } else {
                                isEditorVisible.toggle()
                            }
                        }
                    }
                    if isEditorVisible {
                        MYOrientationStackView(true) {
                            ToolbarView(
                                configure: $configure,
                                showAlert: $showAlert,
                                alertSource: $alertSource
                            )
                            .frame(
                                maxWidth: orientationObserver.orientation == .horizontal ? 44 : nil,
                                maxHeight: orientationObserver.orientation == .vertical ? 44 : nil
                            )
                            .padding()
                            Spacer()
                        }
                        .ignoresSafeArea(.keyboard)
                        MYOrientationStackView(true) {
                            layoutDependent
                            imageConfigurationView
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
                .coordinateSpace(name: "coordinateSpace")
            } else {
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
        .alert(isPresented: $showAlert) {
            switch alertSource {
            case .share:
                Alert(
                    title: Text("Второй алерт"),
                    message: Text("Это второй алерт"),
                    dismissButton: .default(Text("OK"))
                )
            case .trash:
                Alert(
                    title: Text("Подтвердите действие"),
                    message: Text("Вы уверены, что хотите удалить?"),
                    primaryButton: .destructive(Text("Удалить")) {
                        resetEditor()
                    },
                    secondaryButton: .cancel {}
                )
            }
        }
    }
    
    var layoutAnchor: some View {
        GeometryReader { geometry in
            Color.clear
                .onReceive(orientationObserver.$orientation) {
                    switch $0 {
                    case .horizontal:
                        length = geometry.frame(in: .named("coordinateSpace")).maxX
                    case .vertical:
                        length = geometry.frame(in: .named("coordinateSpace")).maxY
                    }
                }
        }
    }
    
    var layoutDependent: some View {
        Color.clear
            .frame(
                width: orientationObserver.orientation == .horizontal ? length : nil,
                height: orientationObserver.orientation == .vertical ? length : nil
            )
    }
        
    @ViewBuilder
    var imageConfigurationView: some View {
        switch configure {
        case .none:
            ZStack {}
        case .text:
            VStack {
                Spacer()
                textLabelConfiguratorView
            }
        case .pensil:
            ZStack {}
        case .rotate:
            MYOrientationStackView(true) {
                Spacer()
                MYOrientationStackView(false) {
                    Spacer()
                    MYIconToggleButtonView(iconName: "rotate.left", isActive: .constant(false)) {
                        start.left.toggle()
                    }
                    MYIconToggleButtonView(iconName: "rotate.right", isActive: .constant(false)) {
                        start.right.toggle()
                    }
                    Spacer()
                }
                .frame(
                    maxWidth: orientationObserver.orientation == .horizontal ? 44 : nil,
                    maxHeight: orientationObserver.orientation == .vertical ? 44 : nil
                )
            }
        }
    }
    
    @ViewBuilder
    var textLabelConfiguratorView: some View {
        switch selectedLabelOption {
        case .none:
            MYTextFieldView("Введите текст...", text: $providerText, opacity: 0.8)
        case .some(_):
            VStack {
                HStack {
                    DynamicInputPickerField(labelConfiguration: $labelConfiguration, selectedLabelOption: $selectedLabelOption)
                        .myDismissKeyboardOnTap()
                        .frame(maxHeight: 44)
                        .padding()
                    if selectedLabelOption == .textColor {
                        ColorPicker(
                            "",
                            selection:
                                Binding(
                                    get: { Color(uiColor: labelConfiguration.textColor) },
                                    set: {
                                        labelConfiguration.textColor = UIColor($0)
                                    }
                                )
                        )
                            .labelsHidden()
                    }
                }
                if let labelConfigurationOption1 = selectedLabelOption {
                    Menu {
                        Button("Закончить редактирование") { selectedLabelOption = nil }
                        Button(LabelEditOption.textColor.rawValue) { selectedLabelOption = .textColor }
                        Button(LabelEditOption.fontPointSize.rawValue) { selectedLabelOption = .fontPointSize }
                        Button(LabelEditOption.fontName.rawValue) { selectedLabelOption = .fontName }
                        Button(LabelEditOption.text.rawValue) { selectedLabelOption = .text }
                        Button(LabelEditOption.rotationAngle.rawValue) { selectedLabelOption = .rotationAngle }
                    } label: {
                        Text(labelConfigurationOption1.rawValue)
                            .padding()
                    }
                }
            }
            .background(Color(.secondarySystemBackground).opacity(0.8))
            .cornerRadius(8)
        }
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
