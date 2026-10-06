import HeraldCore

public protocol FirebasePropertySetterFactory: Sendable {
    func create(_ property: any Property) throws -> Resolution<any FirebasePropertySetter>
}

/// Asks each factory in order and uses the first answer that isn't `declined`. If all decline,
/// nothing is sent. Stops the app if a ``FallbackFactory`` isn't last.
public struct CompositeFirebasePropertySetterFactory: FirebasePropertySetterFactory {
    private let factories: [any FirebasePropertySetterFactory]

    public init(_ factories: [any FirebasePropertySetterFactory]) {
        requireFallbackLast(factories)
        self.factories = factories
    }

    public func create(_ property: any Property) throws -> Resolution<any FirebasePropertySetter> {
        try Resolution.firstOf(factories) { factory in try factory.create(property) }
    }
}
