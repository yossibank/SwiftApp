import Foundation

enum TrackEventType {
    case listView
}

protocol TrackerType {
    func log(type: TrackEventType)
}

final class TrackerService: TrackerType {
    func log(type: TrackEventType) {
        // ログ送信
    }
}
