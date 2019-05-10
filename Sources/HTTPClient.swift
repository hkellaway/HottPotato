//
//  HTTPClient.swift
//  HottPotato
//
//  Created by Harlan Kellaway on 5/10/19.
//  Copyright © 2019 Harlan Kellaway. All rights reserved.
//

import Foundation

/// Sends HTTP requests.
public protocol HTTPClient {
    
    func sendHTTPRequest(with httpRequest: HTTPRequest,
                         success: @escaping (Data, HTTPURLResponse) -> (),
                         failure: @escaping (HTTPClientError) -> ())
    
}
