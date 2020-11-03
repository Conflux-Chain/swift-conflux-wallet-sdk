//
//  JSONBodySerialization.swift
//  ConfluxSDK
//
//  Created by 区块链 on 2020/2/18.
//  Copyright © 2020 com.blockchain.dappbirds. All rights reserved.
//

/// `JSONBodyParameters` serializes JSON object for HTTP body and states its content type is JSON.

public struct JSONBodySerialization {
    /// The JSON object to be serialized.
    public let object: Any
    
    /// The writing options for serialization.
    public let writingOptions: JSONSerialization.WritingOptions
    
    /// Returns `JSONBodyParameters` that is initialized with JSON object and writing options.
    public init(_ object: Any, writingOptions: JSONSerialization.WritingOptions = []) {
        self.object = object
        self.writingOptions = writingOptions
    }
    
    /// `Content-Type` to send. The value for this property will be set to `Accept` HTTP header field.
    public var contentType: String {
        return "application/json"
    }
    
    /// Builds `RequestBodyEntity.data` that represents `JSONObject`.
    public func build() -> Result<Data> {
        guard JSONSerialization.isValidJSONObject(object) else {
            return .failure(ConfluxError.requestError(.invalidParameters(object)))
        }
        
        let data: Data
        do {
            data = try JSONSerialization.data(withJSONObject: object, options: writingOptions)
        } catch {
            return .failure(ConfluxError.requestError(.invalidParameters(object)))
        }
        
        return .success(data)
    }
}
