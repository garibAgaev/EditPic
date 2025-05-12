
import SwiftUI

struct ContentView1: View {
    
    @Binding var isSelected: Bool
    @Binding var start: Rotate
    @Binding var labelConfiguration: MYLabelConfiguration
    @Binding var configure: ConfigureMode?
    
    
    @State private var selectedLabelOption: LabelEditOption?
    @State private var providerText = ""
    @State private var length = 0.0
    
    @ObservedObject var orientationObserver = MYOrientationManager.shared
    
    
    var body: some View {
        ZStack {
            MYOrientationStackView(true) {
                ToolbarView(configure: $configure)
                    .background(layoutAnchor)
                    .padding()
                Spacer()
            }
            .ignoresSafeArea(.keyboard)
            MYOrientationStackView(true) {
                switch orientationObserver.orientation {
                case .horizontal:
                    Color.clear.frame(width: length)
                case .vertical:
                    Spacer()
                }
                imageConfigurationView
//                    .frame(maxWidth: .infinity)
            }
        }
        .onChange(of: selectedLabelOption) {
            if $0 != nil && !isSelected {
                isSelected = true
            }
            if $0 == nil && isSelected {
                isSelected = false
            }
        }
        .onChange(of: isSelected) {
            if $0 && selectedLabelOption == nil {
                selectedLabelOption = .text
            }
            if !$0 {
                selectedLabelOption = nil
            }
        }
    }
    
    var layoutDependent: some View {
        Spacer(minLength: 0)
            .frame(
                width: orientationObserver.orientation == .horizontal ? length : nil,
                height: orientationObserver.orientation == .vertical ? length : nil
            )
    }
    
    @ViewBuilder
    var imageConfigurationView: some View {
        switch configure {
        case .none:
            Group {}
        case .text:
            VStack {
                Spacer()
                textLabelConfiguratorView
            }
        case .pensil:
            Group {}
        case .rotate:
            MYOrientationStackView(true) {
                Spacer()
                rotateLabelConfiguratorView
            }
        }
    }
    
    @ViewBuilder
    var rotateLabelConfiguratorView: some View {
        MYOrientationStackView(false) {
            Spacer()
            MYIconToggleButtonView(iconName: "rotate.left", isActive: .constant(false)) {
                start.left.toggle()
            }
            .frame(width: length)
            MYIconToggleButtonView(iconName: "rotate.right", isActive: .constant(false)) {
                start.right.toggle()
            }
            .frame(width: length)
            Spacer()
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
                        ColorPicker("", selection:
                                        Binding(
                                            get: { Color(labelConfiguration.textColor) },
                                            set: {
                                                labelConfiguration.textColor = UIColor($0)
                                            }
                                        )
                        )
                        .labelsHidden()
                        .padding()
                    }
                }
                if let labelConfigurationOption1 = selectedLabelOption {
                    Menu {
                        Button("Закончить редактирование") { selectedLabelOption = nil }
                        Button(LabelEditOption.textColor.placeholder) { selectedLabelOption = .textColor }
                        Button(LabelEditOption.fontPointSize.placeholder) { selectedLabelOption = .fontPointSize }
                        Button(LabelEditOption.fontName.placeholder) { selectedLabelOption = .fontName }
                        Button(LabelEditOption.text.placeholder) { selectedLabelOption = .text }
                        Button(LabelEditOption.rotationAngle.placeholder) { selectedLabelOption = .rotationAngle }
                    } label: {
                        Text(labelConfigurationOption1.placeholder)
                            .padding()
                    }
                }
            }
            .background(Color(.secondarySystemBackground).opacity(0.8))
        }
    }
    
    var layoutAnchor: some View {
        GeometryReader { geometry in
            Color.clear
                .onReceive(orientationObserver.$orientation) {
                    switch $0 {
                    case .horizontal:
                        length = geometry.size.width
                    case .vertical:
                        length = geometry.size.height
                    }
                }
        }
    }
    
}
