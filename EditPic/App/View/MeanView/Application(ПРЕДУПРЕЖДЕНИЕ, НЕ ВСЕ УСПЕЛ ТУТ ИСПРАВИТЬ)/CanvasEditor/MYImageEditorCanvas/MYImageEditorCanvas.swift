
import UIKit

final class MYImageEditorCanvas: UIImageView {
    
    private enum ImageRotationState {
        case upright, rotatedLeft, rotatedRight, upsideDown
    }
    
    private var rotatedImagesCache: [ImageRotationState: UIImage] = [:]
    private var currentRotationState: ImageRotationState = .upright
    
    private var flag = true
    
    required init?(coder: NSCoder) { fatalError() }
    required override init(image: UIImage?) { fatalError() }
    required override init(image: UIImage?, highlightedImage: UIImage?) { fatalError() }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureImageView()
    }
    
    override var image: UIImage? {
        get { super.image }
        set {
            super.image = newValue
            if flag {
                rotatedImagesCache[.upright] = newValue
                currentRotationState = .upright
                flag = true
            }
        }
    }
}

// MARK: - Setup Views
private extension MYImageEditorCanvas {
    func configureImageView() {
        contentMode = .scaleAspectFit
    }
}

// MARK: - Image Rotation Handling
extension MYImageEditorCanvas: MYRotatableCanvasDelegate {
    func rotateContent(clockwise: Bool) {
        switch currentRotationState {
        case .upsideDown:
            currentRotationState = clockwise ? .rotatedLeft : .rotatedRight
        case .rotatedLeft:
            currentRotationState = clockwise ? .upright : .upsideDown
        case .rotatedRight:
            currentRotationState = clockwise ? .upsideDown : .upright
        case .upright:
            currentRotationState = clockwise ? .rotatedRight : .rotatedLeft
        }

        if rotatedImagesCache[currentRotationState] == nil {
            rotatedImagesCache[currentRotationState] = createRotatedImage(by: getAngle(currentRotationState))
        }
        
        flag = false
        super.image = rotatedImagesCache[currentRotationState]
    }
    
    private func getAngle(_ imageRotationState: ImageRotationState) -> CGFloat {
        switch imageRotationState {
        case .upsideDown:
            return .pi
        case .rotatedLeft:
            return 1.5 * .pi
        case .rotatedRight:
            return 0.5 * .pi
        case .upright:
            return 0
        }

    }
    
    private func createRotatedImage(by angle: CGFloat) -> UIImage? {
        guard let originalImage = rotatedImagesCache[.upright] else { return nil }

        let rotatedSize = CGRect(origin: .zero, size: originalImage.size)
            .applying(CGAffineTransform(rotationAngle: angle)).size

        UIGraphicsBeginImageContextWithOptions(rotatedSize, false, originalImage.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        context.translateBy(x: 0.5 * rotatedSize.width, y: 0.5 * rotatedSize.height)
        context.rotate(by: angle)

        originalImage.draw(in: CGRect(
            x: -0.5 * originalImage.size.width,
            y: -0.5 * originalImage.size.height,
            width: originalImage.size.width,
            height: originalImage.size.height
        ))

        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return rotatedImage
    }
}
