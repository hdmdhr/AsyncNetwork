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
    case cannotAuthorize(data: Data?, urlResponse: URLResponse?)
}
