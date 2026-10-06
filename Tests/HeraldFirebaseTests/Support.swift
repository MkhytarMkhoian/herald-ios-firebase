import Foundation
import HeraldCore

@testable import HeraldFirebase

struct TestEvent: Event {
    let name: String
    var parameters: [String: AnalyticsValue] = [:]
}

struct TestScreenView: ScreenViewEvent {
    let name: String
    var parameters: [String: AnalyticsValue] = [:]
}

struct TestProperty: Property {
    let name: String
    let value: AnalyticsValue
}

/// Records the Firebase calls instead of making them, each as one line that shows every
/// parameter's type, like `logEvent checkout seats=Int(3)`. Locked, so any thread can call it:
/// hence `@unchecked Sendable`.
final class RecordingFirebaseSDK: FirebaseSDK, @unchecked Sendable {
    private let lock = NSLock()
    private var recorded: [String] = []

    var calls: [String] {
        lock.lock()
        defer { lock.unlock() }
        return recorded
    }

    func logEvent(_ name: String, parameters: [String: Any]) {
        var line = "logEvent \(name)"
        for key in parameters.keys.sorted() {
            let value = parameters[key]!
            line += " \(key)=\(type(of: value))(\(value))"
        }
        record(line)
    }

    func setUserProperty(_ value: String?, forName name: String) {
        record("setUserProperty \(name)=\(value ?? "nil")")
    }

    func setUserID(_ userID: String?) {
        record("setUserID \(userID ?? "nil")")
    }

    func setAnalyticsCollectionEnabled(_ enabled: Bool) {
        record("setAnalyticsCollectionEnabled \(enabled)")
    }

    private func record(_ line: String) {
        lock.lock()
        defer { lock.unlock() }
        recorded.append(line)
    }
}

/// What Herald sent to its error reporter. Locked like ``RecordingFirebaseSDK``.
final class ReportedFailures: @unchecked Sendable {
    private let lock = NSLock()
    private var failures: [AnalyticsFailure] = []

    var all: [AnalyticsFailure] {
        lock.lock()
        defer { lock.unlock() }
        return failures
    }

    func append(_ failure: AnalyticsFailure) {
        lock.lock()
        defer { lock.unlock() }
        failures.append(failure)
    }
}
