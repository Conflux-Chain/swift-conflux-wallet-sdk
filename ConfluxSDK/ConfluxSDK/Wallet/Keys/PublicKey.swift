//
//  PublicKey.swift
//  ConfluxSDK
//
//  Created by 区块链 on 2020/2/20.
//  Copyright © 2020 com.blockchain.dappbirds. All rights reserved.
//

public class PublicKey: NSObject {
    public let raw: Data
    
    public init(raw: Data) {
        self.raw = raw
    }
    
    public convenience init(privateKey: PrivateKey) {
        self.init(raw: Data(hex: "0x") + PublicKey.from(data: privateKey.raw, compressed: false))
    }
    
    /// Generates public key from specified private key,
    ///
    /// - Parameters: data of private key and compressed
    /// - Returns: Public key in data format
    public static func from(data: Data, compressed: Bool) -> Data {
        return Crypto.generatePublicKey(data: data, compressed: compressed)
    }
    
    /// generates address from its public key
    ///
    /// - Returns: address in string format
    public func address() -> String {
        return Address(data: addressData).string
    }
    
    /// Address data generated from public key in data format
    private var addressData: Data {
        return Crypto.hashSHA3_256(raw.dropFirst()).suffix(20)
    }
}
