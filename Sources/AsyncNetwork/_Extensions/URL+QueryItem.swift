//
//  File.swift
//  
//
//  Created by Daniel Hu on 2022-09-24.
//

import Foundation

extension URL {
    
    /// If any step throws an error, use the original url.
    mutating func appendQueryItems(_ queryItems: [URLQueryItem]?) {
        self = appendingQueryItems(queryItems)
    }
    
    
    /// - returns: A url after appending query items, if any step throws an error, the original url is returned.
    func appendingQueryItems(_ queryItems: [URLQueryItem]?) -> URL {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: true) else { return self }
        
        
        if components.queryItems == nil {
            components.queryItems = queryItems
        } else {
            components.queryItems?.append(contentsOf: queryItems ?? [])
        }
        
        return components.url ?? self
    }
    
}
