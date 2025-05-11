
import SwiftUI
import PencilKit

struct MYCanvasEditorTest: UIViewRepresentable {
    func updateUIView(_ uiView: MYCanvasEditor, context: Context) {
        
    }
    
    
    func makeUIView(context: Context) -> MYCanvasEditor {
        let canvasView = MYCanvasEditor()
        
        let toolPicker = PKToolPicker()
        
        canvasView.isUserInteractionEnabled = true
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        canvasView.becomeFirstResponder()
        
        return canvasView
    }
}


#Preview {
    MYCanvasEditorTest()
}
