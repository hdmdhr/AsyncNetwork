import Foundation

public protocol Authorizable {
    @discardableResult
    func authorize(urlRequest: inout URLRequest) -> Bool
}


public protocol UrlConvertible {
    var url: URL { get }
}


public protocol HttpClientProtocol: AnyObject {
    var authorizer: Authorizable { get }
    
    /// - parameters:
    ///   - customHandler: if you want to treat some specific response as error, use this closure to map the response in question into the error you want
    func request<Response: Decodable>(
        endpoint: UrlConvertible,
        method: HttpMethod,
        customHeaders: [String: String],
        shouldAuthorize: Bool,
        customHandler: ((Data, URLResponse) throws -> Response)?) async throws -> Response
}
