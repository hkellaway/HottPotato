//
//  HTTPResource.swift
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

/// Properties needed to define an HTTP request against a resource.
public class HTTPResource<T> where T: Decodable {
    
    // MARK: - Types
    
    /// HTTP method.
    ///
    /// - GET: GET.
    /// - POST: POST.
    /// - PUT: PUT.
    /// - DELETE: DELETE.
    public enum Method: String {
        case GET
        case POST
        case PUT
        case DELETE
    }
    
    // MARK: - Properties
    
    /// HTTP method.
    public let method: Method
    
    /// Base URL.
    public let baseURL: String
    
    /// Path.
    public let path: String
    
    // MARK: - Initializers
    
    public init(method: Method,
                baseURL: String,
                path: String) {
        self.method = method
        self.baseURL = baseURL
        self.path = path
    }
    
    // MARK: - Instance functions.
    
    /// URL for requests made for this Resource.
    /// By default, it simply combines baseURL and path;
    /// override to use a different strategy.
    ///
    /// - Returns: URL for requests made for this Resource.
    public func composeURL() -> URL? {
        return URL(string: baseURL + path)
    }
    
    /// Converts Resource to HTTP Request.
    ///
    /// - Returns: HTTP Request if successful, nil otherwise.
    public func toHTTPRequest() -> HTTPRequest? {
        guard let url = composeURL() else {
            return nil
        }
        var request = HTTPRequest(url: url)
        request.httpMethod = method.rawValue
        return request
    }
    
}
