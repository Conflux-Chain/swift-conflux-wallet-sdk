//
//  Cipher.swift
//  EthereumKitSwift
//
//  Created by Dmitriy Karachentsov on 2/9/18.
//

import CryptoSwift

enum CipherParams {
    
    case aes128Ctr(Aes128CtrCipher)
    
}

extension CipherParams {
    
    func cipher(key: Data) throws -> CryptoSwift.Cipher {
        var cipher: CryptoSwift.Cipher!
        switch self {
        case .aes128Ctr(let object):
            cipher = try object.cipher(key:key)
        }
        return cipher
    }
    
}

extension CryptoSwift.Cipher {
    
    func encrypt(input: Data) throws -> Data {
        let encryptedInput = try self.encrypt(input.bytes)
        return Data(bytes: encryptedInput)
    }
    
    func decrypt(input: Data) throws -> Data {
        let encryptedInput = try self.decrypt(input.bytes)
        return Data(bytes: encryptedInput)
    }
    
}
