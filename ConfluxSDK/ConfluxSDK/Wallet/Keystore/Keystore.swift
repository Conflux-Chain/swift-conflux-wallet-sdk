//
//  Keystore.swift
//  EthereumKitSwift
//
//  Created by Dmitriy Karachentsov on 30/8/18.
//

public final class Keystore: Decodable {
    
    public var version: Int
    public var identifier: String
    public var address: String?
    private var crypto: KeystoreCrypto
    
    enum KeystoreError: Error {
        case cryptoNotFound
    }
    
    private enum CodingKeys: String, CodingKey {
        case version
        case identifier = "id"
        case address
        case crypto
        case Crypto
    }
    
    public static func keystore(url: URL) throws -> Keystore {
        let data = try Data(contentsOf: url)
        return try keystore(rawData: data)
    }
    
    public static func keystore(rawData data: Data) throws -> Keystore {
        let decoder = JSONDecoder()
        let keystore = try decoder.decode(Keystore.self, from: data)
        return keystore
    }
    
    public init(privateKey: Data, passphrase: String) throws {
        let password = passphrase.toData()
        crypto = try Keystore.crypto(
            fromPrivateKey: privateKey,
            password: password)
        let key = PrivateKey(raw: privateKey)
        let publicKey = key.publicKey
        address = publicKey.address()
        let uuid = UUID()
        identifier = uuid.uuidString.lowercased()
        version = 3
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        guard let crypto =
            (try? container.decode(KeystoreCrypto.self, forKey: .Crypto)) ??
            (try? container.decode(KeystoreCrypto.self, forKey: .crypto)) else {
                throw KeystoreError.cryptoNotFound
        }
        self.crypto = crypto
        address = try? container.decode(String.self, forKey: .address)
        identifier = try container.decode(String.self, forKey: .identifier)
        version = try container.decode(Int.self, forKey: .version)
    }
    
    public class func create(
        network: Network = .mainnet,
        mnemonic: [String] = Mnemonic.create(),
        passphrase: String) throws -> Keystore {
        let seed = try! Mnemonic.createSeed(mnemonic: mnemonic)
        let wallet = try! Wallet.init(seed: seed, network: network, printDebugLog: true)
        let privateKey = wallet.privateKey()
        return try Keystore(
            privateKey: privateKey,
            passphrase: passphrase)
    }
    
    public func privateKey(passphrase: String) throws -> PrivateKey {
        let password = passphrase.toData()
        let data = try crypto.privateKey(password: password)
        return PrivateKey(raw: data)
    }
    
    public func raw() throws -> Data {
        let encoder = JSONEncoder()
        let data = try encoder.encode(self)
        return data
    }
    
    private static func crypto(
        fromPrivateKey privateKey: Data,
        password: Data)
        throws -> KeystoreCrypto {
        return try KeystoreCrypto(
            privateKey: privateKey,
            password: password)
    }
    
}

extension Keystore: Encodable {

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(crypto, forKey: .Crypto)
        try container.encodeIfPresent(address, forKey: .address)
        try container.encode(identifier, forKey: .identifier)
        try container.encode(version, forKey: .version)
    }
    
}

