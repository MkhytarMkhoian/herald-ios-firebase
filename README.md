# Herald for Firebase

[![Swift versions](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FMkhytarMkhoian%2Fherald-ios-firebase%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/MkhytarMkhoian/herald-ios-firebase)
[![Platforms](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FMkhytarMkhoian%2Fherald-ios-firebase%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/MkhytarMkhoian/herald-ios-firebase)

Sends [Herald](https://github.com/MkhytarMkhoian/herald-ios) events and properties to Firebase
Analytics (GA4), over the [Firebase iOS SDK](https://github.com/firebase/firebase-ios-sdk).

## Install

In Xcode, File → Add Package Dependencies, and add both packages:

- `https://github.com/MkhytarMkhoian/herald-ios`, for `HeraldCore`;
- `https://github.com/MkhytarMkhoian/herald-ios-firebase`, for `HeraldFirebase`.

It works with Firebase 12, and needs iOS 15 or newer. All Herald for iOS
packages share one version, so use the same one for `herald-ios`.

## Set up

Configure Firebase as usual, with `FirebaseApp.configure()` at launch. Then:

```swift
import HeraldCore
import HeraldFirebase

let tracker = FirebaseAnalyticsTrackerService(
    eventTrackerFactory: CompositeFirebaseEventTrackerFactory([
        ScreenViewFirebaseEventTrackerFactory(),  // GA4's own screen_view
        GenericFirebaseEventTrackerFactory(),  // everything else, as-is
    ]),
    propertySetterFactory: GenericFirebasePropertySetterFactory()
)
let service = FirebaseAnalyticsService()

let provider = HeraldProvider(
    name: "firebase",
    events: tracker,
    properties: tracker,
    identity: service,
    lifecycle: service,
    consent: service
)
```

| Herald | Firebase |
| --- | --- |
| an event | `Analytics.logEvent`, with numbers as numbers and flags as `"true"`/`"false"` |
| a `ScreenViewEvent` | `screen_view`, with the event's name as `screen_name` |
| a property | `Analytics.setUserProperty`, as text |
| `identify` / `reset` | `Analytics.setUserID(id)` / `Analytics.setUserID(nil)` |
| `setEnabled` | `Analytics.setAnalyticsCollectionEnabled` |

A screen view with its own `screen_name` parameter is refused and sent to Herald's error reporter,
because it would replace the screen's name.

Herald's error reporter can send vendor failures to Crashlytics:

```swift
let herald = Herald(
    providers: [provider],
    errorReporter: { failure in
        // "firebase failed on Track(checkout_started): ..."
        Crashlytics.crashlytics().record(error: failure.error, userInfo: ["call": "\(failure)"])
    }
)
```

**Firebase collects before consent** unless you turn collection off in `Info.plist` with
`FIREBASE_ANALYTICS_COLLECTION_ENABLED` set to `NO`. `setEnabled(true)` then turns it on, and
Firebase remembers the choice.

## Documentation

The [Herald website](https://mkhytarmkhoian.github.io/herald-docs/) has the guides.

## License

Apache License 2.0. See [LICENSE](LICENSE).
