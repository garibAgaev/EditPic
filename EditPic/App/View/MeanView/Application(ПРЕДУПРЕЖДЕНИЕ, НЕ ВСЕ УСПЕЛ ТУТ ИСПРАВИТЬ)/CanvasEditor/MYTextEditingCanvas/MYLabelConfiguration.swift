
import UIKit

struct MYLabelConfiguration: Equatable {
    var text: String
    var alpha: CGFloat
    var font: UIFont
    var textColor: UIColor
    var rotationAngle: CGFloat
    
    init (text: String = "", alpha: CGFloat = 1, font: UIFont = .systemFont(ofSize: 44), textColor: UIColor = .black, rotationAngle: CGFloat = 0) {
        self.text = text
        self.alpha = alpha
        self.font = font
        self.textColor = textColor
        self.rotationAngle = rotationAngle
    }
}
