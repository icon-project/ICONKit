//
//  ICONExample.swift
//  ICONKit-example
//
//  Created by Seungyeon Lee on 21/02/2019.
//  Copyright © 2019 ICON Foundation. All rights reserved.
//

import Foundation
import ICONKit

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
        //
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
        if let result = response.value {
            ViewController.blockList.append(result)
            ViewController.lastHeight = result.result.height
        }
    }
    
    func getBlockByHeight(height: UInt64) {
        let result = iconService.getBlock(height: height).execute()
        
        if let value = result.value {
            ViewController.blockList.append(value)
            ViewController.lastHeight = value.result.height
            
        } else {
            print("ERROR: \(String(describing: result.error))")
        }
    }
    
    func getBlockByHash() {
        // Mainnet -provider 확인을 잘 하자.
        //        let result = iconService.getBlock(hash: "0x4e468893e56ef2cd75eb82cc4ff7026bf2baf72a47c0355a7a94da523af7aa3f").execute()
        
        // DApps
        let result = iconService.getBlock(hash: "0x3023106753b7545610916085d088df8d8ebd1fd0a12aa6b955b516b4133b3710").execute()
        
        // Exchange
        //        let result = iconService.getBlock(hash: "0x11658452bd891c717b95d262d0fa2006fa49f59da8fcd5dd53987891ae12e0a1").execute()
        
        if let value = result.value {
            print("getBlockHash: \(value.result)")
            
        } else {
            print("error: \(String(describing: result.error))")
        }
    }
    
    func getBalance() {
        
        // DApps
        let result = iconService.getBalance(address: "hxb49c75ce26b0f147a0d5c213082a33035e22c6fc").execute()
        
        // Exchange
        //        let result = iconService.getBalance(address: "hx9f63a41ccca7935d750d140d913d31bee375606e").execute()
        
        if let value = result.value {
            print("getBalance: \(value.result)")
            
        } else {
            print("error: \(String(describing: result.error))")
        }
    }
    
    func getScoreAPI() {
        // DApps
        let result = iconService.getScoreAPI(scoreAddress: "cx5b479511f199d601b4230da4d631b660cc0cb5b9").execute()
        
        //        // Exchange
        //        let result = iconService.getScoreAPI(scoreAddress: "cx5b479511f199d601b4230da4d631b660cc0cb5b9").execute()
        
        if let value = result.value {
            print("result: \(value.result)")
        } else {
            print("ERROR: \(String(describing: result.error))")
        }
    }
    
    func getTotalSupply() {
        let result = iconService.getTotalSupply().execute()
        
        if let value = result.value {
            print("result: \(value.result)")
        } else {
            print("ERROR: \(String(describing: result.error))")
        }
    }
    
    func getTransactionResult() {
        // Mainnet
        //        let result = iconService.getTransactionResult(hash: "0x0966446bcb94b6bae3f6a0b9e8949842d0d4b10f3fa26e9bd6c2ccda185fe3a7").execute()
        
        // DApps
        let result = iconService.getTransactionResult(hash: "0x86bada0b473e7f537fba2bfd09347e2e7e3f84f49c45342372d9a65a79440680").execute()
        
        // Exchange
        //        let result = iconService.getTransactionResult(hash: "0x399c9a1e66c073cfd865e2867b0aef6737ae9c3fdd288648a78ee99a2f7403fb").execute()
        
        if let value = result.value {
            print("result: \(String(describing: value.result.txHash))")
        } else {
            print("ERROR: \(String(describing: result.error))")
        }
    }
    
    func getTransactionByHash() {
        // Mainnet
        //        let result = iconService.getTransaction(hash: "0x0b01b95928fb8ef92f82f1764e36c515a1c1a04946dc04e94df407545098c20b").execute()
        
        // DApps
        let result = iconService.getTransaction(hash: "0x86bada0b473e7f537fba2bfd09347e2e7e3f84f49c45342372d9a65a79440680").execute()
        
        // Exchange
        //        let result = iconService.getTransaction(hash: "0x399c9a1e66c073cfd865e2867b0aef6737ae9c3fdd288648a78ee99a2f7403fb").execute()
        
        if let value = result.value {
            print("BlockHash: \(value.result.blockHash)")
            
        } else {
            print("ERROR: \(String(describing: result.error))")
        }
    }
}
