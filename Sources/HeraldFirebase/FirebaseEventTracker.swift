/// One call to Firebase for one event. A factory builds it.
public protocol FirebaseEventTracker {
    func track() throws
}
