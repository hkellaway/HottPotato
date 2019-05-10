//
//  HottPotato.swift
//  HottPotato
//
//  Created by Harlan Kellaway on 5/10/19.
//  Copyright © 2019 Harlan Kellaway. All rights reserved.
//

import Foundation

/// Sends HTTP requests using preferred patterns and assumed JSON response.
public final class HottPotato: JSONHTTPClient {
    
    // MARK: - Properties
    
    // MARK: Class properties
    
    /// Shared instance.
    public static var shared = HottPotato()
    
    // MARK: Instance properties.
    
    /// Sends HTTP requests assuming JSON response.
    public let requestSender: JSONHTTPClient
    
    /// URL session used for HTTP requests, if default configuration is used.
    public var urlSession: URLSession? {
        return ((requestSender as? DefaultJSONHTTPClient)?.urlSession)
    }
    
    // MARK: - Initializers
    
    public convenience init(jsonReadingOptions: JSONSerialization.ReadingOptions) {
        self.init(requestSender: DefaultJSONHTTPClient(options: jsonReadingOptions))
    }
    
    public init(requestSender: JSONHTTPClient = DefaultJSONHTTPClient()) {
        self.requestSender = requestSender
    }
    
    // MARK: - Instance functions
    
    /// Send HTTP request for provided resource, assuming associated
    /// model type will be parsed from JSON.
    ///
    /// - Parameters:
    ///   - resource: Resource definition.
    ///   - completion: Completion with result.
    public func sendRequest<T>(for resource: HTTPResource<T>,
                               completion: @escaping (Result<T,HottPotatoError>) -> ()) {
        guard let httpRequest = resource.toHTTPRequest() else {
            completion(.failure(.invalidRequestURL))
            return
        }
        
        requestSender.sendModelRequest(with: httpRequest, modelType: T.self, success: { model in
            completion(.success(model))
        }, failure: { error in
            completion(.failure(.requestError(value: error)))
        })
    }
    
    // MARK: - Protocol conformance
    
    // MARK: JSONHTTPClient
    
    public func sendModelRequest<T>(with request: HTTPRequest, modelType: T.Type, success: @escaping (T) -> (), failure: @escaping (Error) -> ()) where T : Decodable {
        requestSender.sendModelRequest(with: request, modelType: modelType, success: success, failure: failure)
    }
    
    public func sendJSONRequest(with request: HTTPRequest, success: @escaping (_ data: JSONData, _ json: JSON) -> (), failure: @escaping (Error) -> ()) {
        requestSender.sendJSONRequest(with: request, success: success, failure: failure)
    }
    
    public func sendHTTPRequest(with request: HTTPRequest, success: @escaping (Data, HTTPURLResponse) -> (), failure: @escaping (HTTPClientError) -> ()) {
        requestSender.sendHTTPRequest(with: request, success: success, failure: failure)
    }
    
}
