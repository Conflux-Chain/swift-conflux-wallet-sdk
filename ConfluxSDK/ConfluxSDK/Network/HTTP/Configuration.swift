//
//  Configuration.swift
//  ConfluxSDK
//
//  Created by 区块链 on 2020/2/19.
//  Copyright © 2020 com.blockchain.dappbirds. All rights reserved.
//

/// Configuration has necessary information to use in Gcfx network
public struct Configuration {
    
    /// represents which network to use
    public let network: Network
    
    /// represents an endpoint of Conflux node to connect to
    public let nodeEndpoint: String
    
    /// represents whether to print debug logs in console
    public let debugPrints: Bool
    
    public init(network: Network, nodeEndpoint: String, debugPrints: Bool) {
        self.network = network
        self.nodeEndpoint = nodeEndpoint
        self.debugPrints = debugPrints
    }
    
    /// reprensets an confluxscan url based on which network to use
//    public var confluxscanURL: URL {
//        switch network {
//        case .mainnet:
//            return URL(string: "")!
//
//        case .testnet:
//            return URL(string: "https://wallet.confluxscan.io/api")!
//
//        case .private:
//            // NOTE: does not get any transactions because of private network.
//            return URL(string: "")!
//        }
//    }
}
