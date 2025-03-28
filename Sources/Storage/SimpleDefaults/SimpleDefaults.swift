// MIT License © Sindre Sorhus
import Foundation

// Fathor library
// https://github.com/sindresorhus/Defaults

public enum SimpleDefaults {
	/**
	Access stored values.

	```swift
    // 如何使用
	import SimpleDefaults

	extension SimpleDefaults.Keys {
	   static let quality = Key<Double>("quality", default: 0.8)
	}
     
    @SimpleSetting(.quality) var quality

	// 1. 不需要进行初始化，可以直接进行使用

	SimpleDefaults[.quality]
	//=> 0.8

	SimpleDefaults[.quality] = 0.5
	//=> 0.5
     
    // 2. 可以使用Enum
     enum DurationKeys: String, SimpleDefaults.Serializable {
         case tenMinutes = "10 Minutes"
         case halfHour = "30 Minutes"
         case oneHour = "1 Hour"
     }

     extension SimpleDefaults.Keys {
         static let defaultDuration = Key<DurationKeys>("defaultDuration", default: .oneHour)
     }

     SimpleDefaults[.defaultDuration].rawValue
     //=> "1 Hour"
     
     // 3. 可以直接使用Model
     struct User: Codable, SimpleDefaults.Serializable {
         let name: String
         let age: String
     }

     extension SimpleDefaults.Keys {
         static let user = Key<User>("user", default: .init(name: "Hello", age: "24"))
     }

     SimpleDefaults[.user].name
     //=> "Hello"
     
     // 4. 直接绑定Toggle使用
     SimpleDefaults.Toggle("Show All-Day Events", key: .showAllDayEvents)
     
     // 5. 将数值恢复默认
     SimpleDefaults.reset(.isUnicornMode)
     
     // 6. Shared UserDefaults
     let extensionDefaults = UserDefaults(suiteName: "com.unicorn.app")!

     extension SimpleDefaults.Keys {
         static let isUnicorn = Key<Bool>("isUnicorn", default: true, suite: extensionDefaults)
     }
     
	```
	*/
	public static subscript<Value: Serializable>(key: Key<Value>) -> Value {
		get { key.suite[key] }
		set {
			key.suite[key] = newValue
		}
	}
}

public typealias _SimpleDefaults = SimpleDefaults
public typealias _SimpleSetting = SimpleSetting

extension SimpleDefaults {
	// We cannot use `Key` as the container for keys because of "Static stored properties not supported in generic types".
	/**
	Type-erased key.
	*/
	public class _AnyKey: @unchecked Sendable {
		public typealias Key = SimpleDefaults.Key

		public let name: String
		public let suite: UserDefaults

		@_alwaysEmitIntoClient
		fileprivate init(name: String, suite: UserDefaults) {
			runtimeWarn(
				isValidKeyPath(name: name),
				"The key name must be ASCII, not start with @, and cannot contain a dot (.)."
			)

			self.name = name
			self.suite = suite
		}

		/**
		Reset the item back to its default value.
		*/
		public func reset() {
			suite.removeObject(forKey: name)
		}
	}

	public typealias Keys = _AnyKey
}

extension SimpleDefaults {
	/**
	Strongly-typed key used to access values.

	You declare the SimpleDefaults keys upfront with a type and default value.

	```swift
	import SimpleDefaults

	extension SimpleDefaults.Keys {
		static let quality = Key<Double>("quality", default: 0.8)
		//            ^            ^         ^                ^
		//           Key          Type   UserDefaults name   Default value
	}
	```

	- Important: The `UserDefaults` name must be ASCII, not start with `@`, and cannot contain a dot (`.`).
	*/
	public final class Key<Value: Serializable>: _AnyKey, @unchecked Sendable {
		/**
		It will be executed in these situations:

		- `UserDefaults.object(forKey: string)` returns `nil`
		- A `bridge` cannot deserialize `Value` from `UserDefaults`
		*/
		@usableFromInline
		let defaultValueGetter: () -> Value

		public var defaultValue: Value { defaultValueGetter() }

		/**
		Create a key.

		- Parameter name: The name must be ASCII, not start with `@`, and cannot contain a dot (`.`).
		- Parameter defaultValue: The default value.
		- Parameter suite: The `UserDefaults` suite to store the value in.
		- Parameter iCloud: Automatically synchronize the value with ``Defaults/iCloud``.

		The `default` parameter should not be used if the `Value` type is an optional.
		*/
		@_alwaysEmitIntoClient
		public init(
			_ name: String,
			default defaultValue: Value,
			suite: UserDefaults = .standard,
			iCloud: Bool = false
		) {
			defer {
				if iCloud {
					SimpleDefaults.iCloud.add(self)
				}
			}

			self.defaultValueGetter = { defaultValue }

			super.init(name: name, suite: suite)

			if (defaultValue as? (any _DefaultsOptionalProtocol))?._defaults_isNil == true {
				return
			}

			guard let serialized = Value.toSerializable(defaultValue) else {
				return
			}

			// Sets the default value in the actual UserDefaults, so it can be used in other contexts, like binding.
			suite.register(defaults: [name: serialized])
		}

		/**
		Create a key with a dynamic default value.

		This can be useful in cases where you cannot define a static default value as it may change during the lifetime of the app.

		```swift
		extension SimpleDefaults.Keys {
			static let camera = Key<AVCaptureDevice?>("camera") { .default(for: .video) }
		}
		```

		- Parameter name: The name must be ASCII, not start with `@`, and cannot contain a dot (`.`).
		- Parameter suite: The `UserDefaults` suite to store the value in.
		- Parameter iCloud: Automatically synchronize the value with ``Defaults/iCloud``.
		- Parameter defaultValueGetter: The dynamic default value.

		- Note: This initializer will not set the default value in the actual `UserDefaults`. This should not matter much though. It's only really useful if you use legacy KVO bindings.
		*/
		@_alwaysEmitIntoClient
		public init(
			_ name: String,
			suite: UserDefaults = .standard,
			iCloud: Bool = false,
			default defaultValueGetter: @escaping () -> Value
		) {
			self.defaultValueGetter = defaultValueGetter

			super.init(name: name, suite: suite)

			if iCloud {
				SimpleDefaults.iCloud.add(self)
			}
		}
	}
}

extension SimpleDefaults.Key {
	// We cannot declare this convenience initializer in class directly because of "@_transparent' attribute is not supported on declarations within classes".
	/**
	Create a key with an optional value.

	- Parameter name: The name must be ASCII, not start with `@`, and cannot contain a dot (`.`).
	- Parameter suite: The `UserDefaults` suite to store the value in.
	- Parameter iCloud: Automatically synchronize the value with ``Defaults/iCloud``.
	*/
	public convenience init<T>(
		_ name: String,
		suite: UserDefaults = .standard,
		iCloud: Bool = false
	) where Value == T? {
		self.init(
			name,
			default: nil,
			suite: suite,
			iCloud: iCloud
		)
	}

	/**
	Check whether the stored value is the default value.

	- Note: This is only for internal use because it would not work for non-equatable values.
	*/
	var _isDefaultValue: Bool {
		let defaultValue = defaultValue
		let value = suite[self]
		guard
			let defaultValue = defaultValue as? any Equatable,
			let value = value as? any Equatable
		else {
			return false
		}

		return defaultValue.isEqual(value)
	}
}

extension SimpleDefaults.Key where Value: Equatable {
	/**
	Indicates whether the value is the same as the default value.
	*/
	public var isDefaultValue: Bool { suite[self] == defaultValue }
}

extension SimpleDefaults {
	/**
	Remove all entries from the given `UserDefaults` suite.

	- Note: This only removes user-defined entries. System-defined entries will remain.
	*/
	public static func removeAll(suite: UserDefaults = .standard) {
		suite.removeAll()
	}
}

extension SimpleDefaults._AnyKey: Equatable {
	public static func == (lhs: SimpleDefaults._AnyKey, rhs: SimpleDefaults._AnyKey) -> Bool {
		lhs.name == rhs.name
			&& lhs.suite == rhs.suite
	}
}

extension SimpleDefaults._AnyKey: Hashable {
	public func hash(into hasher: inout Hasher) {
		hasher.combine(name)
		hasher.combine(suite)
	}
}

extension SimpleDefaults {
	/**
	Observe updates to a stored value.

	- Parameter key: The key to observe updates from.
	- Parameter initial: Trigger an initial event on creation. This can be useful for setting default values on controls.

	```swift
	extension SimpleDefaults.Keys {
		static let isUnicornMode = Key<Bool>("isUnicornMode", default: false)
	}

	// …

	Task {
		for await value in SimpleDefaults.updates(.isUnicornMode) {
			print("Value:", value)
		}
	}
	```
	*/
	public static func updates<Value: Serializable>(
		_ key: Key<Value>,
		initial: Bool = true
	) -> AsyncStream<Value> { // TODO: Make this `some AsyncSequence<Value>` when targeting macOS 15.
		.init { continuation in
			let observation = DefaultsObservation(object: key.suite, key: key.name) { _, change in
				// TODO: Use the `.deserialize` method directly.
				let value = KeyChange(change: change, defaultValue: key.defaultValue).newValue
				continuation.yield(value)
			}

			observation.start(options: initial ? [.initial] : [])

			continuation.onTermination = { _ in
				// `invalidate()` should be thread-safe, but it is not in practice.
				DispatchQueue.main.async {
					observation.invalidate()
				}
			}
		}
	}

	/**
	Observe updates to multiple stored values.

	- Parameter keys: The keys to observe updates from.
	- Parameter initial: Trigger an initial event on creation. This can be useful for setting default values on controls.

	```swift
	Task {
		for await (foo, bar) in SimpleDefaults.updates([.foo, .bar]) {
			print("Values changed:", foo, bar)
		}
	}
	```
	*/
	public static func updates<each Value: Serializable>(
		_ keys: repeat Key<each Value>,
		initial: Bool = true
	) -> AsyncStream<(repeat each Value)> {
		.init { continuation in
			func getCurrentValues() -> (repeat each Value) {
				(repeat self[each keys])
			}

			var observations = [DefaultsObservation]()

			if initial {
				continuation.yield(getCurrentValues())
			}

			for key in repeat (each keys) {
				let observation = DefaultsObservation(object: key.suite, key: key.name) { _, _  in
					continuation.yield(getCurrentValues())
				}

				observation.start(options: [])
				observations.append(observation)
			}

			let immutableObservations = observations

			continuation.onTermination = { _ in
				// `invalidate()` should be thread-safe, but it is not in practice.
				DispatchQueue.main.async {
					for observation in immutableObservations {
						observation.invalidate()
					}
				}
			}
		}
	}

	// We still keep this as it can be useful to pass a dynamic array of keys.
	/**
	Observe updates to multiple stored values without receiving the values.

	- Parameter keys: The keys to observe updates from.
	- Parameter initial: Trigger an initial event on creation. This can be useful for setting default values on controls.

	```swift
	Task {
		for await _ in SimpleDefaults.updates([.foo, .bar]) {
			print("One of the values changed")
		}
	}
	```

	- Note: This does not include which of the values changed. Use ``Defaults/updates(_:initial:)-l03o`` if you need that.
	*/
	public static func updates(
		_ keys: [_AnyKey],
		initial: Bool = true
	) -> AsyncStream<Void> { // TODO: Make this `some AsyncSequence<Void>` when targeting macOS 15.
		.init { continuation in
			let observations = keys.indexed().map { index, key in
				let observation = DefaultsObservation(object: key.suite, key: key.name) { _, _ in
					continuation.yield()
				}

				// Ensure we only trigger a single initial event.
				observation.start(options: initial && index == 0 ? [.initial] : [])

				return observation
			}

			continuation.onTermination = { _ in
				// `invalidate()` should be thread-safe, but it is not in practice.
				DispatchQueue.main.async {
					for observation in observations {
						observation.invalidate()
					}
				}
			}
		}
	}
}
