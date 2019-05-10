//
//  ViewController.swift
//  HTTPClientDemo
//
//  Created by Harlan Kellaway on 5/9/19.
//  Copyright © 2019 Harlan Kellaway. All rights reserved.
//

import UIKit

/// Result with no value type.
public typealias EmptyResult = ()

/// A type that can represent either success with a value or failure with an error.
/// Source: http://alisoftware.github.io/swift/async/error/2016/02/06/async-errors/
public enum Result<T, Error: Swift.Error> {
    
    // MARK: - Types
    
    public typealias Value = T
    public typealias ErrorType = Error
    
    // MARK: - Cases
    
    /// Sucess with value.
    case success(Value)
    
    /// Failure with error.
    case failure(ErrorType)
    
    // MARK: - Properties
    
    /// Value associated with Result.
    /// If there is no value, this will be nil.
    ///
    /// - Returns: Value or nil.
    public var value: Value? {
        switch self {
        case .success(let value):
            return value
        case .failure:
            return nil
        }
    }
    
    /// Error associated with Result.
    /// If there is no error, this will be nil.
    ///
    /// - Returns: Value or nil.
    public var error: Error? {
        switch self {
        case .success:
            return nil
        case .failure(let error):
            return error
        }
    }
    
    // MARK: - Init/Deinit
    
    /// Initializes a Result with the specified value.
    ///
    /// - parameter value: Value.
    ///
    /// - returns: Result with value.
    public init(value: Value) {
        self = .success(value)
    }
    
    /// Initializes a Result with the specified error.
    ///
    /// - parameter error: Error.
    ///
    /// - returns: Result with error.
    public init(error: ErrorType) {
        self = .failure(error)
    }
    
    // MARK: - Instance functions
    
    /// Returns a Result containing the outcome of performing the transform closure.
    ///
    /// - parameter transform: Transform closure.
    ///
    /// - returns: Result with value or error.
    public func map<U>(_ transform: (Value) -> U) -> Result<U,Error> {
        switch self {
        case .success(let value):
            return .success(transform(value))
        case .failure(let error):
            return .failure(error)
        }
    }
    
    /// Returns a Result returned from the outcome of the transform closure.
    ///
    /// - parameter transform: Transform closure.
    ///
    /// - returns: Result with value or error.
    public func flatMap<U>(_ transform: (Value) -> Result<U,Error>) -> Result<U,Error> {
        switch self {
        case .success(let value):
            return transform(value)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    /// Resolves the receiver by either returning a value or throwing an error.
    ///
    /// - throws: Error associated with the receiver.
    ///
    /// - returns: Value associated with the receiver.
    public func resolve() throws -> Value {
        switch self {
        case .success(let value):
            return value
        case .failure(let error):
            throw error
        }
    }
    
}

public class HTTPResource<T> where T: Decodable {
    
    public enum Method: String {
        case GET
        case POST
        case PUT
        case DELETE
    }
    
    public let method: Method
    public let baseURL: String
    public let path: String
    
    public init(method: Method,
                baseURL: String,
                path: String) {
        self.method = method
        self.baseURL = baseURL
        self.path = path
    }
    
    /// URL for requests made for this Resource.
    /// By default, it simply combines baseURL and path;
    /// override to use a different strategy.
    ///
    /// - Returns: URL for requests made for this Resource.
    public func composeURL() -> URL? {
        return URL(string: baseURL + path)
    }
    
}

public final class HottPotato: JSONHTTPClient {
    
    public static var shared = HottPotato()
    
    private let requestSender: JSONHTTPClient
    
    public var urlSession: URLSession? {
        return ((requestSender as? DefaultJSONHTTPClient)?.urlSession)
    }
    
    public convenience init(jsonReadingOptions: JSONSerialization.ReadingOptions) {
        self.init(requestSender: DefaultJSONHTTPClient(options: jsonReadingOptions))
    }
    
    public init(requestSender: JSONHTTPClient = DefaultJSONHTTPClient()) {
        self.requestSender = requestSender
    }
    
    public func sendRequest<T>(for resource: HTTPResource<T>,
                               completion: @escaping (Result<T,HTTPClientError>) -> ()) {
        guard let url = resource.composeURL() else {
            completion(Result(error: .invalidRequestURL))
            return
        }
        
        var httpRequest = HTTPRequest(url: url)
        httpRequest.httpMethod = resource.method.rawValue
        requestSender.sendModelRequest(with: httpRequest, modelType: T.self, success: { model in
            completion(Result(value: model))
        }, failure: { error in
            completion(Result(error: error))
        })
    }
    
    // MARK: - Protocol conformance
    
    // MARK: JSONHTTPClient
    
    public func sendModelRequest<T>(with request: HTTPRequest, modelType: T.Type, success: @escaping (T) -> (), failure: @escaping (HTTPClientError) -> ()) where T : Decodable {
        requestSender.sendModelRequest(with: request, modelType: modelType, success: success, failure: failure)
    }
    
    public func sendJSONRequest(with request: HTTPRequest, success: @escaping (JSONData) -> (), failure: @escaping (HTTPClientError) -> ()) {
        requestSender.sendJSONRequest(with: request, success: success, failure: failure)
    }
    
    public func sendRequest(with request: HTTPRequest, success: @escaping (Data, HTTPURLResponse) -> (), failure: @escaping (HTTPClientError) -> ()) {
        requestSender.sendRequest(with: request, success: success, failure: failure)
    }
    
}

public typealias JSONData = Data

public class DefaultJSONHTTPClient: JSONHTTPClient {
    
    public let urlSession: URLSession
    public let decoder: JSONDecoder
    public let options: JSONSerialization.ReadingOptions
    
    public init(urlSession: URLSession = URLSession.shared,
                decoder: JSONDecoder = JSONDecoder(),
                options: JSONSerialization.ReadingOptions = []) {
        self.urlSession = urlSession
        self.decoder = decoder
        self.options = options
    }
    
    // MARK: - Protocol conformance
    
    // MARK: JSONHTTPClient
    
    public func sendModelRequest<T: Decodable>(with urlRequest: URLRequest,
                                               modelType: T.Type,
                                               success: @escaping (T) -> (),
                                               failure: @escaping (HTTPClientError) -> ()) {
        sendJSONRequest(with: urlRequest, success: { [weak self] json in
            guard let self = self else { return }
            do {
                let model = try self.decoder.decode(modelType.self, from: json)
                success(model)
            } catch {
                failure(.jsonParsingFailed)
            }
            }, failure: { error in
                failure(error)
        })
    }
    
    public func sendJSONRequest(with urlRequest: URLRequest,
                                success: @escaping (JSONData) -> (),
                                failure: @escaping (HTTPClientError) -> ()) {
        sendRequest(with: urlRequest, success: { [weak self] (data, _) in
            guard let self = self else { return }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: self.options)
                guard JSONSerialization.isValidJSONObject(json) else {
                    failure(.invalidJSON)
                    return
                }
                success(data)
            } catch {
                failure(.invalidJSON)
            }
            }, failure: { error in
                failure(.responseError(value: error))
        })
    }
    
    // MARK: HTTPClient
    
    public func sendRequest(with httpRequest: HTTPRequest,
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

public protocol JSONHTTPClient: HTTPClient {
    
    func sendModelRequest<T: Decodable>(with urlRequest: HTTPRequest,
                                        modelType: T.Type,
                                        success: @escaping (T) -> (),
                                        failure: @escaping (HTTPClientError) -> ())
    
    func sendJSONRequest(with urlRequest: HTTPRequest,
                         success: @escaping (JSONData) -> (),
                         failure: @escaping (HTTPClientError) -> ())
    
}

public enum HTTPClientError: Error {
    case invalidRequestURL
    case responseError(value: Error)
    case incompleteResponse(data: Data?, response: HTTPURLResponse?)
    case errorStatusCode(value: Int)
    case invalidJSON
    case jsonParsingFailed
}

public protocol HTTPClient {
    
    func sendRequest(with urlRequest: HTTPRequest,
                     success: @escaping (Data, HTTPURLResponse) -> (),
                     failure: @escaping (HTTPClientError) -> ())
    
}

public typealias HTTPRequest = URLRequest

class ViewController: UIViewController {
    
    var httpClient = HottPotato.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        httpClient.sendRequest(for: HTTPResources.jobIDs) { result in
            switch result {
            case .success(let jobIDs):
                print(jobIDs)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

struct HTTPResources {
    
    static let baseURL = "https://hacker-news.firebaseio.com/v0"
    
    static let jobIDs: HTTPResource<[Int]>
        = HTTPResource(method: .GET,
                       baseURL: HTTPResources.baseURL,
                       path: "/jobstories.json")
    
}
