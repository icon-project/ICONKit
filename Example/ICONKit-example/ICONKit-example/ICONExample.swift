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
//        getBalance()
        sendTransaction()

    }
    
    func createWallet() {
        print("========================")
        print("Begin createWallet")
        let prvStr = "pkpk".hexToData()!
        let wallet = Wallet(privateKey: PrivateKey(hex: prvStr))
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
        let result = iconService.getScoreAPI(scoreAddress: governanceAddress).execute()
        
        guard let apis = result.value else {
            return
        }
        
        let set = apis.result
        
        for key in set.keys {
            let api = set[key]!
            print("name: \(api.name) , type: \(api.type) , input: \(api.inputs) , output: \(String(describing: api.outputs)) , payable: \(String(describing: api.payable)) , readonly: \(String(describing: api.readonly))")
        }
    }
    
    func getDefaultStepCost() {
        print("========================")
        print("Begin getDefaultStepCost")
        let method = "getStepCosts"
        guard let wallet = self.wallet else { return }
        let call = Call<Response.Call<Response.StepCosts>>(from: wallet.address, to: governanceAddress, method: method, params: nil)
        
        let result = iconService.call(call).execute()
        
        guard let response = result.value, let stepCost = response.result else {
            print("error: \(String(describing: result.error))")
            return }
        self.stepCost = stepCost
        print("default: \(stepCost.defaultValue)")
    }
    
    func sendTransaction() {
        // coin transfer
        let coinTransfer = Transaction()
            .from("hx9043346dbaa72bca42ecec6b6e22845a4047426d")
            .to("hx2e26d96bd7f1f46aac030725d1e302cf91420458")
            .value(BigUInt(15000000))
            .stepLimit(BigUInt(1000000))
            .nid(self.iconService.nid)
            .nonce("0x1")
        
        // SCORE function call
        let call = CallTransaction()
            .from("hx9043346dbaa72bca42ecec6b6e22845a4047426d")
            .to("cx8471dca4cff173206d33773c9b74a3cc281efb21")
            .value(BigUInt(15000000))
            .stepLimit(BigUInt(1000000))
            .nid(self.iconService.nid)
            .nonce("0x1")
            .method("transfer")
            .params(["_to": "hx2e26d96bd7f1f46aac030725d1e302cf91420458", "_value": "0x29a2241af62c0000"])
        
        // Message transfer
        let message = MessageTransaction()
            .from("hx9043346dbaa72bca42ecec6b6e22845a4047426d")
            .to("hx2e26d96bd7f1f46aac030725d1e302cf91420458")
            .stepLimit(BigUInt(15000000))
            .nonce("0x1")
            .nid(self.iconService.nid)
            .message("Hello, World!")
        
        do {
            let signed = try SignedTransaction(transaction: call, privateKey: PrivateKey(hex: Data(hex: "pkpkpk")))
            
            let request: Request<Response.TxHash> = iconService.sendTransaction(signedTransaction: signed)
            let response = request.execute()
            switch response {
            case .success(let result):
                print("tx result - \(result.result.description)")
                
            case .failure(let error):
                // Error handling
                print("ERROR 실패 \(error.localizedDescription)")
                print(error)
            }
        } catch {
            print(error)
        }
    }
    
    func getLastBlock() {
        let response = iconService.getLastBlock().execute()
        if let value = response.value {
            for i in value.result.confirmedTransactionList {
                ViewController.blockList.append(i)
            }
            ViewController.lastHeight = value.result.height

        } else {
            print("Error: \(String(describing: response.error))")
        }
    }
    
    func getBlockByHeight(height: UInt64) {
        let response = iconService.getBlock(height: height).execute()
        
        if let value = response.value {
            for i in value.result.confirmedTransactionList {
                ViewController.blockList.append(i)
            }
            ViewController.lastHeight = value.result.height
        
        } else {
            print("ERROR: \(String(describing: response.error))")
        }
    }
    
    func getBlockByHash() {
        let response = iconService.getBlock(hash: "0x4e468893e56ef2cd75eb82cc4ff7026bf2baf72a47c0355a7a94da523af7aa3f").execute()
        
        if let value = response.value {
            print("result: \(value.result)")
            
        } else {
            print("ERROR: \(String(describing: response.error))")
        }
    }
    
    func getBalance() {
        let response = iconService.getBalance(address: "hx9043346dbaa72bca42ecec6b6e22845a4047426d").execute()
        
        if let value = response.value {
            print("result: \(value.result) loop")
            
        } else {
            print("ERROR: \(String(describing: response.error))")
        }
    }
    

    func getScoreAPI() {
        let response = iconService.getScoreAPI(scoreAddress: "cx3ec2814520c0096715159b8fc55fa1f385be038c").execute()

        if let value = response.value {
            print("result score: \(value.result)")
        } else {
            print("ERROR: \(String(describing: response.error))")
        }
    }
    
    // sync
    func getTotalSupply() {
        let response = iconService.getTotalSupply().execute()
        
        if let value = response.value {
            print("result: \(value.result)")
        } else {
            print("ERROR: \(String(describing: response.error))")
        }
    }
    
    // async
    func asyncTotalSupply(_ completion: @escaping ((BigUInt) -> Void)) {
        iconService.getTotalSupply().async { (response) in
            if let value = response.value {
                completion(value.result)        
            }
        }
    }
    
    func getTransactionResult() {
        let response = iconService.getTransactionResult(hash: "0xdca3d024e8361da7a2de42c506f0af2105be7b551ddb2e311b388ae5a41ad304").execute()

        if let value = response.value {
            print("result: \(String(describing: value.result))")
        } else {
            print("ERROR: \(String(describing: response.error))")
        }
    }
    
    func getTransactionByHash() {
        let response = iconService.getTransaction(hash: "0x0b01b95928fb8ef92f82f1764e36c515a1c1a04946dc04e94df407545098c20b").execute()
        
        if let value = response.value {
            print("result: \(value.result.blockHash)")
            
        } else {
            print("ERROR: \(String(describing: response.error))")
        }
    }
}
