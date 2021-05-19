//
//  SMP+Extension.swift
//  ConfluxSDK
//
//  Created by 区块链 on 2020/2/19.
//  Copyright © 2020 com.blockchain.dappbirds. All rights reserved.
//

extension BInt {
    public func toInt() ->Int? {
        return asInt()
    }
    internal init?(str: String, radix: Int) {
        self.init(0)
        let bint16 = BInt(16)

        var exp = BInt(1)

        for c in str.reversed() {
            let int = Int(String(c), radix: radix)
            if int != nil {
                let value = BInt(int!)
                self = self + (value * exp)
                exp = exp * bint16
            } else {
                return nil
            }
        }
    }
}

extension BInt {
    private enum CodingKeys: String, CodingKey {
        case bigInt
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let string = try container.decode(String.self, forKey: .bigInt)
        self = Drip(string)!
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(asString(radix: 10), forKey: .bigInt)
    }
}
