import HeraldCore

extension [String: AnalyticsValue] {
    /// The parameters as Firebase takes them, with their types kept where GA4 has a matching type.
    ///
    /// GA4 accepts text and number parameters, so a number arrives as a number and stays
    /// aggregable. It has no boolean type, so a flag is written as text, `"true"` or `"false"`.
    /// For a tracker of your own: `Analytics.logEvent("refund", parameters: ...)`.
    public func toFirebaseParameters() -> [String: Any] {
        var result: [String: Any] = [:]
        for (key, value) in self {
            switch value {
            case .int(let number):
                result[key] = number
            case .double(let number):
                result[key] = number
            case .string, .bool:
                result[key] = value.asString
            }
        }
        return result
    }
}

/// Why this module refused an event: it says what to change.
struct FirebaseRefusal: Error, CustomStringConvertible {
    let description: String
}
