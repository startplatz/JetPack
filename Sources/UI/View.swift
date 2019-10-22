import UIKit


@objc(JetPack_View)
open class View: UIImageView {

	private static let _dummyView = View()

	private var normalBackgroundColor: UIColor?
	private var normalBorderColor: UIColor?

	open var additionalHitZone = UIEdgeInsets() // TODO don't use UIEdgeInsets because actually we outset
    
	open var backgroundColorLocked = false
	open var hitZoneFollowsCornerRadius = true
	open var isUserInteractionLimitedToSubviews = false


	public init() {
		super.init(frame: .zero)
        isUserInteractionEnabled = true
		clipsToBounds = true
		backgroundColor = super.backgroundColor

		if let layerBorderColor = layer.borderColor {
			borderColor = UIColor(cgColor: layerBorderColor)
		}
	}


	public required init?(coder: NSCoder) {
		super.init(coder: coder)
        isUserInteractionEnabled = true
		backgroundColor = super.backgroundColor

		if let layerBorderColor = layer.borderColor {
			borderColor = UIColor(cgColor: layerBorderColor)
		}
	}


	open override func action(for layer: CALayer, forKey event: String) -> CAAction? {
		switch event {
		case "borderColor", "cornerRadius", "shadowColor", "shadowOffset", "shadowOpacity", "shadowPath", "shadowRadius":
			if
				let animation = super.action(for: layer, forKey: "opacity") as? NSObject,
				let basicAnimation = (animation as? CABasicAnimation) ?? (animation.value(forKey: "pendingAnimation") as? CABasicAnimation)
			{
				basicAnimation.fromValue = layer.value(forKey: event)
				basicAnimation.isRemovedOnCompletion = true
				basicAnimation.keyPath = event

				return basicAnimation
			}

			fallthrough

		default:
			return super.action(for: layer, forKey: event)
		}
	}


	@available(*, deprecated, message: "use Animation()")
	@nonobjc
	open class func animate(duration: TimeInterval, changes: @escaping () -> Void) {
		self.animate(withDuration: duration, delay: 0, options: [], animations: changes, completion: nil)
	}


	@available(*, deprecated, message: "use Animation()")
	@nonobjc
	open class func animate(duration: TimeInterval, changes: @escaping () -> Void, completion: @escaping (Bool) -> Void) {
		self.animate(withDuration: duration, delay: 0, options: [], animations: changes, completion: completion)
	}


	@available(*, deprecated, message: "use Animation()")
	@nonobjc
	open class func animate(duration: TimeInterval, options: UIView.AnimationOptions, changes: @escaping () -> Void) {
		self.animate(withDuration: duration, delay: 0, options: options, animations: changes, completion: nil)
	}


	@available(*, deprecated, message: "use Animation()")
	@nonobjc
	open class func animate(duration: TimeInterval, options: UIView.AnimationOptions, changes: @escaping () -> Void, completion: @escaping (Bool) -> Void) {
		self.animate(withDuration: duration, delay: 0, options: options, animations: changes, completion: completion)
	}


	@available(*, deprecated, message: "use Animation()")
	@nonobjc
	open class func animate(duration: TimeInterval, options: UIView.AnimationOptions, delay: TimeInterval, changes: @escaping () -> Void) {
		self.animate(withDuration: duration, delay: delay, options: options, animations: changes, completion: nil)
	}


	@available(*, deprecated, message: "use Animation()")
	@nonobjc
	open class func animate(duration: TimeInterval, options: UIView.AnimationOptions, delay: TimeInterval, changes: @escaping () -> Void, completion: @escaping (Bool) -> Void) {
		self.animate(withDuration: duration, delay: delay, options: options, animations: changes, completion: completion)
	}


	@available(*, deprecated, message: "use Animation()")
	@nonobjc
	open class func animate(duration: TimeInterval, usingSpringWithDamping damping: CGFloat, changes: @escaping () -> Void) {
		self.animate(withDuration: duration, delay: 0, usingSpringWithDamping: damping, initialSpringVelocity: 0, options: [], animations: changes, completion: nil)
	}


	@available(*, deprecated, message: "use Animation()")
	@nonobjc
	open class func animate(duration: TimeInterval, usingSpringWithDamping damping: CGFloat, changes: @escaping () -> Void, completion: @escaping (Bool) -> Void) {
		self.animate(withDuration: duration, delay: 0, usingSpringWithDamping: damping, initialSpringVelocity: 0, options: [], animations: changes, completion: completion)
	}


	@available(*, deprecated, message: "use Animation()")
	@nonobjc
	open class func animate(duration: TimeInterval, usingSpringWithDamping damping: CGFloat, options: UIView.AnimationOptions, changes: @escaping () -> Void) {
		self.animate(withDuration: duration, delay: 0, usingSpringWithDamping: damping, initialSpringVelocity: 0, options: options, animations: changes, completion: nil)
	}


	@available(*, deprecated, message: "use Animation()")
	@nonobjc
	open class func animate(duration: TimeInterval, usingSpringWithDamping damping: CGFloat, options: UIView.AnimationOptions, changes: @escaping () -> Void, completion: @escaping (Bool) -> Void) {
		self.animate(withDuration: duration, delay: 0, usingSpringWithDamping: damping, initialSpringVelocity: 0, options: options, animations: changes, completion: completion)
	}


	@available(*, deprecated, message: "use Animation()")
	@nonobjc
	open class func animate(duration: TimeInterval, usingSpringWithDamping damping: CGFloat, options: UIView.AnimationOptions, delay: TimeInterval, changes: @escaping () -> Void) {
		self.animate(withDuration: duration, delay: delay, usingSpringWithDamping: damping, initialSpringVelocity: 0, options: options, animations: changes, completion: nil)
	}


	@available(*, deprecated, message: "use Animation()")
	@nonobjc
	open class func animate(duration: TimeInterval, usingSpringWithDamping damping: CGFloat, options: UIView.AnimationOptions, delay: TimeInterval, changes: @escaping () -> Void, completion: @escaping (Bool) -> Void) {
		self.animate(withDuration: duration, delay: delay, usingSpringWithDamping: damping, initialSpringVelocity: 0, options: options, animations: changes, completion: completion)
	}


	@available(*, deprecated, message: "use Animation()")
	@nonobjc
	open class func animate(duration: TimeInterval, usingSpringWithDamping damping: CGFloat, initialSpringVelocity: CGFloat, changes: @escaping () -> Void) {
		self.animate(withDuration: duration, delay: 0, usingSpringWithDamping: damping, initialSpringVelocity: initialSpringVelocity, options: [], animations: changes, completion: nil)
	}


	@available(*, deprecated, message: "use Animation()")
	@nonobjc
	open class func animate(duration: TimeInterval, usingSpringWithDamping damping: CGFloat, initialSpringVelocity: CGFloat, changes: @escaping () -> Void, completion: @escaping (Bool) -> Void) {
		self.animate(withDuration: duration, delay: 0, usingSpringWithDamping: damping, initialSpringVelocity: initialSpringVelocity, options: [], animations: changes, completion: completion)
	}


	@available(*, deprecated, message: "use Animation()")
	@nonobjc
	open class func animate(duration: TimeInterval, usingSpringWithDamping damping: CGFloat, initialSpringVelocity: CGFloat, options: UIView.AnimationOptions, changes: @escaping () -> Void) {
		self.animate(withDuration: duration, delay: 0, usingSpringWithDamping: damping, initialSpringVelocity: initialSpringVelocity, options: options, animations: changes, completion: nil)
	}


	@available(*, deprecated, message: "use Animation()")
	@nonobjc
	open class func animate(duration: TimeInterval, usingSpringWithDamping damping: CGFloat, initialSpringVelocity: CGFloat, options: UIView.AnimationOptions, changes: @escaping () -> Void, completion: @escaping (Bool) -> Void) {
		self.animate(withDuration: duration, delay: 0, usingSpringWithDamping: damping, initialSpringVelocity: initialSpringVelocity, options: options, animations: changes, completion: completion)
	}


	@available(*, deprecated, message: "use Animation()")
	@nonobjc
	open class func animate(duration: TimeInterval, usingSpringWithDamping damping: CGFloat, initialSpringVelocity: CGFloat, options: UIView.AnimationOptions, delay: TimeInterval, changes: @escaping () -> Void) {
		self.animate(withDuration: duration, delay: delay, usingSpringWithDamping: damping, initialSpringVelocity: initialSpringVelocity, options: options, animations: changes, completion: nil)
	}


	@available(*, deprecated, message: "use Animation()")
	@nonobjc
	open class func animate(duration: TimeInterval, usingSpringWithDamping damping: CGFloat, initialSpringVelocity: CGFloat, options: UIView.AnimationOptions, delay: TimeInterval, changes: @escaping () -> Void, completion: @escaping (Bool) -> Void) {
		self.animate(withDuration: duration, delay: delay, usingSpringWithDamping: damping, initialSpringVelocity: initialSpringVelocity, options: options, animations: changes, completion: completion)
	}


	open override var backgroundColor: UIColor? {
		get { return normalBackgroundColor }
		set {
			guard !backgroundColorLocked && newValue != normalBackgroundColor else {
				return
			}

			normalBackgroundColor = newValue

			updateActualBackgroundColor()
		}
	}


	public var backgroundColorDimsWithTint = false {
		didSet {
			guard backgroundColorDimsWithTint != oldValue else {
				return
			}

			updateActualBackgroundColor()
		}
	}


	open var borderColor: UIColor? {
		get { return normalBorderColor }
		set {
			guard newValue != normalBorderColor else {
				return
			}

			normalBorderColor = newValue

			updateActualBorderColor()
		}
	}


	public var borderColorDimsWithTint = false {
		didSet {
			guard borderColorDimsWithTint != oldValue else {
				return
			}

			updateActualBorderColor()
		}
	}


	open var borderWidth: CGFloat {
		get { return layer.borderWidth }
		set { layer.borderWidth = newValue }
	}


	open var cornerRadius: CGFloat {
		get { return layer.cornerRadius }
		set { layer.cornerRadius = newValue }
	}


	open func didResizeFromSize(_ oldSize: CGSize) {
		// override in subclasses
	}


	open override var effectiveUserInterfaceLayoutDirection: UIUserInterfaceLayoutDirection {
		return super.effectiveUserInterfaceLayoutDirection
	}


	// reference implementation
	open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
		guard participatesInHitTesting else {
			return nil
		}
		guard isUserInteractionLimitedToSubviews || self.point(inside: point, with: event) else {
			return nil
		}

		var hitView: UIView?
		for subview in subviews.reversed() {
			hitView = subview.hitTest(convert(point, to: subview), with: event)
			if hitView != nil {
				break
			}
		}

		if hitView == nil && !isUserInteractionLimitedToSubviews {
			hitView = self
		}

		return hitView
	}


	// Documentation does not state what the default value is so we define one for View subclasses.
	open override var intrinsicContentSize : CGSize {
		return CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
	}


	open override class var layerClass : AnyObject.Type {
		return Layer.self
	}


	open func measureOptimalSize(forAvailableSize availableSize: CGSize) -> CGSize {
		return bounds.size
	}


	open var minimumSize = PartialSize() {
		didSet {
			guard minimumSize != oldValue else {
				return
			}

			invalidateIntrinsicContentSize()
		}
	}


	public final override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
		return pointInside(point, withEvent: event, additionalHitZone: additionalHitZone)
	}


	open func pointInside(_ point: CGPoint, withEvent event: UIEvent?, additionalHitZone: UIEdgeInsets) -> Bool {
		let originalHitZone = bounds
		let extendedHitZone = originalHitZone.inset(by: -additionalHitZone)

		let hitZoneCornerRadius: CGFloat
		if hitZoneFollowsCornerRadius && cornerRadius > 0 {
			let halfOriginalHitZoneSize = (originalHitZone.width + originalHitZone.height) / 4  // middle between half height and half width
			let halfExtendedHitZoneSize = (extendedHitZone.width + extendedHitZone.height) / 4  // middle between half extended height and half extended width
			hitZoneCornerRadius = halfExtendedHitZoneSize * (cornerRadius / halfOriginalHitZoneSize)
		}
		else {
			hitZoneCornerRadius = 0
		}

		return extendedHitZone.contains(point, cornerRadius: hitZoneCornerRadius)
	}


	open var preferredSize = PartialSize() {
		didSet {
			guard preferredSize != oldValue else {
				return
			}

			invalidateIntrinsicContentSize()
		}
	}


	open var shadowColor: UIColor? {
		get {
			guard let layerShadowColor = layer.shadowColor else {
				return nil
			}

			return UIColor(cgColor: layerShadowColor)
		}
		set {
			layer.shadowColor = newValue?.cgColor
		}
	}


	open var shadowOffset: UIOffset {
		get {
			let layerShadowOffset = layer.shadowOffset
			return UIOffset(horizontal: layerShadowOffset.width, vertical: layerShadowOffset.height)
		}
		set {
			layer.shadowOffset = CGSize(width: newValue.horizontal, height: newValue.vertical)
		}
	}


	open var shadowOpacity: CGFloat {
		get { return CGFloat(layer.shadowOpacity) }
		set { layer.shadowOpacity = Float(newValue) }
	}


	open var shadowPath: UIBezierPath? {
		get {
			guard let layerShadowPath = layer.shadowPath else {
				return nil
			}

			return UIBezierPath(cgPath: layerShadowPath)
		}
		set { layer.shadowPath = newValue?.cgPath }
	}


	open var shadowRadius: CGFloat {
		get { return layer.shadowRadius }
		set { layer.shadowRadius = newValue }
	}


	open override func sizeThatFitsSize(_ maximumSize: CGSize) -> CGSize {
		guard maximumSize.isPositive else {
			return .zero
		}

		let preferredSize = self.preferredSize

		var availableSize = maximumSize
		if let preferredWidth = preferredSize.width {
			if let preferredHeight = preferredSize.height {
				return alignToGrid(CGSize(width: preferredWidth, height: preferredHeight)
					.coerced(atLeast: minimumSize, atMost: availableSize))
			}

			availableSize.width = availableSize.width.coerced(atMost: preferredWidth)
		}
		else if let preferredHeight = preferredSize.height {
			availableSize.height = availableSize.height.coerced(atMost: preferredHeight)
		}

		var optimalSize = measureOptimalSize(forAvailableSize: availableSize)
		if let preferredWidth = preferredSize.width {
			optimalSize.width = preferredWidth
		}
		else if let preferredHeight = preferredSize.height {
			optimalSize.height = preferredHeight
		}

		return alignToGrid(optimalSize.coerced(atLeast: minimumSize, atMost: maximumSize))
	}


	// Override `sizeThatFitsSize(_:)` instead!
	@available(*, unavailable, renamed: "sizeThatFitsSize")
	public final override func sizeThatFits(_ maximumSize: CGSize) -> CGSize {
		return sizeThatFitsSize(maximumSize)
	}


	// Original implementation calls sizeThatFits(_:) with current size instead of maximum size which is nonsense. The parameter represents the size limit and sizeToFit() as per documentation is not limited to any size.
	open override func sizeToFit() {
		var bounds = self.bounds
		bounds.size = sizeThatFits()
		self.bounds = bounds
	}


	open override var tintColor: UIColor! {
		get { return super.tintColor }
		set {
			guard newValue?.tintAlpha == nil else {
				log("Cannot set .tintColor of \(self) to \(newValue!). Use `nil` instead.")
				super.tintColor = nil
				return
			}

			super.tintColor = newValue
		}
	}


	open override func tintColorDidChange() {
		super.tintColorDidChange()

		updateActualBackgroundColor()
		updateActualBorderColor()
	}


	private func updateActualBackgroundColor() {
		let backgroundColor = normalBackgroundColor?.tinted(for: self, dimsWithTint: backgroundColorDimsWithTint)
		guard backgroundColor != super.backgroundColor else {
			return
		}

		super.backgroundColor = backgroundColor
	}


	private func updateActualBorderColor() {
		let borderColor = normalBorderColor?.tinted(for: self, dimsWithTint: borderColorDimsWithTint).cgColor
		guard borderColor != layer.borderColor else {
			return
		}

		layer.borderColor = borderColor
	}


	open override var wantsSafeAreaInsets: Bool {
		return false
	}


	open func willResizeToSize(_ newSize: CGSize) {
		// override in subclasses
	}
}
