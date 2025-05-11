
import SwiftUI

class MYOrientationManager: ObservableObject {
    @Published private(set) var orientation: MYScreenOrientation = .vertical
    static let shared = MYOrientationManager()

    @objc private func orientationChanged() {
        updateOrientation()
    }

    private func updateOrientation() {
        let deviceOrientation = UIDevice.current.orientation
        switch deviceOrientation {
        case .landscapeLeft, .landscapeRight:
            orientation = .horizontal
        case .portrait, .portraitUpsideDown:
            orientation = .vertical
        default:
            break
        }
    }
    
    private init() {
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        updateOrientation()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(orientationChanged),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
