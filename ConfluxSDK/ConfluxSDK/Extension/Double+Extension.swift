//
//  Double+Extension.swift
//  ConfluxSDK
//
//  Created by R0uter on 12/23/20.
//  Copyright © 2020 com.blockchain.dappbirds. All rights reserved.
//

import Foundation
extension Double {
    public func dripInCFX() ->Drip {
        return dripIn(decimals: 18)
    }
    
    public func dripIn(decimals:Int) ->Drip {
        let powCustome = pow(BDouble(10), decimals)
        return (BDouble(self) * powCustome).rounded()
    }
}
