import Combine

final class GitHubListDispatcher {
    static let shared = GitHubListDispatcher()

    private var cancellables = [AnyCancellable]()

    private let actionSubject = PassthroughSubject<GitHubListAction, Never>()

    func register(callback: @escaping (GitHubListAction) -> Void) {
        let actionStream = actionSubject.sink(receiveValue: callback)
        cancellables += [actionStream]
    }

    func dispatch(_ action: GitHubListAction) {
        actionSubject.send(action)
    }
}
