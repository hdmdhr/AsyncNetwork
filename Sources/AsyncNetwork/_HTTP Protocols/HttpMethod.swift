//
//  File.swift
//  
//
//  Created by Daniel Hu on 2022-09-24.
//

import Foundation

/// Mutating methods (excludes GET)
public enum HttpCommandMethod: String {
    case POST, PUT, PATCH, DELETE
}


public enum HttpMethod {
    case get(queryItemsProvider: QueryItemsProvidable?)
    case command(method: HttpCommandMethod, bodyDataProvider: BodyDataProvidable?)
    
    public static let get: HttpMethod = .get(queryItemsProvider: nil)
    
    public static func post(bodyDataProvider: BodyDataProvidable) -> HttpMethod {
        .command(method: .POST, bodyDataProvider: bodyDataProvider)
    }
    
    var value: String {
        switch self {
        case .get:
            return "GET"
            
        case let .command(commandMethod, _):
            return commandMethod.rawValue
        }
    }
}


