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
        // 1. Mainnet
//        let provider = "https://ctz.solidwallet.io/api/v3"
//        iconService = ICONService(provider: provider, nid: "0x1")
        
        // 2. Testnet for DApps (Yeouido)
//        let provider = "https://bicon.net.solidwallet.io/api/v3"
//        iconService = ICONService(provider: provider, nid: "0x3")
        
        // 3. Testnet for Exchanger (Euljiro)
        let provider = "https://test-ctz.solidwallet.io/api/v3"
        iconService = ICONService(provider: provider, nid: "0x2")
    }
    
    func getLastBlock(_ completion: @escaping(Response.Block) -> Void) {
        let response = iconService.getLastBlock().execute()
        
        switch response {
        case .success(let result):
            print(result.blockHash)
            completion(result)
        case .failure(let err):
            print(err)
        }
    }
    
    func getBlockByHeight(height: UInt64, _ completion: @escaping(Response.Block) -> Void) {
        let response = iconService.getBlock(height: height).execute()
        
        switch response {
        case .success(let result):
            print(result.blockHash)
            completion(result)
        case .failure(let err):
            print(err)
        }
    }
    
    func getBlockByHash() {
        let response = iconService.getBlock(hash: "0xb59574924e58d16503b8d6499f10b0b8713ed8af2376dc71c5391e3ddbcd04fd").execute()
        
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
            print(err)
        }
    }
    
    func getTransactionByHash() {
        let response = iconService.getTransaction(hash: "0xed01444d27fffb7f705120c0106caaaa44114b16cc2b5788d3fd4fe19f170dcb").execute()
        
        switch response {
        case .success(let result):
            if let data = result.data {
                switch data {
                case .message(let message):
                    print(message)
                case .call(let call):
                    print("method: \(call.method)\nparams: \(String(describing: call.params))")
                case .deploy(let deploy):
                    print("content: \(deploy.content)\ncontentType: \(deploy.contentType)\nparams:\(String(describing: deploy.params))")
                }
            }
        case .failure(let err):
            print(err)
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
            print(err)
        }
    }
    
    // Send ICX
    func sendICX() {
        let coinTransfer = Transaction()
            .from(fromAddress)
            .to(toAddress)
            .value(BigUInt(15000000))
            .nid(self.iconService.nid)
        
        // Estimate step cost
        let estimate = iconService.estimateStep(transaction: coinTransfer).execute()

        if let estimatedStep = try? estimate.get() {
            // Set some margin
            let stepLimit = estimatedStep + 10000
            coinTransfer.stepLimit(stepLimit)
        }
        
        // Send transaction
        do {
            let signed = try SignedTransaction(transaction: coinTransfer, privateKey: yourPrivateKey)

            let request = iconService.sendTransaction(signedTransaction: signed)
            let response = request.execute()
            switch response {
            case .success(let result):
                print("ICX tx result - \(result)")

            case .failure(let error):
                print(error)
            }
        } catch {
            print(error)
        }
    }
    
    // Score function call
    func scoreCallTransaction() {
        let call = CallTransaction()
            .from(fromAddress)
            .to(scoreAddress)
            .nid(self.iconService.nid)
            .method("method")
            .params(["owner": "ADDRESS"])
        
        // Estimate step cost
        let estimate = iconService.estimateStep(transaction: call).execute()
        
        do {
            let estimatedStep = try estimate.get()
            
            // Set some margin
            let stepLimit = estimatedStep + 10000
            call.stepLimit(stepLimit)
        } catch {
            print(error)
        }
        
        // Send transaction
        do {
            let signed = try SignedTransaction(transaction: call, privateKey: yourPrivateKey)
            
            let request = iconService.sendTransaction(signedTransaction: signed)
            let response = request.execute()
            
            switch response {
            case .success(let result):
                print("SCORE tx result - \(result)")
            case .failure(let error):
                print(error)
            }
        } catch {
            print(error)
        }
    }
    
    // Send message transaction
    func sendMessageTransaction() {
        let message = MessageTransaction()
            .from(fromAddress)
            .to(toAddress)
            .nid(self.iconService.nid)
            .nonce("0x1")
            .message("Hello, ICON!")
        
        // Estimate step cost
        let estimate = iconService.estimateStep(transaction: message).execute()
        
        switch estimate {
        case .success(let value):
            // Set some margin
            let estimatedStep: BigUInt = value + 10000
            message.stepLimit(estimatedStep)
            
        case .failure(let error):
            print(error)
        }
        
        do {
            let signed = try SignedTransaction(transaction: message, privateKey: self.yourPrivateKey)
            
            let request = self.iconService.sendTransaction(signedTransaction: signed)
            let response = request.execute()
            switch response {
            case .success(let result):
                print("Message tx result - \(result)")
                
            case .failure(let error):
                print(error)
            }
        } catch {
            print(error)
        }
        
        
    }
    
    // Example of Asynchrously query
    func asyncBlock() {
        iconService.getLastBlock().async { (result) in
            switch result {
            case .success(let val):
                print(val.blockHash)
            case .failure(let err):
                print(err)
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
                print(err)
            }
        }
    }
    
    func asyncTransaction() {
        let message = MessageTransaction()
            .from(fromAddress)
            .to(toAddress)
            .nid(self.iconService.nid)
            .message("Hello, ICON!")
        
        let messageRequest = iconService.estimateStep(transaction: message)
        let messageResponse = messageRequest.execute()
        
        if let estimatedStepCost = try? messageResponse.get() {
            print("stepCost: \(estimatedStepCost)")
            message.stepLimit(estimatedStepCost)
        }
        
        do {
            let signed = try SignedTransaction(transaction: message, privateKey: yourPrivateKey)
            let request = iconService.sendTransaction(signedTransaction: signed)
            
            request.async { (result) in
                switch result {
                case .success(let val):
                    print(val)
                case .failure(let err):
                    print(err)
                }
            }
        } catch {
            print(error)
        }
    }
}

