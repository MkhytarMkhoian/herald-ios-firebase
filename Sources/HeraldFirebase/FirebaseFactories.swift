import HeraldCore

/// Logs any event under its own name, with its parameters. Claims every event, so it goes last in
/// a chain.
public struct GenericFirebaseEventTrackerFactory: FirebaseEventTrackerFactory, FallbackFactory {
    private let sdk: any FirebaseSDK

    public init() {
        self.init(sdk: LiveFirebaseSDK())
    }

    init(sdk: any FirebaseSDK) {
        self.sdk = sdk
    }

    public func create(_ event: any Event) -> Resolution<any FirebaseEventTracker> {
        .claimed([GenericFirebaseEventTracker(event: event, sdk: sdk)])
    }
}

/// Claims every ``ScreenViewEvent`` and declines everything else.
///
/// GA4 records a screen view as its own `screen_view` event, with the screen name as a parameter,
/// so screen views can't go through the generic factory. To send them differently, put your own
/// factory before this one.
public struct ScreenViewFirebaseEventTrackerFactory: FirebaseEventTrackerFactory {
    private let sdk: any FirebaseSDK

    public init() {
        self.init(sdk: LiveFirebaseSDK())
    }

    init(sdk: any FirebaseSDK) {
        self.sdk = sdk
    }

    public func create(_ event: any Event) -> Resolution<any FirebaseEventTracker> {
        if let screenView = event as? any ScreenViewEvent {
            return .claimed([
                ScreenViewFirebaseEventTracker(event: screenView, sdk: sdk)
            ])
        }
        return .declined
    }
}

/// Sets any property as a Firebase user property, ``UserProperty`` included: Firebase has one kind
/// of property. Claims every property, so it goes last in a chain.
public struct GenericFirebasePropertySetterFactory: FirebasePropertySetterFactory, FallbackFactory {
    private let sdk: any FirebaseSDK

    public init() {
        self.init(sdk: LiveFirebaseSDK())
    }

    init(sdk: any FirebaseSDK) {
        self.sdk = sdk
    }

    public func create(_ property: any Property) -> Resolution<any FirebasePropertySetter> {
        .claimed([GenericFirebasePropertySetter(property: property, sdk: sdk)])
    }
}
