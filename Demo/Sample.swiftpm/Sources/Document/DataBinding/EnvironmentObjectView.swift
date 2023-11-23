import SwiftUI

struct EnvironmentObjectView: View {
    @EnvironmentObject var dataSource: DataSource

    var body: some View {
        VStack(spacing: 4) {
            Text("子View")
            Text("EnvironmentObject count: \(dataSource.count)")
            Button("increment") {
                dataSource.count += 1
            }
        }
    }
}

#Preview {
    EnvironmentObjectView()
        .environmentObject(DataSource())
}
