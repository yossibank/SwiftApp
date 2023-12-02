import Combine

final class GitHubActionCreator {
    private var cancellables = [AnyCancellable]()

    private let dispatcher: GitHubListDispatcher
    private let apiService: APIServiceType
    private let trackerService: TrackerType
    private let experimentService: ExperimentServiceType

    private let trackingSubject = PassthroughSubject<TrackEventType, Never>()
    private let responseSubject = PassthroughSubject<SearchRepositoryResponse, Never>()
    private let errorSubject = PassthroughSubject<APIServiceError, Never>()
    private let onAppearSubject = PassthroughSubject<Void, Never>()

    init(
        dispatcher: GitHubListDispatcher = .shared,
        apiService: APIServiceType = APIService(),
        trackerService: TrackerType = TrackerService(),
        experimentService: ExperimentServiceType = ExperimentService()
    ) {
        self.dispatcher = dispatcher
        self.apiService = apiService
        self.trackerService = trackerService
        self.experimentService = experimentService

        bindData()
        bindActions()
    }

    private func bindData() {
        let responsePublisher = onAppearSubject
            .flatMap { [apiService] _ in
                apiService.response(from: SearchRepositoryRequest())
                    .catch { [weak self] error -> Empty<SearchRepositoryResponse, Never> in
                        self?.errorSubject.send(error)
                        return .init()
                    }
            }

        let responseStream = responsePublisher
            .share()
            .subscribe(responseSubject)

        let trackingDataStream = trackingSubject
            .sink(receiveValue: trackerService.log)

        let trackingStream = onAppearSubject
            .map { .listView }
            .subscribe(trackingSubject)

        cancellables += [
            responseStream,
            trackingDataStream,
            trackingStream
        ]
    }

    private func bindActions() {
        let responseDataStream = responseSubject
            .map(\.items)
            .sink { [dispatcher] in
                dispatcher.dispatch(.updateRepositories($0))
            }

        let errorDataStream = errorSubject
            .map { error -> String in
                switch error {
                case .responseError: "network error"
                case .parseError: "parse error"
                }
            }
            .sink { [dispatcher] in
                dispatcher.dispatch(.updateErrorMessage($0))
            }

        let errorStream = errorSubject
            .map { _ in }
            .sink { [dispatcher] in
                dispatcher.dispatch(.showError)
            }

        let experimentStream = onAppearSubject
            .filter { [experimentService] _ in
                experimentService.experiment(for: .showIcon)
            }
            .sink { [dispatcher] in
                dispatcher.dispatch(.showIcon)
            }

        cancellables += [
            responseDataStream,
            errorDataStream,
            errorStream,
            experimentStream
        ]
    }

    func onAppear() {
        onAppearSubject.send(())
    }
}
