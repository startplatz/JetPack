import UIKit


@objc(JetPack_GradientView)
open class GradientView: View {

	public override init() {
		super.init()

		isUserInteractionEnabled = false
	}


	public required init?(coder: NSCoder) {
		super.init(coder: coder)
	}


	open var colors: [UIColor] {
		get {
			let cgColors = gradientLayer.colors as? [CGColor]
			return cgColors?.map { UIColor(cgColor: $0) } ?? []
		}
		set {
			gradientLayer.colors = newValue.map { $0.cgColor }
		}
	}


	open var endPoint: CGPoint {
		get { return gradientLayer.endPoint }
		set { gradientLayer.endPoint = newValue }
	}


	public fileprivate(set) final lazy var gradientLayer: CAGradientLayer = self.layer as! CAGradientLayer



	@available(*, unavailable, message: "Don't override this.") // cannot mark as final
	open override class var layerClass: AnyClass {
		return CAGradientLayer.self
	}


	open var locations: [CGFloat] {
		get { return gradientLayer.locations?.map { $0 as! CGFloat } ?? [] }
		set { gradientLayer.locations = newValue as [NSNumber]? }
	}


	open var startPoint: CGPoint {
		get { return gradientLayer.startPoint }
		set { gradientLayer.startPoint = newValue }
	}
}
