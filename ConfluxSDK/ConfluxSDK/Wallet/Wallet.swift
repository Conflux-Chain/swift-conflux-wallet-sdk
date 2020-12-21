//
//  Wallet.swift
//  ConfluxSDK
//
//  Created by 区块链 on 2020/2/20.
//  Copyright © 2020 com.blockchain.dappbirds. All rights reserved.
//

/// Wallet handles all the logic necessary for storing keys

final public class Wallet {
    
    /// Network which this wallet is connecting to
    /// Basiclly Mainnet or Ropsten
    private let network: Network
    
    private let key: PrivateKey
    
    private let printDebugLog: Bool
    
    public init(seed: Data, network: Network, printDebugLog: Bool) throws {
        self.network = network
        self.printDebugLog = printDebugLog
        
        // m/44'/coin_type'/0'/external
        let externalPrivateKey = try HDPrivateKey(seed: seed, network: network)
            .derived(at: 44, hardens: true)
            .derived(at:503, hardens: true)// network.coinType
            .derived(at: 0, hardens: true)
            .derived(at: 0)
        
        key = try externalPrivateKey.derived(at: 0).privateKey()
        
        if printDebugLog {
            printDebugInformation()
        }
    }
    
    public init(network: Network, privateKey: String, printDebugLog: Bool) throws {
        self.network = network
        self.key = PrivateKey(raw: Data(hex: privateKey))
        self.printDebugLog = printDebugLog
        if printDebugLog {
            printDebugInformation()
        }
    }
    
    /// Generate a hash for eth_personal_sign
    ///
    /// - Parameter hex: message in hex format
    /// - Returns: hash of a message
    private func generatePersonalMessageHash(hex: String) -> Data {
        let prefix = "\u{19}Ethereum Signed Message:\n"
        let messageData = Data(hex: hex.cfxStripHexPrefix())
        let prefixData = (prefix + String(messageData.count)).data(using: .ascii)!
        return Crypto.hashSHA3_256(prefixData + messageData)
    }
    
    
    private func printDebugInformation() {
        print(
            """
            \nUsing \(network) network
            PrivateKey is \(privateKey().toHexString())
            PublicKey is \(publicKey().toHexString())
            Address is \(address()) \n
            """
        )
    }
}

// MARK :- Conflux Keys {
extension Wallet {
    /// Generates address from main private key.
    ///
    /// - Returns: Address in string format
    public func address() -> String {
        return key.publicKey.address()
    }
    
    /// Reveal private key of this wallet in data format
    ///
    /// - Returns: Private key in data format
    public func privateKey() -> Data {
        return key.raw
    }
    
    /// Reveal public key of this wallet in data format
    ///
    /// - Returns: Public key in data format
    public func publicKey() -> Data {
        return key.publicKey.raw
    }
}

// MARK: - Conflux Sign Transaction
extension Wallet {
    public func sign(rawTransaction: RawTransaction) throws -> String {
        let singer = EIP155Signer(chainID: network.chainID)
        let rawData = try singer.sign(rawTransaction, privateKey: key)
        
        let hash = "0x" +  rawData.toHexString()
        if printDebugLog {
            print(
                """
                \nSigning \(rawTransaction)
                Raw tx hash is \(hash) \n
                """
            )
        }
        return hash
    }
}

// MARK:- Conflux sign message
extension Wallet {
    /// Sign hex message
    public func sign(hex: String) throws -> String {
        let hash = Crypto.hashSHA3_256(Data(hex: hex.cfxStripHexPrefix()))
        guard var signedMsg = try? key.sign(hash: hash) else {
            throw ConfluxError.cryptoError(.failedToSign)
        }
        signedMsg[64] += 27
        return "0x" + signedMsg.toHexString()
    }
    
    /// Sign message
    public func sign(message: String) throws -> String {
        return try sign(hex: message.cfxToHexString())
    }
}

// MARK :- Conflux Personal-sign message
extension Wallet {
    public func personalSign(hex: String) throws -> String {
        let hash = generatePersonalMessageHash(hex: hex)
        var signature = try key.sign(hash: hash)
        signature[64] += 27
        let signedHash = "0x" + signature.toHexString()
        if printDebugLog {
            print(
                """
                \nSigning \(hex)
                Message hash is \(signedHash) \n
                """
            )
        }
        return signedHash
    }
    
    public func personalSign(message: String) throws -> String {
        return try personalSign(hex: message.cfxToHexString())
    }
}

// MARK: - Conflux Validate signature
extension Wallet {
    /// Verify a personal_signed signature
    ///
    /// - Parameters:
    ///   - signature: signature in string format, must be signed with eth_personal_sign
    ///   - message: message you signed
    ///   - compressed: whether a public key is compressed
    /// - Returns: whether a signature is valid or not
    public func vertify(personalSigned signature: String, message: String, compressed: Bool = false) -> Bool {
        var sig = Data(hex: signature)
        if sig[64] != 27 && sig[64] != 28 {
            fatalError()
        }
        
        sig[64] = sig[64] - 27
        let hash = generatePersonalMessageHash(hex: message.cfxToHexString())
        return verifySignature(signature: sig, hash: hash, compressed: compressed)
    }
    
    /// Verify a signature
    ///
    /// - Parameters:
    ///   - signature: signature in data format
    ///   - hash: hash of an message you signed
    ///   - compressed: whether a public key is compressed
    /// - Returns: whether a signature is valid or not
    public func verify(normalSigned signature: String, message: String, compressed: Bool = false) -> Bool {
        let hash = Crypto.hashSHA3_256(Data(hex: message.cfxToHexString().cfxStripHexPrefix()))
        return verifySignature(signature: Data(hex: signature), hash: hash, compressed: compressed)
    }
    
    private func verifySignature(signature: Data, hash: Data, compressed: Bool) -> Bool {
        return Crypto.isValid(signature: signature, of: hash, publicKey: publicKey(), compressed: compressed)
    }
}



@objc public class ConfluxWalletManager: NSObject {
    var isMainNet: Bool = true
    
    var nodeEndpoint = "https://wallet.confluxscan.io/api/"
    
    var network: Network
    
    @objc public init(netName: String, chainId: Int, nodePoint: String, isDebug: Bool) {
        self.network = Network.init(name: netName, chainID: chainId, testUse: isDebug) ?? Network.mainnet
        self.isMainNet = !isDebug
        self.nodeEndpoint = nodePoint
    }
    
    @objc public func creatNewMnemonicArr(isNormal: Bool) -> [String] {
        return Mnemonic.create(strength: isNormal ? .normal : .height)
    }
    
    @objc public func createSeed(mnemonicArr: [String]) -> Data? {
        return try? Mnemonic.createSeed(mnemonic: mnemonicArr)
    }
    
    /// 使用 seed 创建钱包
    /// - Parameters:
    ///   - seed: 种子
    ///   - completion: 回调， 是否成功，钱包地址，用户私钥
    /// - Returns: void
    @objc public func creatWalletBy(by seed: Data, completion:@escaping (_ success: Bool, _ address:String?, _ PrivateKey: String?) -> ()) {
        guard let cfxWallet = try? Wallet.init(seed: seed, network: self.network, printDebugLog: true) else {
            completion(false, nil, nil)
            return
        }
        completion(true, cfxWallet.address(), cfxWallet.privateKey().toHexString())
    }
    
    @objc public func importWallet(by privateKey: String, completion:@escaping (_ success: Bool, _ address:String?, _ PrivateKey: String?) -> ()) {
        guard let cfxWallet = try? Wallet.init(network: self.network, privateKey: privateKey, printDebugLog: true) else {
            completion(false, nil, nil)
            return
        }
        completion(true, cfxWallet.address(), cfxWallet.privateKey().toHexString())
    }
    
    @objc public func getBalance(privateKey: String, completion:@escaping (_ success: Bool, _ balance:String?) -> ()) {
        guard let cfxWallet = try? Wallet.init(network: self.network, privateKey: privateKey, printDebugLog: !isMainNet) else {
            completion(false, nil)
            return
        }
        self.getGcfx().getBalance(of: cfxWallet.address()) { (result) in
            switch result {
            case .success(let balance):
                if let formatBalance = try? balance.conflux() {
                    completion(true, "\(formatBalance)")
                    return
                }
            case .failure(_):
                completion(false, "request failure")
                break
            }
            completion(false, nil)
        }
    }
    
    private func getGcfx() -> Gcfx {
        let configuration = ConfluxSDK.Configuration(network: self.network, nodeEndpoint: self.nodeEndpoint, debugPrints: !isMainNet)
        return Gcfx(configuration: configuration)
    }

    /// 给其他用户转账 CFX
    /// - Parameters:
    ///   - privateKey: 用户的私钥
    ///   - toAddress: 目标地址
    ///   - sendValue: 要发送的金额
    ///   - gasPrice: gas 单位 Drip
    ///   - gasLimit: gas limit 单位 Drip
    ///   - completion: 发送是否成功，如果成功则返回交易hash，如果失败则返回原因
    /// - Returns: 无
    @objc public func sendCfxToAddress(privateKey: String, toAddress: String, sendValue: String, gasPrice: Int, gasLimit: Int, completion:@escaping (_ success: Bool, _ hash:String?, _ msg: String?) -> ()) {
        guard let cfxWellet = try? Wallet.init(network: self.network, privateKey: privateKey, printDebugLog: !isMainNet) else {
            completion(false, nil, "creat wallet failiure")
            return
        }
        guard let sendValueIntDrip = try? Converter.toDrip(cfx: sendValue) else {
            completion(false, nil, "Converter toDrip failiure")
            return
        }
        self.getGcfx().getNextNonce(of: cfxWellet.address()) { [weak self] (result) in
            guard let storageSelf = self else { return }
            switch result {
            case .success(let nonce):
                let hexSendValue = (try? Converter.toDrip(cfx: sendValue).hexStringWithPrefix) ?? "0x0"
                // let hexFullGasPrice = Converter.toDrip(Gdrip: gasPrice)
                storageSelf.getGcfx().getEstimateGas(from: cfxWellet.address(), to: toAddress, gasPrice: gasPrice.hexStringWithPrefix, value: hexSendValue, nonce: nonce.hexStringWithPrefix) { (result) in
                    switch result {
                    case .success(let res):
                        // let gasUsed = res.gasUsed
                        let storageLimit = res.storageCollateralized
                        storageSelf.getGcfx().getEpochNumber { (result) in
                            switch result {
                            case .success(let epochHeight):
                                let rawTransaction = ConfluxSDK.RawTransaction.init(value: sendValueIntDrip, to: toAddress, gasPrice: gasPrice, gasLimit: gasLimit, nonce: nonce, storageLimit: storageLimit, epochHeight: Drip(epochHeight), chainId: storageSelf.network.chainID)
                                guard let transactionHash = try? cfxWellet.sign(rawTransaction: rawTransaction) else {
                                    print(" sign transaction failure")
                                    return
                                }
                                storageSelf.getGcfx().sendRawTransaction(rawTransaction: transactionHash) { (result) in
                                    switch result {
                                    case .success(let hash):
                                        completion(true, hash.id, nil)
                                    case .failure(_):
                                        completion(false, nil, "send transaction failure")
                                    }
                                }
                                
                            case .failure(let error):
                                completion(false, nil, "getEpochNumber failure")
                            }
                        }
                    case .failure(let error):
                        completion(false, nil, "getEstimateGas failure")
                    }
                }
            case .failure(_):
                completion(false, nil, "GetNextNonce failure")
            }
        }
    }
    
    @objc public func getGasPrice(completion:@escaping (_ success: Bool, _ gasPrice: NSNumber?, _ msg: String?) -> ()) {
        self.getGcfx().getGasPrice { (result) in
            switch result {
            case .success(let resultDirp):
                let reultGdrip = Converter.toGdrip(drip:Int(resultDirp))
                completion(true, reultGdrip as NSNumber, "gasPrice in Gdrip is \(reultGdrip)")
            case .failure(_):
                completion(false, nil, "getGasPrice failure")
            }
        }
    }
        
    @objc public func getNextNonce(fromAddress: String, completion:@escaping (_ success: Bool, _ gasPrice: NSNumber?, _ msg: String?) -> ()) {
        self.getGcfx().getNextNonce(of: fromAddress, completionHandler: { (result) in
            switch result {
            case .success(let nonce):
                completion(true, nonce as NSNumber, nil)
            case .failure(_):
                completion(false, nil, "GetNextNonce failure")
            }
        })
    }
    
    @objc public func getEstimateGas(fromAddress: String, toAddress: String, sendValue: String, gasPrice: Int,  completion:@escaping (_ success: Bool, _ gasUsed: String?, _ storageCollateralized: String?, _ msg: String?) -> ()) {
        self.getGcfx().getNextNonce(of: fromAddress, completionHandler: { [weak self] (result) in
            guard let storageSelf = self else { return }
            switch result {
            case .success(let nonce):
                let formatSendValue = try! Converter.toDrip(cfx: sendValue).hexStringWithPrefix
                let formatGasPrice = gasPrice.hexStringWithPrefix
                let hexNonce = nonce.hexStringWithPrefix
                storageSelf.getGcfx().getEstimateGas(from: fromAddress, to: toAddress, gasPrice: formatGasPrice, value: formatSendValue, nonce: hexNonce) { (result) in
                    switch result {
                    case .success(let resultTruple):
                        let gasUsed = resultTruple.gasUsed
                        let storageCollateralized = resultTruple.storageCollateralized
                        completion(true, "\(gasUsed)", "\(storageCollateralized)",nil)
                    case .failure(let error):
                        print(error)
                        completion(false, nil, nil, nil)
                    }
                }
            case .failure(_):
                completion(false, nil, "GetNextNonce failure", nil)
            }
        })
    }
    
    @objc public func getTokenBalance(address: String, contractAdress: String, decimal: Int, completion: @escaping (_ success: Bool, _ balance: String?, _ msg: String?) -> ()) {
        let dataHex = "0x" + ConfluxToken.ContractFunctions.balanceOf(address: address).data.toHexString()
        self.getGcfx().call(to: contractAdress, data: dataHex) { (result) in
            switch result {
            case .success(let hexBalance):
                if let result = try? Converter.hexDripToCfx(hexDrip: hexBalance, decimal: decimal) {
                    completion(true, result, nil)
                } else {
                    completion(false, nil, "hexBalance convert failure")
                }
            case .failure(_):
                completion(false, nil, "getTokenBalance failure")
            }
        }
    }
    
    @objc public func getTokenDecimal(contractAdress: String, completion: @escaping (_ success: Bool, _ decimal: String?, _ msg: String?) -> ()) {
        let data = "0x" + ConfluxToken.ContractFunctions.decimals.data.toHexString()
        self.getGcfx().call(to: contractAdress, data: data) { (result) in
            switch result {
            case .success(let decimalHex):
                if let decimal = Drip(decimalHex.lowercased().cfxStripHexPrefix(), radix: 16) {
                    completion(true, "\(decimal)", nil)
                } else {
                    completion(false, nil, "Parsing failed")
                }
            case .failure(_):
                completion(false, nil, "getTokenDecimal failed")
            }
        }
    }
    
    /// 给合约币转账
    /// - Parameters:
    ///   - privateKeyStr: 当前用户私钥
    ///   - contractAddress: 合约地址
    ///   - toAddress: 目标用户地址
    ///   - gasPrice: gas 单位 Drip
    ///   - gasLimit: gas limit 单位 Drip
    ///   - sendValue: 发送的金额 对应币单位，会自动根据decimal换算成 Drip 的
    ///   - decimal: 合约的 decimal
    ///   - completion: 发送是否成功，如果成功则返回交易hash，如果失败则返回原因
    /// - Returns: 无
    @objc public func sendToken(privateKeyStr: String, contractAddress: String, toAddress: String, gasPrice: Int, gasLimit: Int, sendValue: String, decimal: Int, completion:@escaping (_ success: Bool, _ hash:String?, _ msg: String?) -> ()) {
//        let sendValue = BInt(Double(0.0) * pow(10, Double(decimal)))
        let powCustome = pow(Decimal(10), decimal)
        guard let decimalConflux = Decimal(string: sendValue),
              let formatSendValue = Drip((decimalConflux * powCustome).description)
        else {
            completion(false, nil, "value trans failiure")
            return
        }
        let data = ConfluxToken.ContractFunctions.transfer(address: toAddress, amount: formatSendValue).data
        
        guard let cfxWellet = try? Wallet.init(network: self.network, privateKey: privateKeyStr, printDebugLog: !isMainNet) else {
            completion(false, nil, "creat wallet failiure")
            return
        }
        self.getGcfx().getNextNonce(of: cfxWellet.address()) { [weak self] (result) in
            guard let storageSelf = self else { return }
            switch result {
            case .success(let nonce):
                storageSelf.getGcfx().getEstimateGas(from: cfxWellet.address(), to: contractAddress, gasPrice: gasPrice.hexStringWithPrefix, value: "0x0", data: "0x" + data.hexString, nonce: nonce.hexStringWithPrefix) { (result) in
                    switch result {
                    case .success(let res):
                        let storageLimit = res.storageCollateralized
                        let gasLimit = res.gasLimit.asInt()!
                        storageSelf.getGcfx().getEpochNumber { (result) in
                            switch result {
                            case .success(let epochHeight):
                                let chainId = storageSelf.getGcfx().chainId
                                let rawTransaction = ConfluxSDK.RawTransaction.init(drip: "0", to: contractAddress, gasPrice: gasPrice, gasLimit: gasLimit, nonce: nonce, data: data, storageLimit: storageLimit, epochHeight: Drip(epochHeight), chainId: chainId)
                                guard let transactionHash = try? cfxWellet.sign(rawTransaction: rawTransaction) else {
                                    completion(false, nil, "sign transaction failure")
                                    return
                                }
                                storageSelf.getGcfx().sendRawTransaction(rawTransaction: transactionHash) { (result) in
                                    switch result {
                                    case .success(let hash):
                                        completion(true, hash.id, nil)
                                    case .failure(let e):
                                        print(e)
                                        completion(false, nil, "send transaction failure")
                                    }
                                }
                                
                            case .failure(_):
                                completion(false, nil, "getEpochNumber failed")
                            }
                        }
                    case .failure(let error):
                        completion(false, nil, "getEstimateGas failed")
                    }
                }
            case .failure(_):
                completion(false, nil, "GetNextNonce failure")
            }
        }
    }
    
    @objc public func signMessage(privateKeyStr:String, msg: String) -> String? {
        guard let cfxWellet = try? Wallet.init(network: self.network, privateKey: privateKeyStr, printDebugLog: true) else {
            return nil
        }
        if msg.hasPrefix("0x") {
            guard let signedMsg = try? cfxWellet.sign(hex: msg) else {
                return nil
            }
            return signedMsg
        } else {
            guard let signedMsg = try? cfxWellet.sign(message: msg) else {
                return nil
            }
            return signedMsg
        }
    }
    
    @objc public func signTypedMessage(privateKeyStr: String, jsonString: String, completion:@escaping (_ success: Bool, _ signedStr: String?, _ msg: String?) -> ()) {
        let data = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        
        guard let cfxWellet = try? Wallet.init(network: self.network, privateKey: privateKeyStr, printDebugLog: true) else {
            return completion(false, nil, "get wallet Failure")
        }
        
        guard let typedData = try? decoder.decode(EIP712TypedData.self, from: data) else {
            completion(false, nil, "trans to EIP712TypedData Failure")
            return
        }
        guard let resultStr = try? cfxWellet.sign(hex: typedData.signHash.hexString) else {
            completion(false, nil, "sign msg failure")
            return
        }
        completion(true, resultStr, nil)
    }
    
    @objc public func signPersonalMessage(privateKeyStr:String, msg: String) -> String? {
        guard let cfxWellet = try? Wallet.init(network: self.network, privateKey: privateKeyStr, printDebugLog: true) else {
            return nil
        }
        if msg.hasPrefix("0x") {
            return try? cfxWellet.personalSign(hex: msg)
        } else {
            return try? cfxWellet.personalSign(message: msg)
        }
    }
    
    @objc public func getEpochNumber(completion:@escaping (_ success: Bool, _ epochHeight:NSNumber?) -> ()) {
        self.getGcfx().getEpochNumber { (result) in
            switch result {
            case .success(let epochHeight):
                completion(true, epochHeight as? NSNumber)
            case .failure(let error):
                completion(false, nil)
            }
        }
    }
    
    @objc public func getPrivateKeyByKeystore(keystoreJson: String, password: String) -> String? {
        guard let keystore = try? Keystore.keystore(rawData: keystoreJson.data(using: .utf8) ?? Data.init()) else {
            print("generate keystore failed")
            return nil
        }
        let privateKey = try? keystore.privateKey(passphrase: password)
        let privateKeyStr = privateKey?.raw.hexString
        return privateKeyStr
    }
    
}
