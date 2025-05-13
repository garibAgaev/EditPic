
import SwiftUI

struct MYEditorView: View {
    
    @Binding var isLabelSelected: Bool
    @Binding var rotationState: Rotate //RotationState
    @Binding var labelConfiguration: MYLabelConfiguration
    @Binding var editMode: ConfigureMode? //EditMode?
    
    @State private var screenLength: CGFloat = 0.0

    var body: some View {
        ZStack {
            MYOrientationStackView(true) {
                ToolbarView(configure: $editMode) //EditorToolbarView(editMode:
                    .background(geometryObserverView)
                    .padding()
                Spacer()
            }
            .ignoresSafeArea(.keyboard)
            
            MYOrientationStackView(true) {
                switch MYOrientationManager.shared.orientation {
                case .horizontal:
                    Color.clear.frame(width: screenLength)
                case .vertical:
                    Spacer()
                }
                editorModeContent
            }
        }
    }
    
    @ViewBuilder
    var editorModeContent: some View {
        switch editMode {
        case .none:
            EmptyView()
        case .text:
            VStack {
                Spacer()
                MYLabelEditorView(labelConfiguration: $labelConfiguration, isLabelSelected: $isLabelSelected)
            }
        case .pensil:
            EmptyView()
        case .rotate:
            MYOrientationStackView(true) {
                Spacer()
                rotationControls
                    .padding()
            }
        }
    }
    
    @ViewBuilder
    var rotationControls: some View {
        MYOrientationStackView(false) {
            Spacer()
            MYIconToggleButtonView(iconName: "rotate.left", isActive: .constant(false)) {
                rotationState.left.toggle()
            }
            .frame(width: screenLength)
            MYIconToggleButtonView(iconName: "rotate.right", isActive: .constant(false)) {
                rotationState.right.toggle()
            }
            .frame(width: screenLength)
            Spacer()
        }
    }
    
    var geometryObserverView: some View {
        GeometryReader { geometry in
            Color.clear
                .onReceive(MYOrientationManager.shared.$orientation) { orientation in
                    switch orientation {
                    case .horizontal:
                        screenLength = geometry.size.width
                    case .vertical:
                        screenLength = geometry.size.height
                    }
                }
        }
    }
}



#Preview {
    MYEditorView(isLabelSelected: .constant(false), rotationState: .constant(.init()), labelConfiguration: .constant(.init()), editMode: .constant(.rotate))
}
