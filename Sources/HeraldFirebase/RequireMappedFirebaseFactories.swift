import HeraldCore

/// Fails for any event that reaches it, so the error reporter shows events nobody mapped. Put it
/// last in a chain.
public struct RequireMappedFirebaseEventTrackerFactory: FirebaseEventTrackerFactory,
    FallbackFactory
{
    public init() {}

    public func create(_ event: any Event) throws -> Resolution<any FirebaseEventTracker> {
        throw UnhandledEventError(event: event)
    }
}

public struct RequireMappedFirebasePropertySetterFactory: FirebasePropertySetterFactory,
    FallbackFactory
{
    public init() {}

    public func create(_ property: any Property) throws -> Resolution<any FirebasePropertySetter> {
        throw UnhandledPropertyError(property: property)
    }
}
