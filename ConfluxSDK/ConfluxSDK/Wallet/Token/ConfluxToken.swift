//
//  ConfluxToken.swift
//  ConfluxSDK
//
//  Created by 区块链 on 2020/2/21.
//  Copyright © 2020 com.blockchain.dappbirds. All rights reserved.
//

public struct ConfluxToken {
    /// Represents a contract address of token
    public let contractAddress: String
    
    /// Represents a decimal specified in a token
    public let decimal: Int
    
    /// Represents a symbol of  token
    public let symbol: String
    
    /// Initializer
    ///
    /// - Parameters:
    ///   - decimal: decimal specified in a contract
    ///   - symbol: symbol of token
    public init(contractAddress: String, decimal: Int, symbol: String) {
        self.contractAddress = contractAddress
        self.decimal = decimal
        self.symbol = symbol
    }
}

public extension ConfluxToken {
    enum ContractFunctions {
        case balanceOf(address: String)
        case transfer(address: String, amount: BInt)
        case decimals
        case name
        case symbol
        case redpacket(redpacketAddress: String,
                       groupId: Int,
                       amount: BInt,
                       mode: Int,
                       number: Int,
                       whiteCount: Int,
                       rootHash: String,
                       msg: String)
        
        case redpacketCFX(mode: Int,
                          groupId: Int,
                          number: Int,
                          whiteCount: Int,
                          rootHash: String,
                          msg: String)
        
        case rob(redPacketID: Int, location: Int, proof: [Data])
        
        var tokenFunction: Function {
            switch self {
            case .balanceOf:
                return Function(name: "balanceOf", parameters: [.address])
            case .transfer:
                return Function(name: "transfer", parameters: [.address, .uint(bits: 256)])
            case .decimals:
                return Function(name: "decimals", parameters: [])
            case .redpacket:
                return Function(name: "send", parameters: [.address, .uint(bits: 256), .dynamicBytes])
            case .redpacketCFX:
                return Function(name: "create", parameters: [.uint(bits: 8), .uint(bits: 256), .uint(bits: 256), .uint(bits: 256), .bytes(32), .string])
            case .rob:
                return Function(name: "rob", parameters: [.uint(bits: 256), .uint(bits: 256), .dynamicArray(.bytes(32))])
            case .name:
                return Function(name: "name", parameters: [])
            case .symbol:
                return Function(name: "symbol", parameters: [])
            }
        }

        public var data: Data {
            let encoder = ABIEncoder()
            
            switch self {
            case .balanceOf(let address):
                try! encoder.encode(function: tokenFunction, arguments: [ConfluxAddress(string: address)!])
                
            case .transfer(let toAddress, let poweredAmount):
                try! encoder.encode(function: tokenFunction, arguments: [ConfluxAddress(string: toAddress)!, BigUInt(poweredAmount)])

            case .decimals, .name, .symbol:
                try! encoder.encode(function: tokenFunction, arguments: [])

            case .redpacket(let redpacketAddress, let groupId, let poweredAmount, let mode,
                            let number, let whiteCount, let rootHash, let msg):
                
                let encoder1 = ABIEncoder()
                
                try! encoder1.encode(tuple: [
                    .uint(bits: 8, BigUInt(mode)),
                    .uint(bits: 256, BigUInt(groupId)),
                    .uint(bits: 256, BigUInt(number)),
                    .uint(bits: 256, BigUInt(whiteCount)),
                    .bytes(Data(hexString: rootHash)!),
                    .string(msg)
                ])

                try! encoder.encode(function: tokenFunction, arguments: [ConfluxAddress(string: redpacketAddress)!, BigUInt(poweredAmount), encoder1.data])
                // 这里encode会丢失data的数据，我们单独拼接一下，由于有padding，去掉padding即可
                return encoder.data + encoder1.data.dropFirst(32)
                                
            case .redpacketCFX(let mode, let groupId, let number, let whiteCount, let rootHash, let msg):

                try! encoder.encode(function: tokenFunction, arguments: [BigUInt(mode), BigUInt(groupId), BigUInt(number), BigUInt(whiteCount), Data(hexString: rootHash)!, msg])
                
            case .rob(let id, let location, let proof):
                try! encoder.encode(function: tokenFunction, arguments: [BigUInt(id), BigUInt(location), proof])
            }
            return encoder.data
        }
    }
}
