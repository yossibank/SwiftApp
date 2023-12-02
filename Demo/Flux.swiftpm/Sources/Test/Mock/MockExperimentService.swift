import Foundation

final class MockExperimentService: ExperimentServiceType {
    var stubs: [ExperimentKey: Bool] = [:]

    func experiment(for key: ExperimentKey, value: Bool) {
        stubs[key] = value
    }

    func experiment(for key: ExperimentKey) -> Bool {
        stubs[key] ?? false
    }
}
