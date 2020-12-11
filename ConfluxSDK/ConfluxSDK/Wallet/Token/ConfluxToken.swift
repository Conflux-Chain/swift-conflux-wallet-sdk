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


extension ConfluxToken {
    public enum ContractFunctions {
        case balanceOf(address: String)
        case transfer(address: String, amount: BInt)
        case decimals
        case redpacket(redpacketAddress: String,
                       amount: BInt,
                       mode:Int,
                       number:Int,
                       whiteCount:Int,
                       rootHash:String,
                       msg:String)
        
        case redpacketCFX(mode:Int,
                          number:Int,
                          whiteCount:Int,
                          rootHash:String,
                          msg:String)
        

        var tokenFunction:Function {
            switch self {
            case .balanceOf:
                return Function(name: "balanceOf", parameters: [.address])
            case .transfer:
                return Function(name: "transfer", parameters: [.address, .uint(bits: 256)])
            case .decimals:
                return Function(name: "decimals", parameters: [])
            case .redpacket:
                return Function(name: "send", parameters: [.address, .uint(bits: 256), .bytes(32)])
            case .redpacketCFX:
                return Function(name: "create", parameters: [.uint(bits: 8), .uint(bits: 256),.uint(bits: 256),.bytes(32),.string])
            }
        }

        
        public var data: Data {
            let encoder = ABIEncoder()
            
            switch self {
            case .balanceOf(let address):
                try! encoder.encode(function: tokenFunction, arguments: [ConfluxAddress(string: address)!])
                
            case .transfer(let toAddress, let poweredAmount):
                try! encoder.encode(function: tokenFunction, arguments: [ConfluxAddress(string: toAddress)!, poweredAmount])

            case .decimals:
                try! encoder.encode(function: tokenFunction, arguments: [])

            case .redpacket(let redpacketAddress, let poweredAmount, _,
                                let number, let whiteCount, let rootHash, let msg):
                
                let encoder1 = ABIEncoder()
                try! encoder1.encode(tuple: [
                    .uint(bits: 8, 0),
                    .uint(bits: 256, BigUInt(number)),
                    .uint(bits: 256, BigUInt(whiteCount)),
                    .bytes(Data(hexString: rootHash)!),
                    .string(msg)
                ])

                try! encoder.encode(function: tokenFunction, arguments: [ConfluxAddress(string: redpacketAddress)!, poweredAmount, encoder1.data])
                                
                
            case .redpacketCFX(let mode, let number, let whiteCount, let rootHash, let msg):

                try! encoder.encode(function: tokenFunction, arguments: [mode, number, whiteCount, Data(hexString: rootHash)!, msg])
                    
            }
            return encoder.data
        }
    }
}
