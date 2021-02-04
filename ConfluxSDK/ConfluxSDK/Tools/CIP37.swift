//
//  File.swift
//  ConfluxSDK
//
//  Created by R0uter on 2/4/21.
//  Copyright © 2021 com.blockchain.dappbirds. All rights reserved.
//

import Foundation
let testData = [
    (("0x85d80245dc02f5a89589e1f19c5c718e405b56cd", "cfx"), "cfx:acc7uawf5ubtnmezvhu9dhc6sghea0403y2dgpyfjp"),
    (("0x85d80245dc02f5a89589e1f19c5c718e405b56cd", "cfxtest"), "cfxtest:acc7uawf5ubtnmezvhu9dhc6sghea0403ywjz6wtpg"),
    (("0x85d80245dc02f5a89589e1f19c5c718e405b56cd", "cfxtest"), "cfxtest:type.contract:acc7uawf5ubtnmezvhu9dhc6sghea0403ywjz6wtpg"),

    (("0x1a2f80341409639ea6a35bbcab8299066109aa55", "cfx"), "cfx:aarc9abycue0hhzgyrr53m6cxedgccrmmyybjgh4xg"),
    (("0x1a2f80341409639ea6a35bbcab8299066109aa55", "cfxtest"), "cfxtest:aarc9abycue0hhzgyrr53m6cxedgccrmmy8m50bu1p"),
    (("0x1a2f80341409639ea6a35bbcab8299066109aa55", "cfxtest"), "cfxtest:type.user:aarc9abycue0hhzgyrr53m6cxedgccrmmy8m50bu1p"),

    (("0x19c742cec42b9e4eff3b84cdedcde2f58a36f44f", "cfx"), "cfx:aap6su0s2uz36x19hscp55sr6n42yr1yk6r2rx2eh7"),
    (("0x19c742cec42b9e4eff3b84cdedcde2f58a36f44f", "cfxtest"), "cfxtest:aap6su0s2uz36x19hscp55sr6n42yr1yk6hx8d8sd1"),
    (("0x19c742cec42b9e4eff3b84cdedcde2f58a36f44f", "cfxtest"), "cfxtest:type.user:aap6su0s2uz36x19hscp55sr6n42yr1yk6hx8d8sd1"),

    (("0x84980a94d94f54ac335109393c08c866a21b1b0e", "cfx"), "cfx:acckucyy5fhzknbxmeexwtaj3bxmeg25b2b50pta6v"),
    (("0x84980a94d94f54ac335109393c08c866a21b1b0e", "cfxtest"), "cfxtest:acckucyy5fhzknbxmeexwtaj3bxmeg25b2nuf6km25"),
    (("0x84980a94d94f54ac335109393c08c866a21b1b0e", "cfxtest"), "cfxtest:type.contract:acckucyy5fhzknbxmeexwtaj3bxmeg25b2nuf6km25"),

    (("0x1cdf3969a428a750b89b33cf93c96560e2bd17d1", "cfx"), "cfx:aasr8snkyuymsyf2xp369e8kpzusftj14ec1n0vxj1"),
    (("0x1cdf3969a428a750b89b33cf93c96560e2bd17d1", "cfxtest"), "cfxtest:aasr8snkyuymsyf2xp369e8kpzusftj14ej62g13p7"),
    (("0x1cdf3969a428a750b89b33cf93c96560e2bd17d1", "cfxtest"), "cfxtest:type.user:aasr8snkyuymsyf2xp369e8kpzusftj14ej62g13p7"),

    (("0x0888000000000000000000000000000000000002", "cfx"), "cfx:aaejuaaaaaaaaaaaaaaaaaaaaaaaaaaaajrwuc9jnb"),
    (("0x0888000000000000000000000000000000000002", "cfxtest"), "cfxtest:aaejuaaaaaaaaaaaaaaaaaaaaaaaaaaaajh3dw3ctn"),
    (("0x0888000000000000000000000000000000000002", "cfxtest"), "cfxtest:type.builtin:aaejuaaaaaaaaaaaaaaaaaaaaaaaaaaaajh3dw3ctn"),
]
let base32TableReverse: [Character: UInt8] = [
    "a": 0x00,
    "j": 0x08,
    "u": 0x10,
    "2": 0x18,
    "b": 0x01,
    "k": 0x09,
    "v": 0x11,
    "3": 0x19,
    "c": 0x02,
    "m": 0x0a,
    "w": 0x12,
    "4": 0x1a,
    "d": 0x03,
    "n": 0x0b,
    "x": 0x13,
    "5": 0x1b,
    "e": 0x04,
    "p": 0x0c,
    "y": 0x14,
    "6": 0x1c,
    "f": 0x05,
    "r": 0x0d,
    "z": 0x15,
    "7": 0x1d,
    "g": 0x06,
    "s": 0x0e,
    "0": 0x16,
    "8": 0x1e,
    "h": 0x07,
    "t": 0x0f,
    "1": 0x17,
    "9": 0x1f,
]
let base32Table: [UInt8: String] = [
    0x00: "a",
    0x08: "j",
    0x10: "u",
    0x18: "2",
    0x01: "b",
    0x09: "k",
    0x11: "v",
    0x19: "3",
    0x02: "c",
    0x0a: "m",
    0x12: "w",
    0x1a: "4",
    0x03: "d",
    0x0b: "n",
    0x13: "x",
    0x1b: "5",
    0x04: "e",
    0x0c: "p",
    0x14: "y",
    0x1c: "6",
    0x05: "f",
    0x0d: "r",
    0x15: "z",
    0x1d: "7",
    0x06: "g",
    0x0e: "s",
    0x16: "0",
    0x1e: "8",
    0x07: "h",
    0x0f: "t",
    0x17: "1",
    0x1f: "9",
]
typealias BitArray = [Bool]
func bits(fromByte bytes: Data) -> BitArray {
    return bytes.flatMap { bits(fromByte: $0) }
}

func bits(fromByte bytes: [UInt8]) -> BitArray {
    return bytes.flatMap { bits(fromByte: $0) }
}

func bits(fromByte byte: UInt8) -> BitArray {
    var byte = byte
    var bits = [Bool](repeating: false, count: 8)
    for i in 0..<8 {
        let currentBit = byte & 0x01
        if currentBit != 0 {
            bits[i] = true
        }
        byte >>= 1
    }

    return bits.reversed()
}

func bitsTo5BitSplitedData(bits: BitArray) -> Data {
    var index: UInt8 = 0
    var payload = Data()
    var cache: UInt8 = 0
    for bit in bits {
        let mask: UInt8 = 1 << UInt8(4 - index)
        if bit { cache |= mask }
        index += 1
        if index == 5 {
            index = 0
            payload.append(cache)
            cache = 0
        }
    }
    return payload
}

func bitsToBytes(bits: BitArray) -> Data {
    let numBits = bits.count
    let numBytes = (numBits + 7) / 8
    var bytes = Data(repeating: 0, count: numBytes)

    for (index, bit) in bits.enumerated() {
        if bit {
            bytes[index / 8] += 1 << (7 - index % 8)
        }
    }
    return bytes
}

public extension String {
    var confluxBase32Data: Data {
        var payload: [UInt8] = []
        for c in self {
            let n = c.asciiValue! & 0b00011111
            payload.append(n)
        }
        return Data(payload)
    }
}

extension Data {
    func testCIP37() {
        for i in testData {
            let address = i.0.0
            let prefix = i.0.1
            let r = prefix + ":" + Data(hexString: address)!.base32StringWithChecksum(prefix: prefix)

            let t = i.1.split(separator: ":")
            let target = "\(t[0]):\(t.last!)"
            if r != target {
                print(i, r)
            }

            let d = Data(confluxBase32Address: r)
            if d!.hexStringWithPrefix != address {
                print(d!.hexStringWithPrefix, address)
            }
        }
        print("if nothing shows up, pass!")
    }

    var bitArray: BitArray {
        flatMap { bits(fromByte: $0) }
    }

    init(base32: String) {
        self.init()
        for char in base32 {
            append(base32TableReverse[char]!)
        }
    }

    init?(confluxBase32Address: String) {
        let l = confluxBase32Address.lowercased().split(separator: ":")
        guard l.count >= 2, let prefix = l.first, let address = l.last
        else { return nil }
        self.init()
        var payload = Data(base32: String(address))
        var ckData: Data = String(prefix).confluxBase32Data + [0]
        ckData.append(contentsOf: payload)
        guard ckData.polyMod == "aaaaaaaa" else { return nil }
        payload.clipZerosForBase32()
        self = payload
    }

    mutating func clipZerosForBase32() {
        var payload: BitArray = []

        for byte in self[0..<count - 8] {
            let b = bits(fromByte: byte)
            payload.append(contentsOf: b.suffix(from: 3))
        }

        self = bitsToBytes(bits: Array(payload[8..<payload.count - 2]))
    }

    func base32StringWithChecksum(prefix: String) -> String {
        let paddedBits = bits(fromByte: 0) + bitArray + [false, false]
        let payload = bitsTo5BitSplitedData(bits: paddedBits)
        var ckData: Data = prefix.confluxBase32Data + [0]
        ckData.append(contentsOf: payload)
        ckData.append(contentsOf: [0, 0, 0, 0, 0, 0, 0, 0])
        let addr = payload.map { base32Table[$0]! }
        return addr.joined() + ckData.polyMod
    }

    private var polyMod: String {
        var c: UInt64 = 1
        for d in self {
            let c0 = c >> 35
            c = ((c & 0x07ffffffff) << 5) ^ UInt64(d)
            if (c0 & 0x01) != 0 { c ^= 0x98f2bc8e61 }
            if (c0 & 0x02) != 0 { c ^= 0x79b76d99e2 }
            if (c0 & 0x04) != 0 { c ^= 0xf33e5fb3c4 }
            if (c0 & 0x08) != 0 { c ^= 0xae2eabe2a8 }
            if (c0 & 0x10) != 0 { c ^= 0x1e4f43e470 }
        }

        c ^= 1

        var bytes = Data()
        for _ in 0..<5 {
            let n = UInt8(truncating: NSNumber(value: c))
            bytes.append(n)
            c >>= 8
        }
        bytes.reverse()

        let s = bitsTo5BitSplitedData(bits: bits(fromByte: bytes)).map { base32Table[$0]! }
        return s.joined()
    }
}
