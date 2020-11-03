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
    
    /// Length of 256 bits
    private static var lengthOf256bits: Int {
        return 256 / 4
    }
    
    /// Generate transaction data for ERC20 token
    ///
    /// - Parameter:
    ///    - toAddress: address you are transfering to
    ///    - amount: amount to send
    /// - Returns: transaction data
    public func generateDataParameter(toAddress: String, amount: String) throws -> Data {
        let poweredAmount = try power(amount: amount)
        return ConfluxToken.ContractFunctions.transfer(address: toAddress, amount: poweredAmount).data
    }
    
    /// Power the amount by the decimal
    ///
    /// - Parameter:
    ///    - amount: amount in string format
    /// - Returns: BigInt value powered by (10 * decimal)
    private func power(amount: String) throws -> BInt {
        let components = amount.split(separator: ".")
        
        // components.count must be 1 or 2. this method accepts only integer or decimal value
        // like 1, 10, 100 or 1.15, 10.7777, 19.9999
        guard components.count == 1 || components.count == 2 else {
            throw ConfluxError.contractError(.containsInvalidCharactor(amount))
        }
        
        guard let integer = BInt(String(components[0]), radix: 10) else {
            throw ConfluxError.contractError(.containsInvalidCharactor(amount))
        }
        
        let poweredInteger = integer * (BInt(10) ** decimal)
        
        if components.count == 2 {
            let count = components[1].count
            
            guard count <= decimal else {
                throw ConfluxError.contractError(.invalidDecimalValue(amount))
            }
            
            guard let digit = BInt(String(components[1]), radix: 10) else {
                throw ConfluxError.contractError(.containsInvalidCharactor(amount))
            }
            
            let poweredDigit = digit * (BInt(10) ** (decimal - count))
            return poweredInteger + poweredDigit
        } else {
            return poweredInteger
        }
    }
    
    /// Pad left spaces out of 256bits with 0
    internal static func pad(string: String) -> String {
        var string = string
        while string.count != lengthOf256bits {
            string = "0" + string
        }
        return string
    }
}


extension ConfluxToken {
    public enum ContractFunctions {
        case balanceOf(address: String)
        case transfer(address: String, amount: BInt)
        case decimals
        
        var methodSignature: Data {
            switch self {
            case .balanceOf:
                return generateSignature(method: "balanceOf(address)")
            case .transfer:
                return generateSignature(method: "transfer(address,uint256)")
            case .decimals:
                return generateSignature(method: "decimals()")
            }
        }
        
        private func generateSignature(method: String) -> Data {
            return method.data(using: .ascii)!.sha3(.keccak256)[0...3]
        }
        
        public var data: Data {
            switch self {
            case .balanceOf(let address):
                let noHexAddress = ConfluxToken.pad(string: address.cfxStripHexPrefix())
                let result = Data(hex: methodSignature.toHexString() + noHexAddress)
                return result
                
            case .transfer(let toAddress, let poweredAmount):
                let address = ConfluxToken.pad(string: toAddress.cfxStripHexPrefix())
                let amount = ConfluxToken.pad(string: poweredAmount.serialize().toHexString())
                return Data(hex: methodSignature.toHexString() + address + amount)
            case .decimals:
                return Data(hex: methodSignature.toHexString())
            }
        }
    }
}
