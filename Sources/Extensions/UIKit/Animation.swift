import UIKit


public struct Animation {

	public typealias Completion = (_ position: UIViewAnimatingPosition) -> Void
	public typealias CompletionRegistration = (@escaping Completion) -> Void

	public var allowsUserInteraction = false
	public var delay = TimeInterval(0)
	public var duration: TimeInterval
	public var isManualHitTestingEnabled = false
	public var timing: Timing

	public private(set) static var current: Animation?


	public init(duration: TimeInterval = 0.3, timing: Timing = .spring(initialVelocity: 0, damping: 1)) {
		self.duration = duration
		self.timing = timing
	}


	public static func ignore(_ changes: Closure) {
		UIView.performWithoutAnimation(changes)
	}


	public func prepare(_ changes: @escaping () -> Void) -> UIViewPropertyAnimator {
		return prepareWithCompletion { _ in changes() }
	}


	public func prepareWithCompletion(_ changes: @escaping (_ complete: CompletionRegistration) -> Void) -> UIViewPropertyAnimator {
		let animator = UIViewPropertyAnimator(duration: duration, timingParameters: timing.toCurveProvider())
		animator.isManualHitTestingEnabled = isManualHitTestingEnabled
		animator.isUserInteractionEnabled = allowsUserInteraction

		animator.addAnimations { [unowned animator] in
			let outerAnimation = Animation.current
			Animation.current = self
			defer { Animation.current = outerAnimation }

			changes(animator.addCompletion)
		}

		return animator
	}


	@discardableResult
	public func run(_ changes: () -> Void) -> UIViewPropertyAnimator {
		return runWithCompletion { _ in changes() }
	}


	@discardableResult
	public func runWithCompletion(_ changes: (_ complete: CompletionRegistration) -> Void) -> UIViewPropertyAnimator {
		var animator: UIViewPropertyAnimator! = nil

		withoutActuallyEscaping(changes) { changes in
			animator = prepareWithCompletion(changes)
			animator.startAnimation(afterDelay: delay)
		}

		return animator
	}


	public func wrap() -> Wrapper {
		return Wrapper(animation: self)
	}



	public enum Timing {

		case easeIn
		case easeInEaseOut
		case easeOut
		case linear
		case curve(UIView.AnimationCurve)
		case spring(initialVelocity: CGFloat, damping: CGFloat)


		public func toCurveProvider() -> UITimingCurveProvider {
			switch self {
			case .easeIn:
				return UICubicTimingParameters(animationCurve: .easeIn)

			case .easeInEaseOut:
				return UICubicTimingParameters(animationCurve: .easeInOut)

			case .easeOut:
				return UICubicTimingParameters(animationCurve: .easeOut)

			case .linear:
				return UICubicTimingParameters(animationCurve: .linear)

			case let .curve(curve):
				return UICubicTimingParameters(animationCurve: curve)

			case let .spring(initialVelocity, dampingRatio):
				return UISpringTimingParameters(dampingRatio: dampingRatio, initialVelocity: CGVector(dx: initialVelocity, dy: initialVelocity))
			}
		}
	}



	public final class Wrapper: NSObject {

		public let animation: Animation


		public init(animation: Animation) {
			self.animation = animation

			super.init()
		}


		public override var description: String {
			return animation.description
		}
	}
}


extension Animation: CustomStringConvertible {

	public var description: String {
		var description = "Animation(duration: "
		description += String(duration)
		description += ", timing: "
		description += String(describing: timing)
		if allowsUserInteraction {
			description += ", allowsUserInteraction: true"
		}
		if delay != 0 {
			description += ", delay: "
			description += String(delay)
		}
		if isManualHitTestingEnabled {
			description += ", isManualHitTestingEnabled: true"
		}
		description += ")"

		return description
	}
}


extension Animation.Timing: CustomStringConvertible {

	public var description: String {
		switch self {
		case .easeIn:                                    return "Timing.easeIn"
		case .easeInEaseOut:                             return "Timing.easeInEaseOut"
		case .easeOut:                                   return "Timing.easeOut"
		case .linear:                                    return "Timing.linear"
		case let .curve(curve):                          return "Timing.curve(\(curve))"
		case let .spring(initialVelocity, dampingRatio): return "Timing.spring(initialVelocity: \(initialVelocity), dampingRatio: \(dampingRatio))"
		}
	}
}


extension Optional where Wrapped == Animation {

	@available(*, unavailable, message: "Makes it clear that changes are still applied and completions still called even if the animation is `nil`", renamed: "runAlways")
	@discardableResult
	public func run(_ changes: () -> Void) -> UIViewPropertyAnimator? {
		return runAlways(changes)
	}


	@discardableResult
	public func runAlways(_ changes: () -> Void) -> UIViewPropertyAnimator? {
		if let animation = value {
			return animation.run(changes)
		}
		else {
			changes()
			return nil
		}
	}


	@available(*, unavailable, message: "Makes it clear that changes are still applied and completions still called even if the animation is `nil`", renamed: "runAlwaysWithCompletion")
	@discardableResult
	public func runWithCompletion(_ changes: (_ complete: Animation.CompletionRegistration) -> Void) -> UIViewPropertyAnimator? {
		return runAlwaysWithCompletion(changes)
	}


	@discardableResult
	public func runAlwaysWithCompletion(_ changes: (_ complete: Animation.CompletionRegistration) -> Void) -> UIViewPropertyAnimator? {
		if let animation = value {
			return animation.runWithCompletion(changes)
		}
		else {
			var completions = [Animation.Completion]()

			changes { completion in
				completions.append(completion)
			}

			for completion in completions {
				completion(.end)
			}

			return nil
		}
	}
}
