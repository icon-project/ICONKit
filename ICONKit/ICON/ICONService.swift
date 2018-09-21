/*
 * Copyright 2018 ICON Foundation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

import Foundation
import Result
import BigInt

open class ICONService {
    static let jsonrpc = "2.0"
    static let API_VER = "v3"
    static let ver = "0x3"
    
    var nid: String
    
    var provider: String
    
    public init(provider: String, nid: String) {
        self.provider = provider
        self.nid = nid
    }
}


public enum ICONResult: Error {
    case error(ICON.Response.DecodableResponse.ResponseError)
    case httpError
    case invalidAddress
    case invalidRequest
    case noSuchKey(String)
    case noAddress
    case parsing
    case privateKey
    case provider
    case sign
    case typeMismatch
    case unknown
}

extension ICONService: SECP256k1, Cipher {
    public func getID() -> Int {
        return Int(arc4random_uniform(9999))
    }
    
    private func makeTBS(method: ICON.METHOD, params: [String: String]) -> Data {
        let allKeys = params.keys.sorted()
        
        var tbs = method.rawValue
        for key in allKeys {
            tbs = tbs + "." + key + "." + String(params[key]!)
        }
        
        print("tbs - \(tbs)")
        
        return tbs.data(using: .utf8)!
    }
    
    private func send(method: ICON.METHOD, params: [String: Any]) -> Result<Data, ICONResult> {
        guard let provider = URL(string: self.provider) else { return .failure(.provider) }
        let request = ICONRequest(provider: provider, method: method, params: params, id: self.getID())
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        var data: Data?
        var response: HTTPURLResponse?
        var error: Error?
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let task = session.dataTask(with: request.asURLRequest()) {
            data = $0
            response = $1 as? HTTPURLResponse
            error = $2
            
            semaphore.signal()
        }
        task.resume()
        
        _ = semaphore.wait(timeout: .distantFuture)
        guard error == nil else {
            return .failure(ICONResult.httpError)
        }
        
        guard let value = data else { return .failure(ICONResult.httpError) }
        print("value - \(String(describing: String(data: value, encoding: .utf8)))")
        guard response?.statusCode == 200 else {
            return .failure(ICONResult.httpError)
        }
        
        return .success(value)
    }
}

extension ICONService {
    
    public func sendICX(privateKey: String, from: String, to: String, value: String, stepLimit: String, message: String? = nil) -> Result<String, ICONResult> {
        var params = [String: String]()
        let timestamp = Date.microTimestampHex
        
        params["version"] = ICONService.ver
        params["from"] = from
        params["to"] = to
        params["stepLimit"] = stepLimit
        params["timestamp"] = timestamp
        params["nid"] = self.nid
        params["value"] = value
        params["nonce"] = "0x1"
        
        if let data = message {
            params["dataType"] = "message"
            params["data"] = data
        }
        
        return self.sendTransaction(privateKey: privateKey, params: params)
    }
    
    func sendTransaction(privateKey: String, params: [String: String]) -> Result<String, ICONResult> {
        
        let tbs = getHash(makeTBS(method: .sendTransaction, params: params))
        
        guard let sign = try? signECDSA(hashedMessage: tbs, privateKey: privateKey) else { return .failure(ICONResult.sign) }
        var signed = params
        signed["signature"] = sign.base64EncodedString()
        
        let result = send(method: .sendTransaction, params: signed)
        
        switch result {
        case .success(let data):
            let decoder = JSONDecoder()
            guard let decodedTx = try? decoder.decode(ICON.Response.TxHash.self, from: data) else { return .failure(ICONResult.parsing) }
            if let result = decodedTx.result {
                return .success(result)
            } else if let error = decodedTx.error {
                return .failure(ICONResult.error(error))
            }
            return .failure(ICONResult.unknown)
            
        case .failure(let error):
            print("Error - \(error)")
            return .failure(error)
        }
    }
    
    
    public func getBalance(wallet: ICON.Wallet) -> Result<BigUInt, ICONResult> {
        guard let address = wallet.address else { return .failure(ICONResult.noAddress) }
        return getBalance(address: address)
    }
    
    public func getBalance(address: String) -> Result<BigUInt, ICONResult> {
        let result = self.send(method: .getBalance, params: ["address": address])
        
        switch result {
        case .success(let data):
            let decoder = JSONDecoder()
            guard let decodedBalance = try? decoder.decode(ICON.Response.Balance.self, from: data) else { return .failure(ICONResult.parsing) }
            if let result = decodedBalance.result {
                let hexBalance = result.prefix0xRemoved()
                guard let balance = BigUInt(hexBalance, radix: 16) else { return .failure(ICONResult.parsing) }
                return .success(balance)
            } else if let error = decodedBalance.error {
                return .failure(ICONResult.error(error))
            }
            return .failure(ICONResult.unknown)
            
        case .failure(let error):
            print("Error: \(error)")
            return .failure(error)
            
        }
    }
    
    public func getScoreAPI(address: String) -> Result<ICON.Response.ScoreAPI, ICONResult> {
        let params: [String: Any] = ["address": address]
        
        let result = self.send(method: .getScoreAPI, params: params)
        
        switch result {
        case .success(let data):
            let decoder = JSONDecoder()
            guard let decodedAPI = try? decoder.decode(ICON.Response.ScoreAPI.self, from: data) else { return .failure(ICONResult.parsing) }
            if decodedAPI.result != nil {
                return .success(decodedAPI)
            } else if let error = decodedAPI.error {
                return .failure(ICONResult.error(error))
            }
            return .failure(ICONResult.unknown)
            
        case .failure(let error):
            return .failure(error)
        }
    }
    
    public func getStepPrice() -> Result<BigUInt, ICONResult> {
        let params: [String: Any] = ["to": "cx0000000000000000000000000000000000000001",
                                     "dataType": "call",
                                     "data": ["method": "getStepPrice"]]
        
        let result = self.send(method: .callMethod, params: params)
        
        switch result {
        case .success(let data):
            let decoder = JSONDecoder()
            guard let priceResult = try? decoder.decode(ICON.Response.StepPrice.self, from: data) else { return .failure(ICONResult.parsing) }
            if let result = priceResult.result {
                let hexPrice = result.prefix0xRemoved()
                guard let price = BigUInt(hexPrice, radix: 16) else { return .failure(ICONResult.parsing) }
                return .success(BigUInt(price))
            } else if let error = priceResult.error {
                return .failure(ICONResult.error(error))
            }
            return .failure(ICONResult.unknown)
            
            
        case .failure(let error):
            print("Error: \(error)")
            return .failure(error)
        }
    }
    
    public func getStepCosts() -> Result<ICON.Response.StepCosts, ICONResult> {
        let params: [String: Any] = ["to": "cx0000000000000000000000000000000000000001",
                                     "dataType": "call",
                                     "data": ["method": "getStepCosts"]]
        
        let result = self.send(method: .callMethod, params: params)
        
        switch result {
        case .success(let data):
            let decoder = JSONDecoder()
            guard let decodedCosts = try? decoder.decode(ICON.Response.StepCosts.self, from: data) else { return .failure(ICONResult.parsing) }
            if decodedCosts.result != nil {
                return .success(decodedCosts)
            } else if let error = decodedCosts.error {
                return .failure(ICONResult.error(error))
            }
            return .failure(ICONResult.unknown)
            
            
        case .failure(let error):
            print("Error - \(error)")
            return .failure(error)
        }
    }
    
    public func getMinStepLimit() -> Result<BigUInt, ICONResult> {
        let result = self.getStepCosts()
        
        switch result {
        case .success(let costs):
            let stepCosts = costs.result!
            let min = stepCosts.defaultValue.prefix0xRemoved()
            return .success(BigUInt(min, radix: 16)!)
            
        case .failure(let error):
            return .failure(error)
        }
    }
    
    public func getMaxStepLimit() -> Result<BigUInt, ICONResult> {
        let params: [String: Any] = ["to" : "cx0000000000000000000000000000000000000001",
                                     "dataType": "call",
                                     "data": ["method": "getMaxStepLimit", "params": ["contextType": "invoke"]]]
        
        let result = self.send(method: .callMethod, params: params)
        
        switch result {
        case .success(let data):
            let decoder = JSONDecoder()
            guard let stepLimit = try? decoder.decode(ICON.Response.MaxStepLimit.self, from: data) else { return .failure(ICONResult.parsing) }
            if let result = stepLimit.result {
                let max = result.prefix0xRemoved()
                return .success(BigUInt(max, radix: 16)!)
            } else if let error = stepLimit.error {
                return .failure(ICONResult.error(error))
            }
            return .failure(ICONResult.unknown)
            
        case .failure(let error):
            print("Error - \(error)")
            return .failure(ICONResult.unknown)
        }
    }
    
    public func call(from: String, to: String, dataType: String, method: String, params: [String: Any]? = nil) -> Result<Any, ICONResult> {
        var data = [String: Any]()
        data["method"] = method
        if let p = params {
            data["params"] = p
        }
        
        let params: [String: Any] = ["from": from,
                                     "to": to,
                                     "dataType": dataType,
                                     "data": data]
        
        let result = self.send(method: .callMethod, params: params)
        
        switch result {
        case .success(let data):
            let decoder = JSONDecoder()
            guard let decodedCall = try? decoder.decode(ICON.Response.Call.self, from: data) else { return .failure(ICONResult.parsing) }
            if let result = decodedCall.result {
                return .success(result)
            } else if let error = decodedCall.error {
                return .failure(ICONResult.error(error))
            }
            return .failure(ICONResult.unknown)
            
        case .failure(let error):
            print("Error - \(error)")
            return .failure(error)
        }
    }
}
