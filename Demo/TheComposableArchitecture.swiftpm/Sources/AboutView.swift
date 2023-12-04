import SwiftUI

struct AboutView: View {
    let description: String

    var body: some View {
        DisclosureGroup("About this case study") {
            Text(description)
        }
    }
}
