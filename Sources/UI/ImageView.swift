import UIKit


@objc(JetPack_ImageView)
open class ImageView: View {

	public typealias Session = _ImageViewSession
	public typealias SessionListener = _ImageViewSessionListener
	public typealias Source = _ImageViewSource

	fileprivate var activityIndicatorIsVisible = false
	fileprivate var imageLayer = ImageLayer()
	fileprivate var isLayouting = false
	fileprivate var isSettingImage = false
	fileprivate var isSettingImageFromSource = false
	fileprivate var isSettingSource = false
	fileprivate var isSettingSourceFromImage = false
	fileprivate var lastAppliedImageColor: UIColor?
	fileprivate var lastLayoutedSize = CGSize()
	fileprivate var sourceImageRetrievalCompleted = false
	fileprivate var sourceSession: Session?
	fileprivate var sourceSessionConfigurationIsValid = true
	fileprivate var colorizedImage: UIImage?

	public var imageChanged: Closure?
	public var sourceTransitionDuration = TimeInterval(0)


	public override init() {
		super.init()

		isUserInteractionEnabled = false

		layer.addSublayer(imageLayer)
	}


	public required init?(coder: NSCoder) {
		super.init(coder: coder)
	}


	deinit {
		sourceSession?.stopRetrievingImage()
	}


	fileprivate var _activityIndicator: UIActivityIndicatorView?
	public final var activityIndicator: UIActivityIndicatorView {
		return _activityIndicator ?? {
			let child = UIActivityIndicatorView(style: .gray)
			child.hidesWhenStopped = false
			child.alpha = 0
			child.startAnimating()

			_activityIndicator = child

			return child
		}()
	}


	fileprivate var activityIndicatorShouldBeVisible: Bool {
		guard showsActivityIndicatorWhileLoading else {
			return false
		}
		guard source != nil && !sourceImageRetrievalCompleted else {
			return false
		}

		return true
	}


	fileprivate func computeImageLayerFrame() -> CGRect {
		guard let image = jpImage else {
			return .zero
		}

		let imageSize = image.size
		let maximumImageLayerFrame = CGRect(size: bounds.size).inset(by: padding)

		guard imageSize.isPositive && maximumImageLayerFrame.size.isPositive else {
			return .zero
		}

		let gravity = self.gravity
		let scaling = self.scaling

		var imageLayerFrame = CGRect()

		switch scaling {
		case .fitIgnoringAspectRatio:
			imageLayerFrame.size = maximumImageLayerFrame.size

		case .fitInside, .fitOutside:
			let horizontalScale = maximumImageLayerFrame.width / imageSize.width
			let verticalScale = maximumImageLayerFrame.height / imageSize.height
			let scale = (scaling == .fitInside ? min : max)(horizontalScale, verticalScale)

			imageLayerFrame.size = imageSize.scale(by: scale)

		case .fitHorizontally:
			imageLayerFrame.widthFromLeft = maximumImageLayerFrame.width
			imageLayerFrame.heightFromTop = imageSize.height * (imageLayerFrame.width / imageSize.width)

		case .fitHorizontallyIgnoringAspectRatio:
			imageLayerFrame.widthFromLeft = maximumImageLayerFrame.width
			imageLayerFrame.heightFromTop = imageSize.height

		case .fitVertically:
			imageLayerFrame.heightFromTop = maximumImageLayerFrame.height
			imageLayerFrame.widthFromLeft = imageSize.width * (imageLayerFrame.height / imageSize.height)

		case .fitVerticallyIgnoringAspectRatio:
			imageLayerFrame.heightFromTop = maximumImageLayerFrame.height
			imageLayerFrame.widthFromLeft = imageSize.width

		case .none:
			imageLayerFrame.size = imageSize
		}

		switch gravity.horizontal {
		case .left:
			imageLayerFrame.left = maximumImageLayerFrame.left

		case .center:
			imageLayerFrame.horizontalCenter = maximumImageLayerFrame.horizontalCenter

		case .right:
			imageLayerFrame.right = maximumImageLayerFrame.right
		}

		switch gravity.vertical {
		case .top:
			imageLayerFrame.top = maximumImageLayerFrame.top

		case .center:
			imageLayerFrame.verticalCenter = maximumImageLayerFrame.verticalCenter

		case .bottom:
			imageLayerFrame.bottom = maximumImageLayerFrame.bottom
		}

		switch image.imageOrientation {
		case .left, .leftMirrored, .right, .rightMirrored:
			let center = imageLayerFrame.center

			let imageLayerFrameWidth = imageLayerFrame.width
			let imageLayerFrameHeight = imageLayerFrame.height
			imageLayerFrame.widthFromLeft = imageLayerFrameHeight
			imageLayerFrame.heightFromTop = imageLayerFrameWidth

			imageLayerFrame.center = center

		case .down, .downMirrored, .up, .upMirrored:
			break

		@unknown default:
			break
		}

		imageLayerFrame = alignToGrid(imageLayerFrame)

		return imageLayerFrame
	}


	fileprivate func computeImageLayerTransform() -> CGAffineTransform {
		guard let image = jpImage else {
			return CGAffineTransform.identity
		}

		// TODO support mirrored variants
		let transform: CGAffineTransform
		switch image.imageOrientation {
		case .down:          transform = CGAffineTransform(rotationAngle: .pi)
		case .downMirrored:  transform = CGAffineTransform(rotationAngle: .pi)
		case .left:          transform = CGAffineTransform(rotationAngle: -.pi / 2)
		case .leftMirrored:  transform = CGAffineTransform(rotationAngle: -.pi / 2)
		case .right:         transform = CGAffineTransform(rotationAngle: .pi / 2)
		case .rightMirrored: transform = CGAffineTransform(rotationAngle: .pi / 2)
		case .up:            transform = CGAffineTransform.identity
		case .upMirrored:    transform = CGAffineTransform.identity
		@unknown default:    transform = CGAffineTransform.identity
		}

		return transform
	}


	@available(*, unavailable, message: "Use .gravity and .scaling instead.")
	public final override var contentMode: UIView.ContentMode {
		get { return super.contentMode }
		set { super.contentMode = newValue }
	}


	open override func didMoveToWindow() {
		super.didMoveToWindow()

		if window != nil {
			setNeedsLayout()
		}
	}


	open var gravity = Gravity.center {
		didSet {
			guard gravity != oldValue else {
				return
			}

			setNeedsLayout()

			invalidateConfiguration()
		}
	}


	open var jpImage: UIImage? {
		didSet {
			precondition(!isSettingImage, "Cannot recursively set ImageView's 'image'.")
			precondition(!isSettingSource || isSettingImageFromSource, "Cannot recursively set ImageView's 'image' and 'source'.")

			isSettingImage = true
			defer { isSettingImage = false }

			guard jpImage != oldValue || (oldValue == nil && source != nil) else { // TODO what if the current image is set again manually? source should be unset?
				return
			}

			if !isSettingImageFromSource {
				isSettingSourceFromImage = true
				source = nil
				isSettingSourceFromImage = false
			}

			lastAppliedImageColor = nil

			setNeedsLayout()

			if (jpImage?.size ?? .zero) != (oldValue?.size ?? .zero) {
				invalidateIntrinsicContentSize()
			}

			updateActivityIndicatorAnimated(true)
		}
	}


	open var imageColor = UIColor.tint {
		didSet {
			guard imageColor != oldValue else {
				return
			}

			setNeedsLayout()
		}
	}


	open override var intrinsicContentSize: CGSize {
		return sizeThatFits()
	}


	fileprivate func invalidateConfiguration() {
		guard sourceSessionConfigurationIsValid else {
			return
		}

		sourceSessionConfigurationIsValid = false
		setNeedsLayout()
	}


	open override func layoutSubviews() {
		isLayouting = true
		defer { isLayouting = false }

		super.layoutSubviews()

		let bounds = self.bounds
		if bounds.size != lastLayoutedSize {
			lastLayoutedSize = bounds.size
			sourceSessionConfigurationIsValid = false
		}

		if let activityIndicator = _activityIndicator {
			activityIndicator.center = bounds.inset(by: padding).center
		}

		let imageLayerFrame = computeImageLayerFrame()
		imageLayer.bounds = CGRect(size: imageLayerFrame.size)
		imageLayer.position = imageLayerFrame.center

		if let image = jpImage, image.renderingMode == .alwaysTemplate {
			let actualImageColor = imageColor.tinted(for: self, dimsWithTint: true)
			if actualImageColor != lastAppliedImageColor {
				lastAppliedImageColor = actualImageColor

				colorizedImage = image.imageWithColor(actualImageColor)
			}
		}
		else {
			colorizedImage = nil
		}

		if let contentImage = colorizedImage ?? jpImage {
			imageLayer.contents = contentImage.cgImage
			imageLayer.contentsScale = contentImage.scale
			imageLayer.transform = CATransform3DMakeAffineTransform(computeImageLayerTransform())

			let capInsets = contentImage.capInsets
			let imageSize = contentImage.size

			if capInsets.isEmpty || !imageSize.isPositive {
				imageLayer.contentsCenter = CGRect(width: 1, height: 1)
			}
			else {
				imageLayer.contentsCenter = CGRect(
					left:   capInsets.left / imageSize.width,
					top:    capInsets.top / imageSize.height,
					width:  (imageSize.width - capInsets.right - capInsets.left) / imageSize.width,
					height: (imageSize.height - capInsets.top - capInsets.bottom) / imageSize.height
				)
			}
		}
		else {
			imageLayer.contents = nil
			imageLayer.transform = CATransform3DIdentity
		}

		startOrUpdateSourceSession()
	}


	open override func measureOptimalSize(forAvailableSize availableSize: CGSize) -> CGSize {
		let fittingSize: CGSize

		let availableSize = availableSize.inset(by: padding)
		if availableSize.isPositive, let imageSize = jpImage?.size, imageSize.isPositive {
			let imageRatio = imageSize.width / imageSize.height

			switch scaling {
			case .fitHorizontally,
			     .fitHorizontallyIgnoringAspectRatio:

				fittingSize = CGSize(
					width:  availableSize.width,
					height: availableSize.width / imageRatio
				)

			case .fitVertically,
			     .fitVerticallyIgnoringAspectRatio:

				fittingSize = CGSize(
					width:  availableSize.height * imageRatio,
					height: availableSize.height
				)

			case .fitIgnoringAspectRatio,
			     .fitInside,
			     .fitOutside,
			     .none:

				fittingSize = imageSize
			}
		}
		else {
			fittingSize = .zero
		}

		return CGSize(
			width:  fittingSize.width  + padding.left + padding.right,
			height: fittingSize.height + padding.top  + padding.bottom
		)
	}


	public var optimalImageScale: CGFloat {
		return gridScaleFactor
	}


	public var optimalImageSize: CGSize {
		let size = bounds.size.inset(by: padding)
		guard size.width > 0 && size.height > 0 else {
			return .zero
		}

		return size
	}


	open var padding = UIEdgeInsets() {
		didSet {
			if padding == oldValue {
				return
			}

			setNeedsLayout()

			invalidateConfiguration()
			invalidateIntrinsicContentSize()
		}
	}


	open override var preferredSize: PartialSize {
		didSet {
			guard preferredSize != oldValue else {
				return
			}

			invalidateConfiguration()
		}
	}


	open var scaling = Scaling.fitInside {
		didSet {
			guard scaling != oldValue else {
				return
			}

			setNeedsLayout()

			invalidateConfiguration()
		}
	}


	open var showsActivityIndicatorWhileLoading = true {
		didSet {
			guard showsActivityIndicatorWhileLoading != oldValue else {
				return
			}

			updateActivityIndicatorAnimated(true)
		}
	}


	open var source: Source? {
		didSet {
			precondition(!isSettingSource, "Cannot recursively set ImageView's 'source'.")
			precondition(!isSettingSource || isSettingSourceFromImage, "Cannot recursively set ImageView's 'source' and 'image'.")

			if let source = source, let oldSource = oldValue, source.equals(oldSource) {
				if sourceImageRetrievalCompleted && jpImage == nil {
					stopSourceSession()
					startOrUpdateSourceSession()

					updateActivityIndicatorAnimated(true)
				}

				return
			}
			if source == nil && oldValue == nil {
				return
			}

			isSettingSource = true
			defer {
				isSettingSource = false
			}

			stopSourceSession()

			if !isSettingSourceFromImage {
				isSettingImageFromSource = true
				jpImage = nil
				isSettingImageFromSource = false
			}

			if source != nil {
				sourceSessionConfigurationIsValid = false
				startOrUpdateSourceSession()
			}

			updateActivityIndicatorAnimated(true)
		}
	}


	fileprivate func startOrUpdateSourceSession() {
		guard !sourceSessionConfigurationIsValid && window != nil && (isLayouting || !needsLayout), let source = source else {
			return
		}

		let optimalImageSize = self.optimalImageSize
		guard !optimalImageSize.isEmpty else {
			return
		}

		sourceSessionConfigurationIsValid = true

		if let sourceSession = sourceSession {
			sourceSession.imageViewDidChangeConfiguration(self)
		}
		else {
			if let sourceSession = source.createSession() {
				let listener = ClosureSessionListener { [weak self] image in
					precondition(Thread.isMainThread, "ImageView.SessionListener.sessionDidRetrieveImage(_:) must be called on the main thread.")

					guard let imageView = self else {
						return
					}

					if sourceSession !== imageView.sourceSession {
						log("ImageView.SessionListener.sessionDidRetrieveImage(_:) was called after session was stopped. The call will be ignored.")
						return
					}
					if imageView.isSettingImageFromSource {
						log("ImageView.SessionListener.sessionDidRetrieveImage(_:) was called from within an 'image' property observer. The call will be ignored.")
						return
					}

					imageView.sourceImageRetrievalCompleted = true

					imageView.isSettingImageFromSource = true
					imageView.jpImage = image
					imageView.isSettingImageFromSource = false

					imageView.updateActivityIndicatorAnimated(true)

					// we only transition from an empty ImageView and not if there was another image shown (which can happen if the image is loaded instantly)
					let transitionDuration = imageView.sourceTransitionDuration
					if transitionDuration > 0 && imageView.imageLayer.presentation()?.contents == nil {
						let transition = CATransition()
						transition.duration = transitionDuration
						imageView.imageLayer.add(transition, forKey: kCATransition)
					}

					imageView.imageChanged?()
				}

				self.sourceSession = sourceSession

				sourceSession.startRetrievingImageForImageView(self, listener: listener)
			}
			else if let image = source.staticImage {
				sourceImageRetrievalCompleted = true

				isSettingImageFromSource = true
				self.jpImage = image
				isSettingImageFromSource = false

				updateActivityIndicatorAnimated(true)
			}
		}
	}


	fileprivate func stopSourceSession() {
		guard let sourceSession = sourceSession else {
			return
		}

		sourceImageRetrievalCompleted = false
		self.sourceSession = nil

		sourceSession.stopRetrievingImage()
	}


	open override func tintColorDidChange() {
		super.tintColorDidChange()

		if imageColor.isTint {
			setNeedsLayout()
		}
	}


	fileprivate func updateActivityIndicatorAnimated(_ animated: Bool) {
		let animation = animated ? Animation() : nil

		if activityIndicatorShouldBeVisible {
			guard !activityIndicatorIsVisible else {
				return
			}

			let activityIndicator = self.activityIndicator

			activityIndicatorIsVisible = true

			addSubview(activityIndicator)

			animation.runAlways {
				activityIndicator.alpha = 1
			}
		}
		else {
			guard activityIndicatorIsVisible, let activityIndicator = _activityIndicator else {
				return
			}

			activityIndicatorIsVisible = false

			animation.runAlwaysWithCompletion { complete in
				activityIndicator.alpha = 0

				complete { _ in
					if !self.activityIndicatorIsVisible {
						activityIndicator.removeFromSuperview()
					}
				}
			}
		}
	}



	public enum Gravity {
		case bottomCenter
		case bottomLeft
		case bottomRight
		case center
		case centerLeft
		case centerRight
		case topCenter
		case topLeft
		case topRight


		public init(horizontal: Horizontal, vertical: Vertical) {
			switch vertical {
			case .bottom:
				switch horizontal {
					case .left:   self = .bottomLeft
					case .center: self = .bottomCenter
					case .right:  self = .bottomRight
				}

			case .center:
				switch horizontal {
					case .left:   self = .centerLeft
					case .center: self = .center
					case .right:  self = .centerRight
				}

			case .top:
				switch horizontal {
				case .left:   self = .topLeft
				case .center: self = .topCenter
				case .right:  self = .topRight
				}
			}
		}


		public var horizontal: Horizontal {
			switch self {
			case .bottomLeft, .centerLeft, .topLeft:
				return .left

			case .bottomCenter, .center, .topCenter:
				return .center

			case .bottomRight, .centerRight, .topRight:
				return .right
			}
		}


		public var vertical: Vertical {
			switch self {
			case .bottomCenter, .bottomLeft, .bottomRight:
				return .bottom

			case .center, .centerLeft, .centerRight:
				return .center

			case .topCenter, .topLeft, .topRight:
				return .top
			}
		}



		public enum Horizontal {
			case center
			case left
			case right
		}


		public enum Vertical {
			case bottom
			case center
			case top
		}
	}


	public enum Scaling {
		case fitHorizontally
		case fitHorizontallyIgnoringAspectRatio
		case fitIgnoringAspectRatio
		case fitInside
		case fitOutside
		case fitVertically
		case fitVerticallyIgnoringAspectRatio
		case none
	}
}


public protocol _ImageViewSession: class {

	func imageViewDidChangeConfiguration  (_ imageView: ImageView)
	func startRetrievingImageForImageView (_ imageView: ImageView, listener: ImageView.SessionListener)
	func stopRetrievingImage              ()
}


public protocol _ImageViewSessionListener {

	func sessionDidFailToRetrieveImageWithFailure (_ failure: Failure)
	func sessionDidRetrieveImage                  (_ image: UIImage)
}


public protocol _ImageViewSource {

	var staticImage: UIImage? { get }

	func createSession () -> ImageView.Session?
	func equals        (_ source: ImageView.Source) -> Bool
}


extension _ImageViewSource {

	public var staticImage: UIImage? {
		return nil
	}
}


extension _ImageViewSource where Self: Equatable {

	public func equals(_ source: ImageView.Source) -> Bool {
		guard let source = source as? Self else {
			return false
		}

		return self == source
	}
}



private struct ClosureSessionListener: ImageView.SessionListener {

	fileprivate let didRetrieveImage: (UIImage) -> Void


	fileprivate init(didRetrieveImage: @escaping (UIImage) -> Void) {
		self.didRetrieveImage = didRetrieveImage
	}


	fileprivate func sessionDidFailToRetrieveImageWithFailure(_ failure: Failure) {
		// TODO support this case
	}


	fileprivate func sessionDidRetrieveImage(_ image: UIImage) {
		didRetrieveImage(image)
	}
}



private final class ImageLayer: Layer {

	fileprivate override func action(forKey event: String) -> CAAction? {
		return nil
	}
}
