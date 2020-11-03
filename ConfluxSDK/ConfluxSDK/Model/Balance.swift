//
//  Balance.swift
//  ConfluxSDK
//
//  Created by 区块链 on 2020/2/19.
//  Copyright © 2020 com.blockchain.dappbirds. All rights reserved.
//

public struct Balance {
    
    /// User's balance in drip unit
    public let drip: Drip
    
    /// User's balance in conflux unit
    public func conflux() throws -> Conflux {
        return try Converter.toConflux(drip: drip)
    }
    
    public init(drip: Drip) {
        self.drip = drip
    }
}

extension Balance: Codable {
    private enum CodingKeys: String, CodingKey {
        case drip
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        drip = try container.decode(Drip.self, forKey: .drip)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(drip, forKey: .drip)
    }
}
