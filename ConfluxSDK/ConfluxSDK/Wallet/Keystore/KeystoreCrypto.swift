//
//  KeystoreCrypto.swift
//  EthereumKitSwift
//
//  Created by Dmitriy Karachentsov on 31/8/18.
//

import Foundation
import CryptoSwift

internal final class KeystoreCrypto: Decodable {
    
    enum KeystoreCryptoError: Swift.Error {
        case unsupportedKdf
        case unsupportedCipher
        case keyDerivationFailed
    }
    
    enum Kdf: String {
        case scrypt = "scrypt"
        case pbkdf2 = "pbkdf2"
    }
    
    enum Cipher: String {
        case aes128ctr = "aes-128-ctr"
    }
    
    private enum CodingKeys: String, CodingKey {
        case ciphertext
        case cipher
        case cipherparams
        case kdf
        case kdfparams
        case mac
    }
    
    var cipher: Cipher
    var cipherParams: CipherParams
    var kdf: Kdf
    var kdfParams: KdfParams
    
    var ciphertext: Data
    var mac: String
    
    init(privateKey: Data, password: Data) throws {
        let iv = Data.randomBytes(count: 16).toHexString()
        let cipher = Aes128CtrCipher(iv: iv)
        self.cipherParams = .aes128Ctr(cipher)
        self.cipher = .aes128ctr
        
        let salt = Data.randomBytes(count: 32)
        let kdf = ScryptKdf(
            dklen: 32,
            n: 8192,
            r: 8,
            p: 1,
            salt: salt.toHexString())
        self.kdfParams = .scrypt(kdf)
        self.kdf = .scrypt
        
        let derivedKey = try self.kdfParams.generate(password: password)
        let slice = derivedKey.subdata(in: 0..<16)
        
        self.ciphertext = try self.cipherParams
            .cipher(key: slice)
            .encrypt(input: privateKey)
        
        let macSlice = derivedKey.subdata(in: 16..<32)
        let concat = macSlice + self.ciphertext
        self.mac = concat.sha3(.keccak256).toHexString()
    }
 
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let ciphertext = try container.decode(String.self, forKey: .ciphertext)
        self.ciphertext = Data(hex: ciphertext)
        let rawCipher = try container.decode(String.self, forKey: .cipher)
        guard let cipher = Cipher(rawValue: rawCipher) else {
            throw KeystoreCryptoError.unsupportedCipher
        }
        self.cipher = cipher
        switch cipher {
        case .aes128ctr:
            let params = try container.decode(Aes128CtrCipher.self, forKey: .cipherparams)
            cipherParams = .aes128Ctr(params)
        }
        let rawKdf = try container.decode(String.self, forKey: .kdf)
        guard let kdf = Kdf(rawValue: rawKdf) else {
            throw KeystoreCryptoError.unsupportedKdf
        }
        self.kdf = kdf
        switch kdf {
        case .pbkdf2:
            let params = try container.decode(Pbkdf2.self, forKey: .kdfparams)
            kdfParams = .pbkdf2(params)
        case .scrypt:
            let params = try container.decode(ScryptKdf.self, forKey: .kdfparams)
            kdfParams = .scrypt(params)
        }
        mac = try container.decode(String.self, forKey: .mac)
    }
    
    func privateKey(password: Data) throws -> Data {
        let derivedKey = try kdfParams.generate(password: password)
        let concat = derivedKey.subdata(in: 16..<32) + ciphertext
        let mac = concat.sha3(.keccak256).toHexString()
        guard mac == self.mac else {
            throw KeystoreCryptoError.keyDerivationFailed
        }
        let slice = derivedKey.subdata(in: 0..<16)
        let privateKey = try self.cipherParams
            .cipher(key: slice)
            .decrypt(input: ciphertext)
        return privateKey
    }
    
}

extension KeystoreCrypto: Encodable {
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let ciphertext = self.ciphertext.toHexString()
        try container.encode(ciphertext, forKey: .ciphertext)
        try container.encode(cipher.rawValue, forKey: .cipher)
        switch cipherParams {
        case .aes128Ctr(let cipher):
            try container.encode(cipher, forKey: .cipherparams)
        }
        try container.encode(kdf.rawValue, forKey: .kdf)
        switch kdfParams {
        case .scrypt(let params):
            try container.encode(params, forKey: .kdfparams)
        case .pbkdf2(let params):
            try container.encode(params, forKey: .kdfparams)
        }
        try container.encode(mac, forKey: .mac)
    }
    
}
