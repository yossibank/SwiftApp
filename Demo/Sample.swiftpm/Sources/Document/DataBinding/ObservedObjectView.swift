import SwiftUI

struct ObservedObjectView: View {
    // デフォルト値や初期値を持つべきでない
    @ObservedObject private var dataSource = DataSource()

    var body: some View {
        VStack(spacing: 4) {
            Text("子View")
            Text("ObservedObject count: \(dataSource.count)")
            Button("increment") {
                dataSource.count += 1
            }
        }
    }
}

#Preview {
    ObservedObjectView()
}
