//
//  File.swift
//  
//
//  Created by Daniel Hu on 2022-09-24.
//

import Foundation

public protocol QueryItemsProvidable {
    var queryItems: [URLQueryItem] { get }
    var queryEncoder: DataEncoderProtocol { get }
}

public extension QueryItemsProvidable {
    var queryEncoder: DataEncoderProtocol { JSONEncoder() }
}

/// String dictionary conform to ``QueryItemsProvidable`` automatically
extension Dictionary: QueryItemsProvidable where Key == String, Value: LosslessStringConvertible {
    public var queryItems: [URLQueryItem] {
        map{ URLQueryItem(name: $0.key, value: $0.value.description) }
    }
}

extension Dictionary where Key == String, Value == LosslessStringConvertible {
    var queryItems: [URLQueryItem] {
        map{ URLQueryItem(name: $0.key, value: $0.value.description) }
    }
}

/// Encodable types conform to ``QueryItemsProvidable`` automatically.
/// It will be encoded by its ``queryEncoder`` and converted into a dictionary, then `URLQueryItem`s.
/// If any step failed, an empty array will be returned, as it is a consumer side error.
extension QueryItemsProvidable where Self: Encodable {
    public var queryItems: [URLQueryItem] {
        guard let data = try? queryEncoder.encode(self),
              let dictionary = try? JSONSerialization.jsonObject(with: data) as? [String: LosslessStringConvertible]
        else { return [] }
        
        return dictionary.queryItems
    }
}
