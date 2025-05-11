
import UIKit

extension MYRotatableCanvasDelegate {
    func rotationAngle(clockwise: Bool) -> CGFloat {
        clockwise ? 0.5 * .pi : 1.5 * .pi
    }

    func rotationTransform(clockwise: Bool) -> CGAffineTransform {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let angle = rotationAngle(clockwise: clockwise)
        return CGAffineTransform(translationX: -center.x, y: -center.y)
            .concatenating(CGAffineTransform(rotationAngle: angle))
            .concatenating(CGAffineTransform(translationX: center.y, y: center.x))
    }
}
