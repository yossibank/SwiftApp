// arbitary[マクロを使用するまで名前がわからない宣言をマクロで生成できるようにする]
/// A macro that produces a peer struct which implements the builder pattern
///
///     @CustomBuilder
///     struct Person {
///         let name: String
///         let age: Int
///         let address: Address
///     }
///
/// will expand to
///
///     struct Person {
///         let name: String
///         let age: Int
///         let address: Address
///     }
///
///     struct PersonBuilder {
///         var name: String = ""
///         var age: Int = 0
///         var address: Address = AddressBuilder().build()
///
///         func build() -> Person {
///             return Person(
///                 name: name,
///                 age: age,
///                 address: address
///             )
///         }
///     }
@attached(peer, names: arbitrary)
public macro CustomBuilder() = #externalMacro(
    module: "StructBuilderMacro",
    type: "CustomBuilderMacro"
)
