import SwiftUI

struct AsyncImageView: View {
    let url: URL?
    let successImage: (Image) -> Image
    let failureImage: () -> Image
    let placeholderImage: () -> Image

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case let .success(image):
                successImage(image)

            case .empty, .failure:
                failureImage()

            @unknown default:
                failureImage()
            }
        }
    }
}
