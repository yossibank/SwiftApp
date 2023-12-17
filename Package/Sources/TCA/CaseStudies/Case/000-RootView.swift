import ComposableArchitecture
import SwiftUI

public struct ComposableArchitectureRootView: View {
    @State private var isNavigationStackCaseStudyPresented = false

    public init() {}

    public var body: some View {
        NavigationStack {
            Form {
                Section {
                    NavigationLink("Counter") {
                        CounterDemoView()
                    }
                    NavigationLink("TwoCounters Combining Reducers") {
                        TwoCountersView()
                    }
                    NavigationLink("Bindings Basic") {
                        BindingBasicsView()
                    }
                    NavigationLink("Bindings Form") {
                        BindingFormView()
                    }
                    NavigationLink("Alerts & Confirmation Dialogs") {
                        AlertAndConfirmationDialogView()
                    }
                    NavigationLink("Optional State") {
                        OptionalBasicsView()
                    }
                    NavigationLink("Shared State") {
                        SharedStateView()
                    }
                    NavigationLink("Focus State") {
                        FocusDemoView()
                    }
                    NavigationLink("Animations") {
                        AnimationsView()
                    }
                } header: {
                    Text("基本的な使い方")
                }

                Section {
                    NavigationLink("Effects") {
                        EffectsBasicsView()
                    }
                    NavigationLink("Cancellation") {
                        EffectsCancellationView()
                    }
                    NavigationLink("Long-Living") {
                        EffectsLongLivingView()
                    }
                    NavigationLink("Refreshable") {
                        RefreshableView()
                    }
                    NavigationLink("Timers") {
                        TimersView()
                    }
                    NavigationLink("Web Socket") {
                        WebSocketView()
                    }
                } header: {
                    Text("Effectsについて")
                }

                Section {
                    NavigationLink("Navigate and load data") {
                        NavigateAndLoadView()
                    }
                    NavigationLink("Lists: Navigate and load data") {
                        NavigateAndLoadListView()
                    }
                    NavigationLink("Sheets: Present and load data") {
                        PresentAndLoadView()
                    }
                    NavigationLink("Sheets: Load data then present") {
                        LoadThenPresentView()
                    }
                    NavigationLink("Multiple destinations") {
                        MultipleDestinationsView()
                    }
                    Button("Stack") {
                        isNavigationStackCaseStudyPresented = true
                    }
                    .buttonStyle(.plain)
                } header: {
                    Text("Navigation")
                }

                Section {
                    NavigationLink("Reusalbe favoriting component") {
                        EpisodesView()
                    }
                    NavigationLink("Reusable offline download component") {
                        CitiesView()
                    }
                    NavigationLink("Recursive state and actions") {
                        NestedView()
                    }
                } header: {
                    Text("Higher-order reducers")
                }

                Section {
                    NavigationLink("Todos") {
                        TodosView(store: Store(initialState: Todos.State()) {
                            Todos()._printChanges()
                        })
                    }
                } header: {
                    Text("Todos")
                }
            }
            .navigationTitle("Case Studies")
            .sheet(isPresented: $isNavigationStackCaseStudyPresented) {
                NavigationDemoView()
            }
        }
    }
}
