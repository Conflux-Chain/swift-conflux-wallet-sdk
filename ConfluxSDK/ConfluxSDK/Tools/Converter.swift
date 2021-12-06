//
//  Converter.swift
//  ConfluxSDK
//
//  Created by 区块链 on 2020/2/19.
//  Copyright © 2020 com.blockchain.dappbirds. All rights reserved.
//

public typealias Conflux = Decimal
public typealias Drip = BInt

public extension Drip {
    init?(dripHexStr n:String) {
        self.init(n.lowercased().cfxStripHexPrefix(), radix: 16)
    }
}

@objc public final class Converter : NSObject {
    // NOTE: calculate drip by 10^18
    private static let confluxInDrip = pow(Decimal(10), 18)
    
    
    public static func convert(oldAddress:String) ->ConfluxAddress? {
        guard let data = Data(hexString: oldAddress), ConfluxAddress.isValid(data: data) else {
            return nil
        }
        return ConfluxAddress(data: data)
    }
    /// Convert Drip(BInt) unit to Conflux(Decimal) unit
    public static func toConflux(drip: Drip) throws -> Conflux {
        guard let decimalDrip = Decimal(string: drip.description) else {
            throw ConfluxError.convertError(.failedToConvert(drip.description))
        }
        return decimalDrip / confluxInDrip
    }
    
    /// Convert Conflux(Decimal) unit to Drip(BInt) unit
    public static func toDrip(cfx: Conflux) throws -> Drip {
        guard let drip = Drip((cfx * confluxInDrip).description) else {
            throw ConfluxError.convertError(.failedToConvert(cfx * confluxInDrip))
        }
        return drip
    }
    
    /// Convert Conflux(String) unit to Drip(BInt) unit
    public static func toDrip(cfx: String) throws -> Drip {
        guard let decimalConflux = Decimal(string: cfx) else {
            throw ConfluxError.convertError(.failedToConvert(cfx))
        }
        return try toDrip(cfx: decimalConflux)
    }
    
    /// Only used for calcurating gas price and gas limit
    public static func toDrip(Gdrip: Int) -> Int {
        return Gdrip * 1000000000
    }
    
    public static func toGdrip(drip: Int) -> Int {
        return drip / 1000000000
    }
    
    public static func dripToStrWithDecimal(drip: BInt, decimal: Int) throws -> String {
        guard let decimalDrip = Decimal(string: drip.description) else {
            throw ConfluxError.convertError(.failedToConvert(drip.description))
        }
        let result = decimalDrip / pow(Decimal(10), decimal)
        return "\(result)"
    }
    
    
    @objc public static func hexDripToCfx(hexDrip: String, decimal: Int = 18) throws -> String {
        guard let drip = BInt(hexDrip) else {
            throw ConfluxError.convertError(.failedToConvert(hexDrip))
        }
        guard let result = try? self.dripToStrWithDecimal(drip: drip, decimal: decimal) else {
            throw ConfluxError.convertError(.failedToConvert(drip))
        }
        return result
    }
    
    @objc public static func dripToCfxStr(drip: Int) -> String {
        let decimal = Decimal(drip)
        let result = decimal / confluxInDrip
        return "\(result)"
    }
    
    @objc public static func GdripToCfxStr(Gdrip: Int) -> String {
        let decimal = Decimal(Gdrip)
        let result = decimal / pow(Decimal(10), 9)
        return "\(result)"
    }
    
    @objc public static func cfxStrToDrip(cfx: String) -> String? {
        guard let decimalConflux = Decimal(string: cfx) else {
            return nil
        }
        do {
            let result = BInt(try toDrip(cfx: decimalConflux))
            return "\(result)"
        } catch {
            return nil
        }
    }

}
