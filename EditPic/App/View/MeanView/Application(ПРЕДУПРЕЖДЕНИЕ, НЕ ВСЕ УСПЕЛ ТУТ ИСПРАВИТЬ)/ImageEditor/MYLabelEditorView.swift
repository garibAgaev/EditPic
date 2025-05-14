
import SwiftUI

struct MYLabelEditorView: View {
    
    @Binding var labelConfiguration: MYLabelConfiguration
    @Binding var isLabelSelected: Bool
    
    @State private var activeEditOption: LabelEditOption?
    @State private var inputText: String = ""
    
    var body: some View {
        Group {
            switch activeEditOption {
            case .none:
                MYTextFieldView("Введите текст...",
                                text: $inputText,
                                opacity: MYDefaultStyle.backgroundOpacity)
                .padding()
                
            case .some(let currentOption):
                VStack {
                    HStack {
                        DynamicInputPickerField(labelConfiguration: $labelConfiguration, selectedLabelOption: $activeEditOption)
                            .myDismissKeyboardOnTap()
                            .frame(maxHeight: 44)
                            .padding()
                        
                        if activeEditOption == .textColor {
                            ColorPicker("", selection:
                                            Binding(
                                                get: { Color(labelConfiguration.textColor) },
                                                set: { labelConfiguration.textColor = UIColor($0) }
                                            )
                            )
                            .labelsHidden()
                            .padding()
                        }
                    }
                    
                    Menu {
                        Button("Закончить редактирование") { activeEditOption = nil }
                        Button(LabelEditOption.textColor.placeholder) { activeEditOption = .textColor }
                        Button(LabelEditOption.fontPointSize.placeholder) { activeEditOption = .fontPointSize }
                        Button(LabelEditOption.fontName.placeholder) { activeEditOption = .fontName }
                        Button(LabelEditOption.text.placeholder) { activeEditOption = .text }
                        Button(LabelEditOption.rotationAngle.placeholder) { activeEditOption = .rotationAngle }
                    } label: {
                        Text(currentOption.placeholder)
                            .padding()
                    }
                }
                .background(MYDefaultStyle.backgroundColor)
            }
        }
        .onAppear {
            updateActiveEditOption()
        }
        .onChange(of: activeEditOption) { _ in
            updateLabelSelectionState()
        }
        .onChange(of: isLabelSelected) { _ in
            updateActiveEditOption()
        }
    }
    
    private func updateActiveEditOption() {
        if isLabelSelected && activeEditOption == nil {
            activeEditOption = .text
        }
        if !isLabelSelected {
            activeEditOption = nil
        }
    }

    private func updateLabelSelectionState() {
        if activeEditOption != nil && !isLabelSelected {
            isLabelSelected = true
        }
        if activeEditOption == nil && isLabelSelected {
            isLabelSelected = false
        }
    }
}


#Preview {
    MYLabelEditorView(labelConfiguration: .constant(.init()), isLabelSelected: .constant(.random()))
}
