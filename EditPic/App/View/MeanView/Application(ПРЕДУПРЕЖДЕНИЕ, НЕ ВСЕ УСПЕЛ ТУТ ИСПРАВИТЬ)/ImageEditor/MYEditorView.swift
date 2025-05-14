
import SwiftUI

struct MYEditorView: View {
    
    @Binding var isLabelSelected: Bool
    @Binding var rotationState: MYRotationState //RotationState
    @Binding var labelConfiguration: MYLabelConfiguration
    @Binding var editMode: ConfigureMode?
    
    @State private var screenLength: CGFloat = 0.0

    var body: some View {
        ZStack {
            MYOrientationStackView(true) {
                MYEditorToolbarView(configure: $editMode)
                    .frame(
                        maxWidth: MYOrientationManager.shared.orientation == .horizontal
                        ? MYDefaultStyle.buttonSize.width
                        : nil,
                        maxHeight: MYOrientationManager.shared.orientation == .vertical
                        ? MYDefaultStyle.buttonSize.height
                        : nil
                    )
                    .padding()
                Spacer()
            }
            .ignoresSafeArea(.keyboard)
            
            MYOrientationStackView(true) {
                switch MYOrientationManager.shared.orientation {
                case .horizontal:
                    Color.clear.frame(width: MYDefaultStyle.buttonSize.width)
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
            .frame(maxWidth: MYDefaultStyle.buttonSize.width, maxHeight:  MYDefaultStyle.buttonSize.height)
            MYIconToggleButtonView(iconName: "rotate.right", isActive: .constant(false)) {
                rotationState.right.toggle()
            }
            .frame(maxWidth: MYDefaultStyle.buttonSize.width, maxHeight:  MYDefaultStyle.buttonSize.height)
            Spacer()
        }
    }
}



#Preview {
    MYEditorView(isLabelSelected: .constant(false), rotationState: .constant(.init()), labelConfiguration: .constant(.init()), editMode: .constant(.rotate))
}
