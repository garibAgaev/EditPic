import Foundation

enum LabelEditOption: CaseIterable {
    case textColor
    case fontPointSize
    case fontName
    case text
    case rotationAngle
    
    var placeholder: String {
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
    
    init?(_ flag: Bool) {
        guard flag else { return nil }
        self = .text
    }
}
