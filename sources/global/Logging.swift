import Foundation

#if DEBUG
	public var LOGenabled = true
#else
	public var LOGenabled = false
#endif


public func LOG(message: (@autoclosure () -> String), function: StaticString = __FUNCTION__, file: StaticString = __FILE__, line: UWord = __LINE__) {
	if !LOGenabled {
		return
	}

	let fileName = file.stringValue.lastPathComponent.stringByDeletingPathExtension
	NSLog("%@", "\(fileName)/\(function.stringValue):\(line) | \(message())")
}


// temporary workaround for lack of #warning instruction
public func WARN(message: (@autoclosure () -> String), function: StaticString = __FUNCTION__, file: StaticString = __FILE__, line: UWord = __LINE__) {
	if !LOGenabled {
		return
	}

	LOG("Warning: \(message())", function: function, file: file, line: line)
}
