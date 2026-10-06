import HeraldCore
import Testing

@testable import HeraldFirebase

@Suite struct Parameters {
    @Test func numbersStayNumbersAndFlagsBecomeTextSinceGA4HasNoBooleanType() {
        let firebase = RecordingFirebaseSDK()
        let event = TestEvent(
            name: "checkout_started",
            parameters: [
                "plan": .string("pro"), "seats": .int(3), "price": .double(9.99),
                "trial": .bool(false),
            ])

        GenericFirebaseEventTracker(event: event, sdk: firebase).track()

        #expect(
            firebase.calls == [
                "logEvent checkout_started plan=String(pro) price=Double(9.99) seats=Int(3) "
                    + "trial=String(false)"
            ])
    }
}

@Suite struct Trackers {
    let firebase = RecordingFirebaseSDK()

    @Test func theGenericTrackerLogsTheEventUnderItsOwnName() {
        GenericFirebaseEventTracker(event: TestEvent(name: "cart_viewed"), sdk: firebase)
            .track()

        #expect(firebase.calls == ["logEvent cart_viewed"])
    }

    @Test func aScreenViewIsLoggedAsScreenViewWithItsNameAsTheScreenName() throws {
        let screen = TestScreenView(name: "checkout", parameters: ["source": .string("cart")])

        try ScreenViewFirebaseEventTracker(event: screen, sdk: firebase).track()

        #expect(
            firebase.calls == [
                "logEvent screen_view screen_name=String(checkout) source=String(cart)"
            ])
    }

    @Test func aScreenViewWithItsOwnScreenNameParameterIsRefusedAndNothingIsSent() {
        let screen = TestScreenView(name: "checkout", parameters: ["screen_name": .string("other")])

        #expect {
            try ScreenViewFirebaseEventTracker(event: screen, sdk: firebase).track()
        } throws: { error in
            "\(error)".contains("can't have a 'screen_name' parameter")
        }
        #expect(firebase.calls.isEmpty)
    }

    @Test func aPropertyIsSetAsAUserPropertyAsText() {
        let property = TestProperty(name: "seats", value: .int(3))

        GenericFirebasePropertySetter(property: property, sdk: firebase).set()

        #expect(firebase.calls == ["setUserProperty seats=3"])
    }
}

/// Keeps `debug_ping` away from Firebase.
private struct DropDebugPing: FirebaseEventTrackerFactory {
    func create(_ event: any Event) -> Resolution<any FirebaseEventTracker> {
        event.name == "debug_ping" ? .dropped : .declined
    }
}

@Suite struct Factories {
    let firebase = RecordingFirebaseSDK()

    @Test func theScreenViewFactoryClaimsScreenViewsAndDeclinesTheRest() throws {
        let factory = ScreenViewFirebaseEventTrackerFactory(sdk: firebase)

        #expect(
            try factory.create(TestScreenView(name: "home")).handlers().first
                is ScreenViewFirebaseEventTracker)
        #expect(try factory.create(TestEvent(name: "cart_viewed")).handlers().isEmpty)
    }

    @Test func aChainSendsScreenViewsAsScreenViewsAndEverythingElseAsIs() {
        let tracker = FirebaseAnalyticsTrackerService(
            eventTrackerFactory: CompositeFirebaseEventTrackerFactory([
                ScreenViewFirebaseEventTrackerFactory(sdk: firebase),
                GenericFirebaseEventTrackerFactory(sdk: firebase),
            ]),
            propertySetterFactory: GenericFirebasePropertySetterFactory(sdk: firebase)
        )
        let herald = Herald(providers: [HeraldProvider(name: "firebase", events: tracker)])

        herald.track(TestScreenView(name: "home"))
        herald.track(TestEvent(name: "cart_viewed"))

        #expect(
            firebase.calls == [
                "logEvent screen_view screen_name=String(home)", "logEvent cart_viewed",
            ])
    }

    @Test func aChainEndingInRequireMappedReportsAnUnclaimedEventThroughHerald() throws {
        let failures = ReportedFailures()
        let tracker = FirebaseAnalyticsTrackerService(
            eventTrackerFactory: CompositeFirebaseEventTrackerFactory([
                ScreenViewFirebaseEventTrackerFactory(sdk: firebase),
                RequireMappedFirebaseEventTrackerFactory(),
            ]),
            propertySetterFactory: RequireMappedFirebasePropertySetterFactory()
        )
        let herald = Herald(
            providers: [HeraldProvider(name: "firebase", events: tracker, properties: tracker)],
            errorReporter: { failure in failures.append(failure) }
        )

        herald.track(TestEvent(name: "checkout_started"))
        herald.set(TestProperty(name: "plan", value: .string("pro")))

        #expect(firebase.calls.isEmpty)
        #expect(failures.all.count == 2)
        let failure = try #require(failures.all.first)
        #expect(failure.provider == "firebase")
        #expect(failure.operation == .track(eventName: "checkout_started"))
        #expect(failure.error is UnhandledEventError)
        #expect(failures.all.last?.error is UnhandledPropertyError)
    }

    @Test func aRefusedScreenViewIsReportedThroughHerald() throws {
        let failures = ReportedFailures()
        let tracker = FirebaseAnalyticsTrackerService(
            eventTrackerFactory: ScreenViewFirebaseEventTrackerFactory(sdk: firebase),
            propertySetterFactory: GenericFirebasePropertySetterFactory(sdk: firebase)
        )
        let herald = Herald(
            providers: [HeraldProvider(name: "firebase", events: tracker)],
            errorReporter: { failure in failures.append(failure) }
        )

        herald.track(TestScreenView(name: "home", parameters: ["screen_name": .string("x")]))

        let failure = try #require(failures.all.first)
        #expect("\(failure)".hasPrefix("firebase failed on Track(home): Screen view 'home'"))
    }

    @Test func droppedKeepsOneEventAwayFromFirebase() {
        let tracker = FirebaseAnalyticsTrackerService(
            eventTrackerFactory: CompositeFirebaseEventTrackerFactory([
                DropDebugPing(),
                GenericFirebaseEventTrackerFactory(sdk: firebase),
            ]),
            propertySetterFactory: GenericFirebasePropertySetterFactory(sdk: firebase)
        )
        let herald = Herald(providers: [HeraldProvider(name: "firebase", events: tracker)])

        herald.track(TestEvent(name: "debug_ping"))
        herald.track(TestEvent(name: "cart_viewed"))

        #expect(firebase.calls == ["logEvent cart_viewed"])
    }

    #if os(macOS)
        @Test func aGenericFactoryAnywhereButLastIsRefusedWhenTheChainIsBuilt() async throws {
            let result = await #expect(
                processExitsWith: .failure, observing: [\.standardErrorContent]
            ) {
                _ = CompositeFirebaseEventTrackerFactory([
                    GenericFirebaseEventTrackerFactory(),
                    ScreenViewFirebaseEventTrackerFactory(),
                ])
            }
            let message = String(
                decoding: try #require(result).standardErrorContent, as: UTF8.self)
            #expect(message.contains("GenericFirebaseEventTrackerFactory answers for everything"))
        }
    #endif
}

@Suite struct Service {
    let firebase = RecordingFirebaseSDK()

    @Test func consentMapsToCollectionEnabled() {
        let service = FirebaseAnalyticsService(sdk: firebase)

        service.setEnabled(true)
        service.setEnabled(false)

        #expect(
            firebase.calls == [
                "setAnalyticsCollectionEnabled true", "setAnalyticsCollectionEnabled false",
            ])
    }

    @Test func identifyAndResetSetAndClearTheUserId() {
        let service = FirebaseAnalyticsService(sdk: firebase)

        service.identify(Identity(userId: "user-1"))
        service.reset()

        #expect(firebase.calls == ["setUserID user-1", "setUserID nil"])
    }

    @Test func startAndFlushTouchNothingSinceFirebaseStartsItselfAndHasNoFlush() {
        let service = FirebaseAnalyticsService(sdk: firebase)

        service.start()
        service.flush()

        #expect(firebase.calls.isEmpty)
    }
}
