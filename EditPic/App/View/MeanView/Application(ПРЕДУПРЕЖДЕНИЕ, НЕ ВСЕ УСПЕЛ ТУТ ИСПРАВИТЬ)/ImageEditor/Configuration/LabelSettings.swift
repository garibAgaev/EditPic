import SwiftUI

struct LabelSettings: Equatable {
    var color = LabelSettings.defaultColor
    var font = LabelSettings.defaultFont
    var text = LabelSettings.defaultText
    var rotation = LabelSettings.defaultRotation
    
    static var defaultColor = Color.black
    static var defaultFont = UIFont.systemFont(ofSize: 24.0)
    static var defaultText = ""
    static var defaultRotation = Angle.radians(0)
}
