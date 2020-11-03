//
//  Method.swift
//  ConfluxSDK
//
//  Created by 区块链 on 2020/2/18.
//  Copyright © 2020 com.blockchain.dappbirds. All rights reserved.
//


public enum Method: String {
    case get
    case post
    
    public var prefersQueryParameters: Bool {
        switch self {
        case .get:
            return true
        case .post:
            return false
        }
    }
}
