//
//  EIP55.swift
//  ConfluxSDK
//
//  Created by 区块链 on 2020/2/20.
//  Copyright © 2020 com.blockchain.dappbirds. All rights reserved.
//


//public struct EIP55 {
//    public static func encode(_ data: Data) -> String {
//        let address = data.toHexString()
//        let hash = Crypto.hashSHA3_256(address.data(using: .ascii)!).toHexString()
//        
//        var resultStr = zip(address, hash)
//        .map { a, h -> String in
//            switch (a, h) {
//            case ("0", _), ("1", _), ("2", _), ("3", _), ("4", _), ("5", _), ("6", _), ("7", _), ("8", _), ("9", _):
//                return String(a)
//            case (_, "8"), (_, "9"), (_, "a"), (_, "b"), (_, "c"), (_, "d"), (_, "e"), (_, "f"):
//                return String(a).uppercased()
//            default:
//                return String(a).lowercased()
//            }
//        }
//        .joined()
//        resultStr = "1" + resultStr.dropFirst()
//        return resultStr
//    }
//}
