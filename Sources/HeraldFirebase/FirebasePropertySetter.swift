/// One call to Firebase for one property. A factory builds it.
public protocol FirebasePropertySetter {
    func set() throws
}
