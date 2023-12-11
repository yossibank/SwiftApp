import ComposableArchitecture
import SwiftUI

extension DependencyValues {
    var screenshots: @Sendable () async -> AsyncStream<Void> {
        get { self[ScreenShotsKey.self] }
        set { self[ScreenShotsKey.self] = newValue }
    }
}

private enum ScreenShotsKey: DependencyKey {
    static let liveValue: @Sendable () async -> AsyncStream<Void> = {
        await AsyncStream(
            NotificationCenter.default
                .notifications(named: UIApplication.userDidTakeScreenshotNotification)
                .map { _ in }
        )
    }

    static var testValue: @Sendable () async -> AsyncStream<Void> = unimplemented(
        #"@Dependency(\.screenshots)"#,
        placeholder: .finished
    )
}
