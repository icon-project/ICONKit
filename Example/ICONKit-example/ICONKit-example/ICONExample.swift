//
//  ICONExample.swift
//  ICONKit-example
//
//  Created by Seungyeon Lee on 21/02/2019.
//  Copyright © 2019 ICON Foundation. All rights reserved.
//

import Foundation
import ICONKit
import BigInt

class ICONExample {
    private var iconService: ICONService!
    private var wallet: Wallet?
    private var stepCost: Response.StepCosts?
    private var fromAddress = "ADDRESS"
    private var toAddress = "ADDRESS"
    private var scoreAddress = "SCORE_ADDRESS"
    private var yourPrivateKey: PrivateKey = PrivateKey(hex: Data(hex: "YOUR_PRIVATE_KEY"))
    
    let governanceAddress = "cx0000000000000000000000000000000000000001"
    
    init() {
        // Mainnet
//        let provider = "https://ctz.solidwallet.io/api/v3"
//        iconService = ICONService(provider: provider, nid: "0x1")
        
        // Testnet for DApps
//        let provider = "https://bicon.net.solidwallet.io/api/v3"
//        iconService = ICONService(provider: provider, nid: "0x3")
        
        // Testnet for Exchanger
        let provider = "https://test-ctz.solidwallet.io/api/v3"
        iconService = ICONService(provider: provider, nid: "0x2")
        
        // If you have a wallet which has some ICX for test, use loadWallet with your private key
//        createWallet()
//        loadWallet(privateKey: yourPrivateKey)
        
//        asyncBlock()
//        asyncSupply()
//        asyncTransaction()
//        getLastBlock()
//        getBlockByHash()
//        getBlockByHeight(height: 54156)
//        getTransactionByHash()
//        getTransactionResult()
//        getScoreAPI()
//        getGovernanceScoreAPI()
//        getBalance()
//        sendTransaction()
//        getTotalSupply()
//        getDefaultStepCost()
    }
    
    func asyncBlock() {
        iconService.getLastBlock().async { (result) in
            switch result {
            case .success(let val):
                print(val.blockHash)
            case .failure(let err):
                print(err.errorDescription)
            }
            
        }
    }
    func asyncSupply(_ completion: @escaping(BigUInt) -> Void) {
        iconService.getTotalSupply().async { (result) in
            switch result {
            case .success(let val):
                print(val)
                completion(val)
            case .failure(let err):
                print(err.errorDescription)
//                completion(err.errorDescription)
            }
        }
    }
    func asyncTransaction() {
        let message = MessageTransaction()
            .from(fromAddress)
            .to(toAddress)
            .stepLimit(BigUInt(15000000))
            .nonce("0x1")
            .nid(self.iconService.nid)
            .message("Hello, ICON!")
        
        do {
            let signed = try SignedTransaction(transaction: message, privateKey: yourPrivateKey)
            
            let request = iconService.sendTransaction(signedTransaction: signed)
            request.async { (result) in
                switch result {
                case .success(let val):
                    print(val)
                case .failure(let err):
                    print(err.errorDescription)
                }
            }
        } catch {
            print(error)
        }
    }
    
    func createWallet() {
        print("========================")
        print("Begin createWallet")
        let wallet = Wallet(privateKey: yourPrivateKey)
        print("address: \(String(describing: wallet.address))")
        
        self.wallet = wallet
        print("Wallet created.")
    }
    
    func loadWallet(privateKey: PrivateKey) {
        let wallet = Wallet(privateKey: privateKey)
        print("address: \(String(describing: wallet.address))")
        
        self.wallet = wallet
        print("Wallet loaded.")
    }
    
    func getGovernanceScoreAPI() {
        print("========================")
        print("Begin getGovernanceScoreAPI")
        let result = iconService.getScoreAPI(scoreAddress: governanceAddress).execute()
        
        switch result {
        case .success(let data):
            for api in data {
                print("name: \(api.name) , type: \(api.type) , input: \(api.inputs) , output: \(String(describing: api.outputs)) , payable: \(String(describing: api.payable)) , readonly: \(String(describing: api.readonly))")
            }
        case .failure(let err):
            print(err)
        }
    }
    
    func getDefaultStepCost() {
        print("========================")
        print("Begin getDefaultStepCost")
        let method = "getStepCosts"
        guard let wallet = self.wallet else { return }
        let call = Call<Response.StepCosts>(from: wallet.address, to: governanceAddress, method: method, params: nil)
        
        let result = iconService.call(call).execute()
        
        switch result {
        case .success(let val):
            print(val.apiCall)
        case .failure(let err):
            print(err.errorDescription)
        }
    }
    
    func sendTransaction() {
        // coin transfer
        let coinTransfer = Transaction()
            .from(fromAddress)
            .to(toAddress)
            .value(BigUInt(15000000))
            .stepLimit(BigUInt(1000000))
            .nid(self.iconService.nid)
            .nonce("0x1")
        
        // SCORE function call
        let call = CallTransaction()
            .from(fromAddress)
            .to(scoreAddress)
            .value(BigUInt(15000000))
            .stepLimit(BigUInt(1000000))
            .nid(self.iconService.nid)
            .nonce("0x1")
            .method("transfer")
            .params(["_to": "hx2e26d96bd7f1f46aac030725d1e302cf91420458", "_value": "0x29a2241af62c0000"])
        
        // Message transfer
        let message = MessageTransaction()
            .from(fromAddress)
            .to(toAddress)
            .stepLimit(BigUInt(15000000))
            .nonce("0x1")
            .nid(self.iconService.nid)
            .message("Hello, ICON!")
        
        do {
            let signed = try SignedTransaction(transaction: message, privateKey: yourPrivateKey)
            
            let request = iconService.sendTransaction(signedTransaction: signed)
            let response = request.execute()
            switch response {
            case .success(let result):
                print("tx result - \(result)")

            case .failure(let error):
                print(error)
            }
        } catch {
            print(error)
        }
    }
    
    func getLastBlock(_ completion: @escaping(Response.ResultInfo) -> Void) {
        let response = iconService.getLastBlock().execute()
        
        switch response {
        case .success(let result):
            print(result.blockHash)
            completion(result)
        case .failure(let err):
            print(err.errorDescription)
        }
    }
    
    func getBlockByHeight(height: UInt64, _ completion: @escaping(Response.ResultInfo) -> Void) {
        let response = iconService.getBlock(height: height).execute()
        
        switch response {
        case .success(let result):
            print(result.blockHash)
            completion(result)
        case .failure(let err):
            print(err.errorDescription)
        }
    }
    
    func getBlockByHash() {
        let response = iconService.getBlock(hash: "0x4e468893e56ef2cd75eb82cc4ff7026bf2baf72a47c0355a7a94da523af7aa3f").execute()
        
        switch response {
        case .success(let result):
            print(result.blockHash)
        case .failure(let err):
            print(err.localizedDescription)
        }
    }
    
    func getBalance() {
        let response = iconService.getBalance(address: "hx9043346dbaa72bca42ecec6b6e22845a4047426d").execute()
        switch response {
        case .success(let data):
            print(data)
        case .failure(let err):
            print(err)
        }
    }
    

    func getScoreAPI() {
        let result = iconService.getScoreAPI(scoreAddress: scoreAddress).execute()
        switch result {
        case .success(let data):
            for api in data {
                print("name: \(api.name) , type: \(api.type) , input: \(api.inputs) , output: \(String(describing: api.outputs)) , payable: \(String(describing: api.payable)) , readonly: \(String(describing: api.readonly))")
            }
        case .failure(let err):
            print(err)
        }
    }
    
    func getTotalSupply() {
        let response = iconService.getTotalSupply().execute()
        
        switch response {
        case .success(let data):
            print(data)
        case .failure(let err):
            print(err)
        }
    }
    
    func getTransactionResult() {
        let response = iconService.getTransactionResult(hash: "0x1155fd70a265db32f2fa307dd64fa74820dfada2969da6ca7ea00242e319e067").execute()

        switch response {
        case .success(let result):
            print(result.blockHash)
        case .failure(let err):
            print(err.errorDescription)
        }
    }
    
    func getTransactionByHash() {
        let response = iconService.getTransaction(hash: "0x1155fd70a265db32f2fa307dd64fa74820dfada2969da6ca7ea00242e319e067").execute()
        
        switch response {
        case .success(let result):
            print(result.blockHash)
        case .failure(let err):
            print(err.errorDescription)
        }
    }
}
