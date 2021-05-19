//
//  Scrypt.swift
//  EthereumKitSwift
//
//  Created by Dmitriy Karachentsov on 29/8/18.
//

//import Scrypt
//
//public class Scrypt {
//    
//    public enum Error: Swift.Error {
//        case computeError
//        case cpuCostInvalid
//        case cpuCostTooLarge
//        case memoryCostTooLarge
//        case desiredKeyTooLarge
//    }
//    
//    /// Compute scrypt derivation key
//    ///
//    /// - Parameters:
//    ///   - password: Password
//    ///   - salt: Salt
//    ///   - N: CPU AND RAM cost (first modifier)
//    ///   - r: RAM Cost
//    ///   - p: CPU cost (parallelisation)
//    ///   - dkLen: Key length
//    /// - Returns: Result of scrypt algorithm
//    public static func scrypt(
//        password: Data,
//        salt: Data,
//        N: UInt64,
//        r: UInt32,
//        p: UInt32,
//        dkLen: Int) throws -> Data {
//        if (N < 2 || (N & (N - 1)) != 0) {
//            throw Error.cpuCostInvalid
//        }
//        if N > UInt64.max / 128 / UInt64(r) {
//            throw Error.cpuCostTooLarge
//        }
//        if r > UInt32.max / 128 / p {
//            throw Error.memoryCostTooLarge
//        }
//        if dkLen > (1 << (32) - 1) * 32 {
//            throw Error.desiredKeyTooLarge
//        }
//        let passwordLen = password.count
//        let saltLen = salt.count
//        var pointer = UnsafeMutablePointer<UInt8>.allocate(capacity: dkLen)
//        defer {
//            pointer.deallocate()
//        }
//        if libscrypt_scrypt(password.bytes, passwordLen, salt.bytes, saltLen, N, r, p, pointer, dkLen) == -1 {
//            throw Error.computeError
//        }
//        let data = Data(bytes: pointer, count: dkLen)
//        return data
//    }
//    
//}
