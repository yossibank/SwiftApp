import API
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataSource: DataSource

    var body: some View {
        VStack(spacing: 32) {
            ObservedObjectView()
            StateObjectView()
            EnvironmentObjectView()
            EnvironmentView()

            Button("TAP [+2]") {
                dataSource.count += 2
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(DataSource())
}
