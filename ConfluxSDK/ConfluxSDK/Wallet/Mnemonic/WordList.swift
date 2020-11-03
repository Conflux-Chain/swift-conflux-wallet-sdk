//
//  WordList.swift
//  ConfluxSDK
//
//  Created by 区块链 on 2020/2/20.
//  Copyright © 2020 com.blockchain.dappbirds. All rights reserved.
//

import Foundation

public enum WordList {
    case english
    
    public var words: [String] {
        switch self {
        case .english:
            return englishWords
        }
    }
}
