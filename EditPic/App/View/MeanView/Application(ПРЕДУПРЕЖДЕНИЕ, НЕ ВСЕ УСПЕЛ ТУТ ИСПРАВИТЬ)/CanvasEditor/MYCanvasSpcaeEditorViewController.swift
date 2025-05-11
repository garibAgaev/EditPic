//import PencilKit
//
//class MYCanvasSpcaeEditorViewController: UIViewController {
//    
//    private enum RotateState {
//        case top, left, right, bottom
//    }
//        
//    var delegate: MYTextEditingCanvasDelegate? {
//        get { textView.delegate }
//        set { textView.delegate = newValue }
//    }
//    
//    private let rootScrollView = UIScrollView()
//    private let contentView = UIView()
//    private var imageView = MYImageEditorCanvas()
//    private var canvasView = MYCanvasEditor()
//    private var textView = MYTextEditingCanvas()
//    
//    private let toolPicker = PKToolPicker()
//        
//    private var needsInitialLayoutUpdate = true
//
//    var image: UIImage? {
//        get { imageView.image }
//        set { setImageAndResetRotation(newValue) }
//    }
//        
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        setupRootScrollView()
//        setupSubviews()
//        setupConstraintsToRootScrollView()
//    }
//        
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        updateZoomScaleLimits()
//        updateScrollViewInsets()
//        if needsInitialLayoutUpdate {
//            needsInitialLayoutUpdate = false
//            rootScrollView.setZoomScale(min(rootScrollView.maximumZoomScale, rootScrollView.minimumZoomScale), animated: false)
//        }
//        print(contentView.frame)
//    }
//    
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        super.viewWillTransition(to: size, with: coordinator)
//        needsInitialLayoutUpdate = true
//        coordinator.animate { [weak self] context in
//            self?.updateZoomScaleLimits()
//            self?.updateScrollViewInsets()
//        } completion: { context in
//            
//        }
//        print(contentView.frame)
//    }
//}
//
//// MARK: - Public API
//extension MYCanvasSpcaeEditorViewController {
//    func updateActiveLabel(with config: MYLabelConfiguration) {
//        textView.updateActiveLabel(with: config)
//    }
//
//    func clearActiveLabel() {
//        textView.clearActiveLabel()
//    }
//}
//
//
////MARK: SetupViews
//private extension MYCanvasSpcaeEditorViewController {
//    func setupSubviews() {
//        
//        setupImageView()
//        setupCanvasView()
//        setupTextView()
//
//        setupConstraints()
//    }
//    
//    func setupRootScrollView() {
//        view.addSubview(rootScrollView)
//        rootScrollView.addInteraction(UIDropInteraction(delegate: self))
//        rootScrollView.delegate = self
//        rootScrollView.addSubview(contentView)
//        rootScrollView.translatesAutoresizingMaskIntoConstraints = false
//    }
//    
//    func setupImageView() {
//        contentView.addSubview(imageView)
//        imageView.contentMode = .scaleAspectFit
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//    }
//    
//    func setupCanvasView() {
//        contentView.addSubview(canvasView)
//        configureCanvasViewInteraction(false)
//        canvasView.translatesAutoresizingMaskIntoConstraints = false
//    }
//    
//    func setupTextView() {
//        contentView.addSubview(textView)
//        textView.delegate = delegate
//        configureTextViewInteraction(false)
//        textView.translatesAutoresizingMaskIntoConstraints = false
//    }
//        
//    func setupConstraintsToRootScrollView() {
//        NSLayoutConstraint.activate([
//            rootScrollView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor),
//            rootScrollView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor),
//            rootScrollView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
//            rootScrollView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
//        ])
//    }
//    
//    func setupConstraints() {
//        NSLayoutConstraint.activate([
//            imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
//            imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor),
//            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
//            imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
//            
//            canvasView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
//            canvasView.heightAnchor.constraint(equalTo: contentView.heightAnchor),
//            canvasView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
//            canvasView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
//            
//            textView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
//            textView.heightAnchor.constraint(equalTo: contentView.heightAnchor),
//            textView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
//            textView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
//        ])
//    }
//}
//
////MARK: TextSpace
//extension MYCanvasSpcaeEditorViewController {
//    func configureTextViewInteraction(_ isEnabled: Bool) {
//        textView.isUserInteractionEnabled = isEnabled
//        updateScrollViewScrolling()
//    }
//}
//
////MARK: Canvas
//extension MYCanvasSpcaeEditorViewController {
//    func configureCanvasViewInteraction(_ isEnabled: Bool) {
//        if isEnabled {
//            canvasView.isUserInteractionEnabled = true
//            toolPicker.setVisible(true, forFirstResponder: canvasView)
//            toolPicker.addObserver(canvasView)
//            canvasView.becomeFirstResponder()
//        } else {
//            canvasView.isUserInteractionEnabled = false
//        }
//        
//        updateScrollViewScrolling()
//    }
//}
//
////MARK: SystemSetting
//extension MYCanvasSpcaeEditorViewController {
//    func updateZoomScaleLimits() {
//        let imageSize = image?.size ?? .zero
//        let heightRatio = rootScrollView.bounds.height / imageSize.height
//        let widthRatio = rootScrollView.bounds.width / imageSize.width
//        rootScrollView.maximumZoomScale = max(widthRatio, heightRatio)
//        rootScrollView.minimumZoomScale = min(widthRatio, heightRatio)
//    }
//    
//    func updateScrollViewInsets() {
//        let size = 0.5 * .max(.zero, rootScrollView.bounds.size - rootScrollView.contentSize)
//
//        rootScrollView.contentInset = UIEdgeInsets(
//            top: size.height,
//            left: size.width,
//            bottom: size.height,
//            right: size.width
//        )
//    }
//
//    func setImageAndResetRotation(_ newImage: UIImage?) {
//        needsInitialLayoutUpdate = true
//
//        imageView.image = newImage
//                
//        contentView.bounds = CGRect(origin: .zero, size: newImage?.size ?? .zero)
//        contentView.frame.origin = .zero
//        
//        contentView.layoutIfNeeded()
//    }
//    
//    func updateScrollViewScrolling() {
//        rootScrollView.isScrollEnabled = !textView.isUserInteractionEnabled && !canvasView.isUserInteractionEnabled
//    }
//}
//
////MARK: MYRotatableCanvasDelegate
//extension MYCanvasSpcaeEditorViewController {
//    func rotateContent(clockwise: Bool) {
//        imageView.rotateContent(clockwise: clockwise)
//        canvasView.rotateContent(clockwise: clockwise)
//        textView.rotateContent(clockwise: clockwise)
//        
//        image = imageView.image
//    }
//}
//
////MARK: UIScrollViewDelegate
//extension MYCanvasSpcaeEditorViewController: UIScrollViewDelegate {
//    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
//        contentView
//    }
//    
//    func scrollViewDidZoom(_ scrollView: UIScrollView) {
//        updateScrollViewInsets()
//    }
//}
//
//// MARK: - Drop Interaction
//
//extension MYCanvasSpcaeEditorViewController: UIDropInteractionDelegate {
//    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
//        session.loadObjects(ofClass: NSString.self) { [weak self] items in
//            Task { @MainActor [weak self] in
//                guard let self, let text = items.first as? String else { return }
//
//                let location = textView.convert(session.location(in: rootScrollView), from: rootScrollView)
//                
//                textView.addLabel(
//                    MYLabelConfiguration(text: text),
//                    location: location
//                )
//            }
//        }
//    }
//
//    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
//        session.canLoadObjects(ofClass: NSString.self)
//    }
//
//    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
//        UIDropProposal(operation: .copy)
//    }
//}


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
