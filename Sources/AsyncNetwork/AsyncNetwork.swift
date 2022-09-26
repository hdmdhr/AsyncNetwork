import Foundation

public protocol Authorizable {
    var maxReAuthorizeTimes: Int { get }
    
    @discardableResult
    func authorize(urlRequest: inout URLRequest) -> Bool
    /// Optional. Only implement when you want to trigger re-authorize on failure.
    func shouldReAuthorize(data: Data, urlResponse: URLResponse) -> Bool
    /// Optional. Only implement when you need to support re-authorize on failure.
    /// You should try to regain authorization in this method.
    func refresh(with httpClient: HttpClientProtocol) async throws
}

public extension Authorizable {
    var maxReAuthorizeTimes: Int { 1 }
    
    func shouldReAuthorize(data: Data, urlResponse: URLResponse) -> Bool { false }
    
    func refresh(with httpClient: HttpClientProtocol) async throws { }
}

public protocol HttpClientProtocol: AnyObject {
    /// - parameters:
    ///   - customHandler: if you want to treat some specific response as error, use this closure to map the response in question into the error you want
    func request<Response: Decodable>(
        endpoint: UrlConvertible,
        method: HttpMethod,
        customHeaders: [String: String],
        shouldAuthorize: Bool,
        customHandler: ((Data, URLResponse) throws -> Response)?) async throws -> Response
}

@available(macOS 10.15, iOS 13.0, *)
public class HttpClient: HttpClientProtocol {
    
    public init(authorizer: Authorizable?, urlSession: URLSession, decoder: DataDecoderProtocol) {
        self.authorizer = authorizer
        self.urlSession = urlSession
        self.decoder = decoder
    }
    
    public let authorizer: Authorizable?
    public let urlSession: URLSession
    public let decoder: DataDecoderProtocol
    
    public func request<Response: Decodable>(
        endpoint: UrlConvertible,
        method: HttpMethod,
        customHeaders: [String: String],
        shouldAuthorize: Bool,
        customHandler: ((Data, URLResponse) throws -> Response)?) async throws -> Response
    {
        var url = endpoint.url
        
        // add queries
        if case .get(let queryItemsProvider) = method, let queryItemsProvider {
            url.appendQueryItems(queryItemsProvider.queryItems)
        }
        
        // http method
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.value
        
        // headers
//        config.headers.forEach { (key: String, value: String) in
//            urlRequest.setValue(value, forHTTPHeaderField: key)
//        }
        
        for header in customHeaders {
            urlRequest.setValue(header.value, forHTTPHeaderField: header.key)
        }
        
        // authorize
        if shouldAuthorize, let authorizer, !authorizer.authorize(urlRequest: &urlRequest) {
            throw NetworkError.cannotAuthorize(data: nil, urlResponse: nil)
        }
        
        // add body data
        if case .command(_, let bodyDataProvider) = method {
            urlRequest.httpBody = bodyDataProvider?.bodyData
        }
        
        do {
            let (data, urlResponse) = try await urlSession.data(for: urlRequest)
            
            // execute request custom handler first (if there is one)
            if let customHandler {
                return try customHandler(data, urlResponse)
            }
            
            // check if authorization failed (if there is an authorizer)
            if let authorizer, authorizer.shouldReAuthorize(data: data, urlResponse: urlResponse) {
                var retryTimes = 0
                var _data: Data = data
                var _urlResponse: URLResponse = urlResponse
                
                /// repeat for `maxReAuthorizeTimes`
                /// 1. try to regain authorization
                /// 2. authorize request
                /// 3. fire request, try to decode response
                /// before finally giving up and throw a `.cannotAuthorize` error
                repeat {
                    try await authorizer.refresh(with: self)
                    guard authorizer.authorize(urlRequest: &urlRequest) else { break }
                    (_data, _urlResponse) = try await urlSession.data(for: urlRequest)
                    retryTimes += 1
                    if let res = try? decoder.decode(Response.self, from: _data) {
                        return res
                    }
                } while retryTimes < authorizer.maxReAuthorizeTimes
                && authorizer.shouldReAuthorize(data: _data, urlResponse: _urlResponse)
                
                throw NetworkError.cannotAuthorize(data: _data, urlResponse: _urlResponse)
            }
            
            // decode data and return
            return try decoder.decode(Response.self, from: data)
            
        } catch let decodingError as DecodingError {
            throw NetworkError.decoding(decodingError)
        } catch {
            throw error
        }
        
    }
    
}
