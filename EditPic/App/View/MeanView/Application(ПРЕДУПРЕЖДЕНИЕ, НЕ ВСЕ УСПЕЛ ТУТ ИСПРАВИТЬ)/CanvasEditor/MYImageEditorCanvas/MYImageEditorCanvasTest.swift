

import SwiftUI

struct MYImageEditorCanvasTest: UIViewRepresentable {
    func updateUIView(_ uiView: MYImageEditorCanvas, context: Context) {
        
    }
    
    func makeUIView(context: Context) -> MYImageEditorCanvas {
        let imageView = MYImageEditorCanvas()
        imageView.image = UIImage(systemName: "photo")
        return imageView
    }
}


#Preview {
    MYImageEditorCanvasTest()
}
