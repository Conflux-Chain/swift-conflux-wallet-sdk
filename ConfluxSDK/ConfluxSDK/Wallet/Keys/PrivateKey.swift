//
//  Keys.swift
//  ConfluxSDK
//
//  Created by 区块链 on 2020/2/20.
//  Copyright © 2020 com.blockchain.dappbirds. All rights reserved.
//

 public class PrivateKey: NSObject {
    public let raw: Data
    
    public init(raw: Data) {
        self.raw = raw
    }
    
    /// Publish key derived from private key
    public var publicKey: PublicKey {
        return PublicKey(privateKey: self)
    }
    
    /// Sign signs provided hash data with private key by Elliptic Curve, Secp256k1
    ///
    /// - Parameter hash: hash in data format
    /// - Returns: signiture in data format
    /// - Throws: .cryptoError(.failedToSign) when failed to sign
    public func sign(hash: Data) throws -> Data {
        return try Crypto.sign(hash, privateKey: raw)
    }
}
