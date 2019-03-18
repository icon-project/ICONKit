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
    private let privateKey = PrivateKey(hex: Data(hex: "hx"))
    private let fromAddress = "hx"
    private let toAddress = "hx"
    private let score = "cx"
    
    let governanceAddress = "cx0000000000000000000000000000000000000001"
    
    init() {
        // Mainnet
//        let provider = "https://ctz.solidwallet.io"
//        iconService = ICONService(provider: provider, nid: "0x1")
        
        // Testnet for DApps
//        let provider = "https://bicon.net.solidwallet.io"
//        iconService = ICONService(provider: provider, nid: "0x3")
        
        // Testnet for Exchanger
        let provider = "https://test-ctz.solidwallet.io"
        iconService = ICONService(provider: provider, nid: "0x2")
        
        // If you have a wallet which has some ICX for test, use loadWallet with your private key
        //        createWallet()
        
        getBlockByHash()
        getBalance()
        asyncTest()
        
        getLastBlock()
        getBlockByHeight()
        getBlockByHash()

        getBalance()

        getGovernanceScoreAPI()
        getTotalSupply()
        getTransactionResult()
        getTransactionByHash()
        getDefaultStepCost()
//        sendTransaction()
    }
    
    func createWallet() {
        print("========================")
        print("Begin createWallet")
        let wallet = Wallet(privateKey: privateKey)
        print("address: \(String(describing: wallet.address))")

        self.wallet = wallet
        print("Wallet created.")
    }

    func loadWallet(privateKey: String) {
        let keyData = privateKey.hexToData()!
        let prvKey = PrivateKey(hex: keyData)
        let wallet = Wallet(privateKey: prvKey)
        print("address: \(String(describing: wallet.address))")

        self.wallet = wallet
        print("Wallet loaded.")
    }

    func getGovernanceScoreAPI() {
        print("========================")
        print("Begin getGovernanceScoreAPI")
        let response = iconService.getScoreAPI(scoreAddress: governanceAddress)
        switch response {
        case .error(let err):
            print("ERROR MESSAGE: \(err.message)")
        case .result(let res):
            for key in res.keys {
                let api = res[key]!
                print("name: \(api.name) , type: \(api.type) , input: \(api.inputs) , output: \(String(describing: api.outputs)) , payable: \(String(describing: api.payable)) , readonly: \(String(describing: api.readonly))")
            }
        }
    }
    
    func getDefaultStepCost() {
        print("========================")
        print("Begin getDefaultStepCost")
        let method = "getStepCosts"
//        guard let wallet = self.wallet else { return }
        let call = Call<Response.StepCosts>(from: fromAddress, to: governanceAddress, method: method, params: nil)
        
        let result = iconService.call(call)
        switch result {
        case .result(let result):
            
            self.stepCost = result
            print("getDefaultStepCost: \(result.defaultValue)")
            
        case .error(let error):
            print("ERROR getDefaultStepCost \(error)")
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
            .to(score)
            .stepLimit(BigUInt(1000000))
            .nid(self.iconService.nid)
            .nonce("0x1")
            .method("method")
            .params(["params": "params"])

        // Message transfer
        let message = MessageTransaction()
            .from(fromAddress)
            .to(toAddress)
            .stepLimit(BigUInt(15000000))
            .nonce("0x1")
            .nid(self.iconService.nid)
            .message("Hello, ICON!")
        
        do {
            
            // Sync
            let signed = try SignedTransaction(transaction: coinTransfer, privateKey: privateKey)

            let response = iconService.sendTransaction(signedTransaction: signed)
            switch response {
            case .result(let result):
                print("성공 tx result - \(result)")

            case .error(let error):
                // Error handling
                print("ERROR 실패 \(error.message)")
                print(error)
            }
//            // Async
//            let signed = try SignedTransaction(transaction: message, privateKey: privateKey)
//
//            iconService.sendTransactionAsync(signedTransaction: signed) { (response) in
//                switch response {
//                case .result(let result):
//                    print("Async 성공 tx result - \(result)")
//
//                case .error(let error):
//                    print("ERROR 실패 \(error.message)")
//                    print(error)
//                }
//            }
            
        } catch {
            print(error)
        }
    }

    func getLastBlock() {
        let response = iconService.getLastBlock()
        switch response {
        case .error(let err):
            print("에러 메세지 \(err.message)")
            print("에러 코드 \(err.code)")
        case .result(let res):
            print("BLOCKHASH \(res.blockHash)")
            print("높이 \(res.height)")
        }
    }

    func getBlockByHeight() {
        let response = iconService.getBlock(height: 53745)
        switch response {
        case .error(let err):
            print("에러 메세지 \(err.message)")
            print("에러 코드 \(err.code)")
        case .result(let res):
            print("BLOCKHASH \(res.blockHash)")
            print("높이 \(res.height)")
        }
    }
    
    func getBlockByHash() {
        let response = iconService.getBlock(hash: "0x11658452bd891c717b95d262d0fa2006fa49f59da8fcd5dd53987891ae12e0a1")
        switch response {
        case .error(let err):
            print("에러 메세지 \(err.message)")
            print("에러 코드 \(err.code)")
        case .result(let res):
            print("BLOCKHASH \(res.blockHash)")
            print("높이 \(res.height)")
        }
    }
    
    func getBalance() {
        let response = iconService.getBalance(address: fromAddress)
        
        switch response {
        case .error(let err):
            print("에러 메세지 \(err.message)")
            print("에러 코드 \(err.code)")
        case .result(let res):
            print("Balance: \(res)")
        }
    }
    
    // getBalance async
    func asyncTest() {
        iconService.getBalanceAsync(address: fromAddress) { (response) in
            print(response)
        }
    }
    
    // sync
    func getTotalSupply() {
        let response = iconService.getTotalSupply()
        if let response = response {
            print("SUPPLY: \(response)")
        }
    }
        
    func getTransactionResult() {
        let response = iconService.getTransactionResult(hash: "0xba773201438b5d01868464323c2862289988584cd0b53ba0fd63a40e4f0f94f6")
        
        switch response {
        case .error(let err):
            print("에러 메세지 \(err.message)")
            print("에러 코드 \(err.code)")
        case .result(let res):
            print("getTransactionResult: \(res.blockHash)")
        }
    }
    
    func getTransactionByHash() {
        let response = iconService.getTransaction(hash: "0xba773201438b5d01868464323c2862289988584cd0b53ba0fd63a40e4f0f94f6")
        
        switch response {
        case .error(let err):
            print("에러 메세지 \(err.message)")
            print("에러 코드 \(err.code)")
        case .result(let res):
            print("getTransactionByHash: \(res.blockHash)")
        }
    }
}
