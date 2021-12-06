//
//  Cancellable.swift
//  ConfluxSDK
//
//  Created by 区块链 on 2020/2/18.
//  Copyright © 2020 com.blockchain.dappbirds. All rights reserved.
//

public protocol Cancellable: AnyObject {
    func cancel()
}

extension URLSessionTask: Cancellable {}
