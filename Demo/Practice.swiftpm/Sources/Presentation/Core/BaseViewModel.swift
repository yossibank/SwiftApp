import Combine

protocol LogicProtocol {
    associatedtype State
    associatedtype Dependency = Void
    associatedtype Output = Void
}

typealias BaseViewModel<Logic: LogicProtocol> = LogicProtocol & ViewModel<Logic>

@MainActor
class ViewModel<Logic: LogicProtocol>: ObservableObject {
    typealias State = Logic.State
    typealias Dependency = Logic.Dependency
    typealias Output = Logic.Output

    @Published var state: State
    let dependency: Dependency
    let output: AnyPublisher<Output, Never>
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var cancellables = Set<AnyCancellable>()

    required init(
        state: State,
        dependency: Dependency
    ) {
        self.state = state
        self.dependency = dependency
        self.output = outputSubject.eraseToAnyPublisher()
    }

    convenience init(state: State) where Dependency == Void {
        self.init(state: state, dependency: ())
    }

    func send(_ output: Output) {
        outputSubject.send(output)
    }
}
