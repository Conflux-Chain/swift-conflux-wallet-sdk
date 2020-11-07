# swift-conflux-wallet-sdk

```swift
let mnemonicArr = Mnemonic.create(strength: .normal)
guard let seed = try? Mnemonic.createSeed(mnemonic: mnemonicArr) else {
    print( "creat seed failure")
    return
}

guard let cfxWallet = try? Wallet.init(seed: seed, network: .testnet, printDebugLog: true) else {
    print( "creat wallet failiure")
    return
}

let privateKeyStr = cfxWallet.privateKey().hexString
let address = cfxWallet.address()
```
## Features
- Conflux Wallet Create
- Sign transaction
- Token transfer
- Sign message

## Requirements

- Swift 5 or later
- iOS 9.0 or later

## Install (Carthage)
    github "https://github.com/R0uter/swift-conflux-wallet-sdk"

## Usage
- Provide usage examples of related methods in Demo ConfluxSwiftTest and ConfluxOCTest

## Dependency

- [CryptoSwift](https://github.com/krzyzanowskim/CryptoSwift): Crypto related functions and helpers for Swift implemented in Swift.
- [SipHash](https://github.com/attaswift/SipHash):SipHash is a pure Swift implementation of the SipHash hashing algorithm designed by Jean-Philippe Aumasson and Daniel J. Bernstein in 2012.

## Author
ChrisChen,chengzhongzheng888@gmail.com



