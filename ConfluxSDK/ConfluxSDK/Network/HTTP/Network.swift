//
//  Network.swift
//  ConfluxSDK
//
//  Created by 区块链 on 2020/2/19.
//  Copyright © 2020 com.blockchain.dappbirds. All rights reserved.
//

public enum Network {
    case mainnet
    case testnet
    case `private`(chainID: Int, testUse: Bool)
    
    public init?(name: String, chainID: Int = 0, testUse: Bool = false) {
        switch name {
        case "main":
            self = .mainnet
        case "testnet":
            self = .testnet
        case "private":
            self = .private(chainID: chainID, testUse: testUse)
        default:
            return nil
        }
    }
    
    public var coinType: UInt32 {
        let mainnetCoinType = UInt32(60)
        let testnetCoinType = UInt32(1)
        
        switch self {
        case .mainnet:
            return mainnetCoinType
        case .testnet:
            return testnetCoinType
        case .private(_, let testUse):
            return testUse ? testnetCoinType : mainnetCoinType
        }
    }
    
    public var privateKeyPrefix: UInt32 {
        let mainnetPrefix: UInt32 = 0x0488ade4
        let testnetPrefix: UInt32 = 0x04358394
        
        switch self {
        case .mainnet:
            return mainnetPrefix
        case .testnet:
            return testnetPrefix
        case .private(_, let testUse):
            return testUse ? testnetPrefix : mainnetPrefix
        }
    }
    
    public var publicKeyPrefix: UInt32 {
        let mainnetPrefix: UInt32 = 0x0488b21e
        let testnetPrefix: UInt32 = 0x043587cf
        
        switch self {
        case .mainnet:
            return mainnetPrefix
        case .testnet:
            return testnetPrefix
        case .private(_, let testUse):
            return testUse ? testnetPrefix : mainnetPrefix
        }
    }
    
    public var name: String {
        switch self {
        case .mainnet:
            return "Mainnet"
        case .testnet:
            return "Testnet"
        case .private(_, _):
            return "Privatenet"
        }
    }
    
    public var chainID: Int {
        switch self {
        case .mainnet:
            return 1
        case .testnet:
            return 0
        case .private(let chainID, _):
            return chainID
        }
    }
}

extension Network: Equatable {
    public static func == (lhs: Network, rhs: Network) -> Bool {
        switch (lhs, rhs) {
        case (.mainnet, .mainnet), (.testnet, .testnet):
            return true
        case (.private(let firstChainID, let firstTestUse), .private(let secondChainID, let secondTestUse)):
            return firstChainID == secondChainID && firstTestUse == secondTestUse
        default:
            return false
        }
    }
}
