import Foundation

final class MockTrackerService: TrackerType {
    private(set) var loggedTypes: [TrackEventType] = []

    func log(type: TrackEventType) {
        loggedTypes.append(type)
    }
}
