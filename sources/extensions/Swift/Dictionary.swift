public extension Dictionary {

	public mutating func mapValues(transform: Value -> Value) {
		for (key, value) in self {
			self[key] = transform(value)
		}
	}


	public func mapped<K : Hashable, V>(transform: (Key, Value) -> (K, V)) -> [K : V] {
		var mappedDictionary = [K : V](minimumCapacity: count)
		for (key, value) in self {
			let (mappedKey, mappedValue) = transform(key, value)
			mappedDictionary[mappedKey] = mappedValue
		}

		return mappedDictionary
	}
}
