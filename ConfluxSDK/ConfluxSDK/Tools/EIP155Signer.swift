//
//  EIP155Signer.swift
//  ConfluxSDK
//
//  Created by 区块链 on 2020/2/20.
//  Copyright © 2020 com.blockchain.dappbirds. All rights reserved.
//

import Foundation

public struct EIP155Signer {
    
    private let chainID: Int
    
    public init(chainID: Int) {
        self.chainID = chainID
    }
    
    public func sign(_ rawTransaction: RawTransaction, privateKey: PrivateKey) throws -> Data {
        let transactionHash = try hash(rawTransaction: rawTransaction)
        print("transactionHash: \(transactionHash.hexString)")
        let signiture = try privateKey.sign(hash: transactionHash)
        print("signiture: \(signiture.hexString)")
        let (r, s, v) = calculateRSV(signature: signiture)
        
        let rlp = try RLP.encode([
            [rawTransaction.nonce,
            rawTransaction.gasPrice,
            rawTransaction.gasLimit,
            rawTransaction.to.data,
            rawTransaction.value,
            rawTransaction.storageLimit,
            rawTransaction.epochHeight,
            rawTransaction.chainId,
            rawTransaction.data,
            ],
                    v, r, s
        ])
        print("transactionHash: \(rlp.hexString)")
        return rlp
    }
    public func hash(rawTransaction: RawTransaction) throws -> Data {
        return Crypto.hashSHA3_256(try encode(rawTransaction: rawTransaction))
    }
    
    public func encode(rawTransaction: RawTransaction) throws -> Data {
        let toEncode: [Any] = [
            rawTransaction.nonce,
            rawTransaction.gasPrice,
            rawTransaction.gasLimit,
            rawTransaction.to.data,
            rawTransaction.value,
            rawTransaction.storageLimit,
            rawTransaction.epochHeight,
            rawTransaction.chainId,
            rawTransaction.data,
        ]
//        if chainID != 0 {
//            toEncode.append(contentsOf: [chainID, 0, 0 ]) // EIP155
//        }
        let result = try RLP.encode(toEncode)
        print(result.hexString)
        return result
    }

    @available(*, deprecated, renamed: "calculateRSV(signature:)")
    public func calculateRSV(signiture: Data) -> (r: BInt, s: BInt, v: BInt) {
        return calculateRSV(signature: signiture)
    }

    // cfx use
    public func calculateRSV(signature: Data) -> (r: BInt, s: BInt, v: BInt) {
        return (
            r: BInt(str: signature[..<32].toHexString(), radix: 16)!,
            s: BInt(str: signature[32..<64].toHexString(), radix: 16)!,
            v: (BInt(signature[64])) // + (chainID == 0 ? 27 : (35 + 2 * chainID)) - 27)
        )
    }
    
    // eth use
  /*  public func calculateRSV(signature: Data) -> (r: BInt, s: BInt, v: BInt) {
        return (
            r: BInt(str: signature[..<32].toHexString(), radix: 16)!,
            s: BInt(str: signature[32..<64].toHexString(), radix: 16)!,
            v: BInt(signature[64]) + (chainID == 0 ? 27 : (35 + 2 * chainID))
        )
    } */

    public func calculateSignature(r: BInt, s: BInt, v: BInt) -> Data {
        let isOldSignitureScheme = [27, 28].contains(v)
        let suffix = isOldSignitureScheme ? v - 27 : v - 35 - 2 * chainID
        let sigHexStr = hex64Str(r) + hex64Str(s) + suffix.asString(withBase: 16)
        return Data(hex: sigHexStr)
    }

    private func hex64Str(_ i: BInt) -> String {
        let hex = i.asString(withBase: 16)
        return String(repeating: "0", count: 64 - hex.count) + hex
    }
}

extension Data {
    public var fullHexString: String {
        return self.map {
            return String(format: "%02x", $0)
        }.joined()
    }
}

