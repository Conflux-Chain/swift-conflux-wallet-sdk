//
//  File.swift
//  EthereumKitSwift
//
//  Created by Dmitriy Karachentsov on 2/9/18.
//

import CryptoSwift

struct ScryptKdf: Codable {
    var dklen: Int
    var n: UInt64
    var r: UInt32
    var p: UInt32
    var salt: String
}

extension ScryptKdf {
    
    func scrypt(password: Data) throws -> Data {
        let scrypt = try CryptoSwift.Scrypt(password: Array(password), salt: Array(Data(hex: salt)), dkLen: dklen, N: Int(n), r: Int(r), p: Int(p)).calculate()
        
        return Data(scrypt)
    }
    
}
