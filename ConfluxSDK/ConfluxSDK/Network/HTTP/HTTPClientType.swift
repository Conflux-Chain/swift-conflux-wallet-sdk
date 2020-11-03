//
//  HTTPClientType.swift
//  ConfluxSDK
//
//  Created by 区块链 on 2020/2/18.
//  Copyright © 2020 com.blockchain.dappbirds. All rights reserved.
//

public protocol HTTPClientType {
    @discardableResult
    func send<Request: RequestType>(
        _ request: Request,
        completionHandler: @escaping (Result<Request.Response>) -> Void) -> Cancellable?
    
    @discardableResult
    func send<Request: JSONRPCRequest>(
        _ request: Request,
        completionHandler: @escaping (Result<Request.Response>) -> Void) -> Cancellable?
}
