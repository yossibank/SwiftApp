import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image("information", bundle: .module)
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
    }
}
