//
//  Gcfx.swift
//  ConfluxSDK
//
//  Created by 区块链 on 2020/2/19.
//  Copyright © 2020 com.blockchain.dappbirds. All rights reserved.
//

public final class Gcfx {
    private let configuration: Configuration
    private let httpClient: HTTPClient
    public let chainId: Int
    
    /// init initialize Gcfx instance
    ///
    /// - Parameter configuration: configuration to use in http client
    public init(configuration: Configuration) {
        self.configuration = configuration
        self.httpClient = HTTPClient(configuration: configuration)
        self.chainId = configuration.network.chainID
    }
    
    // MARK: - JSONRPC APIs
    
    /// getGasPrice returns currenct gas price
    ///
    /// - Parameters:
    ///   - completionHandler:
    public func getGasPrice(completionHandler: @escaping (Result<Drip>) -> Void) {
        httpClient.send(JSONRPC.GetGasPrice(), completionHandler: completionHandler)
    }
    
    /// getBalance returns currenct balance of specified address.
    ///
    /// - Parameters:
    ///   - address: address you want to get the balance of
    ///   - blockParameter:
    ///   - completionHandler:
    public func getBalance(of address: String, blockParameter: EpochParameter = .latest_state, completionHandler: @escaping (Result<Balance>) -> Void) {
        httpClient.send(JSONRPC.GetBalance(address: address, epochParameter: blockParameter), completionHandler: completionHandler)
    }
    
    /// GetNextNonce returns the current nonce of specified address
    ///
    /// - Parameters:
    ///   - address: address to check
    ///   - blockParameter:
    ///   - completionHandler:
    public func getNextNonce(of address: String, blockParameter: EpochParameter = .latest_state, completionHandler: @escaping (Result<Int>) -> Void) {
        httpClient.send(JSONRPC.GetNextNonce(address: address, epochParameter: blockParameter), completionHandler: completionHandler)
    }
    
    /// sendRawTransaction sends the raw transaction string
    ///
    /// - Parameters:
    ///   - rawTransaction: raw transaction encoded in rlp hex format
    ///   - completionHandler:
    public func sendRawTransaction(rawTransaction: String, completionHandler: @escaping (Result<SentTransaction>) -> Void) {
        httpClient.send(JSONRPC.SendRawTransaction(rawTransaction: rawTransaction), completionHandler: completionHandler)
    }
    
    /// getBlockNumber returns the latest block number
    ///
    /// - Parameter completionHandler:
    public func getEpochNumber(completionHandler: @escaping (Result<Int>) -> Void) {
        httpClient.send(JSONRPC.GetEpochNumber(), completionHandler: completionHandler)
    }
    
    /// call sends transaction to a contract method
    /// - Parameters:
    ///   - from: which address to send from
    ///   - to: which address to send to
    ///   - gasLimit: gas limit
    ///   - gasPrice: gas price
    ///   - value: value in drip
    ///   - data: data to include in tx
    ///   - blockParameter:
    ///   - completionHandler:
    public func call(from: String? = nil, to: String, gasLimit: Int? = nil, gasPrice: Int? = nil, value: Int? = nil, data: String? = nil, blockParameter: EpochParameter = .latest_state, completionHandler: @escaping (Result<String>) -> Void) {
        let request = JSONRPC.Call(
            from: from,
            to: to,
            gasLimit: gasLimit,
            gasPrice: gasPrice,
            value: value,
            data: data,
            epochParameter: blockParameter
        )
        httpClient.send(request, completionHandler: completionHandler)
    }
    
    /// getEstimateGas returns estimated gas for the tx
    ///
    /// - Parameters:
    ///   - from: which address to send from
    ///   - to: which address to send to
    ///   - gasLimit: gas limit
    ///   - gasPrice: gas price
    ///   - value: value in drip
    ///   - data: data to include in tx
    ///   - completionHandler:
    public func getEstimateGas(from: String? = nil, to: String? = nil, gasLimit: String? = nil, gasPrice: String? = nil, value: String? = nil, data: String? = nil, nonce: String?, completionHandler: @escaping (Result<(gasUsed: Drip, gasLimit: Drip, storageCollateralized: Drip)>) -> Void) {
        let request = JSONRPC.GetEstimatGas(
            from: from,
            to: to,
            gasLimit: gasLimit,
            gasPrice: gasPrice,
            nonce: nonce,
            value: value,
            data: data
        )
        httpClient.send(request, completionHandler: completionHandler)
    }
    
    public func getTransactionStatus(by hash: String, completionHandler: @escaping (Result<Int>) -> Void) {
        let request = JSONRPC.GetTransactionStatusByHash(transactionHash: hash)
        httpClient.send(request, completionHandler: completionHandler)
    }
    
    public func getTransactionReceipt(by hash: String, completionHandler: @escaping (Result<[String: Any]>) -> Void) {
        let request = JSONRPC.GetTransactionReceiptByHash(transactionHash: hash)
        httpClient.send(request, completionHandler: completionHandler)
    }
}
