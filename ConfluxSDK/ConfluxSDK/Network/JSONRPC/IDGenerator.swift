//
//  IDGenerator.swift
//  ConfluxSDK
//
//  Created by 区块链 on 2020/2/19.
//  Copyright © 2020 com.blockchain.dappbirds. All rights reserved.
//

public struct IDGenerator {
    private var currentId = 1
    
    public mutating func next() -> Int {
        defer { currentId += 1 }
        return currentId
    }
}
