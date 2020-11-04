//
//  JSONRPCRequest.swift
//  ConfluxSDK
//
//  Created by 区块链 on 2020/2/19.
//  Copyright © 2020 com.blockchain.dappbirds. All rights reserved.
//

public protocol JSONRPCRequest {
    associatedtype Response
    
    var method: String { get }
    var parameters: Any? { get }
    
    func response(from resultObject: Any) throws -> Response
}

public extension JSONRPCRequest {
    var parameters: Any? {
        return nil
    }
}
