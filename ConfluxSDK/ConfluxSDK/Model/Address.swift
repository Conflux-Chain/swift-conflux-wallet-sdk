//
//  Address.swift
//  ConfluxSDK
//
//  Created by 区块链 on 2020/2/20.
//  Copyright © 2020 com.blockchain.dappbirds. All rights reserved.
//

public struct Address {
    public let data: Data
    
    public let string: String
    
    public init(data: Data, string: String) {
        self.data = data
        self.string = string
    }
    
    public init(data: Data, isTestNet:Bool) {
        self.data = data
        let prefix = isTestNet ? "cfxtest" : "cfx"
        self.string = data.cip37AddressWith(prefix: prefix)
    }
    
    public init(string: String) {
        let addr = ConfluxAddress(string: string)
        self.data = addr?.data ?? Data()
        self.string = string
    }
}

extension Address: Codable {
    private enum CodingKeys: String, CodingKey {
        case data
        case string
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        data = try container.decode(Data.self, forKey: .data)
        string = try container.decode(String.self, forKey: .string)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(data, forKey: .data)
        try container.encode(string, forKey: .string)
    }
}
