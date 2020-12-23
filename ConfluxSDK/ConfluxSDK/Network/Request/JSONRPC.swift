//
//  JSONRPC.swift
//  ConfluxSDK
//
//  Created by 区块链 on 2020/2/19.
//  Copyright © 2020 com.blockchain.dappbirds. All rights reserved.
//

public final class JSONRPC {
    
    public struct GetGasPrice: JSONRPCRequest {
        public typealias Response = Drip
                        
        public var method: String {
            return "cfx_gasPrice"
        }
        
        public func response(from resultObject: Any) throws -> Drip {
            guard let response = resultObject as? String, let drip = Drip(response.lowercased().cfxStripHexPrefix(), radix: 16) else {
                throw JSONRPCError.unexpectedTypeObject(resultObject)
            }
            return drip
        }
    }
    
    // epochNumber
    public struct GetEpochNumber: JSONRPCRequest {
        public typealias Response = Int
        
        public var method: String {
            return "cfx_epochNumber"
        }
        
        public func response(from resultObject: Any) throws -> Int {
            guard let response = resultObject as? String, let epochNumber = Int(response.cfxStripHexPrefix(), radix: 16) else {
                throw JSONRPCError.unexpectedTypeObject(resultObject)
            }
            return epochNumber
        }
    }
    
    
    public struct GetBalance: JSONRPCRequest {
        public typealias Response = Balance
        
        public let address: String
        public let epochParameter: EpochParameter
        
        public var method: String {
            return "cfx_getBalance"
        }
        
        public var parameters: Any? {
            return [address, epochParameter.rawValue]
        }
        
        public func response(from resultObject: Any) throws -> Balance {
            guard let response = resultObject as? String, let drip = Drip(response.lowercased().cfxStripHexPrefix(), radix: 16) else {
                throw JSONRPCError.unexpectedTypeObject(resultObject)
            }
            return Balance(drip: drip)
        }
    }
    
    public struct GetNextNonce: JSONRPCRequest {
        public typealias Response = Int
        
        public let address: String
        public let epochParameter: EpochParameter
        
        public var method: String {
            return "cfx_getNextNonce"
        }
        
        public var parameters: Any? {
            return [address, epochParameter.rawValue]
        }
        
        public func response(from resultObject: Any) throws -> Response {
            guard let response = resultObject as? String else {
                throw JSONRPCError.unexpectedTypeObject(resultObject)
            }
            return Int(response.cfxStripHexPrefix(), radix: 16) ?? 0
        }
    }
    
    public struct SendRawTransaction: JSONRPCRequest {
         public typealias Response = SentTransaction
         
         public let rawTransaction: String
         
         public var method: String {
             return "cfx_sendRawTransaction"
         }
         
         public var parameters: Any? {
             return [rawTransaction]
         }
         
         public func response(from resultObject: Any) throws -> Response {
             guard let transactionID = resultObject as? String else {
                 throw JSONRPCError.unexpectedTypeObject(resultObject)
             }
             return Response(id: transactionID)
         }
     }

    
    public struct GetEstimatGas: JSONRPCRequest {
        public typealias Response = (gasUsed:Drip, gasLimit:Drip, storageCollateralized: Drip)
        
        public let from: String?
        public let to: String?
        public let gasLimit: Int?
        public let gasPrice: Int?
        public let nonce: Int?
        public let value: Drip?
        public let data: Data?
        
        public var method: String {
            return "cfx_estimateGasAndCollateral"
        }
        
        public var parameters: Any? {
            var txParams: [String: Any] = [:]
            
            if let fromAddress = from {
                txParams["from"] = fromAddress
            }
            
            if let toAddress = to {
                txParams["to"] = toAddress
            }
            
            if let gas = gasLimit {
                txParams["gas"] = gas.hexStringWithPrefix
            }
            
            if let gasPrice = gasPrice {
                txParams["gasPrice"] = gasPrice.hexStringWithPrefix
            }
            if let nonce = nonce {
                txParams["nonce"] = nonce.hexStringWithPrefix
            }
            
            if let value = value {
                txParams["value"] = value.hexStringWithPrefix
            }
            
            if let data = data {
                txParams["data"] = data.hexStringWithPrefix
            }
            return [txParams]
        }
        
        public func response(from resultObject: Any) throws -> Response {
            guard let response = resultObject as? Dictionary<String, Any>,
                  let gasUsedStr =  response["gasUsed"] as? String,
                  let storageCollateralizedStr = response["storageCollateralized"] as? String,
                  let gasLimitStr = response["gasLimit"] as? String
            else{
                throw JSONRPCError.unexpectedTypeObject(resultObject)
            }
            
            guard let gasUsed = Drip(gasUsedStr.lowercased().cfxStripHexPrefix(), radix: 16) , let storageCollateralized = Drip(storageCollateralizedStr.lowercased().cfxStripHexPrefix(), radix: 16),
                  let gasLimit = Drip(gasLimitStr.lowercased().cfxStripHexPrefix(), radix: 16)
            else {
                throw JSONRPCError.unexpectedTypeObject(resultObject)
            }
                        
            return (gasUsed: gasUsed, gasLimit:gasLimit, storageCollateralized: storageCollateralized)
        }
    }
    
    public struct Call: JSONRPCRequest {
        public typealias Response = String
        
        public let from: String?
        public let to: String
        public let gasLimit: Int?
        public let gasPrice: Int?
        public let value: Int?
        public let data: String?
        public let epochParameter: EpochParameter
        
        public var method: String {
            return "cfx_call"
        }
        
        public var parameters: Any? {
            var txParams: [String: Any] = [:]
            
            if let fromAddress = from {
                txParams["from"] = fromAddress
            }
            
            txParams["to"] = to
            
            if let gas = gasLimit {
                txParams["gas"] = gas.hexStringWithPrefix
            }
            
            if let gasPrice = gasPrice {
                txParams["gasPrice"] = gasPrice.hexStringWithPrefix
            }
            
            if let value = value {
                txParams["value"] = value.hexStringWithPrefix
            }
            
            if let data = data {
                txParams["data"] = data
            }
            
            return [txParams, epochParameter.rawValue]
        }
        
        public func response(from resultObject: Any) throws -> Response {
            guard let response = resultObject as? Response else {
                throw JSONRPCError.unexpectedTypeObject(resultObject)
            }
            return response
        }
    }
    
    public struct GetTransactionStatusByHash: JSONRPCRequest {
        public typealias Response = Int
        
        public let transactionHash: String
        
        public var method: String {
            return "cfx_getTransactionByHash"
        }
        
        public var parameters: Any? {
            return [transactionHash]
        }
        
        public func response(from resultObject: Any) throws -> Response {
            guard let response = resultObject as? Dictionary<String, Any>,
                  let status =  response["status"] as? String,
                  let code = Int(status.dropFirst(2), radix: 16)
            else{
                throw JSONRPCError.unexpectedTypeObject(resultObject)
            }
                        
            return code
        }
    }
    
    public struct GetTransactionReceiptByHash: JSONRPCRequest {
        public typealias Response = Dictionary<String, Any>
        
        public let transactionHash: String
        
        public var method: String {
            return "cfx_getTransactionReceipt"
        }
        
        public var parameters: Any? {
            return [transactionHash]
        }
        
        public func response(from resultObject: Any) throws -> Response {
            guard let response = resultObject as? Dictionary<String, Any>
            else{
                throw JSONRPCError.unexpectedTypeObject(resultObject)
            }
                        
            return response
        }
    }
    
}
