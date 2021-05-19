//
//  RawTransaction.swift
//  ConfluxSDK
//
//  Created by 区块链 on 2020/2/20.
//  Copyright © 2020 com.blockchain.dappbirds. All rights reserved.
//

/// RawTransaction constructs necessary information to publish transaction.
public struct RawTransaction {
    public let value: Drip
    public let to: Address
    public let gasPrice: Int
    public let gasLimit: Int
    public let nonce: Int
    public let chainId: Int
    public let storageLimit: Drip
    public let epochHeight: Drip
    public let data: Data
}

extension RawTransaction {
    public init(value: Drip, to:String, gasPrice: Int, gasLimit: Int, nonce: Int, data: Data = Data(), storageLimit: Drip, epochHeight: Drip, chainId: Int) {
        self.value = value
        self.to = Address(string: to)
        self.gasPrice = gasPrice
        self.gasLimit = gasLimit
        self.nonce = nonce
        self.chainId = chainId
        self.storageLimit = storageLimit
        self.epochHeight = epochHeight
        self.data = data
    }
}

extension RawTransaction: Codable {
    private enum CodingKeys: String, CodingKey {
        case value
        case to
        case gasPrice
        case gasLimit
        case nonce
        case chainId
        case storageLimit
        case epochHeight
        case data
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        value = try container.decode(Drip.self, forKey: .value)
        to = try container.decode(Address.self, forKey: .to)
        gasPrice = try container.decode(Int.self, forKey: .gasPrice)
        gasLimit = try container.decode(Int.self, forKey: .gasLimit)
        nonce = try container.decode(Int.self, forKey: .nonce)
        chainId = try container.decode(Int.self, forKey: .chainId)
        storageLimit = try container.decode(Drip.self, forKey: .storageLimit)
        epochHeight = try container.decode(Drip.self, forKey: .epochHeight)
        data = try container.decode(Data.self, forKey: .data)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(value, forKey: .value)
        try container.encode(to, forKey: .to)
        try container.encode(gasPrice, forKey: .gasPrice)
        try container.encode(gasLimit, forKey: .gasLimit)
        try container.encode(nonce, forKey: .nonce)
        try container.encode(chainId, forKey: .chainId)
        try container.encode(storageLimit, forKey: .storageLimit)
        try container.encode(epochHeight, forKey: .epochHeight)
        try container.encode(data, forKey: .data)
    }
    
}

