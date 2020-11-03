//
//  Kdf.swift
//  EthereumKitSwift
//
//  Created by Dmitriy Karachentsov on 2/9/18.
//

import Foundation

enum KdfParams {
    case scrypt(ScryptKdf)
    case pbkdf2(Pbkdf2)
}

extension KdfParams {
    
    func generate(password: Data) throws -> Data {
        var data: Data!
        switch self {
        case .scrypt(let object):
            data = try object.scrypt(password: password)
        case .pbkdf2(let object):
            data = try object.pbkdf2(password: password)
        }
        return data
    }
    
}
