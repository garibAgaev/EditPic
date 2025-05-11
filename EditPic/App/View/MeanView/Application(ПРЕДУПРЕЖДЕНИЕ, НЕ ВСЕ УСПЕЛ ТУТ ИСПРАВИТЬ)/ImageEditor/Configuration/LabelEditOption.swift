import Foundation

enum LabelEditOption: String, CaseIterable {
    case textColor = "Изменить цвет"
    case fontPointSize = "Изменить размер шрифта"
    case fontName = "Изменить шрифт"
    case text = "Отредактировать текст"
    case rotationAngle = "Повернуть"
    
    func placeholder() -> String {
        switch self {
        case .textColor:
            return "Изменить цвет"
        case .fontPointSize:
            return "Введите размер шрифта"
        case .fontName:
            return "Введите шрифт"
        case .text:
            return "Введите текст"
        case .rotationAngle:
            return "Повернуть"
        }
    }
}
