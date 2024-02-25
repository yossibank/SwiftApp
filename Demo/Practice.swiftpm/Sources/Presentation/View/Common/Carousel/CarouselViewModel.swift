import Combine
import SwiftUI

final class CarouselViewModel: ObservableObject {
    @Published var array: [URL] = []
    @Published var currentIndex = 2
    @Published var dragAnimation: Animation?
    @Published private var isOffsetAnimation = false

    private let padding: CGFloat = 16
    private let animationTime = 0.2

    private var cancellables = Set<AnyCancellable>()

    init(urls: [URL]) {
        self.array = createInfinityItems(urls)

        $currentIndex
            .receive(on: RunLoop.main)
            .sink { index in
                Task { @MainActor in
                    try? await Task.sleep(
                        for: .seconds(self.animationTime)
                    )

                    if index <= 1 {
                        self.isOffsetAnimation = false
                        self.currentIndex = 1 + urls.count
                    } else if index >= 2 + urls.count {
                        self.isOffsetAnimation = false
                        self.currentIndex = 2
                    }
                }
            }
            .store(in: &cancellables)

        $isOffsetAnimation
            .receive(on: DispatchQueue.main)
            .map { isAnimation in
                isAnimation
                    ? .linear(duration: self.animationTime)
                    : .none
            }
            .assign(to: \.dragAnimation, on: self)
            .store(in: &cancellables)
    }

    private func createInfinityItems(_ target: [URL]) -> [URL] {
        if target.count > 1 {
            var result: [URL] = []
            result += target.suffix(2)
            result += target
            result += target.prefix(2).map { $0 }
            return result
        } else {
            return target
        }
    }
}

extension CarouselViewModel {
    var itemPadding: CGFloat {
        padding
    }

    func carouselLeadingPadding(
        geometry: GeometryProxy,
        index: Int
    ) -> CGFloat {
        index == 0
            ? geometry.size.width * 0.1
            : 0
    }

    func carouselItemWidth(geometry: GeometryProxy) -> CGFloat {
        geometry.size.width * 0.8
    }

    func carouselOffsetX(geometry: GeometryProxy) -> CGFloat {
        -CGFloat(currentIndex) * (geometry.size.width * 0.8 + padding)
    }

    func onChangedDragGesture() {
        if !isOffsetAnimation {
            isOffsetAnimation = true
        }
    }

    func updateCurrentIndex(
        geometry: GeometryProxy,
        dragGestureValue: _ChangedGesture<
            GestureStateGesture<DragGesture, CGFloat>
        >.Value
    ) {
        var newIndex = currentIndex

        if abs(dragGestureValue.translation.width) > geometry.size.width * 0.3 {
            newIndex = dragGestureValue.translation.width > 0
                ? currentIndex - 1
                : currentIndex + 1
        }

        if newIndex < 0 {
            newIndex = 0
        } else if newIndex > array.count - 1 {
            newIndex = array.count - 1
        }

        isOffsetAnimation = true
        currentIndex = newIndex
    }
}
