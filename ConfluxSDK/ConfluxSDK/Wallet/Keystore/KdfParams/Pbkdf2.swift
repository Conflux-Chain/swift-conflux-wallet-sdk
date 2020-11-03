//
//  Pbkdf2Params.swift
//  EthereumKitSwift
//
//  Created by Dmitriy Karachentsov on 2/9/18.
//

import CryptoSwift

struct Pbkdf2: Codable {
    var c: Int
    var dklen: Int
    var prf: String
    var salt: String
}

extension Pbkdf2 {
    
    func pbkdf2(password: Data) throws -> Data {
        let saltData = Data(hex: self.salt)
        let PBKDF2 = try PKCS5.PBKDF2(
            password: password.bytes,
            salt: saltData.bytes,
            iterations: c,
            keyLength: dklen,
            variant: .sha256)
        let bytes = try PBKDF2.calculate()
        return Data(bytes: bytes)
    }

}
