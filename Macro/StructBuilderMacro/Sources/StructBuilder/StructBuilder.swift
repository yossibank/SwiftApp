/// A macro that produces both a value and a string containing the
/// source code that generated the value. For example,
///
///     #stringify(x + y)
///
/// produces a tuple `(x + y, "x + y")`.
@freestanding(expression)
public macro stringify<T>(_ value: T) -> (T, String) = #externalMacro(
    module: "StructBuilderMacro",
    type: "StringifyMacro"
)

// arbitary[マクロを使用するまで名前がわからない宣言をマクロで生成できるようにする]
@attached(peer, names: arbitrary)
public macro CustomBuilder() = #externalMacro(
    module: "StructBuilderMacro",
    type: "CustomBuilderMacro"
)
