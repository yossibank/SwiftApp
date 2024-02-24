import SwiftUI

struct AsyncImageView: View {
    let url: URL?
    let successImage: (Image) -> Image
    let failureImage: () -> Image
    let placeholderImage: () -> Image

    var body: some View {
        AsyncImage(
            url: url,
            transaction: .init(animation: .easeIn(duration: 0.6))
        ) { phase in
            switch phase {
            case let .success(image):
                successImage(image)

            case .failure:
                failureImage()

            case .empty:
                ProgressView()

            @unknown default:
                failureImage()
            }
        }
    }
}
