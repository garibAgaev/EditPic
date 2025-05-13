
import SwiftUI

struct MYCanvasSpaceEditorView: UIViewControllerRepresentable {
    @Binding var start: Rotate
    @Binding var flagCanvas: Bool
    @Binding var flagText: Bool
    @Binding var labelConfiguration: MYLabelConfiguration
    @Binding var isSelectedLabel: Bool
    @Binding var image: UIImage?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, flagCanvas: flagCanvas, flagText: flagText, labelConfiguration: labelConfiguration, image: image, start: start)
    }
    
    func makeUIViewController(context: Context) -> MYCanvasSpaceEditorViewController {
        let myView = MYCanvasSpaceEditorViewController()
        myView.image = image
        myView.delegate = context.coordinator
        return myView
    }
    
    func updateUIViewController(_ uiView: MYCanvasSpaceEditorViewController, context: Context) {
        defer {
            context.coordinator.flagCanvas = flagCanvas
            context.coordinator.flagText = flagText
            context.coordinator.labelConfiguration = labelConfiguration
            context.coordinator.image = image
            context.coordinator.start = start
            
            context.coordinator.flag = false
        }
        if context.coordinator.start.left != start.left {
            uiView.rotateContent(clockwise: false)
        }
        if context.coordinator.start.right != start.right {
            uiView.rotateContent(clockwise: true)
        }
        if context.coordinator.flag || context.coordinator.image != image {
            uiView.image = image
        }
        if context.coordinator.flag || context.coordinator.flagCanvas != flagCanvas {
            uiView.enableCanvasInteraction(flagCanvas)
        }
        if context.coordinator.flag || context.coordinator.flagText != flagText {
            uiView.enableTextInteraction(flagText)
        }
        
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
        var flagCanvas: Bool
        var flagText: Bool
        var labelConfiguration: MYLabelConfiguration
        var image: UIImage?
        var start: Rotate

        var flag = true
        
        init(_ parent: MYCanvasSpaceEditorView, flagCanvas: Bool, flagText: Bool, labelConfiguration: MYLabelConfiguration, image: UIImage?, start: Rotate) {
            self.parent = parent
            self.flagCanvas = flagCanvas
            self.flagText = flagText
            self.labelConfiguration = labelConfiguration
            self.image = image
            self.start = start
        }
        
        func textEditingCanvas(_ canvas: MYTextEditingCanvas, didSelectLabel config: MYLabelConfiguration) {
            parent.isSelectedLabel = true
            parent.labelConfiguration = config
        }
    }
}


#Preview {
    MYCanvasSpaceEditorView(start: .constant(.init()), flagCanvas: .constant(false), flagText: .constant(false), labelConfiguration: .constant(.init()), isSelectedLabel: .constant(false), image: .constant(UIImage(systemName: "person")))
        .background(
            Color.red
            )
}
