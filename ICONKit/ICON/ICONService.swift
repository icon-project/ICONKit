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

open class ICONService {
    static let jsonrpc = "2.0"
    static let API_VER = "v3"
    static let ver = "0x3"
    static let nid = "0x3"
    
    var provider: String
    
    init(provider: String) {
        self.provider = provider
    }
    
    convenience init(_ provider: String) {
        self.init(provider: provider)
    }
    
    open static func localTest() -> ICONService {
        return ICONService("http://52.79.233.89:9000")
    }
    
    open static func testNet() -> ICONService {
        return ICONService("https://testwallet.icon.foundation")
    }
    
    open static func mainNet() -> ICONService {
        return ICONService("https://wallet.icon.foundation")
    }
}


enum ICONResult: Error {
    case httpError
    case noSuchKey(String)
    case typeMismatch
    case noAddress
    case provider
    case parsing
    case unknown
}

public struct ICONResponse: Codable {
    var jsonrpc: String
    var id: Int
    var error: String?
    var result: String?
}

extension ICONService: SECP256k1, Cipher {
    public func getID() -> Int {
        return Int(arc4random_uniform(6))
    }
    
    public func getBalance(wallet: ICON.Wallet) -> String? {
        guard let address = wallet.address else { return nil }
        return getBalance(address: address)
    }
    
    public func getBalance(address: String) -> String? {
        let result = self.send(method: .getBalance, params: ["address": address])
        
        switch result {
        case .success(let response):
            guard let value = response.result, let data = value.data(using: .utf8) else { return nil }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                
                guard let hexBalance = json["result"] as? String else { return nil }
                
                return hexBalance
            } catch {
                return nil
            }
            
        default:
            break
        }
        
        return nil
    }
    
    public func sendTransaction(privateKey: String, from: String, to: String, value: String, stepLimit: String) -> String? {
        var params = [String: String]()
        let timestamp = Date.microTimestamp
        
        params["version"] = ICONService.ver
        params["from"] = from
        params["to"] = to
        params["stepLimit"] = stepLimit
        params["timestamp"] = timestamp
        params["nid"] = ICONService.nid
        params["nonce"] = "0x29"
        
        let tbs = getHash(makeTBS(method: .sendTransaction, params: params))
        
        guard let sign = try? signECDSA(hashedMessage: tbs, privateKey: privateKey) else { return nil }
        params["signature"] = sign.toHexString()
        
        let result = send(method: .sendTransaction, params: params)
        
        switch result {
        case .success(let response):
            guard let resultParams = response.result, let data = resultParams.data(using: .utf8) else { return nil }
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as! [String: Any] else { return nil }
            guard let txHash = json["result"] as? String else { return nil }
            return txHash
            
        default:
            break
        }
        
        return nil
    }
    
    private func makeTBS(method: ICON.METHOD, params: [String: String]) -> Data {
        let allKeys = params.keys.sorted()
        
        var tbs = method.rawValue
        for key in allKeys {
            tbs = tbs + "." + key + "." + String(params[key]!)
        }
        
        return tbs.data(using: .utf8)!
    }
    
    private func send(method: ICON.METHOD, params: [String: Any]) -> Result<ICONResponse, ICONResult> {
        guard let provider = URL(string: self.provider) else { return .failure(.provider) }
        let request = ICONRequest(provider: provider, method: ICON.METHOD.getBalance, params: params, id: self.getID()).asURLRequest()
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        var data: Data?
        var response: HTTPURLResponse?
        var error: Error?
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let task = session.dataTask(with: request) {
            data = $0
            response = $1 as? HTTPURLResponse
            error = $2
            
            semaphore.signal()
        }
        task.resume()
        
        _ = semaphore.wait(timeout: .distantFuture)
        guard error == nil, response?.statusCode == 200, let value = data else { return .failure(ICONResult.httpError) }
        
        let decoder = JSONDecoder()
        guard let parsed = try? decoder.decode(ICONResponse.self, from: value) else { return .failure(ICONResult.parsing) }
        
        return .success(parsed)
    }
}
