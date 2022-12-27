//
//  File.swift
//  
//
//  Created by Daniel Hu on 2022-09-24.
//

import Foundation

@available(macOS, introduced: 10.15, deprecated: 12.0, message: "Use the built-in API instead")
@available(iOS, introduced: 13.0, deprecated: 15.0, message: "Use the built-in API instead")
extension URLSession {
    
    private static func continueWith(_ continuation: CheckedContinuation<(Data, URLResponse), Error>,
                                     data: Data?,
                                     response: URLResponse?,
                                     error: Error?)
    {
        guard let data = data, let response = response else {
            let error = error ?? URLError(.badServerResponse)
            return continuation.resume(throwing: error)
        }

        continuation.resume(returning: (data, response))
    }
    
    func data(from url: URL) async throws -> (Data, URLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            let task = dataTask(with: url) { data, response, error in
                Self.continueWith(continuation, data: data, response: response, error: error)
            }

            task.resume()
        }
    }
    
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await withCheckedThrowingContinuation{ continuation in
            let task = dataTask(with: request) { data, response, error in
                Self.continueWith(continuation, data: data, response: response, error: error)
            }
            
            task.resume()
        }
    }
    
}
