import HeraldCore

public struct GenericFirebaseEventTracker: FirebaseEventTracker {
    private let event: any Event
    private let sdk: any FirebaseSDK

    public init(event: any Event) {
        self.init(event: event, sdk: LiveFirebaseSDK())
    }

    init(event: any Event, sdk: any FirebaseSDK) {
        self.event = event
        self.sdk = sdk
    }

    public func track() {
        sdk.logEvent(event.name, parameters: firebaseParameters(event.parameters))
    }
}
