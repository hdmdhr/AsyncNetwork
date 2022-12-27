//
//  File.swift
//  
//
//  Created by Daniel Hu on 2022-09-24.
//

import Foundation

public enum NetworkError: Error {
    /// Case wrapping Swift native `URLError`
    case urlError(URLError)
    /// Case wrapping Swift native `DecodingError`
    case decoding(DecodingError)
}

public extension NetworkError {
    
    enum Authorization: Error {
        case reachedMaxRetryLimit
        case expiredRefreshToken
        case general(data: Data?, urlResponse: URLResponse?)
    }
    
}
