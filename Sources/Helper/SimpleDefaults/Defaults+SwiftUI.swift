import SwiftUI
import Combine

extension SimpleDefaults {
	@MainActor
	final class Observable<Value: Serializable>: ObservableObject {
		private var cancellable: AnyCancellable?
		private var task: Task<Void, Never>?

		var key: SimpleDefaults.Key<Value> {
			didSet {
				if key != oldValue {
					observe()
				}
			}
		}

		var value: Value {
			get { SimpleDefaults[key] }
			set {
				SimpleDefaults[key] = newValue
			}
		}

		init(_ key: Key<Value>) {
			self.key = key

			observe()
		}

		deinit {
			task?.cancel()
		}

		private func observe() {
			// We only use this on the latest OSes (as of adding this) since the backdeploy library has a lot of bugs.
			if #available(macOS 13, iOS 16, tvOS 16, watchOS 9, visionOS 1.0, *) {
				task?.cancel()

				// The `@MainActor` is important as the `.send()` method doesn't inherit the `@MainActor` from the class.
				task = .detached(priority: .userInitiated) { @MainActor [weak self, key] in
					for await _ in SimpleDefaults.updates(key) {
						guard let self else {
							return
						}

						objectWillChange.send()
					}
				}
			} else {
				cancellable = SimpleDefaults.publisher(key, options: [.prior])
					.sink { [weak self] change in
						guard change.isPrior else {
							return
						}

						Task { @MainActor in
							self?.objectWillChange.send()
						}
					}
			}
		}

		/**
		Reset the key back to its default value.
		*/
		func reset() {
			key.reset()
		}
	}
}

/**
Access stored values from SwiftUI.

This is similar to `@AppStorage` but it accepts a ``Defaults/Key`` and many more types.
*/
@propertyWrapper
public struct SimpleSetting<Value: SimpleDefaults.Serializable>: DynamicProperty {
	@_documentation(visibility: private)
	public typealias Publisher = AnyPublisher<SimpleDefaults.KeyChange<Value>, Never>

	private let key: SimpleDefaults.Key<Value>

	@StateObject private var observable: SimpleDefaults.Observable<Value>

	/**
	Get/set a `Defaults` item and also have the view be updated when the value changes. This is similar to `@State`.

	- Important: You cannot use this in an `ObservableObject`. It's meant to be used in a `View`.

	```swift
	extension SimpleDefaults.Keys {
		static let hasUnicorn = Key<Bool>("hasUnicorn", default: false)
	}

	struct ContentView: View {
		@Default(.hasUnicorn) var hasUnicorn

		var body: some View {
			Text("Has Unicorn: \(hasUnicorn)")
			Toggle("Toggle", isOn: $hasUnicorn)
			Button("Reset") {
				_hasUnicorn.reset()
			}
		}
	}
	```
	*/
	public init(_ key: SimpleDefaults.Key<Value>) {
		self.key = key
		self._observable = .init(wrappedValue: .init(key))
	}

	public var wrappedValue: Value {
		get { observable.value }
		nonmutating set {
			observable.value = newValue
		}
	}

	public var projectedValue: Binding<Value> { $observable.value }

	/**
	The default value of the key.
	*/
	public var defaultValue: Value { key.defaultValue }

	/**
	Combine publisher that publishes values when the `Defaults` item changes.
	*/
	public var publisher: Publisher { SimpleDefaults.publisher(key) }

	@_documentation(visibility: private)
	public mutating func update() {
		observable.key = key
		_observable.update()
	}

	/**
	Reset the key back to its default value.

	```swift
	extension SimpleDefaults.Keys {
		static let opacity = Key<Double>("opacity", default: 1)
	}

	struct ContentView: View {
		@Default(.opacity) var opacity

		var body: some View {
			Button("Reset") {
				_opacity.reset()
			}
		}
	}
	```
	*/
	public func reset() {
		key.reset()
	}
}

extension SimpleSetting where Value: Equatable {
	/**
	Indicates whether the value is the same as the default value.
	*/
	public var isDefaultValue: Bool { wrappedValue == defaultValue }
}

extension SimpleDefaults {
	/**
	A SwiftUI `Toggle` view that is connected to a ``Defaults/Key`` with a `Bool` value.

	The toggle works exactly like the SwiftUI `Toggle`.

	```swift
	extension SimpleDefaults.Keys {
		static let showAllDayEvents = Key<Bool>("showAllDayEvents", default: false)
	}

	struct ShowAllDayEventsSetting: View {
		var body: some View {
			Defaults.Toggle("Show All-Day Events", key: .showAllDayEvents)
		}
	}
	```

	You can also listen to changes:

	```swift
	struct ShowAllDayEventsSetting: View {
		var body: some View {
			Defaults.Toggle("Show All-Day Events", key: .showAllDayEvents)
				// Note that this has to be directly attached to `SimpleDefaults.Toggle`. It's not `View#onChange()`.
				.onChange {
					print("Value", $0)
				}
		}
	}
	```
	*/
	public struct Toggle<Label: View>: View {
		@ViewStorage private var onChange: ((Bool) -> Void)?

		private let label: () -> Label

		// Intentionally using `@ObservedObjected` over `@StateObject` so that the key can be dynamically changed.
		@ObservedObject private var observable: SimpleDefaults.Observable<Bool>

		public init(key: SimpleDefaults.Key<Bool>, @ViewBuilder label: @escaping () -> Label) {
			self.label = label
			self.observable = .init(key)
		}

		@_documentation(visibility: private)
		public var body: some View {
			SwiftUI.Toggle(isOn: $observable.value, label: label)
				.onChange(of: observable.value) {
                    onChange?(observable.value)
				}
		}
	}
}

extension SimpleDefaults.Toggle<Text> {
	public init(
		_ title: some StringProtocol,
		key: SimpleDefaults.Key<Bool>
	) {
		self.label = { Text(title) }
		self.observable = .init(key)
	}
}

extension SimpleDefaults.Toggle<Label<Text, Image>> {
	public init(
		_ title: some StringProtocol,
		systemImage: String,
		key: SimpleDefaults.Key<Bool>
	) {
		self.label = { Label(title, systemImage: systemImage) }
		self.observable = .init(key)
	}
}

extension SimpleDefaults.Toggle {
	/**
	Do something when the value changes to a different value.
	*/
	public func onChange(_ action: @escaping (Bool) -> Void) -> Self {
		onChange = action
		return self
	}
}

@propertyWrapper
private struct ViewStorage<Value>: DynamicProperty {
	private final class ValueBox {
		var value: Value

		init(_ value: Value) {
			self.value = value
		}
	}

	@State private var valueBox: ValueBox

	var wrappedValue: Value {
		get { valueBox.value }
		nonmutating set {
			valueBox.value = newValue
		}
	}

	init(wrappedValue value: @autoclosure @escaping () -> Value) {
		self._valueBox = .init(wrappedValue: ValueBox(value()))
	}
}
