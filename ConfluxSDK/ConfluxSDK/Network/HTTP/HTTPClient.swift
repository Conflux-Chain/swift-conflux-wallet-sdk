//
//  HTTPClient.swift
//  ConfluxSDK
//
//  Created by 区块链 on 2020/2/18.
//  Copyright © 2020 com.blockchain.dappbirds. All rights reserved.
/// HTTPClient is responsible for sending and canceling url requests

public class HTTPClient: HTTPClientType {
    
    /// batchFactory is used for creating batch request for JSONRPC request
    private let batchFactory = BatchFactory(version: "2.0")
    
    /// configuration is used for configuring request information
    public let configuration: Configuration
    
    public init(configuration: Configuration) {
        self.configuration = configuration
    }
    
    /// send method sends specified jsonrpc request and returns a session task.
    ///
    /// - Parameters:
    ///   - request: request to send. needs to be conformed to JSONRPCRequest protocol
    ///   - completionHandler:
    /// - Returns: session task used to send request
//    public func send<Request: JSONRPCRequest>(_ request: Request, completionHandler: @escaping (Result<Request.Response>) -> Void) -> Cancellable? {
//        let httpRequest = HTTPJSONRPCRequest(batch: batchFactory.create(request), endpoint: URL.init(string: configuration.nodeEndpoint)!)
//        return send(httpRequest, completionHandler: completionHandler)
//    }
    @discardableResult
    public func send<Request: JSONRPCRequest>(_ request: Request, completionHandler: @escaping (Result<Request.Response>) -> Void) -> Cancellable? {
        let httpRequest = HTTPJSONRPCRequest(batch: batchFactory.create(request), endpoint: URL(string: configuration.nodeEndpoint)!)
        // print(httpRequest)
        return send(httpRequest, completionHandler: completionHandler)
    }
    
    /// send method sends specified json request and returns a session task.
    ///
    /// - Parameters:
    ///   - request: request to send, needs to be conformed to RequestType protocol
    ///   - completionHandler:
    /// - Returns: session task used to send request
    @discardableResult
    public func send<Request: RequestType>(_ request: Request, completionHandler: @escaping (Result<Request.Response>) -> Void) -> Cancellable? {
        switch request.build() {
        case .success(let urlRequest):
            let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                let result = request.buildResponse(from: data, response: response, error: error)
                completionHandler(self.intercept(request, result: result))
                
            }
            
            task.resume()
            return task
            
        case .failure(let error):
            completionHandler(.failure(error))
            return nil
        }
    }
    
    private func intercept<Request: RequestType>(_ request: Request, result: Result<Request.Response>) -> Result<Request.Response> {
        if configuration.debugPrints {
            print(
                """
                \(request.description)
                \(result.description)\n
                """
            )
        }
        return result
    }
}
