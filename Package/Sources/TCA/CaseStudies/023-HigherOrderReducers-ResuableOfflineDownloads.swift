import ComposableArchitecture
import SwiftUI

private let description = """
Composable Architectureで再利用可能なコンポーネントを作成する方法を示しています。

「ダウンロードコンポーネント」は、オフラインコンテンツのダウンロード機能を付加するために任意のビューに追加できるコンポーネントです。

これにより、データのダウンロード、ダウンロード中の進捗ビューの表示、アクティブなダウンロードのキャンセル、以前にダウンロードしたデータの削除が容易になります。

ダウンロードアイコンをタップしてダウンロードを開始し、再度タップして進行中のダウンロードをキャンセルするか、完了したダウンロードを削除します。

ファイルがダウンロード中の間に、行をタップして別の画面に移動し、状態が引き継がれていることを確認できます。
"""

// MARK: - Reusable download component

@Reducer
struct DownloadComponent {
    @Dependency(\.downloadClient) var downloadClient

    private var deleteAlert: AlertState<Action.Alert> {
        AlertState {
            TextState("Do you want to delete this map from your offline storage?")
        } actions: {
            ButtonState(
                role: .destructive,
                action: .send(
                    .deleteButtonTapped,
                    animation: .default
                )
            ) {
                TextState("Delete")
            }
            nevermindButton
        }
    }

    private var stopAlert: AlertState<Action.Alert> {
        AlertState {
            TextState("Do you want to stop downloading this map?")
        } actions: {
            ButtonState(
                role: .destructive,
                action: .send(
                    .stopButtonTapped,
                    animation: .default
                )
            ) {
                TextState("Stop")
            }
            nevermindButton
        }
    }

    private var nevermindButton: ButtonState<Action.Alert> {
        ButtonState(role: .cancel) {
            TextState("Nevermind")
        }
    }

    struct State: Equatable {
        @PresentationState var alert: AlertState<Action.Alert>?
        let id: AnyHashable
        var mode: Mode
        let url: URL
    }

    enum Action {
        case alert(PresentationAction<Alert>)
        case buttonTapped
        case downloadClient(Result<DownloadClient.Event, Error>)

        enum Alert {
            case deleteButtonTapped
            case stopButtonTapped
        }
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .alert(.presented(.deleteButtonTapped)):
                state.alert = nil
                state.mode = .notDownloaded
                return .none

            case .alert(.presented(.stopButtonTapped)):
                state.alert = nil
                state.mode = .notDownloaded
                return .cancel(id: state.id)

            case .alert:
                return .none

            case .buttonTapped:
                switch state.mode {
                case .downloaded:
                    state.alert = deleteAlert
                    return .none

                case .downloading:
                    state.alert = stopAlert
                    return .none

                case .notDownloaded:
                    state.mode = .startingToDownload
                    return .run { [url = state.url] send in
                        for try await event in downloadClient.download(url) {
                            await send(
                                .downloadClient(.success(event)),
                                animation: .default
                            )
                        }
                    } catch: { error, send in
                        await send(
                            .downloadClient(.failure(error)),
                            animation: .default
                        )
                    }
                    .cancellable(id: state.id)

                case .startingToDownload:
                    state.alert = stopAlert
                    return .none
                }

            case .downloadClient(.success(.response)):
                state.alert = nil
                state.mode = .downloaded
                return .none

            case let .downloadClient(.success(.updateProgress(progress))):
                state.mode = .downloading(progress: progress)
                return .none

            case .downloadClient(.failure):
                state.alert = nil
                state.mode = .notDownloaded
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}

enum Mode: Equatable {
    case downloaded
    case downloading(progress: Double)
    case notDownloaded
    case startingToDownload

    var progress: Double {
        if case let .downloading(progress) = self {
            return progress
        }
        return 0
    }

    var isDownloading: Bool {
        switch self {
        case .downloaded, .notDownloaded:
            false

        case .downloading, .startingToDownload:
            true
        }
    }
}

struct DownloadComponentView: View {
    let store: StoreOf<DownloadComponent>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Button {
                viewStore.send(.buttonTapped)
            } label: {
                switch viewStore.mode {
                case .downloaded:
                    Image(systemName: "checkmark.circle")
                        .tint(.accentColor)

                case let .downloading(progress):
                    ZStack {
                        CircularProgressView(value: progress)
                            .frame(width: 16, height: 16)
                        Rectangle()
                            .frame(width: 6, height: 6)
                    }

                case .notDownloaded:
                    Image(systemName: "icloud.and.arrow.down")

                case .startingToDownload:
                    ZStack {
                        ProgressView()
                        Rectangle()
                            .frame(width: 6, height: 6)
                    }
                }
            }
            .foregroundStyle(.primary)
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
struct CityMap {
    struct State: Equatable, Identifiable {
        var download: Download
        var downloadAlert: AlertState<DownloadComponent.Action.Alert>?
        var downloadMode: Mode

        var id: UUID {
            download.id
        }

        var downloadComponent: DownloadComponent.State {
            get {
                DownloadComponent.State(
                    alert: downloadAlert,
                    id: download.id,
                    mode: downloadMode,
                    url: download.downloadVideoUrl
                )
            }
            set {
                downloadAlert = newValue.alert
                downloadMode = newValue.mode
            }
        }

        struct Download: Equatable, Identifiable {
            var blurb: String
            var downloadVideoUrl: URL
            var title: String
            let id: UUID
        }
    }

    enum Action {
        case downloadComponent(DownloadComponent.Action)
    }

    struct CityMapEnvironment {
        var downloadClient: DownloadClient
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.downloadComponent, action: \.downloadComponent) {
            DownloadComponent()
        }

        Reduce<State, Action> { _, action in
            switch action {
            case .downloadComponent(.downloadClient(.success(.response))):
                // これは、データをディスク上のファイルに保存するためのエフェクトを実行することができる場所です。
                .none

            case .downloadComponent(.alert(.presented(.deleteButtonTapped))):
                // これは、ディスクからデータを削除するエフェクトを実行することができる場所です。
                .none

            case .downloadComponent:
                .none
            }
        }
    }
}

struct CityMapRowView: View {
    let store: StoreOf<CityMap>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            HStack {
                NavigationLink(destination: CityMapDetailView(store: store)) {
                    HStack {
                        Image(systemName: "map")
                        Text(viewStore.download.title)
                    }
                    .layoutPriority(1)

                    Spacer()

                    DownloadComponentView(
                        store: store.scope(
                            state: \.downloadComponent,
                            action: \.downloadComponent
                        )
                    )
                    .padding(.trailing, 8)
                }
            }
        }
    }
}

struct CityMapDetailView: View {
    let store: StoreOf<CityMap>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 32) {
                Text(viewStore.download.blurb)

                HStack {
                    if viewStore.downloadMode == .notDownloaded {
                        Text("Download for offline viewing")
                    } else if viewStore.downloadMode == .downloaded {
                        Text("Downloaded")
                    } else {
                        Text("Downloading \(Int(100 * viewStore.downloadComponent.mode.progress))%")
                    }

                    Spacer()

                    DownloadComponentView(
                        store: store.scope(
                            state: \.downloadComponent,
                            action: \.downloadComponent
                        )
                    )
                }

                Spacer()
            }
            .navigationTitle(viewStore.download.title)
            .padding()
        }
    }
}

@Reducer
struct MapApp {
    struct State: Equatable {
        var cityMaps: IdentifiedArrayOf<CityMap.State>
    }

    enum Action {
        case cityMaps(IdentifiedActionOf<CityMap>)
    }

    var body: some Reducer<State, Action> {
        EmptyReducer().forEach(\.cityMaps, action: \.cityMaps) {
            CityMap()
        }
    }
}

struct CitiesView: View {
    @State var store = Store(initialState: MapApp.State(cityMaps: .mocks)) {
        MapApp()
    }

    var body: some View {
        Form {
            Section {
                AboutView(description: description)
            }

            ForEachStore(store.scope(state: \.cityMaps, action: \.cityMaps)) { cityMapStore in
                CityMapRowView(store: cityMapStore)
                    .buttonStyle(.borderless)
            }
        }
        .navigationTitle("Offline Downloads")
    }
}

// MARK: - Preview

#Preview {
    Group {
        NavigationStack {
            CitiesView(
                store: Store(initialState: MapApp.State(cityMaps: .mocks)) {
                    MapApp()
                }
            )
        }

        NavigationStack {
            CityMapDetailView(
                store: Store(
                    initialState: IdentifiedArrayOf<CityMap.State>.mocks.first!
                ) {}
            )
        }
    }
}

// MARK: - Mock

extension IdentifiedArray where ID == CityMap.State.ID, Element == CityMap.State {
    static let mocks: Self = [
        CityMap.State(
            download: CityMap.State.Download(
                blurb: """
                New York City (NYC), known colloquially as New York (NY) and officially as the City of \
                New York, is the most populous city in the United States. With an estimated 2018 \
                population of 8,398,748 distributed over about 302.6 square miles (784 km2), New York \
                is also the most densely populated major city in the United States.
                """,
                downloadVideoUrl: URL(string: "http://ipv4.download.thinkbroadband.com/50MB.zip")!,
                title: "New York, NY",
                id: UUID()
            ),
            downloadMode: .notDownloaded
        ),
        CityMap.State(
            download: CityMap.State.Download(
                blurb: """
                Los Angeles, officially the City of Los Angeles and often known by its initials L.A., \
                is the largest city in the U.S. state of California. With an estimated population of \
                nearly four million people, it is the country's second most populous city (after New \
                York City) and the third most populous city in North America (after Mexico City and \
                New York City). Los Angeles is known for its Mediterranean climate, ethnic diversity, \
                Hollywood entertainment industry, and its sprawling metropolis.
                """,
                downloadVideoUrl: URL(string: "http://ipv4.download.thinkbroadband.com/50MB.zip")!,
                title: "Los Angeles, LA",
                id: UUID()
            ),
            downloadMode: .notDownloaded
        ),
        CityMap.State(
            download: CityMap.State.Download(
                blurb: """
                Paris is the capital and most populous city of France, with a population of 2,148,271 \
                residents (official estimate, 1 January 2020) in an area of 105 square kilometres (41 \
                square miles). Since the 17th century, Paris has been one of Europe's major centres of \
                finance, diplomacy, commerce, fashion, science and arts.
                """,
                downloadVideoUrl: URL(string: "http://ipv4.download.thinkbroadband.com/50MB.zip")!,
                title: "Paris, France",
                id: UUID()
            ),
            downloadMode: .notDownloaded
        ),
        CityMap.State(
            download: CityMap.State.Download(
                blurb: """
                Tokyo, officially Tokyo Metropolis (東京都, Tōkyō-to), is the capital of Japan and the \
                most populous of the country's 47 prefectures. Located at the head of Tokyo Bay, the \
                prefecture forms part of the Kantō region on the central Pacific coast of Japan's main \
                island, Honshu. Tokyo is the political, economic, and cultural center of Japan, and \
                houses the seat of the Emperor and the national government.
                """,
                downloadVideoUrl: URL(string: "http://ipv4.download.thinkbroadband.com/50MB.zip")!,
                title: "Tokyo, Japan",
                id: UUID()
            ),
            downloadMode: .notDownloaded
        ),
        CityMap.State(
            download: CityMap.State.Download(
                blurb: """
                Buenos Aires is the capital and largest city of Argentina. The city is located on the \
                western shore of the estuary of the Río de la Plata, on the South American continent's \
                southeastern coast. "Buenos Aires" can be translated as "fair winds" or "good airs", \
                but the former was the meaning intended by the founders in the 16th century, by the \
                use of the original name "Real de Nuestra Señora Santa María del Buen Ayre", named \
                after the Madonna of Bonaria in Sardinia.
                """,
                downloadVideoUrl: URL(string: "http://ipv4.download.thinkbroadband.com/50MB.zip")!,
                title: "Buenos Aires, Argentina",
                id: UUID()
            ),
            downloadMode: .notDownloaded
        )
    ]
}
