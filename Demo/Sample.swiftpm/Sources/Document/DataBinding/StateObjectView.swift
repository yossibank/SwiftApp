import SwiftUI

struct StateObjectView: View {
    @StateObject private var dataSource = DataSource()

    var body: some View {
        VStack(spacing: 4) {
            Text("子View")
            Text("StateObject count: \(dataSource.count)")
            Button("increment") {
                dataSource.count += 1
            }
        }
    }
}

#Preview {
    StateObjectView()
}
