//
//  SentTransaction.swift
//  ConfluxSDK
//
//  Created by 区块链 on 2020/2/19.
//  Copyright © 2020 com.blockchain.dappbirds. All rights reserved.
//

public struct SentTransaction {
    /// Transaction ID published when broadcasting raw tx
    public let id: String
    
    public init(id: String) {
        self.id = id
    }
}
