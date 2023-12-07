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
                } header: {
                    Text("基本的な使い方")
                }
            }
            .navigationTitle("Case Studies")
        }
    }
}
