import ComposableArchitecture
@testable import TCA
import XCTest

/// The Composable Architectureにおけるテスト
///
/// ・ Reducerの処理が意図通り書かれているか
/// ・ Effectの実行が意図通りか
/// ・ Stateの変化が意図通りか
///     - 差分をもとに検証
///
/// ※ 副作用自体のテストは上記には含まれていないので必要なら別途自作する必要がある
