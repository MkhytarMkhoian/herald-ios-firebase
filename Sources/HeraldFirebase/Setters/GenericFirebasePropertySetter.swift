import HeraldCore

/// Sets `property` as a Firebase user property. Firebase user properties are text only, so the
/// value is written as text.
public struct GenericFirebasePropertySetter: FirebasePropertySetter {
    private let property: any Property
    private let sdk: any FirebaseSDK

    public init(property: any Property) {
        self.init(property: property, sdk: LiveFirebaseSDK())
    }

    init(property: any Property, sdk: any FirebaseSDK) {
        self.property = property
        self.sdk = sdk
    }

    public func set() {
        sdk.setUserProperty(property.value.asString, forName: property.name)
    }
}
