// arbitary[マクロを使用するまで名前がわからない宣言をマクロで生成できるようにする]
@attached(peer, names: arbitrary)
public macro CustomBuilder() = #externalMacro(
    module: "StructBuilderMacro",
    type: "CustomBuilderMacro"
)
