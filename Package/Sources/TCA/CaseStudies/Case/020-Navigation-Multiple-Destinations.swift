import ComposableArchitecture
import SwiftUI

private let description = """
単一の列挙型状態から3種類のナビゲーション（ドリルダウン、シート、ポップオーバー）を制御する方法を示しています。
"""

@Reducer
struct MultipleDestinations {
    struct State: Equatable {
        @PresentationState var destination: Destination.State?
    }

    enum Action {
        case destination(PresentationAction<Destination.Action>)
        case showDrilldown
        case showPopover
        case showSheet
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .destination:
                return .none

            case .showDrilldown:
                state.destination = .drillDown(Counter.State())
                return .none

            case .showPopover:
                state.destination = .popover(Counter.State())
                return .none

            case .showSheet:
                state.destination = .sheet(Counter.State())
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination) {
            Destination()
        }
    }

    @Reducer
    struct Destination {
        enum State: Equatable {
            case drillDown(Counter.State)
            case popover(Counter.State)
            case sheet(Counter.State)
        }

        enum Action {
            case drillDown(Counter.Action)
            case popover(Counter.Action)
            case sheet(Counter.Action)
        }

        var body: some Reducer<State, Action> {
            Scope(state: \.drillDown, action: \.drillDown) {
                Counter()
            }
            Scope(state: \.popover, action: \.popover) {
                Counter()
            }
            Scope(state: \.sheet, action: \.sheet) {
                Counter()
            }
        }
    }
}

// MARK: - Feature view

struct MultipleDestinationsView: View {
    @State private var store = Store(initialState: MultipleDestinations.State()) {
        MultipleDestinations()
    }

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                Section {
                    AboutView(description: description)
                }

                Button("Show drill-down") {
                    viewStore.send(.showDrilldown)
                }

                Button("Show popover") {
                    viewStore.send(.showPopover)
                }

                Button("Show sheet") {
                    viewStore.send(.showSheet)
                }
            }
            .navigationDestination(
                store: store.scope(
                    state: \.$destination.drillDown,
                    action: \.destination.drillDown
                )
            ) {
                CounterView(store: $0)
            }
            .popover(
                store: store.scope(
                    state: \.$destination.popover,
                    action: \.destination.popover
                )
            ) {
                CounterView(store: $0)
            }
            .sheet(
                store: store.scope(
                    state: \.$destination.sheet,
                    action: \.destination.sheet
                )
            ) {
                CounterView(store: $0)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        MultipleDestinationsView()
    }
}
