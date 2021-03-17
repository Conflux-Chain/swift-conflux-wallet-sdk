// Copyright © 2017-2018 Trust.
//
// This file is part of Trust. The full Trust copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import Foundation

public protocol SuperAddress: CustomStringConvertible {
    /// Validates that the raw data is a valid address.
    static func isValid(data: Data) -> Bool

    /// Validates that the string is a valid address.
    static func isValid(string: String) -> Bool

    /// Raw representation of the address.
    var data: Data { get }

    /// Creates a address from a string representation.
    init?(string: String)

    /// Creates a address from a raw representation.
    init?(data: Data)
}

public struct ConfluxAddress: SuperAddress, Hashable {
    private(set) var newVersion = false // CIP37
    
    public static let size = 20

    /// Validates that the raw data is a valid address.
    public static func isValid(data: Data) -> Bool {
        return data.count == ConfluxAddress.size
    }

    /// Validates that the string is a valid address.
    public static func isValid(string: String) -> Bool {
        guard let data = Data(hexString: string) else {
            return false
        }
        return ConfluxAddress.isValid(data: data)
    }

    /// Raw address bytes, length 20.
    public let data: Data

    /// EIP55 representation of the address.
    public let eip55String: String
    
    /// CIP37 representation of the address.
    public func cip37String(prefix:String) -> String {
        return data.cip37AddressWith(prefix: prefix)
    }

    /// Creates an address with `Data`.
    ///
    /// - Precondition: data contains exactly 20 bytes
    public init?(data: Data) {
        if !ConfluxAddress.isValid(data: data) {
            return nil
        }
        self.data = data
        eip55String = ConfluxChecksum.computeString(for: data, type: .eip55)
    }

    /// Creates an address with an hexadecimal string representation.
    public init?(string: String) {
        if let d = Data(confluxBase32Address: string) {
            self.init(data: d)
            return
        }
        return nil
//        guard let data = Data(hexString: string), ConfluxAddress.isValid(data: data) else {
//            return nil
//        }
//        self.init(data: data)
    }

    public var description: String {
        return eip55String
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(data)
    }

    public static func == (lhs: ConfluxAddress, rhs: ConfluxAddress) -> Bool {
        return lhs.data == rhs.data
    }
}
