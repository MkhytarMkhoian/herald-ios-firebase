import HeraldCore

/// Sends events and properties to Firebase, as its factory chains decide. The calls for one event
/// run in order, and if one fails the rest don't run. Anything no factory claims isn't sent.
///
/// ```swift
/// let tracker = FirebaseAnalyticsTrackerService(
///     eventTrackerFactory: CompositeFirebaseEventTrackerFactory([
///         ScreenViewFirebaseEventTrackerFactory(),  // GA4's own screen_view
///         GenericFirebaseEventTrackerFactory(),  // everything else, as-is
///     ]),
///     propertySetterFactory: GenericFirebasePropertySetterFactory()
/// )
/// ```
public struct FirebaseAnalyticsTrackerService: EventTrackerService, PropertyTrackerService {
    private let eventTrackerFactory: any FirebaseEventTrackerFactory
    private let propertySetterFactory: any FirebasePropertySetterFactory

    public init(
        eventTrackerFactory: any FirebaseEventTrackerFactory,
        propertySetterFactory: any FirebasePropertySetterFactory
    ) {
        self.eventTrackerFactory = eventTrackerFactory
        self.propertySetterFactory = propertySetterFactory
    }

    public func track(_ event: any Event) {
        do {
            for tracker in try eventTrackerFactory.create(event).handlers() {
                try tracker.track()
            }
        } catch {
            Herald.reportFailure(error)
        }
    }

    public func set(_ property: any Property) {
        do {
            for setter in try propertySetterFactory.create(property).handlers() {
                try setter.set()
            }
        } catch {
            Herald.reportFailure(error)
        }
    }
}
