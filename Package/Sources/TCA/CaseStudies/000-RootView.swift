import ComposableArchitecture
import SwiftUI

public struct ComposableArchitectureRootView: View {
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
                } header: {
                    Text("Navigation")
                }
            }
            .navigationTitle("Case Studies")
        }
    }
}
