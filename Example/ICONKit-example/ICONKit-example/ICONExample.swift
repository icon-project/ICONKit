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
        let provider = "https://ctz.solidwallet.io"
        iconService = ICONService(provider: provider, nid: "0x1")
        
        // Testnet for DApps
        //        let provider = "https://bicon.net.solidwallet.io"
        //        iconService = ICONService(provider: provider, nid: "0x3")
        
        // Testnet for Exchanger
        //        let provider = "https://test-ctz.solidwallet.io"
        //        iconService = ICONService(provider: provider, nid: "0x2")
        
        // If you have a wallet which has some ICX for test, use loadWallet with your private key
        //        createWallet()
        //        loadWallet(privateKey: "YOUR_PRIVATE_KEY")
    }
    
    func createWallet() {
        print("========================")
        print("Begin createWallet")
        let wallet = Wallet(privateKey: nil)
        print("address: \(String(describing: wallet.address))")
        
        self.wallet = wallet
        print("Wallet created.")
    }
    
    func loadWallet(privateKey: String) {
        let keyData = privateKey.hexToData()!
        let prvKey = PrivateKey(hexData: keyData)
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
        let response = iconService.getBalance(address: "hx7ccc54932b913c71f7051e9dc1b621074c91d462").execute()
        
        if let value = response.value {
            print("result: \(value.result)")
            
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
