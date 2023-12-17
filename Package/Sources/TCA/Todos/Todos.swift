import ComposableArchitecture
import SwiftUI

enum Filter: LocalizedStringKey, CaseIterable, Hashable {
    case all = "All"
    case active = "Active"
    case completed = "Completed"
}

@Reducer
struct Todos {
    @Dependency(\.continuousClock) var clock
    @Dependency(\.uuid) var uuid

    struct State: Equatable {
        @BindingState var editMode: EditMode = .inactive
        @BindingState var filter: Filter = .all
        var todos: IdentifiedArrayOf<Todo.State> = []

        var filteredTodos: IdentifiedArrayOf<Todo.State> {
            switch filter {
            case .all: todos
            case .active: todos.filter { !$0.isComplete }
            case .completed: todos.filter(\.isComplete)
            }
        }
    }

    enum Action: BindableAction, Sendable {
        case addTodoButtonTapped
        case binding(BindingAction<State>)
        case clearCompletedButtonTapped
        case delete(IndexSet)
        case move(IndexSet, Int)
        case sortCompletedTodos
        case todos(IdentifiedActionOf<Todo>)
    }

    private enum CancelID {
        case todoCompletion
    }

    var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce<State, Action> { state, action in
            switch action {
            case .addTodoButtonTapped:
                state.todos.insert(.init(id: uuid()), at: 0)
                return .none

            case .binding:
                return .none

            case .clearCompletedButtonTapped:
                state.todos.removeAll(where: \.isComplete)
                return .none

            case let .delete(indexSet):
                let filteredTodos = state.filteredTodos

                for index in indexSet {
                    state.todos.remove(id: filteredTodos[index].id)
                }

                return .none

            case var .move(source, destination):
                if state.filter == .completed {
                    source = IndexSet(
                        source
                            .map { state.filteredTodos[$0] }
                            .compactMap { state.todos.index(id: $0.id) }
                    )

                    destination = (
                        destination < state.filteredTodos.endIndex
                            ? state.todos.index(id: state.filteredTodos[destination].id)
                            : state.todos.endIndex
                    ) ?? destination
                }

                state.todos.move(
                    fromOffsets: source,
                    toOffset: destination
                )

                return .run { send in
                    try await clock.sleep(for: .milliseconds(100))
                    await send(.sortCompletedTodos)
                }

            case .sortCompletedTodos:
                state.todos.sort { $1.isComplete && !$0.isComplete }
                return .none

            case .todos(.element(id: _, action: .binding(\.$isComplete))):
                return .run { send in
                    try await clock.sleep(for: .seconds(1))
                    await send(
                        .sortCompletedTodos,
                        animation: .default
                    )
                }
                .cancellable(id: CancelID.todoCompletion, cancelInFlight: true)

            case .todos:
                return .none
            }
        }
        .forEach(\.todos, action: \.todos) {
            Todo()
        }
    }
}

struct TodosView: View {
    let store: StoreOf<Todos>

    struct ViewState: Equatable {
        @BindingViewState var editMode: EditMode
        @BindingViewState var filter: Filter
        let isClearCompletedButtonDisabled: Bool

        init(store: BindingViewStore<Todos.State>) {
            self._editMode = store.$editMode
            self._filter = store.$filter
            self.isClearCompletedButtonDisabled = !store.todos.contains(where: \.isComplete)
        }
    }

    var body: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in
            NavigationStack {
                VStack(alignment: .leading) {
                    Picker("Filter", selection: viewStore.$filter.animation()) {
                        ForEach(Filter.allCases, id: \.self) { filter in
                            Text(filter.rawValue)
                                .tag(filter)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    List {
                        ForEachStore(
                            store.scope(
                                state: \.filteredTodos,
                                action: \.todos
                            )
                        ) { store in
                            TodoView(store: store)
                        }
                        .onDelete {
                            viewStore.send(.delete($0))
                        }
                        .onMove {
                            viewStore.send(.move($0, $1))
                        }
                    }
                }
            }
            .navigationTitle("Todos")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 20) {
                        EditButton()

                        Button("完了クリア") {
                            viewStore.send(
                                .clearCompletedButtonTapped,
                                animation: .default
                            )
                        }
                        .disabled(viewStore.isClearCompletedButtonDisabled)

                        Button("追加") {
                            viewStore.send(
                                .addTodoButtonTapped,
                                animation: .default
                            )
                        }
                    }
                }
            }
            .environment(\.editMode, viewStore.$editMode)
        }
    }
}

extension IdentifiedArray where ID == Todo.State.ID, Element == Todo.State {
    static let mock: Self = [
        Todo.State(
            id: UUID(),
            description: "Check Mail",
            isComplete: false
        ),
        Todo.State(
            id: UUID(),
            description: "Buy Milk",
            isComplete: false
        ),
        Todo.State(
            id: UUID(),
            description: "Call Mom",
            isComplete: true
        )
    ]
}

#Preview {
    NavigationStack {
        TodosView(
            store: Store(initialState: Todos.State(todos: .mock)) {
                Todos()
            }
        )
    }
}
