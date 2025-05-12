
import SwiftUI

struct ContentView1: View {
    
    @Binding var isSelected: Bool
    @Binding var start: Rotate
    @Binding var labelConfiguration: MYLabelConfiguration

    
    @State private var selectedLabelOption: LabelEditOption? = nil
    @State private var configure: ConfigureMode? = nil
    @State private var providerText = ""
    @State private var length = 0.0
    
    @ObservedObject var orientationObserver = MYOrientationManager.shared

    
    var body: some View {
        ZStack {
            MYOrientationStackView(true) {
                ToolbarView(
                    configure: $configure,
                )
                .frame(
                    maxWidth: orientationObserver.orientation == .horizontal ? 44 : nil,
                    maxHeight: orientationObserver.orientation == .vertical ? 44 : nil
                )
                .background(
                    layoutAnchor
                )
                .padding()
                Spacer()
            }
            .ignoresSafeArea(.keyboard)
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
            MYOrientationStackView(true) {
                layoutDependent
                imageConfigurationView
                    .frame(maxWidth: .infinity)
            }
        }
        .coordinateSpace(name: "coordinateSpace")
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
            .cornerRadius(8)
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

}
