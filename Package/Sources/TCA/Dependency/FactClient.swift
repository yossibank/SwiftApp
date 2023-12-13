import ComposableArchitecture
import Foundation

struct FactClient {
    var fetch: @Sendable (Int) async throws -> String
}

extension FactClient: DependencyKey {
    /// APIにアクセスして結果を取得するdependency
    /// 通常、この実装は独自のモジュール内に存在し、
    /// メイン機能がそれをコンパイルする必要がないようになっている
    static var liveValue = Self(
        fetch: { number in
            try await Task.sleep(for: .seconds(1))

            let (data, _) = try await URLSession.shared.data(
                from: .init(
                    string: "http://numbersapi.com/\(number)/trivia"
                )!
            )

            return String(decoding: data, as: UTF8.self)
        }
    )

    /// テスト用のdependencyの作成
    /// dependencyが必要ないことを証明できる
    /// テスト側でDIをしていないと、この処理を通ってXCTFailが実行される
    static var testValue = Self(
        fetch: unimplemented("\(Self.self).fetch")
    )
}

extension DependencyValues {
    var factClient: FactClient {
        get { self[FactClient.self] }
        set { self[FactClient.self] = newValue }
    }
}
