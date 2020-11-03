//
//  Result.swift
//  ConfluxSDK
//
//  Created by 区块链 on 2020/2/18.
//  Copyright © 2020 com.blockchain.dappbirds. All rights reserved.
//

public enum Result<Object> {
    case success(Object)
    case failure(ConfluxError)
    
    /// For debug
    public var description: String {
        switch self {
        case .success(let object):
            return "success \(object)"
        case .failure(let error):
            return "failed \(error)"
        }
    }
}
