
import PencilKit

final class MYCanvasEditor: PKCanvasView {

    required init?(coder: NSCoder) { fatalError() }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureCanvas()
    }
}

// MARK: - Setup Views
private extension MYCanvasEditor {
    func configureCanvas() {
        isScrollEnabled = false
        backgroundColor = .clear
        drawingPolicy = .anyInput
    }
}

// MARK: - Rotation Handling
extension MYCanvasEditor: MYRotatableCanvasDelegate {
    func rotateContent(clockwise: Bool) {
        let rotatedStrokes = drawing.strokes.map { stroke in
            PKStroke(
                ink: stroke.ink,
                path: PKStrokePath(
                    controlPoints: stroke.path.map { point in
                        PKStrokePoint(
                            location: point.location.applying(rotationTransform(clockwise: clockwise)),
                            timeOffset: point.timeOffset,
                            size: point.size,
                            opacity: point.opacity,
                            force: point.force,
                            azimuth: point.azimuth,
                            altitude: point.altitude
                        )
                    },
                    creationDate: stroke.path.creationDate
                ),
                transform: .identity,
                mask: stroke.mask
            )
        }
        drawing = PKDrawing(strokes: rotatedStrokes)
    }
}
