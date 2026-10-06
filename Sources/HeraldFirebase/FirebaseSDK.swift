import FirebaseAnalytics

/// The Firebase calls this module makes, so the tests can record them instead: ``LiveFirebaseSDK``
/// in the app, a recorder in the tests. Firebase's API is static functions on `Analytics`, which a
/// test can't replace.
protocol FirebaseSDK: Sendable {
    func logEvent(_ name: String, parameters: [String: Any])
    func setUserProperty(_ value: String?, forName name: String)
    func setUserID(_ userID: String?)
    func setAnalyticsCollectionEnabled(_ enabled: Bool)
}

/// Calls Firebase Analytics itself.
struct LiveFirebaseSDK: FirebaseSDK {
    func logEvent(_ name: String, parameters: [String: Any]) {
        Analytics.logEvent(name, parameters: parameters)
    }

    func setUserProperty(_ value: String?, forName name: String) {
        Analytics.setUserProperty(value, forName: name)
    }

    func setUserID(_ userID: String?) {
        Analytics.setUserID(userID)
    }

    func setAnalyticsCollectionEnabled(_ enabled: Bool) {
        Analytics.setAnalyticsCollectionEnabled(enabled)
    }
}
