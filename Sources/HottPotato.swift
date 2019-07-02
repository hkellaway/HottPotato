//
//  HottPotato.swift
//  HottPotato
//
// Copyright (c) 2019 Harlan Kellaway
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
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
    
    /// Sets keyDecodingStrategy, if default configuration is used.
    public var keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys {
        didSet {
            (requestSender as? DefaultJSONHTTPClient)?.decoder
                .keyDecodingStrategy = keyDecodingStrategy
        }
    }
    
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
    
    // MARK: HTTPClient
    
    public func sendHTTPRequest(with request: HTTPRequest, success: @escaping (Data, HTTPURLResponse) -> (), failure: @escaping (HTTPClientError) -> ()) {
        requestSender.sendHTTPRequest(with: request, success: success, failure: failure)
    }
    
}
