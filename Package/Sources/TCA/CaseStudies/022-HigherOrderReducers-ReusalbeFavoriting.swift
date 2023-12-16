import ComposableArchitecture
import SwiftUI

private let description = """
Composable Architectureで再利用可能なコンポーネントを作成する方法を示しています。

これは、「お気に入り」という概念のドメイン、ロジック、およびビューを紹介しますが、これはかなり複雑です。

機能は、お気に入りのドメインを組み込み、`Favoriting` リデューサーを使用し、適切にスコープされたストアを `FavoriteButton` に渡すことで、その状態の一部を「お気に入り」にする能力を持たせることができます。

行のお気に入りボタンをタップすると、UIに即座に反映され、データベースへの書き込みやAPIリクエストなどの必要な作業を行うエフェクトが発火します。

1秒かかり、25％の確率で失敗するリクエストをシミュレートしています。

失敗はお気に入り状態のロールバックとアラートの表示をもたらします。
"""

// MARK: - Reusable favorite component

struct FavoritingState<ID: Hashable & Sendable>: Equatable {
    @PresentationState var alert: AlertState<FavoritingAction.Alert>?
    let id: ID
    var isFavorite: Bool
}

@CasePathable
enum FavoritingAction {
    case alert(PresentationAction<Alert>)
    case buttonTapped
    case response(Result<Bool, Error>)

    enum Alert: Equatable {}
}

@Reducer
struct Favoriting<ID: Hashable & Sendable> {
    let favorite: @Sendable (ID, Bool) async throws -> Bool

    private struct CancelID: Hashable {
        let id: AnyHashable
    }

    var body: some Reducer<FavoritingState<ID>, FavoritingAction> {
        Reduce { state, action in
            switch action {
            case .alert(.dismiss):
                state.alert = nil
                state.isFavorite.toggle()
                return .none

            case .buttonTapped:
                state.isFavorite.toggle()
                return .run { [id = state.id, isFavorite = state.isFavorite] send in
                    await send(.response(Result {
                        try await favorite(id, isFavorite)
                    }))
                }
                .cancellable(id: CancelID(id: state.id), cancelInFlight: true)

            case let .response(.failure(error)):
                state.alert = AlertState {
                    TextState(error.localizedDescription)
                }
                return .none

            case let .response(.success(isFavorite)):
                state.isFavorite = isFavorite
                return .none
            }
        }
    }
}

struct FavoriteButton<ID: Hashable & Sendable>: View {
    let store: Store<FavoritingState<ID>, FavoritingAction>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Button {
                viewStore.send(.buttonTapped)
            } label: {
                Image(systemName: "heart")
                    .symbolVariant(viewStore.isFavorite ? .fill : .none)
            }
            .alert(
                store: store.scope(
                    state: \.$alert,
                    action: \.alert
                )
            )
        }
    }
}

// MARK: - Feature domain

@Reducer
struct Episode {
    let favorite: @Sendable (UUID, Bool) async throws -> Bool

    struct State: Equatable, Identifiable {
        var alert: AlertState<FavoritingAction.Alert>?
        let id: UUID
        var isFavorite: Bool
        let title: String

        var favorite: FavoritingState<ID> {
            get {
                .init(
                    alert: alert,
                    id: id,
                    isFavorite: isFavorite
                )
            }
            set {
                (alert, isFavorite) = (newValue.alert, newValue.isFavorite)
            }
        }
    }

    enum Action {
        case favorite(FavoritingAction)
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.favorite, action: \.favorite) {
            Favoriting(favorite: favorite)
        }
    }
}

// MARK: - Feature view

struct EpisodeView: View {
    let store: StoreOf<Episode>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            HStack(alignment: .firstTextBaseline) {
                Text(viewStore.title)
                Spacer()
                FavoriteButton(
                    store: store.scope(
                        state: \.favorite,
                        action: \.favorite
                    )
                )
            }
        }
    }
}

// MARK: - Feature domain

@Reducer
struct Episodes {
    let favorite: @Sendable (UUID, Bool) async throws -> Bool

    struct State: Equatable {
        var episodes: IdentifiedArrayOf<Episode.State> = []
    }

    enum Action {
        case episodes(IdentifiedActionOf<Episode>)
    }

    var body: some Reducer<State, Action> {
        Reduce { _, _ in
            .none
        }
        .forEach(\.episodes, action: \.episodes) {
            Episode(favorite: favorite)
        }
    }
}

// MARK: - Feature view

struct EpisodesView: View {
    @State var store = Store(initialState: Episodes.State(episodes: .mocks)) {
        Episodes(favorite: favorite(id:isFavorite:))
    }

    var body: some View {
        Form {
            Section {
                AboutView(description: description)
            }

            ForEachStore(store.scope(state: \.episodes, action: \.episodes)) { rowStore in
                EpisodeView(store: rowStore)
            }
            .buttonStyle(.borderless)
        }
        .navigationTitle("Favoriting")
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        EpisodesView(
            store: Store(initialState: Episodes.State(episodes: .mocks)) {
                Episodes(favorite: favorite(id:isFavorite:))
            }
        )
    }
}

@Sendable func favorite(id: some Any, isFavorite: Bool) async throws -> Bool {
    try await Task.sleep(for: .seconds(1))

    if .random(in: 0 ... 1) > 0.25 {
        return isFavorite
    } else {
        throw FavoriteError()
    }
}

struct FavoriteError: LocalizedError, Equatable {
    var errorDescription: String? {
        "Favoriting failed."
    }
}

extension IdentifiedArray where ID == Episode.State.ID, Element == Episode.State {
    static let mocks: Self = [
        Episode.State(id: UUID(), isFavorite: false, title: "Functions"),
        Episode.State(id: UUID(), isFavorite: false, title: "Side Effects"),
        Episode.State(id: UUID(), isFavorite: false, title: "Algebraic Data Types"),
        Episode.State(id: UUID(), isFavorite: false, title: "DSLs"),
        Episode.State(id: UUID(), isFavorite: false, title: "Parsers"),
        Episode.State(id: UUID(), isFavorite: false, title: "Composable Architecture")
    ]
}
