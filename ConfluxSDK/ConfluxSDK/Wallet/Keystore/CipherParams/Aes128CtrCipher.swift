//
//  Aes128CtrCipher.swift
//  EthereumKitSwift
//
//  Created by Dmitriy Karachentsov on 2/9/18.
//

import CryptoSwift

struct Aes128CtrCipher: Codable {
    
    var iv: String
    
}

extension Aes128CtrCipher {
    
    func cipher(key: Data) throws -> CryptoSwift.Cipher {
        let ivData = Data(hex: iv)
        let cipher = try AES(
            key: key.bytes,
            blockMode: CTR(iv: ivData.bytes),
            padding: .noPadding)
        return cipher
    }
    
}
