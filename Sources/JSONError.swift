//
//  JSONError.swift
//  HottPotato
//
//  Created by Harlan Kellaway on 5/10/19.
//  Copyright © 2019 Harlan Kellaway. All rights reserved.
//

import Foundation

/// Errors when transforming HTTP request reponse to model from JSON.
///
/// - invalidJSON: Data not in valid JSON format.
/// - jsonParsingFailed: JSON could not be parsed into expected model.
public enum JSONError: Error {
    case invalidJSON(value: Any)
    case jsonParsingFailed
}
