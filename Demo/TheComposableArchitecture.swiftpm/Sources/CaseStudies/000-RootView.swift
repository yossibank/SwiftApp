import ComposableArchitecture
import SwiftUI

struct RootView: View {
    var body: some View {
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
            }
            .navigationTitle("Case Studies")
        }
    }
}
