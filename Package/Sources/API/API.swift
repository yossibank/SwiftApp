import CodingKeys
import StructBuilder

/// @mockable
protocol TestProtocol {
    func hoge() -> String
}

public final class APIClient {
    public init() {}

    public func request() {
        print("Request!!!")
    }

    public func test() -> String {
        TestBuilder(test: "Test!!!").build().test
    }
}

@CodingKeys(.all)
public struct Coding {
    let hogeHoge: String
    let fooBar: String
}

@Buildable
public struct Test {
    let test: String
}
