import SwiftUI

struct DynamicInputPickerField: UIViewRepresentable {
    static let availableFonts: [UIFont] = UIFont.familyNames.flatMap { family in
        UIFont.fontNames(forFamilyName: family).compactMap { fontName in
            UIFont(name: fontName, size: LabelSettings.defaultFont.pointSize)
        }
    }
    
    @Binding var labelConfiguration: MYLabelConfiguration
    @Binding var selectedLabelOption: LabelEditOption?
    
    @State private var isTextFieldFocused = false
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, isTextFieldFocused, labelConfiguration, selectedLabelOption)
    }

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator

        textField.borderStyle = .roundedRect
        textField.addTarget(context.coordinator, action: #selector(context.coordinator.textDidChange), for: .editingChanged)
        
        let pickerView = UIPickerView()
        pickerView.delegate = context.coordinator
        pickerView.dataSource = context.coordinator
        
        context.coordinator.textField = textField
        context.coordinator.pickerView = pickerView
        
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        
        defer {
            context.coordinator.wasTextFieldFocused = isTextFieldFocused
            context.coordinator.previousLabelConfiguration = labelConfiguration
            context.coordinator.previousSelectedOption = selectedLabelOption
            
            context.coordinator.needsUpdate = false
        }
        
        if context.coordinator.needsUpdate || context.coordinator.previousSelectedOption != selectedLabelOption {
            updateSelectedLabelOption(uiView, context: context)
            updateLabelSettings(uiView, context: context)
            updateIsTextFieldFocused(uiView, context: context)
        } else {
            if context.coordinator.needsUpdate || context.coordinator.previousLabelConfiguration != labelConfiguration {
                updateLabelSettings(uiView, context: context)
            }
            
            if context.coordinator.needsUpdate || context.coordinator.wasTextFieldFocused != isTextFieldFocused {
                updateIsTextFieldFocused(uiView, context: context)
            }
        }
    }
    
    func updateIsTextFieldFocused(_ uiView: UITextField, context: Context) {
        if isTextFieldFocused && !uiView.isFirstResponder {
            uiView.becomeFirstResponder()
        } else
        if !isTextFieldFocused && uiView.isFirstResponder {
            uiView.resignFirstResponder()
        }
    }
    
    func updateSelectedLabelOption(_ uiView: UITextField, context: Context) {

        if selectedLabelOption != .fontName {
            uiView.inputView = nil
        }
        
        switch selectedLabelOption {
        case .none:
            break
        case .text, .textColor:
            uiView.keyboardType = .default
            uiView.placeholder = "Введите текст..."
        case .fontPointSize:
            uiView.keyboardType = .numberPad
            uiView.placeholder = "Введите размер шрифта..."
        case .fontName:
            uiView.inputView = context.coordinator.pickerView
            uiView.placeholder = ""
        case .rotationAngle:
            uiView.keyboardType = .numberPad
            uiView.placeholder = "Введите угол..."
        }
        
        uiView.reloadInputViews()
    }
    
    func updateLabelSettings(_ uiView: UITextField, context: Context) {
        switch selectedLabelOption {
        case .none:
            break
        case .text, .textColor:
            uiView.text = labelConfiguration.text
        case .fontPointSize:
            uiView.text = String(format: "%.0f", labelConfiguration.font.pointSize)
        case .fontName:
            let row = DynamicInputPickerField.availableFonts.firstIndex {
                $0.fontName == labelConfiguration.font.fontName
            } ?? DynamicInputPickerField.availableFonts.firstIndex {
                $0.fontName == MYLabelConfiguration().font.fontName
            } ?? 0
            context.coordinator.pickerView?.selectRow(row, inComponent: 0, animated: true)
            uiView.text = DynamicInputPickerField.availableFonts[row].fontName
        case .rotationAngle:
            uiView.text = String(format: "%.0f", labelConfiguration.rotationAngle * 180 / .pi)
        }
    }


    class Coordinator: NSObject, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
        var parent: DynamicInputPickerField
        
        var previousLabelConfiguration: MYLabelConfiguration
        var previousSelectedOption: LabelEditOption?
        var wasTextFieldFocused: Bool
        
        var needsUpdate = true
        
        var textField: UITextField?
        var pickerView: UIPickerView?
        
        init(_ parent: DynamicInputPickerField, _ lastIsFocused: Bool, _ lastLabelConfigure: MYLabelConfiguration, _ lastLabelConfigurationOption: LabelEditOption?) {
            self.parent = parent
            self.wasTextFieldFocused = lastIsFocused
            self.previousLabelConfiguration = lastLabelConfigure
            self.previousSelectedOption = lastLabelConfigurationOption
        }

        func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            DynamicInputPickerField.availableFonts.count
        }
        
        func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
            let label = UILabel()
            let font = DynamicInputPickerField.availableFonts[row]
            label.font = font
            label.text = font.fontName
            label.textColor = .systemBlue
            label.textAlignment = .center
            return label
        }

        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            parent.labelConfiguration.font = DynamicInputPickerField.availableFonts[row].withSize(parent.labelConfiguration.font.pointSize)
            textField?.text = DynamicInputPickerField.availableFonts[row].fontName
        }
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            if !parent.isTextFieldFocused {
                parent.isTextFieldFocused = true
            }
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            if parent.isTextFieldFocused {
                parent.isTextFieldFocused = false
            }
        }
        
        @objc func textDidChange(_ textField: UITextField) {
            guard let text = textField.text else { return }
            switch parent.selectedLabelOption {
            case .text:
                parent.labelConfiguration.text = text
            case .textColor:
                parent.labelConfiguration.text = text
            case .fontPointSize:
                if let fontSize = textField.text.flatMap({ Double($0) }) {
                    parent.labelConfiguration.font = parent.labelConfiguration.font.withSize(fontSize)
                }
            case .rotationAngle:
                if let angle = textField.text.flatMap({ Double($0) }) {
                    parent.labelConfiguration.rotationAngle = angle * .pi / 180
                }
            default:
                break
            }
        }
    }
}
