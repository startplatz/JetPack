import CoreGraphics


public extension CGRect {

	init(size: CGSize) {
		self.init(x: 0, y: 0, width: size.width, height: size.height)
	}


	init(left: CGFloat, top: CGFloat, width: CGFloat, height: CGFloat) {
		self.init(x: left, y: top, width: width, height: height)
	}


	init(width: CGFloat, height: CGFloat) {
		self.init(x: 0, y: 0, width: width, height: height)
	}


	func applying(_ transform: CGAffineTransform, anchorPoint: CGPoint) -> CGRect {
		if anchorPoint != .zero {
			let anchorLeft = left + (width * anchorPoint.left)
			let anchorTop = top + (height * anchorPoint.top)

			let t1 = CGAffineTransform(horizontalTranslation: anchorLeft, verticalTranslation: anchorTop)
			let t2 = CGAffineTransform(horizontalTranslation: -anchorLeft, verticalTranslation: -anchorTop)

			return applying(t2 * transform * t1)
		}
		else {
			return applying(transform)
		}
	}


	var bottom: CGFloat {
		get { return origin.top + size.height }
		mutating set { origin.top = newValue - size.height }
	}


	var bottomCenter: CGPoint {
		get { return CGPoint(left: left + (width / 2), top: bottom) }
		mutating set { left = newValue.left - (width / 2); bottom = newValue.top }
	}


	var bottomLeft: CGPoint {
		get { return CGPoint(left: left, top: bottom) }
		mutating set { left = newValue.left; bottom = newValue.top }
	}


	var bottomRight: CGPoint {
		get { return CGPoint(left: right, top: bottom) }
		mutating set { right = newValue.left; bottom = newValue.top }
	}


	var center: CGPoint {
		get { return CGPoint(left: left + (width / 2), top: top + (height / 2)) }
		mutating set { left = newValue.left - (width / 2); top = newValue.top - (height / 2) }
	}


	func centered(at center: CGPoint) -> CGRect {
		var rect = self
		rect.center = center
		return rect
	}


	var centerLeft: CGPoint {
		get { return CGPoint(left: left, top: top + (height / 2)) }
		mutating set { left = newValue.left; top = newValue.top - (height / 2) }
	}


	var centerRight: CGPoint {
		get { return CGPoint(left: right, top: top + (height / 2)) }
		mutating set { right = newValue.left; top = newValue.top - (height / 2) }
	}


	func contains(_ point: CGPoint, cornerRadius: CGFloat) -> Bool {
		guard contains(point) else {
			// full rect misses, so does any rounded rect
			return false
		}
		guard cornerRadius > 0 else {
			// full rect already hit
			return true
		}

		// we already hit the full rect, so if the point is at least cornerRadius pixels away from both sides in one axis we have a hit

		let minX = origin.x
		let minXAfterCorner = minX + cornerRadius
		let maxX = minX + width
		let maxXBeforeCorner = maxX - cornerRadius

		guard point.x < minXAfterCorner || point.x > maxXBeforeCorner else {
			return true
		}

		let minY = origin.y
		let minYAfterCorner = minY + cornerRadius
		let maxY = minY + height
		let maxYBeforeCorner = maxY - cornerRadius

		guard point.y < minYAfterCorner || point.y > maxYBeforeCorner else {
			return true
		}

		// it must be near one of the corners - figure out which one

		let midX = minX + (width / 2)
		let midY = minY + (height / 2)
		let circleCenter: CGPoint

		if point.x <= midX {  // must be near one of the left corners
			if point.y <= midY {  // must be near the top left corner
				circleCenter = CGPoint(x: minXAfterCorner, y: minYAfterCorner)
			}
			else {  // must be near the bottom left corner
				circleCenter = CGPoint(x: minXAfterCorner, y: maxYBeforeCorner)
			}
		}
		else {  // must ne near one of the right corners
			if point.y <= midY {  // must be near the top right corner
				circleCenter = CGPoint(x: maxXBeforeCorner, y: minYAfterCorner)
			}
			else {  // must be near the bottom right corner
				circleCenter = CGPoint(x: maxXBeforeCorner, y: maxYBeforeCorner)
			}
		}

		// just test distance from the matching circle to the point
		return (circleCenter.distance(to: point) <= cornerRadius)
	}


	func displacement(to point: CGPoint) -> CGPoint {
		return CGPoint(
			left: point.left.coerced(in: left ... right),
			top:  point.top.coerced(in: top ... bottom)
		).displacement(to: point)
	}


	func distance(to point: CGPoint) -> CGFloat {
		let displacement = self.displacement(to: point)
		return ((displacement.x * displacement.x) + (displacement.y * displacement.y)).squareRoot()
	}


	internal var height: CGFloat { // public doesn't work due getter ambigutity
		get { return size.height }
		@available(*, deprecated, renamed: "heightFromTop")
		mutating set { size.height = newValue }
	}


	var heightFromBottom: CGFloat {
		get { return size.height }
		mutating set { top += height - newValue; heightFromTop = newValue }
	}


	var heightFromTop: CGFloat {
		get { return size.height }
		mutating set { size.height = newValue }
	}


	var horizontalCenter: CGFloat {
		get { return CGFloat(left + (width / 2)) }
		mutating set { left = newValue - (width / 2) }
	}


	func interpolate(to destination: CGRect, fraction: CGFloat) -> CGRect {
		return CGRect(
			left:   left + ((destination.left - left) * fraction),
			top:    top + ((destination.top - top) * fraction),
			width:  width + ((destination.width - width) * fraction),
			height: height + ((destination.height - height) * fraction)
		)
	}


	var isValid: Bool {
		return size.isValid
	}


	var left: CGFloat {
		get { return origin.left }
		mutating set { origin.left = newValue }
	}


	func offsetBy(_ offset: CGPoint) -> CGRect {
		return offsetBy(dx: offset.x, dy: offset.y)
	}


	var right: CGFloat {
		get { return origin.left + size.width }
		mutating set { origin.left = newValue - size.width }
	}


	var top: CGFloat {
		get { return origin.top }
		mutating set { origin.top = newValue }
	}


	var topCenter: CGPoint {
		get { return CGPoint(left: left + (width / 2), top: top) }
		mutating set { left = newValue.left - (width / 2); top = newValue.top }
	}


	var topLeft: CGPoint {
		get { return origin }
		mutating set { origin = newValue }
	}


	var topRight: CGPoint {
		get { return CGPoint(left: right, top: top) }
		mutating set { right = newValue.left; top = newValue.top }
	}


	var verticalCenter: CGFloat {
		get { return CGFloat(top + (height / 2)) }
		mutating set { top = newValue - (height / 2) }
	}


	internal var width: CGFloat { // public doesn't work due getter ambigutity
		get { return size.width }
		@available(*, deprecated, renamed: "widthFromLeft")
		mutating set { size.width = newValue }
	}


	var widthFromLeft: CGFloat {
		get { return size.width }
		mutating set { size.width = newValue }
	}


	var widthFromRight: CGFloat {
		get { return size.width }
		mutating set { left += width - newValue; widthFromLeft = newValue }
	}
}
