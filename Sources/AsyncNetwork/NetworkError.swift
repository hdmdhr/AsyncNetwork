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
    
}
