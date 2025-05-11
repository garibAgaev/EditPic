
import UIKit

protocol MYTextEditingCanvasDelegate: NSObjectProtocol {
    func textEditingCanvas(_ canvas: MYTextEditingCanvas, didSelectLabel config: MYLabelConfiguration)
}

