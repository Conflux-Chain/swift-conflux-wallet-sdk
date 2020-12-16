//
//  ViewController.swift
//  ConfluxSwiftTest
//
//  Created by 区块链 on 2020/2/18.
//  Copyright © 2020 com.blockchain.dappbirds. All rights reserved.
//

import UIKit
import ConfluxSDK

class ViewController: UIViewController {
    
    let privateKeyStr = "8DC44AC70E9AED9991ED441945F3FEA29AA9015C5ED2629181EE388C502F473C"  // 52121b96e4129cc979b41f5105934e49b104b1da4f74793162478fec76e86df0
    let fromAddress = "0x1cAf3Ef2F05BD59350297eE43aE8b31e19478C33"
    let toAddress = "0x1e01c8ED8006E11f942e16C9f5022dfCe2CDe121"
    
    let FCContractAddress = "0x85b693011c05197f4acbb4246830be8fbd4e904f"
    let fcAddress = "0x1e01c8ED8006E11f942e16C9f5022dfCe2CDe121" // "0x1E9Df1b31c720C893C651de98caDCA6959015496"
    let fcPrivateKey = "52121b96e4129cc979b41f5105934e49b104b1da4f74793162478fec76e86df0" // "dd7e6331983d72b65d0e93849ec531b453a18a898d9e8bb397eba86e7f377036"
    let o = ConfluxWalletManager(netName: "main", chainId: 1029, nodePoint: "http://test.confluxrpc.org", isDebug: false)
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.lightGray
        
        // 1. create new walet
        // self.testCreatNewWallet()
        
        // 2. import wallet by privateKey
        // self.importWallet()
        
        // 3. get balance
        // self.getBalance(privateKey: privateKeyStr)
        
        // 4. send Cfx
//         self.sendCfxToAddress()
        self.sendRedPacketToken()
//        self.sendCFXRedpacket()
        
        // 5. get gasPrice
        // self.getGasPrice()
        
        // 6. get EstimateGas
        // self.getEstimateGas()
        
        // 7. get token balance
//        self.getTokenBalance(of: self.fcAddress)
//        self.getTokenBalance(of: self.fromAddress)
        
        // 8. get TokenDecimal
        // self.getTokenDecimal()
        
        // 9. sendToken
//         self.sendToken()
        
        // 10. signMsg
        // signMessage(msg: "0x5feb31c03d814f8D317aeB78510a6846B2a019c9")
        
        // 11. signTypedMessage
        // self.signTypedMessage()
        
        // 12. signPersonalMessage
        // self.signPersonalMessage(msg: "message")
    func printError(e:ConfluxError) {
        switch e {
            case .responseError(let e):
                switch e {
                    case .unexpected(let e):
                    
                        switch e as! ConfluxError {
                            case .responseError(let e):
                                switch e {
                                    case .jsonrpcError(let e):
                                    switch e {
                                        case .responseError(let code, let message, let data):
                                            let s = data as? String ?? "nil"
                                            if let d = Data(hexString: s) {
                                                print(code, message, String(data: d, encoding: .utf8) ?? s)
                                            } else {
                                                print(code, message, s)
                                            }
                                            
                                        default:break
                                    }
                                    default:break
                                }
                        default:
                            break
                    }
                    default:
                        break
                }
            
            
            default:
                print(e)
        }
    }
    func sendCFXRedpacket() {
        guard let cfxWellet = self.importWallet() else {
            print( "creat wallet failiure")
            return
        }
        let sendValue = "8"
        let fromAddress = cfxWellet.address()
        guard let sendValueIntDrip = try? Converter.toDrip(cfx: sendValue) else {
            print( "Converter toDrip failiure")
            return
        }
        
        let data =  ConfluxToken.ContractFunctions.redpacketCFX(mode: 0, groupId: 123123123, number: 3, whiteCount: 10, rootHash: "0x"+"fdsdferewddesffedrdssddedrffdddd".data(using: .utf8)!.hexString, msg: "ddd").data
        let dataString = "0x" + data.hexString
        
        self.getGcfx().getNextNonce(of: cfxWellet.address()) { [weak self] (result) in
            guard let storageSelf = self else { return }
            switch result {
            case .success(let nonce):
                let hexSendValue = sendValueIntDrip.hexStringWithPrefix
                storageSelf.getGcfx().getEstimateGas(from: fromAddress, to: storageSelf.redpacketAddress, gasPrice: 1.hexStringWithPrefix, value: hexSendValue, data:dataString, nonce: nonce.hexStringWithPrefix ) { (result) in
                    switch result {
                    case .success(let res):
                        let gasLimit = res.gasLimit * 1.3
                        storageSelf.getGcfx().getEpochNumber { (result) in
                            switch result {
                            case .success(let epochHeight):
                                
                                let rawTransaction = RawTransaction( drip: sendValueIntDrip.description, to: storageSelf.redpacketAddress, gasPrice: 1, gasLimit: Int(gasLimit), nonce: nonce, data: data, storageLimit: res.storageCollateralized, epochHeight: Drip(epochHeight), chainId: 1)
                                    
                                guard let transactionHash = try? cfxWellet.sign(rawTransaction: rawTransaction) else {
                                    print(" sign transaction failure")
                                    return
                                }
                                storageSelf.getGcfx().sendRawTransaction(rawTransaction: transactionHash) { (result) in
                                    switch result {
                                    case .success(let hash):
                                        print( hash)
                                    case .failure(let e):
                                        storageSelf.printError(e: e)
                                        print( " send transaction failure")
                                    }
                                }
                                
                            case .failure(let error):
                                self!.printError(e: error)
                            }
                        }
                        
                    case .failure(let error):
                        self!.printError(e: error)
                    }
                }
            case .failure(_):
                print( "GetNextNonce failure")
            }
        }
    }
    func sendRedPacketToken() {

        let powCustome = pow(Decimal(10), 18)
        guard let decimalConflux = Decimal(string: "20") else { return  }
        let sendValue = Drip((decimalConflux * powCustome).description)!
        let data = ConfluxToken.ContractFunctions.redpacket(redpacketAddress: self.redpacketAddress, groupId: 1000, amount: sendValue, mode: 0, number: 8, whiteCount: 10, rootHash:Data(hexString: "04afe54e292938c07fdf22bfadfc44bb8d9841f15e1babe8ba2b5c0d9a9f303e")!.hexString, msg: "恭喜发财").data

        self.getGcfx().getNextNonce(of: walletAddress) { (r) in
            switch r {
                case .success(let n):
                    self.getGcfx().getEstimateGas(from: self.walletAddress, to: self.FCContractAddress, gasPrice: 1.hexStringWithPrefix, value: "0x0", data: "0x"+data.hexString, nonce: n.hexStringWithPrefix) { (r) in
                        switch r {
                            case .success( let res):
                                let gasLimit = res.gasLimit * 1.3
                                let storageLimit = res.storageCollateralized
                                self.getGcfx().getEpochNumber { (result) in
                                    switch result {
                                    case .success(let epochHeight):
                                        
                                        let rawTransaction = ConfluxSDK.RawTransaction(drip: "0", to: self.FCContractAddress, gasPrice: 1, gasLimit: Int(gasLimit), nonce: n, data: data, storageLimit: storageLimit, epochHeight: Drip(epochHeight), chainId: 1)
                                        
                                        guard let transactionHash = try? self.importWallet()!.sign(rawTransaction: rawTransaction) else {
                                            print( " sign transaction failure")
                                            return
                                        }
                                        self.getGcfx().sendRawTransaction(rawTransaction: transactionHash) { (result) in
                                            switch result {
                                            case .success(let hash):
                                                print( hash)
                                            case .failure(let e):
                                                self.printError(e: e)
                                            }
                                        }
                                        
                                    case .failure(let error):
                                        print( " getEpochNumber failure")
                                    }
                                }
                            
                            case .failure(let e):
                                self.printError(e: e)
                        }
                    }
                case .failure(let e):
                    self.printError(e: e)
            }
        }
        
    }
    
    func sendToken() {
        
        let powCustome = pow(Decimal(10), 18)
        guard let decimalConflux = Decimal(string: "20") else { return  }
        let sendValue = Drip((decimalConflux * powCustome).description)!
        print(sendValue)
        
        let receiveFCAddress = self.toAddress // 接收代币地址
        let data = ConfluxToken.ContractFunctions.transfer(address: receiveFCAddress, amount: sendValue).data
        let gasPrice = Converter.toDrip(Gdrip: 30)
        let gasLimit = 500000
        
        let network = Network.init(name: "private", chainID: 0, testUse: false)
        guard let FCWellet = try? Wallet.init(network: network ?? .testnet, privateKey: self.fcPrivateKey, printDebugLog: true) else {
            print( "creat wallet failiure")
            return
        }
        
        self.getGcfx().getNextNonce(of: FCWellet.address()) { [weak self] (result) in
            guard let storageSelf = self else { return }
            switch result {
            case .success(let nonce):
                print( nonce)
                // let sendValue = try! Converter.toDrip(cfx: "1").hexStringWithPrefix // "0xde0b6b3a7640000"
                let hexNonce = nonce.hexStringWithPrefix
                print(gasPrice.hexStringWithPrefix)
                print(data.hexString)
                storageSelf.getGcfx().getEstimateGas(from: storageSelf.fcAddress, to: storageSelf.FCContractAddress, gasPrice: gasPrice.hexStringWithPrefix, value: "0x0", data: "0x" + data.hexString, nonce: hexNonce ) { (result) in
                    switch result {
                    case .success(let res):
                        let storageLimit = res.storageCollateralized
                        print( "gasUsed is \(res.gasUsed)")
                        print( "storageCollateralized is \(res.storageCollateralized)")
                        
                        storageSelf.getGcfx().getEpochNumber { (result) in
                            switch result {
                            case .success(let epochHeight):
                                print(epochHeight)
                                let rawTransaction = ConfluxSDK.RawTransaction.init(drip: "0", to: storageSelf.FCContractAddress, gasPrice: gasPrice, gasLimit: gasLimit, nonce: nonce, data: data, storageLimit: storageLimit, epochHeight: Drip(epochHeight), chainId: 0)
                                guard let transactionHash = try? FCWellet.sign(rawTransaction: rawTransaction) else {
                                    print( " sign transaction failure")
                                    return
                                }
                                storageSelf.getGcfx().sendRawTransaction(rawTransaction: transactionHash) { (result) in
                                    switch result {
                                    case .success(let hash):
                                        print( hash)
                                    case .failure(_):
                                        print( " send transaction failure")
                                    }
                                }
                                
                            case .failure(let error):
                                print( " getEpochNumber failure")
                            }
                        }
                        
                    case .failure(let error):
                        print( " getEstimateGas failure")
                    }
                }
            case .failure(_):
                print( "GetNextNonce failure")
            }
        }
    }
    
    
        
    func testCreatNewWallet() {
        let mnemoStr = "finish oppose decorate face calm tragic certain desk hour urge dinosaur mango"
        let mnemonicArr = mnemoStr.split(separator: " ").map({ (substring) in
            return String(substring)
        })
        
//        let mnemonicArr = ["loyal","auto", "believe", "weasel", "shy", "law", "boy", "amateur", "nephew", "powder", "bulk", "furnace"]
        // Mnemonic.create(strength: .normal)
        guard let seed = try? Mnemonic.createSeed(mnemonic: mnemonicArr) else {
            print("creat seed failure")
            return
        }

        let network = Network.init(name: "private", chainID: 0, testUse: false)
        guard let cfxWallet = try? Wallet.init(seed: seed, network: network ?? .testnet, printDebugLog: true) else {
            print( "creat wallet failiure")
            return
        }

        let privateKeyStr = cfxWallet.privateKey().hexString
        let address = cfxWallet.address()

        var mnemonicStr = ""
        mnemonicArr.forEach { (subString) in
            mnemonicStr += subString + " "
        }
        mnemonicStr = mnemonicStr.trimmingCharacters(in: NSCharacterSet.whitespaces)

        print( privateKeyStr)
        print( mnemonicStr)
        print( address)
    }
    
    func importWallet() -> Wallet? {
        let network = Network.init(name: "private", chainID: 0, testUse: false)
        guard let cfxWellet = try? Wallet.init(network: network ?? .testnet, privateKey: self.privateKeyStr, printDebugLog: true) else {
            print( "creat wallet failiure")
            return nil
        }
        print( cfxWellet.address())
        return cfxWellet
    }
    
    func getGcfx() -> Gcfx {
         let network = Network.init(name: "private", chainID: 0, testUse: false)
        let configuration = ConfluxSDK.Configuration(network: network ?? .testnet, nodeEndpoint: "http://testnet-jsonrpc.conflux-chain.org:12537", debugPrints: true)
        return Gcfx(configuration: configuration)
    }
    
    func getBalance(privateKey: String) {
        guard let cfxWellet = self.importWallet() else {
            print( "creat wallet failiure")
            return
        }
        self.getGcfx().getBalance(of: cfxWellet.address()) { (result) in
            switch result {
            case .success(let balance):
                let formatBalance = try? balance.conflux()
                print( formatBalance!)
            case .failure(let error):
                print( error)
            }
        }
    }
    
    func sendCfxToAddress() {
        // 0x1cAF3eF2F05bd59350297Ee43Ae8B31e19478C33
        guard let cfxWellet = self.importWallet() else {
            print( "creat wallet failiure")
            return
        }
        let sendValue = "1" // send 1 cfx to "0x63428378C5D7d168c9Ef2809a76812d40E018Ac9"
        let fromAddress = cfxWellet.address()
        let gasPrice = Converter.toDrip(Gdrip: 20) // "0x2540be400"
        let gasLimit = 50000
        
        guard let sendValueIntDrip = try? Converter.toDrip(cfx: sendValue) else {
            print( "Converter toDrip failiure")
            return
        }
        
        self.getGcfx().getNextNonce(of: cfxWellet.address()) { [weak self] (result) in
            guard let storageSelf = self else { return }
            switch result {
            case .success(let nonce):
                print( nonce)
                let hexSendValue = (try? Converter.toDrip(cfx: sendValue).hexStringWithPrefix) ?? "0x0"
                storageSelf.getGcfx().getEstimateGas(from: fromAddress, to: storageSelf.toAddress, gasPrice: gasPrice.hexStringWithPrefix, value: hexSendValue, nonce: nonce.hexStringWithPrefix) { (result) in
                    switch result {
                    case .success(let res):
                        let gasUsed = res.gasUsed
                        let storageLimit = res.storageCollateralized
                        print( "gasUsed is \(gasUsed)")
                        print( "storageCollateralized is \(storageLimit)")
                        
                        storageSelf.getGcfx().getEpochNumber { (result) in
                            switch result {
                            case .success(let epochHeight):
                                print(epochHeight)
                                let chainId = storageSelf.getGcfx().chainId
                                let rawTransaction = ConfluxSDK.RawTransaction.init(value: sendValueIntDrip, to: storageSelf.toAddress, gasPrice: gasPrice, gasLimit: gasLimit, nonce: nonce, storageLimit: storageLimit, epochHeight: Drip(epochHeight), chainId: chainId)
                                guard let transactionHash = try? cfxWellet.sign(rawTransaction: rawTransaction) else {
                                    print(" sign transaction failure")
                                    return
                                }
                                storageSelf.getGcfx().sendRawTransaction(rawTransaction: transactionHash) { (result) in
                                    switch result {
                                    case .success(let hash):
                                        print( hash)
                                    case .failure(_):
                                        print( " send transaction failure")
                                    }
                                }
                                
                            case .failure(let error):
                                print(error)
                            }
                        }
                        
                    case .failure(let error):
                        print( error)
                    }
                }
            case .failure(_):
                print( "GetNextNonce failure")
            }
        }
    }
    
    func getGasPrice() {
        self.getGcfx().getGasPrice { (result) in
            switch result {
            case .success(let resultDirp):
                print( "gasPrice Drip is \(resultDirp)")
                let reultGdrip = Converter.toGdrip(drip:Int(resultDirp))
                print( "gasPrice in Gdrip is \(reultGdrip)")
            case .failure(_):
                print( "getGasPrice failure")
            }
        }
    }
    
    func getEstimateGas() {
        self.getGcfx().getNextNonce(of: fromAddress) { [weak self] (result) in
             guard let storageSelf = self else { return }
             switch result {
             case .success(let nonce):
                 print( nonce)
                 let sendValue = try! Converter.toDrip(cfx: "1").hexStringWithPrefix // "0xde0b6b3a7640000"
                 let gasPrice = Converter.toDrip(Gdrip: 10).hexStringWithPrefix // "0x2540be400"
                 let hexNonce = nonce.hexStringWithPrefix
                 storageSelf.getGcfx().getEstimateGas(from: storageSelf.fromAddress, to: storageSelf.toAddress, gasPrice: gasPrice, value: sendValue, nonce: hexNonce ) { (result) in
                    switch result {
                    case .success(let res):
                        print( "gasUsed is \(res.gasUsed)")
                        print( "storageCollateralized is \(res.storageCollateralized)")
                    case .failure(let error):
                        print( error)
                    }
                }
             case .failure(_):
                print( "error")
            }
        }
    }
    
    func getTokenBalance(of address: String) {
        let dataHex = "0x" + ConfluxToken.ContractFunctions.balanceOf(address: address).data.hexString
        self.getGcfx().call(to: FCContractAddress, data: dataHex) { (result) in
            switch result {
            case .success(let hexBalance):
                if let result = try? Converter.hexDripToCfx(hexDrip: hexBalance, decimal: 18) {
                    print("\(address): \(result)")
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    
    func getTokenDecimal() {
        let data = "0x" + ConfluxToken.ContractFunctions.decimals.data.hexString
        self.getGcfx().call(to: FCContractAddress, data: data) { (result) in
            switch result {
            case .success(let decimalHex):
                if let decimal = Drip(decimalHex.lowercased().cfxStripHexPrefix(), radix: 16) {
                    print( decimal)
                }
            case .failure(let error):
                print( error)
            }
        }
    }
    
    func signMessage(msg: String) {
        guard let cfxWellet = self.importWallet() else {
            print( "creat wallet failiure")
            return
        }
        if msg.hasPrefix("0x") {
            let signedMsg = try? cfxWellet.sign(hex: msg)
            print(signedMsg)
        } else {
            let signedMsg = try? cfxWellet.sign(message: msg)
            print(signedMsg ?? "")
        }
    }
    
    func signPersonalMessage(msg: String){
        guard let cfxWellet = self.importWallet() else {
            print( "creat wallet failiure")
            return
        }
        if msg.hasPrefix("0x") {
            let signedMsg = try? cfxWellet.personalSign(hex: msg)
            print(signedMsg ?? "")
        } else {
            let signedMsg = try? cfxWellet.personalSign(message: msg)
            print(msg)
            print(signedMsg ?? "")
        }
    }
    
    
    func signTypedMessage() {
        let jsonString =
        """
    {\"types\":{\"EIP712Domain\":[{\"name\":\"name\",\"type\":\"string\"},{\"name\":\"version\",\"type\":\"string\"},{\"name\":\"chainId\",\"type\":\"uint256\"},{\"name\":\"verifyingContract\",\"type\":\"address\"}],\"Order\":[{\"name\":\"userAddress\",\"type\":\"address\"},{\"name\":\"amount\",\"type\":\"uint256\"},{\"name\":\"price\",\"type\":\"uint256\"},{\"name\":\"orderType\",\"type\":\"uint256\"},{\"name\":\"side\",\"type\":\"bool\"},{\"name\":\"expirationTimeSeconds\",\"type\":\"uint256\"},{\"name\":\"salt\",\"type\":\"uint256\"},{\"name\":\"baseAssetAddress\",\"type\":\"address\"},{\"name\":\"quoteAssetAddress\",\"type\":\"address\"}]},\"primaryType\":\"Order\",\"domain\":{\"name\":\"Boomflow\",\"version\":\"1.0\",\"chainId\":2,\"verifyingContract\":\"0xaffb844789ed7cc00fe5e16e51483c210e5fea31\"},\"message\":{\"userAddress\":\"0x5feb31c03d814f8d317aeb78510a6846b2a019c9\",\"amount\":\"1000000000000000000\",\"price\":\"5220000000000000000\",\"orderType\":0,\"side\":false,\"expirationTimeSeconds\":10000000000000,\"salt\":1583911078589,\"baseAssetAddress\":\"0x07ebe89e0e2d7e5e057767cd7316e1fd3fbcf83c\",\"quoteAssetAddress\":\"0xf39aea7786fe2cac54fc342e939681220065615c\"}}
    """
        let data = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        guard let typedData = try? decoder.decode(EIP712TypedData.self, from: data) else {
            print("trans to EIP712TypedData Failure")
            return
        }
        print(typedData.signHash.hexString)
        self.signMessage(msg:"0x" + typedData.signHash.hexString)
    }
    
    func getEpochNumber() {
        self.getGcfx().getEpochNumber { (result) in
            switch result {
            case .success(let epochHeight):
                print(epochHeight)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getPrivateKeyByKeystore() {
        let keystoreJson = """
            {"version":3,"id":"59d9ee74-e94c-4c4d-82a1-af95c7a71d6c","address":"be4907a0157a11202f57fdf5d2ceb4021e4f2640","crypto":{"ciphertext":"42c75c75f676b40379e863ac11dab8e3091abd95a1a8567723d4f79db95946fc","cipherparams":{"iv":"4960eeb8b125fc2ae95ae5a83917033d"},"cipher":"aes-128-ctr","kdf":"scrypt","kdfparams":{"dklen":32,"salt":"4809a7b96900a47a388251d95451059a25f1fbafd15a76d01855cb3a17e24a3b","n":8192,"r":8,"p":1},"mac":"eec19957f96312943eaf125d250134ecee95f6bd3d1b700eed18311abc015411"}}
            """
        let pwd = "chenyujie123"
        
        guard let keystore = try? Keystore.keystore(rawData: keystoreJson.data(using: .utf8) ?? Data.init()) else {
            print("generate keystore failed")
            return
        }
        let privateKey = try? keystore.privateKey(passphrase: pwd)
        let privateKeyStr = privateKey?.raw.hexString
        print(privateKeyStr)
    }
}

extension Data {
    public var hexString: String {
        return self.map {
            return String(format: "%02x", $0)
        }.joined()
    }
}


