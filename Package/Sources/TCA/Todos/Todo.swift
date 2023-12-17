import ComposableArchitecture
import SwiftUI

@Reducer
struct Todo {
    struct State: Equatable, Identifiable {
        let id: UUID
        @BindingState var description = ""
        @BindingState var isComplete = false
    }

    enum Action: BindableAction, Sendable {
        case binding(BindingAction<State>)
    }

    var body: some Reducer<State, Action> {
        BindingReducer()
    }
}

struct TodoView: View {
    let store: StoreOf<Todo>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            HStack {
                Button {
                    viewStore.$isComplete.wrappedValue.toggle()
                } label: {
                    Image(
                        systemName: viewStore.isComplete
                            ? "checkmark.square"
                            : "square"
                    )
                }
                .buttonStyle(.plain)

                TextField(
                    "Untitled Todo",
                    text: viewStore.$description
                )
            }
            .foregroundStyle(viewStore.isComplete ? .gray : .black)
        }
    }
}

#Preview {
    NavigationStack {
        TodoView(
            store: Store(initialState: Todo.State(
                id: UUID(),
                description: "Call Mom",
                isComplete: false
            )) {
                Todo()
            }
        )
    }
}
