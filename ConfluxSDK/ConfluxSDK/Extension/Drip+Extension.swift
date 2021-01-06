//
//  Drip+Extension.swift
//  ConfluxSDK
//
//  Created by R0uter on 12/30/20.
//  Copyright © 2020 com.blockchain.dappbirds. All rights reserved.
//

import Foundation
extension Drip {
    public func gDripInCFX() ->Double {
        return gDripIn(decimals: 18)
    }
    
    public func gDripIn(decimals:Int) ->Double {
        let powCustome = Drip(10) ** decimals
        let g = BDouble(self) / BDouble(powCustome)
        return Double(g.decimalDescription)!
    }
}
