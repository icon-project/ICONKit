//
//  ViewController.swift
//  ICONKit-example
//
//  Created by a1ahn on 01/11/2018.
//  Copyright © 2018 ICON Foundation. All rights reserved.
//

import UIKit
import ICONKit
import Result
import BigInt

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let example = ICONExample()
        
//        example.createWallet()
//
//        example.getGovernanceScoreAPI()
//
//        example.getDefaultStepCost()
        
        example.getLastBlock()
    }
}

class ICONExample {
    private var iconService: ICONService!
    private var wallet: Wallet?
    private var stepCost: Response.StepCosts?
    
    let governanceAddress = "cx0000000000000000000000000000000000000001"
    
    init() {
        let provider = "https://test-ctz.solidwallet.io"
        iconService = ICONService(provider: provider, nid: "0x2")
        
        // If you have a wallet which has some ICX for test, use loadWallet with your private key
        createWallet()
        
        // loadWallet(privateKey: "YOUR_PRIVATE_KEY")
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

        let set = apis.value

        for key in set.keys {
            let api = set[key]!
            print("name: \(api.name) , type: \(api.type) , input: \(api.inputs) , output: \(api.outputs) , payable: \(api.payable) , readonly: \(api.readonly)")
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
        let result = iconService.getLastBlock().execute()
        
        if let value = result.value {
            print("Block: \(value)")
        }
    }
}
