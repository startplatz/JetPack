import UIKit


public /* non-final */ class ScrollViewController: ViewController {

	public typealias ScrollCompletion = (cancelled: Bool) -> Void

	private lazy var childContainer = View()
	private lazy var delegateProxy: DelegateProxy = DelegateProxy(scrollViewController: self)

	private var appearState = AppearState.DidDisappear
	private var ignoresScrollViewDidScroll = 0
	private var isAnimatingScrollView = false
	private var isSettingPrimaryViewControllerInternally = false
	private var reusableChildView: ChildView?
	private var scrollCompletion: ScrollCompletion?
	private var viewControllersNotYetMovedToParentViewController = [UIViewController]()


	public override init() {
		super.init()
	}


	public required init?(coder: NSCoder) {
		super.init(coder: coder)

		automaticallyAdjustsScrollViewInsets = false
	}


	private func childViewForIndex(index: Int) -> ChildView? {
		guard isViewLoaded() else {
			return nil
		}

		for subview in childContainer.subviews {
			guard let childView = subview as? ChildView where childView.index == index else {
				continue
			}

			return childView
		}

		return nil
	}


	private func childViewForViewController(viewController: UIViewController) -> ChildView? {
		guard isViewLoaded() else {
			return nil
		}

		for subview in childContainer.subviews {
			guard let childView = subview as? ChildView where childView.viewController === viewController else {
				continue
			}

			return childView
		}

		return nil
	}


	public var currentIndex: CGFloat {
		let scrollViewWidth = scrollView.bounds.width
		
		if isViewLoaded() && scrollViewWidth > 0 {
			return scrollView.contentOffset.left / scrollViewWidth
		}
		else if let primaryViewController = primaryViewController, index = viewControllers.indexOfIdentical(primaryViewController) {
			return CGFloat(index)
		}
		else {
			return 0
		}
	}


	public func didScroll() {
		// override in subclasses
	}


	private var isInTransition: Bool {
		return appearState == .WillAppear || appearState == .WillDisappear || isAnimatingScrollView || scrollView.tracking || scrollView.decelerating
	}


	private func layoutChildContainer() {
		let viewSize = view.bounds.size
		let contentSize = CGSize(width: CGFloat(viewControllers.count) * viewSize.width, height: viewSize.height)

		childContainer.frame = CGRect(size: contentSize)
		scrollView.contentSize = contentSize
	}


	private func layoutChildView(childView: ChildView) {
		guard childView.index >= 0 else {
			return
		}

		let viewSize = view.bounds.size

		var childViewFrame = CGRect()
		childViewFrame.left = CGFloat(childView.index) * viewSize.width
		childViewFrame.size = viewSize
		childView.frame = childViewFrame
	}


	public var primaryViewController: UIViewController? {
		didSet {
			if isSettingPrimaryViewControllerInternally {
				return
			}

			guard let primaryViewController = primaryViewController else {
				fatalError("Cannot set primaryViewController to nil")
			}

			scrollToViewController(primaryViewController, animated: false)
		}
	}


	public func scrollToViewController(viewController: UIViewController, animated: Bool = true, completion: ScrollCompletion? = nil) {
		guard let index = viewControllers.indexOfIdentical(viewController) else {
			fatalError("Cannot scroll to view controller \(viewController) which is not a child view controller")
		}

		if viewController != primaryViewController {
			isSettingPrimaryViewControllerInternally = true
			primaryViewController = viewController
			isSettingPrimaryViewControllerInternally = false
		}

		if isViewLoaded() {
			let previousScrollCompletion = self.scrollCompletion
			scrollCompletion = completion

			scrollView.setContentOffset(CGPoint(left: CGFloat(index) * scrollView.bounds.width, top: 0), animated: true)

			previousScrollCompletion?(cancelled: true)
		}
	}


	public private(set) final lazy var scrollView: UIScrollView = {
		let child = ScrollView()
		child.bounces = false
		child.canCancelContentTouches = true
		child.delaysContentTouches = true
		child.delegate = self.delegateProxy
		child.pagingEnabled = true
		child.scrollsToTop = false
		child.showsHorizontalScrollIndicator = false
		child.showsVerticalScrollIndicator = false

		return child
	}()


	public override func shouldAutomaticallyForwardAppearanceMethods() -> Bool {
		return false
	}


	private func updateAppearStateForAllChildrenAnimated(animated: Bool) {
		for subview in childContainer.subviews {
			guard let childView = subview as? ChildView else {
				continue
			}

			updateChildView(childView, withPreferredAppearState: appearState, animated: animated)
		}
	}


	private func updateChildView(childView: ChildView, withPreferredAppearState preferredAppearState: AppearState, animated: Bool) {
		var targetAppearState = min(preferredAppearState, appearState)
		if isInTransition && targetAppearState != .DidDisappear {
			switch childView.appearState {
			case .DidDisappear:  targetAppearState = .WillAppear
			case .WillAppear:    return
			case .DidAppear:     targetAppearState = .WillDisappear
			case .WillDisappear: return
			}
		}

		childView.updateAppearState(targetAppearState, animated: animated)
	}


	private func updateChildrenAfterLayoutChanged(layoutChanged: Bool) {
		let viewSize = view.bounds.size
		let viewControllers = self.viewControllers
		var contentOffset = scrollView.contentOffset

		if layoutChanged {
			let maximumContentOffset = scrollView.maximumContentOffset
			if contentOffset.left > maximumContentOffset.left {
				contentOffset.left = maximumContentOffset.left

				++ignoresScrollViewDidScroll
				scrollView.contentOffset = contentOffset
				--ignoresScrollViewDidScroll
			}
		}

		let visibleIndexes: Range<Int>

		if viewControllers.isEmpty || viewSize.isEmpty {
			visibleIndexes = 0 ..< 0
		}
		else {
			let floatingIndex = contentOffset.left / viewSize.width
			visibleIndexes = Int(floor(floatingIndex)).clamp(min: 0, max: viewControllers.count - 1) ... Int(ceil(floatingIndex)).clamp(min: 0, max: viewControllers.count - 1)
		}

		for subview in childContainer.subviews {
			guard let childView = subview as? ChildView where !visibleIndexes.contains(childView.index) else {
				continue
			}

			updateChildView(childView, withPreferredAppearState: .WillDisappear, animated: false)
			childView.removeFromSuperview()
			updateChildView(childView, withPreferredAppearState: .DidDisappear, animated: false)

			childView.index = -1
			childView.viewController = nil

			reusableChildView = childView
		}

		for index in visibleIndexes {
			if let childView = childViewForIndex(index) {
				if layoutChanged {
					layoutChildView(childView)
				}
			}
			else {
				let viewController = viewControllers[index]

				let childView = reusableChildView ?? ChildView()
				childView.index = index
				childView.viewController = viewController

				reusableChildView = nil

				layoutChildView(childView)

				updateChildView(childView, withPreferredAppearState: .WillAppear, animated: false)
				childContainer.addSubview(childView)
				updateChildView(childView, withPreferredAppearState: .DidAppear, animated: false)

				if let index = viewControllersNotYetMovedToParentViewController.indexOfIdentical(viewController) {
					viewControllersNotYetMovedToParentViewController.removeAtIndex(index)
					viewController.didMoveToParentViewController(self)
				}
			}
		}
	}


	private func updatePrimaryViewController() {
		guard isViewLoaded() else {
			return
		}

		var mostVisibleViewController: UIViewController?
		var mostVisibleWidth = CGFloat.min

		let bounds = view.bounds
		for subview in childContainer.subviews {
			guard let childView = subview as? ChildView else {
				continue
			}

			let childFrameInView = childView.convertRect(childView.bounds, toView: view)
			let intersection = childFrameInView.intersect(bounds)
			guard !intersection.isNull else {
				continue
			}

			if intersection.width > mostVisibleWidth {
				mostVisibleViewController = childView.viewController
				mostVisibleWidth = intersection.width
			}
		}

		guard mostVisibleViewController != primaryViewController else {
			return
		}

		isSettingPrimaryViewControllerInternally = true
		primaryViewController = mostVisibleViewController
		isSettingPrimaryViewControllerInternally = false
	}


	public var viewControllers = [UIViewController]() {
		didSet {
			guard viewControllers != oldValue else {
				return
			}

			++ignoresScrollViewDidScroll
			defer { --ignoresScrollViewDidScroll }

			struct KnownLocation {
				let childView: ChildView
				let intersectionWidth: CGFloat
				let offset: CGFloat
			}

			var bestKnownLocation: KnownLocation?

			if isViewLoaded() && viewControllers.count > 1 {
				let viewBounds = view.bounds
				let contentOffset = scrollView.contentOffset

				for subview in childContainer.subviews {
					guard let childView = subview as? ChildView, viewController = childView.viewController where viewControllers.contains(viewController) else {
						continue
					}

					let childFrameInView = childView.convertRect(childView.bounds, toView: view)
					let intersection = childFrameInView.intersect(viewBounds)
					guard !intersection.isNull else {
						continue
					}

					guard intersection.width > bestKnownLocation?.intersectionWidth ?? 0 else {
						continue
					}

					let expectedContentOffsetLeft = CGFloat(childView.index) * viewBounds.width
					let offset = (expectedContentOffsetLeft - contentOffset.left)

					bestKnownLocation = KnownLocation(childView: childView, intersectionWidth: intersection.width, offset: offset)
				}
			}

			var removedViewControllers = [UIViewController]()
			for viewController in oldValue where viewController.parentViewController === self && !viewControllers.containsIdentical(viewController) {
				viewController.willMoveToParentViewController(nil)

				childViewForViewController(viewController)?.index = -1
				removedViewControllers.append(viewController)
				viewControllersNotYetMovedToParentViewController.removeFirstIdentical(viewController)
			}

			for index in 0 ..< viewControllers.count {
				let viewController = viewControllers[index]

				if viewController.parentViewController !== self {
					addChildViewController(viewController)
					viewControllersNotYetMovedToParentViewController.append(viewController)
				}
				else {
					childViewForViewController(viewController)?.index = index
				}
			}

			if isViewLoaded() {
				layoutChildContainer()

				if let bestKnownLocation = bestKnownLocation {
					scrollView.contentOffset = CGPoint(left: (CGFloat(bestKnownLocation.childView.index) * view.bounds.width) - bestKnownLocation.offset, top: 0)
						.clamp(min: scrollView.minimumContentOffset, max: scrollView.maximumContentOffset)
				}

				updateChildrenAfterLayoutChanged(true)
				updatePrimaryViewController()
			}
			else {
				if let primaryViewController = primaryViewController where viewControllers.containsIdentical(primaryViewController) {
					// primaryViewController still valid
				}
				else {
					primaryViewController = viewControllers.first
				}
			}

			for viewController in removedViewControllers {
				viewController.removeFromParentViewController()
			}
		}
	}


	public override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		++ignoresScrollViewDidScroll
		defer { --ignoresScrollViewDidScroll }

		let viewSize = view.bounds.size
		scrollView.frame = CGRect(size: viewSize)

		layoutChildContainer()
		updateChildrenAfterLayoutChanged(true)
	}


	public override func viewDidLoad() {
		super.viewDidLoad()

		scrollView.addSubview(childContainer)
		view.addSubview(scrollView)
	}


	public override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)

		appearState = .DidAppear
		updateAppearStateForAllChildrenAnimated(animated)
	}


	public override func viewDidDisappear(animated: Bool) {
		super.viewDidDisappear(animated)

		appearState = .DidDisappear
		updateAppearStateForAllChildrenAnimated(animated)
	}


	public override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)

		appearState = .WillAppear
		updateAppearStateForAllChildrenAnimated(animated)
	}


	public override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)

		appearState = .WillDisappear
		updateAppearStateForAllChildrenAnimated(animated)
	}
}



private final class DelegateProxy: NSObject {

	private unowned let scrollViewController: ScrollViewController


	private init(scrollViewController: ScrollViewController) {
		self.scrollViewController = scrollViewController
	}
}


extension DelegateProxy: UIScrollViewDelegate {

	@objc
	private func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
		let scrollViewController = self.scrollViewController

		scrollViewController.updateAppearStateForAllChildrenAnimated(true)
		scrollViewController.updatePrimaryViewController()
	}


	@objc
	private func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
		let scrollViewController = self.scrollViewController

		scrollViewController.isAnimatingScrollView = false

		scrollViewController.updateAppearStateForAllChildrenAnimated(true)
		scrollViewController.updatePrimaryViewController()

		let scrollCompletion = scrollViewController.scrollCompletion
		scrollViewController.scrollCompletion = nil

		// TODO not called when scrolling was not necessary
		scrollCompletion?(cancelled: false)
	}


	@objc
	private func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		let scrollViewController = self.scrollViewController

		scrollViewController.isAnimatingScrollView = false

		if !decelerate {
			onMainQueue { // loop one cycle because UIScrollView did not yet update .tracking
				scrollViewController.updateAppearStateForAllChildrenAnimated(true)
				scrollViewController.updatePrimaryViewController()
			}
		}
	}
	

	@objc
	private func scrollViewDidScroll(scrollView: UIScrollView) {
		let scrollViewController = self.scrollViewController
		guard scrollViewController.ignoresScrollViewDidScroll == 0 else {
			return
		}

		scrollViewController.updateChildrenAfterLayoutChanged(false)

		if scrollView.tracking {
			scrollViewController.updatePrimaryViewController()
		}

		scrollViewController.didScroll()
	}


	@objc
	private func scrollViewWillBeginDragging(scrollView: UIScrollView) {
		let scrollViewController = self.scrollViewController

		scrollViewController.isAnimatingScrollView = false

		let scrollCompletion = scrollViewController.scrollCompletion
		scrollViewController.scrollCompletion = nil

		scrollViewController.updateAppearStateForAllChildrenAnimated(true)

		scrollCompletion?(cancelled: true)
	}


	@objc
	private func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
		scrollViewController.isAnimatingScrollView = false
	}
}



private final class ChildView: View {

	private var appearState = AppearState.DidDisappear
	private var index = -1


	private override func layoutSubviews() {
		super.layoutSubviews()

		guard let viewControllerView = viewController?.view else {
			return
		}

		let viewSize = bounds.size
		viewControllerView.frame = CGRect(size: viewSize)
	}


	private func updateAppearState(appearState: AppearState, animated: Bool) {
		let oldAppearState = self.appearState
		guard appearState != oldAppearState else {
			return
		}

		self.appearState = appearState

		guard let viewController = self.viewController else {
			return
		}

		switch appearState {
		case .DidDisappear:
			switch oldAppearState {
			case .DidDisappear:
				break

			case .WillAppear, .DidAppear:
				viewController.beginAppearanceTransition(false, animated: animated)
				fallthrough

			case .WillDisappear:
				viewController.view.removeFromSuperview()
				viewController.endAppearanceTransition()
			}

		case .WillAppear:
			switch oldAppearState {
			case .DidAppear, .WillAppear:
				break

			case .WillDisappear, .DidDisappear:
				viewController.beginAppearanceTransition(true, animated: animated)

				addSubview(viewController.view)
				setNeedsLayout()
				layoutIfNeeded()
			}

		case .WillDisappear:
			switch oldAppearState {
			case .DidDisappear, .WillDisappear:
				break

			case .WillAppear, .DidAppear:
				viewController.beginAppearanceTransition(false, animated: animated)
			}

		case .DidAppear:
			switch oldAppearState {
			case .DidAppear:
				break

			case .DidDisappear, .WillDisappear:
				viewController.beginAppearanceTransition(true, animated: animated)

				addSubview(viewController.view)
				setNeedsLayout()
				layoutIfNeeded()
				
				fallthrough

			case .WillAppear:
				viewController.endAppearanceTransition()
			}
		}
	}


	private var viewController: UIViewController? {
		didSet {
			precondition((viewController != nil) != (oldValue != nil))
		}
	}
}



private class ScrollView: UIScrollView {

	private override func setContentOffset(contentOffset: CGPoint, animated: Bool) {
		let willBeginAnimation = animated && contentOffset != self.contentOffset

		super.setContentOffset(contentOffset, animated: animated)

		if willBeginAnimation, let viewController = delegate as? ScrollViewController {
			viewController.isAnimatingScrollView = true
		}
	}
}



private enum AppearState: Int {
	case DidDisappear = 0
	case WillDisappear = 1
	case WillAppear = 2
	case DidAppear = 3


	private var isTransition: Bool {
		switch self {
		case .WillAppear, .WillDisappear: return true
		case .DidAppear, .DidDisappear:   return false
		}
	}
}


extension AppearState: Comparable {}


private func < (a: AppearState, b: AppearState) -> Bool {
	return a.rawValue < b.rawValue
}
