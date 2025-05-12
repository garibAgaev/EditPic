import PencilKit

final class MYCanvasSpaceEditorViewController: UIViewController {
    
    // MARK: - Nested Types
    
    private enum RotationState {
        case top, left, right, bottom
    }
    
    // MARK: - Public Properties
    
    var delegate: MYTextEditingCanvasDelegate? {
        get { textLayer.delegate }
        set { textLayer.delegate = newValue }
    }

    var image: UIImage? {
        get { imageLayer.image }
        set { setImageAndResetRotation(to: newValue) }
    }

    // MARK: - Private Properties

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let imageLayer = MYImageEditorCanvas()
    private let drawingLayer = MYCanvasEditor()
    private let textLayer = MYTextEditingCanvas()

    private let toolPicker = PKToolPicker()
    
    private var needsZoomReset = true

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewHierarchy()
        setupConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateZoomScales()
        updateScrollInsets()
        
        if needsZoomReset {
            needsZoomReset = false
            scrollView.setZoomScale(min(scrollView.maximumZoomScale, scrollView.minimumZoomScale), animated: false)
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        needsZoomReset = true

        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.updateZoomScales()
            self?.updateScrollInsets()
        })
    }
}

// MARK: - Public API

extension MYCanvasSpaceEditorViewController {
    func updateActiveLabel(with config: MYLabelConfiguration) {
        textLayer.updateActiveLabel(with: config)
    }

    func clearActiveLabel() {
        textLayer.clearActiveLabel()
    }
}

// MARK: - Setup

private extension MYCanvasSpaceEditorViewController {
    func setupViewHierarchy() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.delegate = self
        scrollView.addInteraction(UIDropInteraction(delegate: self))
        scrollView.addSubview(contentView)

        [imageLayer, drawingLayer, textLayer].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        drawingLayer.isUserInteractionEnabled = false
        textLayer.isUserInteractionEnabled = false
        textLayer.delegate = delegate
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        for layer in [imageLayer, drawingLayer, textLayer] {
            NSLayoutConstraint.activate([
                layer.widthAnchor.constraint(equalTo: contentView.widthAnchor),
                layer.heightAnchor.constraint(equalTo: contentView.heightAnchor),
                layer.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                layer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
            ])
        }
    }
}

// MARK: - Canvas & Text Interaction

extension MYCanvasSpaceEditorViewController {
    func enableCanvasInteraction(_ isEnabled: Bool) {
        drawingLayer.isUserInteractionEnabled = isEnabled

        if isEnabled {
            toolPicker.setVisible(true, forFirstResponder: drawingLayer)
            toolPicker.addObserver(drawingLayer)
            drawingLayer.becomeFirstResponder()
        }

        updateScrollEnabledState()
    }

    func enableTextInteraction(_ isEnabled: Bool) {
        textLayer.isUserInteractionEnabled = isEnabled
        updateScrollEnabledState()
    }

    private func updateScrollEnabledState() {
        scrollView.isScrollEnabled = !(textLayer.isUserInteractionEnabled || drawingLayer.isUserInteractionEnabled)
    }
}

// MARK: - Image & Zoom

private extension MYCanvasSpaceEditorViewController {
    func updateZoomScales() {
        guard let imageSize = image?.size, imageSize != .zero else { return }

        let widthRatio = scrollView.bounds.width / imageSize.width
        let heightRatio = scrollView.bounds.height / imageSize.height

        scrollView.minimumZoomScale = min(widthRatio, heightRatio)
        scrollView.maximumZoomScale = max(widthRatio, heightRatio)
    }

    func updateScrollInsets() {
        let insetWidth = max(0, (scrollView.bounds.width - scrollView.contentSize.width) / 2)
        let insetHeight = max(0, (scrollView.bounds.height - scrollView.contentSize.height) / 2)

        scrollView.contentInset = UIEdgeInsets(top: insetHeight, left: insetWidth, bottom: insetHeight, right: insetWidth)
    }

    func setImageAndResetRotation(to newImage: UIImage?) {
        needsZoomReset = true
        imageLayer.image = newImage

        contentView.bounds = CGRect(origin: .zero, size: newImage?.size ?? .zero)
        contentView.frame.origin = .zero

        contentView.layoutIfNeeded()
    }
}

// MARK: - Rotation

extension MYCanvasSpaceEditorViewController {
    func rotateContent(clockwise: Bool) {
        [imageLayer, drawingLayer, textLayer].forEach { (view: MYRotatableCanvasDelegate) in
            view.rotateContent(clockwise: clockwise)
        }

        image = imageLayer.image
    }
}

// MARK: - UIScrollViewDelegate

extension MYCanvasSpaceEditorViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        contentView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateScrollInsets()
    }
}

// MARK: - UIDropInteractionDelegate

extension MYCanvasSpaceEditorViewController: UIDropInteractionDelegate {
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        session.canLoadObjects(ofClass: NSString.self)
    }

    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        UIDropProposal(operation: .copy)
    }

    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        session.loadObjects(ofClass: NSString.self) { [weak self] items in
            Task { @MainActor [weak self] in
                guard let self, let text = items.first as? String else { return }

                let location = textLayer.convert(session.location(in: scrollView), from: scrollView)
                textLayer.addLabel(MYLabelConfiguration(text: text), location: location)
            }
        }
    }
}
