import HeraldCore

/// Firebase's lifecycle, identity and consent.
///
/// **Before consent arrives, Firebase collects.** `start` doesn't turn collection off, because
/// Firebase reads its off switch when the app launches. If a fresh install must collect nothing
/// until the user has answered, add this to the app's `Info.plist`:
///
/// ```xml
/// <key>FIREBASE_ANALYTICS_COLLECTION_ENABLED</key>
/// <false/>
/// ```
///
/// `setEnabled` then turns collection on, and Firebase remembers the choice across launches.
///
/// To keep the user id away from Firebase, register the provider without `identity`.
public struct FirebaseAnalyticsService: AnalyticsLifecycleService, IdentifiableUserService,
    ConsentService
{
    private let sdk: any FirebaseSDK

    public init() {
        self.init(sdk: LiveFirebaseSDK())
    }

    init(sdk: any FirebaseSDK) {
        self.sdk = sdk
    }

    /// Firebase starts itself when the app calls `FirebaseApp.configure()`, so there is nothing to
    /// do.
    public func start() {}

    /// Firebase has no flush call.
    public func flush() {}

    public func setEnabled(_ enabled: Bool) {
        sdk.setAnalyticsCollectionEnabled(enabled)
    }

    public func identify(_ identity: Identity) {
        sdk.setUserID(identity.userId)
    }

    public func reset() {
        sdk.setUserID(nil)
    }
}
