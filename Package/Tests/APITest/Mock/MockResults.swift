///
/// @Generated by Mockolo
///

#if DEBUG

import Foundation
@testable import API


final class APIClientRequestMock: APIClientRequest {
    init() { }


    private(set) var requestCallCount = 0
    var requestHandler: ((Any) async throws -> (Any))?
    func request<T>(item: some Request<T>) async throws -> T {
        requestCallCount += 1
        if let requestHandler = requestHandler {
            return try await requestHandler(item) as! T
        }
        fatalError("requestHandler returns can't have a default value thus its handler must be set")
    }
}

#endif