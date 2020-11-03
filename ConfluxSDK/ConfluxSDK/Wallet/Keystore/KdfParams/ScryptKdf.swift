//
//  File.swift
//  EthereumKitSwift
//
//  Created by Dmitriy Karachentsov on 2/9/18.
//

import Foundation

struct ScryptKdf: Codable {
    var dklen: Int
    var n: UInt64
    var r: UInt32
    var p: UInt32
    var salt: String
}

extension ScryptKdf {
    
    func scrypt(password: Data) throws -> Data {
        let scrypt = try Scrypt.scrypt(
            password: password,
            salt: Data(hex: salt),
            N: n,
            r: r,
            p: p,
            dkLen: dklen)
        return scrypt
    }
    
}
