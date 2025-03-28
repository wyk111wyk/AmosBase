import SwiftUI
#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension SimpleDefaults.Serializable {
	public static var isNativelySupportedType: Bool { false }
}

extension Data: SimpleDefaults.Serializable {
	public static let isNativelySupportedType = true
}

extension Date: SimpleDefaults.Serializable {
	public static let isNativelySupportedType = true
}

extension Bool: SimpleDefaults.Serializable {
	public static let isNativelySupportedType = true
}

extension Int: SimpleDefaults.Serializable {
	public static let isNativelySupportedType = true
}

extension UInt: SimpleDefaults.Serializable {
	public static let isNativelySupportedType = true
}

extension Double: SimpleDefaults.Serializable {
	public static let isNativelySupportedType = true
}

extension Float: SimpleDefaults.Serializable {
	public static let isNativelySupportedType = true
}

extension String: SimpleDefaults.Serializable {
	public static let isNativelySupportedType = true
}

// swiftlint:disable:next no_cgfloat
extension CGFloat: SimpleDefaults.Serializable {
	public static let isNativelySupportedType = true
}

extension Int8: SimpleDefaults.Serializable {
	public static let isNativelySupportedType = true
}

extension UInt8: SimpleDefaults.Serializable {
	public static let isNativelySupportedType = true
}

extension Int16: SimpleDefaults.Serializable {
	public static let isNativelySupportedType = true
}

extension UInt16: SimpleDefaults.Serializable {
	public static let isNativelySupportedType = true
}

extension Int32: SimpleDefaults.Serializable {
	public static let isNativelySupportedType = true
}

extension UInt32: SimpleDefaults.Serializable {
	public static let isNativelySupportedType = true
}

extension Int64: SimpleDefaults.Serializable {
	public static let isNativelySupportedType = true
}

extension UInt64: SimpleDefaults.Serializable {
	public static let isNativelySupportedType = true
}

extension URL: SimpleDefaults.Serializable {
	public static let bridge = SimpleDefaults.URLBridge()
}

extension SimpleDefaults.Serializable where Self: Codable {
	public static var bridge: SimpleDefaults.TopLevelCodableBridge<Self> { SimpleDefaults.TopLevelCodableBridge() }
}

extension SimpleDefaults.Serializable where Self: Codable & NSSecureCoding & NSObject {
	public static var bridge: SimpleDefaults.CodableNSSecureCodingBridge<Self> { SimpleDefaults.CodableNSSecureCodingBridge() }
}

extension SimpleDefaults.Serializable where Self: Codable & NSSecureCoding & NSObject & SimpleDefaults.PreferNSSecureCoding {
	public static var bridge: SimpleDefaults.NSSecureCodingBridge<Self> { SimpleDefaults.NSSecureCodingBridge() }
}

extension SimpleDefaults.Serializable where Self: Codable & RawRepresentable {
	public static var bridge: SimpleDefaults.RawRepresentableCodableBridge<Self> { SimpleDefaults.RawRepresentableCodableBridge() }
}

extension SimpleDefaults.Serializable where Self: Codable & RawRepresentable & SimpleDefaults.PreferRawRepresentable {
	public static var bridge: SimpleDefaults.RawRepresentableBridge<Self> { SimpleDefaults.RawRepresentableBridge() }
}

extension SimpleDefaults.Serializable where Self: RawRepresentable {
	public static var bridge: SimpleDefaults.RawRepresentableBridge<Self> { SimpleDefaults.RawRepresentableBridge() }
}

extension SimpleDefaults.Serializable where Self: NSSecureCoding & NSObject {
	public static var bridge: SimpleDefaults.NSSecureCodingBridge<Self> { SimpleDefaults.NSSecureCodingBridge() }
}

extension Optional: SimpleDefaults.Serializable where Wrapped: SimpleDefaults.Serializable {
	public static var isNativelySupportedType: Bool { Wrapped.isNativelySupportedType }
	public static var bridge: SimpleDefaults.OptionalBridge<Wrapped> { SimpleDefaults.OptionalBridge() }
}

extension SimpleDefaults.CollectionSerializable where Element: SimpleDefaults.Serializable {
	public static var bridge: SimpleDefaults.CollectionBridge<Self> { SimpleDefaults.CollectionBridge() }
}

extension SimpleDefaults.SetAlgebraSerializable where Element: SimpleDefaults.Serializable & Hashable {
	public static var bridge: SimpleDefaults.SetAlgebraBridge<Self> { SimpleDefaults.SetAlgebraBridge() }
}

extension Set: SimpleDefaults.Serializable where Element: SimpleDefaults.Serializable {
	public static var bridge: SimpleDefaults.SetBridge<Element> { SimpleDefaults.SetBridge() }
}

extension Array: SimpleDefaults.Serializable where Element: SimpleDefaults.Serializable {
	public static var isNativelySupportedType: Bool { Element.isNativelySupportedType }
	public static var bridge: SimpleDefaults.ArrayBridge<Element> { SimpleDefaults.ArrayBridge() }
}

extension Dictionary: SimpleDefaults.Serializable where Key: LosslessStringConvertible & Hashable, Value: SimpleDefaults.Serializable {
	public static var isNativelySupportedType: Bool { (Key.self is String.Type) && Value.isNativelySupportedType }
	public static var bridge: SimpleDefaults.DictionaryBridge<Key, Value> { SimpleDefaults.DictionaryBridge() }
}

extension UUID: SimpleDefaults.Serializable {
	public static let bridge = SimpleDefaults.UUIDBridge()
}

extension Color: SimpleDefaults.Serializable {
	public static let bridge = SimpleDefaults.ColorBridge()
}

extension Color.Resolved: SimpleDefaults.Serializable {}

extension Range: SimpleDefaults.RangeSerializable where Bound: SimpleDefaults.Serializable {
	public static var bridge: SimpleDefaults.RangeBridge<Range> { SimpleDefaults.RangeBridge() }
}

extension ClosedRange: SimpleDefaults.RangeSerializable where Bound: SimpleDefaults.Serializable {
	public static var bridge: SimpleDefaults.RangeBridge<ClosedRange> { SimpleDefaults.RangeBridge() }
}

#if os(macOS)
/**
`NSColor` conforms to `NSSecureCoding`, so it goes to `NSSecureCodingBridge`.
*/
extension NSColor: SimpleDefaults.Serializable {}
#else
/**
`UIColor` conforms to `NSSecureCoding`, so it goes to `NSSecureCodingBridge`.
*/
extension UIColor: SimpleDefaults.Serializable {}
#endif

#if os(macOS)
extension NSFontDescriptor: SimpleDefaults.Serializable {}
#else
extension UIFontDescriptor: SimpleDefaults.Serializable {}
#endif

extension NSUbiquitousKeyValueStore: DefaultsKeyValueStore {}
extension UserDefaults: DefaultsKeyValueStore {}

extension SimpleDefaultsLockProtocol {
	@discardableResult
	func with<R, E>(_ body: @Sendable () throws(E) -> R) throws(E) -> R where R: Sendable {
		lock()

		defer {
			unlock()
		}

		return try body()
	}
}
