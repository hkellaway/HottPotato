//
//  JSONHTTPClient.swift
//  HottPotato
//
//  Created by Harlan Kellaway on 5/10/19.
//  Copyright © 2019 Harlan Kellaway. All rights reserved.
//

import Foundation

/// HTTP client that assumes JSON is being returned in requests.
public protocol JSONHTTPClient: HTTPClient {
    
    func sendModelRequest<T: Decodable>(with urlRequest: HTTPRequest,
                                        modelType: T.Type,
                                        success: @escaping (T) -> (),
                                        failure: @escaping (Error) -> ())
    
    func sendJSONRequest(with urlRequest: HTTPRequest,
                         success: @escaping (_ data: JSONData, _ json: JSON) -> (),
                         failure: @escaping (Error) -> ())
    
}

