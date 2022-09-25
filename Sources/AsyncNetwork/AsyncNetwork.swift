import Foundation

public protocol Authorizable {
    @discardableResult
    func authorize(urlRequest: inout URLRequest) -> Bool
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
            // failed authorizing request
        }
        
        // add body data
        if case .command(_, let bodyDataProvider) = method {
            urlRequest.httpBody = bodyDataProvider?.bodyData
        }
        
        do {
            let response: Response
            let (data, urlResponse) = try await urlSession.data(for: urlRequest)
            
            if let customHandler {
                response = try customHandler(data, urlResponse)
            } else {   
                response = try decoder.decode(Response.self, from: data)
            }
            
            return response
            
        } catch {
            throw error
        }
        
    }
    
}
