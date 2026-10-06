import FirebaseAnalytics
import HeraldCore

/// Logs `event` as GA4's `screen_view`, with its name as `screen_name`.
///
/// Throws if the event has its own `screen_name` parameter, because it would replace the screen's
/// name.
public struct ScreenViewFirebaseEventTracker: FirebaseEventTracker {
    private let event: any ScreenViewEvent
    private let sdk: any FirebaseSDK

    public init(event: any ScreenViewEvent) {
        self.init(event: event, sdk: LiveFirebaseSDK())
    }

    init(event: any ScreenViewEvent, sdk: any FirebaseSDK) {
        self.event = event
        self.sdk = sdk
    }

    public func track() throws {
        var parameters = firebaseParameters(event.parameters)
        if parameters[AnalyticsParameterScreenName] != nil {
            throw FirebaseRefusal(
                description: "Screen view '\(event.name)' can't have a 'screen_name' parameter: "
                    + "GA4 uses it for the screen's name.")
        }
        parameters[AnalyticsParameterScreenName] = event.name
        sdk.logEvent(AnalyticsEventScreenView, parameters: parameters)
    }
}
