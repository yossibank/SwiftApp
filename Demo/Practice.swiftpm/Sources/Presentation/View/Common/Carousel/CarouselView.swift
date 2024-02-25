import SwiftUI

struct CarouselView: View {
    @StateObject private var viewModel: CarouselViewModel
    @GestureState private var dragOffset: CGFloat = 0

    init(viewModel: CarouselViewModel) {
        self._viewModel = .init(wrappedValue: viewModel)
    }

    var body: some View {
        GeometryReader { geometry in
            VStack {
                LazyHStack(spacing: viewModel.itemPadding) {
                    ForEach(viewModel.array.indices, id: \.self) { index in
                        AsyncImageView(
                            url: viewModel.array[index],
                            successImage: { image in
                                image.resizable()
                            },
                            failureImage: {
                                Image("noImage", bundle: .module).resizable()
                            },
                            placeholderImage: {
                                Image("placeholder", bundle: .module).resizable()
                            }
                        )
                        .frame(
                            width: viewModel.carouselItemWidth(geometry: geometry),
                            height: viewModel.carouselItemWidth(geometry: geometry)
                        )
                        .padding(
                            .leading,
                            viewModel.carouselLeadingPadding(
                                geometry: geometry,
                                index: index
                            )
                        )
                    }
                }
                .animation(
                    viewModel.dragAnimation,
                    value: viewModel.dragAnimation
                )
                .offset(x: viewModel.carouselOffsetX(geometry: geometry))
                .offset(x: dragOffset)
                .gesture(
                    DragGesture()
                        .updating(
                            $dragOffset,
                            body: { value, state, _ in
                                state = value.translation.width
                            }
                        )
                        .onChanged { _ in
                            viewModel.onChangedDragGesture()
                        }
                        .onEnded { value in
                            viewModel.updateCurrentIndex(
                                geometry: geometry,
                                dragGestureValue: value
                            )
                        }
                )
            }
        }
    }
}

#Preview {
    CarouselView(
        viewModel: .init(
            urls: [
                .init(string: "https://placehold.jp/150x150.png")!,
                .init(string: "https://placehold.jp/3d4070/ffffff/150x150.png")!,
                .init(string: "https://placehold.jp/1ca919/ffffff/150x150.png")!,
                .init(string: "https://placehold.jp/69671b/ffffff/150x150.png")!,
                .init(string: "https://placehold.jp/b33819/ffffff/150x150.png")!
            ]
        )
    )
}
