import Alamofire
import StructBuilder

public final class APIClient {
    public init() {}

    public func request() {
        print("Request!!!")
    }

    public func test() -> String {
        TestBuilder(test: "Test!!!").build().test
    }
}

@Buildable
public struct Test {
    let test: String
}
