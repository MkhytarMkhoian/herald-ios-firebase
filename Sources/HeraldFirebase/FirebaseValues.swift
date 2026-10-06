import HeraldCore

/// The parameters with their types kept where GA4 has a matching type.
///
/// GA4 accepts text and number parameters, so a number arrives as a number and stays aggregable.
/// It has no boolean type, so a flag is written as text, `"true"` or `"false"`.
func firebaseParameters(_ parameters: [String: AnalyticsValue]) -> [String: Any] {
    var result: [String: Any] = [:]
    for (key, value) in parameters {
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

/// Why this module refused an event: it says what to change.
struct FirebaseRefusal: Error, CustomStringConvertible {
    let description: String
}
