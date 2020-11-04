//
//  File.swift
//  EthereumKitSwift
//
//  Created by Dmitriy Karachentsov on 2/9/18.
//

import Scrypt

struct ScryptKdf: Codable {
    var dklen: Int
    var n: UInt64
    var r: UInt32
    var p: UInt32
    var salt: String
}

extension ScryptKdf {
    
    func scrypt(password: Data) throws -> Data {
        let scrypt = try Scrypt.generateHash(passwordData: password, salt: Data(hex: salt), N: Int(n), r: Int(r), p: Int(p), length: dklen)

        return scrypt
    }
    
}
