//
//  DefaultJSONHTTPClient.swift
//  HottPotato
//
//  Created by Harlan Kellaway on 5/10/19.
//  Copyright © 2019 Harlan Kellaway. All rights reserved.
//

import Foundation

/// Default JSON HTTP client.
public class DefaultJSONHTTPClient: JSONHTTPClient {
    
    // MARK: - Properties
    
    /// URL session used for requests.
    public let urlSession: URLSession
    
    /// Decoder used to parse JSON in responses.
    public let decoder: JSONDecoder
    
    /// Options used when converting Data to JSON.
    public let options: JSONSerialization.ReadingOptions
    
    // MARK: - Initializers
    
    public init(urlSession: URLSession = URLSession.shared,
                decoder: JSONDecoder = JSONDecoder(),
                options: JSONSerialization.ReadingOptions = []) {
        self.urlSession = urlSession
        self.decoder = decoder
        self.options = options
    }
    
    // MARK: - Protocol conformance
    
    // MARK: JSONHTTPClient
    
    /// Sends
    ///
    /// - Parameters:
    ///   - httpRequest: HTTP request.
    ///   - modelType: Type of model to be parsed from JSON.
    ///   - success: Completion called with request is successful.
    ///   - failure: Completion called when request fails.
    public func sendModelRequest<T: Decodable>(with httpRequest: HTTPRequest,
                                               modelType: T.Type,
                                               success: @escaping (T) -> (),
                                               failure: @escaping (Error) -> ()) {
        sendJSONRequest(with: httpRequest, success: { [weak self] (data, json) in
            guard let self = self else { return }
            do {
                let model = try self.decoder.decode(modelType.self, from: data)
                success(model)
            } catch {
                failure(JSONError.jsonParsingFailed)
            }
            }, failure: { error in
                failure(error)
        })
    }
    
    public func sendJSONRequest(with urlRequest: URLRequest,
                                success: @escaping (_ data: JSONData, _ json: JSON) -> (),
                                failure: @escaping (Error) -> ()) {
        sendHTTPRequest(with: urlRequest, success: { [weak self] (data, _) in
            guard let self = self else { return }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: self.options)
                guard JSONSerialization.isValidJSONObject(json) else {
                    failure(JSONError.invalidJSON(value: json))
                    return
                }
                success(data, json)
            } catch {
                failure(JSONError.invalidJSON(value: data))
            }
            }, failure: { error in
                failure(error)
        })
    }
    
    // MARK: HTTPClient
    
    public func sendHTTPRequest(with httpRequest: HTTPRequest,
                                success: @escaping (Data, HTTPURLResponse) -> (),
                                failure: @escaping (HTTPClientError) -> ()) {
        let _ = urlSession.dataTask(with: httpRequest, completionHandler: { (data, response, error) in
            if let error = error {
                failure(.responseError(value: error))
                return
            }
            
            guard
                let unwrappedData = data,
                let httpResponse = response as? HTTPURLResponse else {
                    failure(.incompleteResponse(data: data, response: response as? HTTPURLResponse))
                    return
            }
            
            let successStatusCodes: Range<Int> = 200..<300
            
            guard successStatusCodes.contains(httpResponse.statusCode) else {
                failure(.errorStatusCode(value: httpResponse.statusCode))
                return
            }
            
            success(unwrappedData, httpResponse)
        }).resume()
    }
    
}
