//
//  HottPotatoError.swift
//  HottPotato
//
//  Created by Harlan Kellaway on 5/10/19.
//  Copyright © 2019 Harlan Kellaway. All rights reserved.
//

import Foundation

/// HottPotato error.
///
/// - invalidRequestURL: Could not compose URL for HTTP request.
/// - requestError: Error occurred during HTTP request.
public enum HottPotatoError: Error {
    case invalidRequestURL
    case requestError(value: Error)
}
