import ComposableArchitecture
@testable import TCA
import XCTest

@MainActor
final class EffectsCancellationTests: XCTestCase {
    func testTrivia_SuccessfulRequest() async {
        let store = TestStore(initialState: EffectsCancellation.State()) {
            EffectsCancellation()
        } withDependencies: {
            $0.factClient.fetch = {
                "\($0) is a good number Brent"
            }
        }

        await store.send(.stepperChanged(1)) {
            $0.count = 1
        }

        await store.send(.stepperChanged(0)) {
            $0.count = 0
        }

        await store.send(.factButtonTapped) {
            $0.isFactRequestInFlight = true
        }

        await store.receive(\.factResponse.success) {
            $0.currentFact = "0 is a good number Brent"
            $0.isFactRequestInFlight = false
        }
    }

    func testTrivia_FailedRequest() async {
        struct FactError: Equatable, Error {}

        let store = TestStore(initialState: EffectsCancellation.State()) {
            EffectsCancellation()
        } withDependencies: {
            $0.factClient.fetch = { _ in
                throw FactError()
            }
        }

        await store.send(.factButtonTapped) {
            $0.isFactRequestInFlight = true
        }

        await store.receive(\.factResponse.failure) {
            $0.isFactRequestInFlight = false
        }
    }

    // キャンセルボタンが実際に進行中のAPIリクエストをキャンセルすることを確認するテスト
    // このテストの真の力を確認するには、`effectsCancellationReducer`の`.cancelButtonTapped`アクションで`.cancel`エフェクトを`.none`エフェクトに置き換えてみてください。
    // これによりテストが失敗し、エフェクトが本当にキャンセルされ、
    // 決して発行されないことを徹底的に主張していることが示されます。
    func testTrivia_CancelButtonCancelsRequest() async {
        let store = TestStore(initialState: EffectsCancellation.State()) {
            EffectsCancellation()
        } withDependencies: {
            $0.factClient.fetch = { _ in
                try await Task.never()
            }
        }

        await store.send(.factButtonTapped) {
            $0.isFactRequestInFlight = true
        }

        await store.send(.cancelButtonTapped) {
            $0.isFactRequestInFlight = false
        }
    }

    func testTrivia_PlusMinusButtonsCancelsRequest() async {
        let store = TestStore(initialState: EffectsCancellation.State()) {
            EffectsCancellation()
        } withDependencies: {
            $0.factClient.fetch = { _ in
                try await Task.never()
            }
        }

        await store.send(.factButtonTapped) {
            $0.isFactRequestInFlight = true
        }

        await store.send(.stepperChanged(1)) {
            $0.count = 1
            $0.isFactRequestInFlight = false
        }
    }
}
