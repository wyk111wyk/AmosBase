import Foundation

extension UserDefaults {
	func _get<Value: SimpleDefaults.Serializable>(_ key: String) -> Value? {
		guard let anyObject = object(forKey: key) else {
			return nil
		}

		return Value.toValue(anyObject)
	}

	 func _set<Value: SimpleDefaults.Serializable>(_ key: String, to value: Value) {
		if (value as? (any _DefaultsOptionalProtocol))?._defaults_isNil == true {
			removeObject(forKey: key)
			return
		}

		set(Value.toSerializable(value), forKey: key)
	}

	public subscript<Value: SimpleDefaults.Serializable>(key: SimpleDefaults.Key<Value>) -> Value {
		get { _get(key.name) ?? key.defaultValue }
		set {
			_set(key.name, to: newValue)
		}
	}
}

extension UserDefaults {
	/**
	Remove all entries.

	- Note: This only removes user-defined entries. System-defined entries will remain.
	*/
	public func removeAll() {
		// We're not using `.removePersistentDomain(forName:)` as it requires knowing the suite name and also because it doesn't emit change events for each key, but rather just `UserDefaults.didChangeNotification`, which we don't subscribe to.
		for key in dictionaryRepresentation().keys {
			removeObject(forKey: key)
		}
	}
}
