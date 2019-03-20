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

open class Request<T: Decodable>: Sendable {
    private let jsonrpc = "2.0"
    private let id: Int
    var provider: String
    var method: ICON.METHOD
    var params: [String: Any]?
    
    init(id: Int, provider: String, method: ICON.METHOD, params: [String: Any]?) {
        self.id = id
        self.provider = provider
        self.method = method
        self.params = params
    }
}

extension Request {
    /// Request synchronously
    public func execute() -> Result<T, ICError> {
        let result = self.send()
        
        switch result {
        case .failure(let error):
            return .failure(error)
            
        case .success(let data):
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
                
                if let jsonResult = json["result"] {
                    if let jsonRes = jsonResult as? T {
                        // icx_sendTransaction
                        return .success(jsonRes)
                        
                    } else if let jsonRes = jsonResult as? [String : Any] {
                        print(json)
                        // icx_getBlockByHeight, icx_getBlockByHash, icx_getTransactionResult, icx_getTransactionByHash, icx_getTransactionResult, icx_getTransactionByHash
                        let resultData = try JSONSerialization.data(withJSONObject: jsonRes, options: .prettyPrinted)
                        let decoded = try decoder.decode(T.self, from: resultData)
                        return .success(decoded)
                        
                    } else if let jsonRes = jsonResult as? [Any] {
                        // icx_getScoreApi
                        let resultData = try JSONSerialization.data(withJSONObject: jsonRes, options: .prettyPrinted)
                        let decoded = try decoder.decode(T.self, from: resultData)
                        return .success(decoded)
                        
                    } else {
                        // icx_getBalance, icx_getTotalSupply
                        guard let bigStr = jsonResult as? String, let bigVal = bigStr.hexToBigUInt() as? T else {
                            return .failure(ICError.fail(reason: .parsing))
                        }
                        return .success(bigVal)
                    }

                } else if let error = json["error"] {
                    let errorData = try JSONSerialization.data(withJSONObject: error, options: .prettyPrinted)
                    let decoded = try decoder.decode(Response.ResponseError.self, from: errorData)
                    return .failure(ICError.message(error: decoded.message))
                    
                } else {
                    return .failure(ICError.message(error: "unknown"))
                }
                
            } catch {
                return .failure(ICError.fail(reason: .parsing))
            }
        }
    }
    
    /// Request asynchronously
    public func async(_ completion: @escaping (Result<T, ICError>) -> Void){
        self.send { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
                return
                
            case .success(let data):
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
                    
                    if let jsonResult = json["result"] {
                        if let jsonRes = jsonResult as? T {
                            // icx_sendTransaction
                            completion(.success(jsonRes))
                            return
                            
                        } else if let jsonRes = jsonResult as? [String : Any] {
                            // icx_getBlockByHeight, icx_getBlockByHash, icx_getTransactionResult, icx_getTransactionByHash, icx_getTransactionResult, icx_getTransactionByHash
                            let resultData = try JSONSerialization.data(withJSONObject: jsonRes, options: .prettyPrinted)
                            let decoded = try decoder.decode(T.self, from: resultData)
                            completion(.success(decoded))
                            return
                            
                        } else if let jsonRes = jsonResult as? [Any] {
                            // icx_getScoreApi
                            let resultData = try JSONSerialization.data(withJSONObject: jsonRes, options: .prettyPrinted)
                            let decoded = try decoder.decode(T.self, from: resultData)
                            completion(.success(decoded))
                            return
                            
                        } else {
                            // icx_getBalance, icx_getTotalSupply
                            guard let bigStr = jsonResult as? String, let bigVal = bigStr.hexToBigUInt() as? T else {
                                completion(.failure(ICError.fail(reason: .parsing)))
                                return
                            }
                            completion(.success(bigVal))
                            return
                        }
                        
                    } else if let error = json["error"] {
                        let errorData = try JSONSerialization.data(withJSONObject: error, options: .prettyPrinted)
                        let decoded = try decoder.decode(Response.ResponseError.self, from: errorData)
                        completion(.failure(ICError.message(error: decoded.message)))
                        return
                        
                    } else {
                        completion(.failure(ICError.message(error: "unknown")))
                        return
                    }
                } catch {
                    completion(.failure(ICError.fail(reason: .parsing)))
                    return
                }
            }
        }
    }
}

extension ICONService {
    /// getLastBlock
    ///
    /// - Returns: `Request<Response.ResultInfo>`
    public func getLastBlock() -> Request<Response.ResultInfo> {
        return Request<Response.ResultInfo>(id: self.getID(), provider: self.provider, method: .getLastBlock, params: nil)
    }
    
    /// getBlockByHeight
    ///
    /// - Parameters:
    ///   - height: A height of block.
    /// - Returns: `Request<Response.ResultInfo>`
    public func getBlock(height: UInt64) -> Request<Response.ResultInfo> {
        return Request<Response.ResultInfo>(id: self.getID(), provider: self.provider, method: .getBlockByHeight, params: ["height": "0x" + String(height, radix: 16)])
    }
    
    /// getBlockByHash
    ///
    /// - Parameters:
    ///   - hash: A hash of block.
    /// - Returns: `Request<Response.ResultInfo>`
    public func getBlock(hash: String) -> Request<Response.ResultInfo> {
        return Request<Response.ResultInfo>(id: self.getID(), provider: self.provider, method: .getBlockByHash, params: ["hash": hash])
    }
    
    /// getBalance
    ///
    /// - Parameters:
    ///   - address: A address.
    /// - Returns: `Request<BigUInt>`
    public func getBalance(address: String) -> Request<BigUInt> {
        return Request<BigUInt>(id: self.getID(), provider: self.provider, method: .getBalance, params: ["address": address])
    }

    /// getScoreApi
    ///
    /// - Parameters:
    ///   - scoreAddress: A String
    /// - Returns: `Request<[Response.API]>`
    public func getScoreAPI(scoreAddress: String) -> Request<[Response.API]> {
        return Request<[Response.API]>(id: self.getID(), provider: self.provider, method: .getScoreAPI, params: ["address": scoreAddress])
    }
    
    /// getTotalSupply
    ///
    /// - Returns: `Request<BigUInt>`
    public func getTotalSupply() -> Request<BigUInt> {
        return Request<BigUInt>(id: self.getID(), provider: self.provider, method: .getTotalSupply, params: nil)
    }
    
    /// getTransactionResult
    ///
    /// - Parameters:
    ///   - hash: A hash of transaction.
    /// - Returns: `Request<Response.TransactionByHashResult>`
    public func getTransaction(hash: String) -> Request<Response.TransactionByHashResult> {
        return Request<Response.TransactionByHashResult>(id: self.getID(), provider: self.provider, method: .getTransactionByHash, params: ["txHash": hash])
    }
    
    /// getTransactionByHash
    ///
    /// - Parameters:
    ///   - hash: A hash of transaction.
    /// - Returns: `Request<Response.Result>`
    public func getTransactionResult(hash: String) -> Request<Response.Result> {
        return Request<Response.Result>(id: self.getID(), provider: self.provider, method: .getTransactionResult, params: ["txHash": hash])
    }
}
