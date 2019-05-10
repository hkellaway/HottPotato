//
//  HTTPClientError.swift
//  HottPotato
//
//  Created by Harlan Kellaway on 5/10/19.
//  Copyright © 2019 Harlan Kellaway. All rights reserved.
//

import Foundation

/// Errors when making an HTTP request.
///
/// - invalidRequestURL: Could not determine valid URL for HTTP request.
/// - responseError: HTTP request returned with an error.
/// - incompleteResponse: HTTP request returned without error but with incomplete info.
/// - errorStatusCode: HTTP request returned without error but with error status code.
public enum HTTPClientError: Error {
    case responseError(value: Error)
    case incompleteResponse(data: Data?, response: HTTPURLResponse?)
    case errorStatusCode(value: Int)
}
