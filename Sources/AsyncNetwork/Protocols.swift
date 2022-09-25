//
//  File.swift
//  
//
//  Created by Daniel Hu on 2022-09-24.
//

import Foundation

public protocol UrlConvertible {
    var url: URL { get }
}

extension URL: UrlConvertible {
    public var url: URL { self }
}

public protocol DataDecoderProtocol {
    func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable
}

extension JSONDecoder: DataDecoderProtocol { }
extension PropertyListDecoder: DataDecoderProtocol { }


public protocol DataEncoderProtocol {
    func encode<T>(_ value: T) throws -> Data where T : Encodable
}

extension JSONEncoder: DataEncoderProtocol { }
extension PropertyListEncoder: DataEncoderProtocol { }
