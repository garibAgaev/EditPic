
import UIKit

final class MYTextEditingCanvas: UIView {

    weak var delegate: MYTextEditingCanvasDelegate?
    private var activeLabel: MYLabel?

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureCanvas()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let result = super.hitTest(point, with: event), result is UILabel {
            return result
        } else {
            return nil
        }
    }

    @objc private func handleLabelTap(_ gesture: UITapGestureRecognizer) {
        guard let label = gesture.view as? MYLabel else { return }
        activeLabel = label
        highlightActiveLabel()
        delegate?.textEditingCanvas(
            self,
            didSelectLabel: MYLabelConfiguration(
                text: label.text ?? "",
                alpha: label.alpha,
                font: label.font,
                textColor: label.textColor,
                rotationAngle: atan2(label.transform.b, label.transform.a)
            )
        )
    }

    @objc private func handleLabelPan(_ gesture: UIPanGestureRecognizer) {
        guard let label = gesture.view as? MYLabel else { return }
        let location = gesture.location(in: self)

        label.centerXConstraint?.constant = location.x
        label.centerYConstraint?.constant = location.y
        
        layoutIfNeeded()
        confineLabelToBounds(label)
    }
}

// MARK: - Public API

extension MYTextEditingCanvas {
    func updateActiveLabel(with config: MYLabelConfiguration) {
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let label = self?.activeLabel else { return }
            label.text = config.text
            label.font = config.font
            label.textColor = config.textColor
            label.alpha = config.alpha
            label.transform = CGAffineTransform(rotationAngle: config.rotationAngle)
            self?.adjustFontToFit(label)
        }
    }

    func clearActiveLabel() {
        if activeLabel?.text?.isEmpty ?? true {
            activeLabel?.removeFromSuperview()
        } else {
            removeHighlightFromActiveLabel()
            activeLabel = nil
        }
    }
    
    func addLabel(_ labelConfiguration: MYLabelConfiguration, location: CGPoint) {
        guard !labelConfiguration.text.isEmpty else { return }
        guard bounds.contains(location) else { return }
        let label = MYLabel()
        addSubview(label)

        label.numberOfLines = 0
        label.isUserInteractionEnabled = true
        
        label.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.handleLabelTap)
        ))
        label.addGestureRecognizer(UIPanGestureRecognizer(
            target: self,
            action: #selector(self.handleLabelPan)
        ))
        
        label.centerXConstraint = label.centerXAnchor.constraint(equalTo: leadingAnchor, constant: location.x)
        label.centerYConstraint = label.centerYAnchor.constraint(equalTo: topAnchor, constant: location.y)
        
        update(label, with: labelConfiguration)
        adjustFontToFit(label)
    }
}

// MARK: - Setup

private extension MYTextEditingCanvas {
    func configureCanvas() {
        backgroundColor = .clear
    }
}

// MARK: - Label Highlighting

private extension MYTextEditingCanvas {
    func highlightActiveLabel() {
        activeLabel?.layer.borderColor = UIColor.systemGray.cgColor
        activeLabel?.layer.borderWidth = 1.0
        activeLabel?.layer.cornerRadius = 8.0
        activeLabel?.layer.masksToBounds = true
    }

    func removeHighlightFromActiveLabel() {
        activeLabel?.layer.borderColor = nil
        activeLabel?.layer.borderWidth = 0.0
        activeLabel?.layer.cornerRadius = 0.0
        activeLabel?.layer.masksToBounds = false
    }
}

// MARK:

private extension MYTextEditingCanvas {
    func update(_ label: MYLabel, with config: MYLabelConfiguration) {
        label.text = config.text
        label.font = config.font
        label.textColor = config.textColor
        label.alpha = config.alpha
        label.transform = CGAffineTransform(rotationAngle: config.rotationAngle)
        adjustFontToFit(label)
    }
}

// MARK: - Bounds and Font Adjustment

private extension MYTextEditingCanvas {

    func maxAllowedLabelSize(for label: MYLabel) -> CGSize {
        let limitSize = CGSize.min(label.frame.size, frame.size)
        let scale = limitSize / label.frame.size
        return label.bounds.size * min(1, scale.width, scale.height)
    }

    func adjustFontToFit(_ label: MYLabel) {
        guard let text = label.text else { return }
        layoutIfNeeded()
        
        var upperBound = label.font.pointSize
        var lowerBound: CGFloat = 0
        let epsilon: CGFloat = 0.01
        let targetSize = maxAllowedLabelSize(for: label)

        while upperBound - lowerBound > epsilon {
            let midSize = (lowerBound + upperBound) / 2
            let testFont = label.font.withSize(midSize)
            let attributed = NSAttributedString(string: text, attributes: [.font: testFont])
            let bounding = attributed.boundingRect(
                with: bounds.size,
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                context: nil
            )

            if CGSize.max(bounding.size, targetSize) == targetSize {
                lowerBound = midSize
            } else {
                upperBound = midSize
            }
        }

        label.font = label.font.withSize(lowerBound)
        layoutIfNeeded()
        confineLabelToBounds(label)
    }

    func confineLabelToBounds(_ label: MYLabel) {
        label.centerXConstraint?.constant -= min(0, label.frame.minX)
        label.centerXConstraint?.constant -= max(0, label.frame.maxX - bounds.width)
        label.centerYConstraint?.constant -= min(0, label.frame.minY)
        label.centerYConstraint?.constant -= max(0, label.frame.maxY - bounds.height)
    }
}

// MARK: - Rotation Support

extension MYTextEditingCanvas: MYRotatableCanvasDelegate {
    func rotateContent(clockwise: Bool) {
        subviews
            .compactMap { $0 as? MYLabel }
            .forEach {
                let rotatedCenter = $0.center.applying(rotationTransform(clockwise: clockwise))
                $0.centerXConstraint?.constant = rotatedCenter.x
                $0.centerYConstraint?.constant = rotatedCenter.y
                $0.transform = $0.transform.concatenating(CGAffineTransform(rotationAngle: rotationAngle(clockwise: clockwise)))
            }
    }
}
