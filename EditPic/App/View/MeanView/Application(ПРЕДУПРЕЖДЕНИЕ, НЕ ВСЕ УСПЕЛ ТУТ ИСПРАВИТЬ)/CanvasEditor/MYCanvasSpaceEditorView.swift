
import SwiftUI

struct MYCanvasSpaceEditorView: UIViewControllerRepresentable {
    @Binding var start: Rotate
    let flagCanvas: Bool
    let flagText: Bool
    @Binding var labelConfiguration: MYLabelConfiguration
    @Binding var isSelectedLabel: Bool
    let image: UIImage?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, labelConfiguration: labelConfiguration, start: start)
    }
    
    func makeUIViewController(context: Context) -> MYCanvasSpaceEditorViewController {
        let myView = MYCanvasSpaceEditorViewController()
        myView.image = image
        myView.delegate = context.coordinator
        return myView
    }
    
    func updateUIViewController(_ uiView: MYCanvasSpaceEditorViewController, context: Context) {
        defer {
            context.coordinator.labelConfiguration = labelConfiguration
            context.coordinator.start = start
            
            context.coordinator.flag = false
        }
        if context.coordinator.start.left != start.left {
            uiView.rotateContent(clockwise: false)
        }
        if context.coordinator.start.right != start.right {
            uiView.rotateContent(clockwise: true)
        }
        uiView.image = image
        uiView.enableCanvasInteraction(flagCanvas)
        uiView.enableTextInteraction(flagText)
        
        if isSelectedLabel {
            if context.coordinator.flag || context.coordinator.labelConfiguration != labelConfiguration {
                uiView.updateActiveLabel(with: labelConfiguration)
            }
        } else {
            uiView.clearActiveLabel()
        }
    }
    
    class Coordinator: NSObject, MYTextEditingCanvasDelegate {

        var parent: MYCanvasSpaceEditorView
        var labelConfiguration: MYLabelConfiguration
        var start: Rotate

        var flag = true
        
        init(_ parent: MYCanvasSpaceEditorView, labelConfiguration: MYLabelConfiguration, start: Rotate) {
            self.parent = parent
            self.labelConfiguration = labelConfiguration
            self.start = start
        }
        
        func textEditingCanvas(_ canvas: MYTextEditingCanvas, didSelectLabel config: MYLabelConfiguration) {
            parent.isSelectedLabel = true
            parent.labelConfiguration = config
        }
    }
}


#Preview {
    MYCanvasSpaceEditorView(start: .constant(.init()), flagCanvas: false, flagText: false, labelConfiguration: .constant(.init()), isSelectedLabel: .constant(false), image: UIImage(systemName: "person"))
        .background(
            Color.red
            )
}
