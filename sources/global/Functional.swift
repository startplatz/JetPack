public func any<S : SequenceType>(source: S, includeElement: (S.Generator.Element) -> Bool) -> Bool {
	for element in source {
		if includeElement(element) {
			return true
		}
	}

	return false
}


public func findIdentical<C: CollectionType where C.Generator.Element: AnyObject>(collection: C, element: C.Generator.Element) -> C.Index? {
	for index in collection.startIndex ..< collection.endIndex {
		if collection[index] === element {
			return index
		}
	}

	return nil
}


public func findLast<C: CollectionType where C.Generator.Element: Equatable, C.Index: BidirectionalIndexType>(collection: C, element: C.Generator.Element) -> C.Index? {
	for index in reverse(collection.startIndex ..< collection.endIndex) {
		if collection[index] == element {
			return index
		}
	}

	return nil
}


public func first<S : SequenceType>(source: S, includeElement: (S.Generator.Element) -> Bool) -> S.Generator.Element? {
	for element in source {
		if includeElement(element) {
			return element
		}
	}

	return nil
}


public func max <T: Comparable>(x: T?, y: T?) -> T? {
	if let x = x, y = y {
		return Swift.max(x, y)
	}
	else if let x = x {
		return x
	}
	else {
		return y
	}
}


public func max <T: Comparable>(x: T, y: T?) -> T? {
	if let y = y {
		return Swift.max(x, y)
	}
	else {
		return x
	}
}


public func max <T: Comparable>(x: T?, y: T) -> T? {
	if let x = x {
		return Swift.max(x, y)
	}
	else {
		return y
	}
}


public func min <T: Comparable>(x: T?, y: T?) -> T? {
	if let x = x, y = y {
		return Swift.min(x, y)
	}
	else if let x = x {
		return x
	}
	else {
		return y
	}
}


public func min <T: Comparable>(x: T, y: T?) -> T? {
	if let y = y {
		return Swift.min(x, y)
	}
	else {
		return x
	}
}


public func min <T: Comparable>(x: T?, y: T) -> T? {
	if let x = x {
		return Swift.min(x, y)
	}
	else {
		return y
	}
}


public func not<T>(source: T -> Bool) -> T -> Bool {
	return { !source($0) }
}


public func not<T>(source: Bool) -> Bool {
	return !source
}


public func removeFirst<C : RangeReplaceableCollectionType where C.Generator.Element : Equatable>(inout collection: C, element: C.Generator.Element) -> C.Index? {
	let index = find(collection, element)
	if let index = index {
		collection.removeAtIndex(index)
	}

	return index
}


public func removeFirstIdentical<C : RangeReplaceableCollectionType where C.Generator.Element : AnyObject>(inout collection: C, element: C.Generator.Element) -> C.Index? {
	let index = findIdentical(collection, element)
	if let index = index {
		collection.removeAtIndex(index)
	}

	return index
}


public func separate<E, S : SequenceType where S.Generator.Element == E>(source: S, isLeftElement: (E) -> Bool) -> ([E], [E]) {
	var left = [E]()
	var right = [E]()

	for element in source {
		if isLeftElement(element) {
			left.append(element)
		}
		else {
			right.append(element)
		}
	}

	return (left, right)
}
