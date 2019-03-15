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
    public func execute() -> Result<T, ICONResult> {
        let result = self.send()
        
        switch result {
        case .failure(let error):
            return .failure(error)
            
        case .success(let data):
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            do {
                let decoded = try decoder.decode(T.self, from: data)
                
                return .success(decoded)
            } catch {
                return .failure(ICONResult.parsing)
            }
        }
    }
    
    public func async(_ completion: @escaping (Result<T, ICONResult>) -> Void) {
        self.send { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
                return
                
            case .success(let data):
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                do {
                    let decoded = try decoder.decode(T.self, from: data)
                    completion(.success(decoded))
                    return
                } catch {
                    completion(.failure(ICONResult.parsing))
                    return
                }
            }
        }
    }
}

extension ICONService {
    /// Used to define whether to return `error` or `result`.
    ///
    /// - error: `Response.ResponseError`
    /// - result: T
    public enum Foo<T: Decodable>: Decodable {
        case error(Response.ResponseError)
        case result(T)
        
        public init(from decoder: Decoder) throws {
            if let error = try? decoder.singleValueContainer().decode(Response.ResponseError.self) {
                self = .error(error)
            }
            if let result = try? decoder.singleValueContainer().decode(T.self) {
                self = .result(result)
            }
            throw FooValueError.missingValue
        }
    }
    
    public enum FooValueError: Error {
        case missingValue
    }
    
    /// getLastBlock
    ///
    /// - Returns: `.error(Response.ResponseError)` or `.result(Response.ResultInfo)`.
    public func getLastBlock() -> Foo<Response.ResultInfo> {
        let response = Request<Response.Block>(id: self.getID(), provider: self.provider, method: .getLastBlock, params: nil).execute()
        guard let res = response.value?.result else {
            return .error((response.value?.error)!)
        }
        return .result(res)

    }
    
    /// getBlockByHeight
    ///
    /// - Parameters:
    ///   - height: A height of block.
    /// - Returns: `.error(Response.ResponseError)` or `.result(Response.ResultInfo)`.
    public func getBlock(height: UInt64) -> Foo<Response.ResultInfo> {
        let response = Request<Response.Block>(id: self.getID(), provider: self.provider, method: .getBlockByHeight, params: ["height": "0x" + String(height, radix: 16)]).execute()
        guard let res = response.value?.result else {
            return .error((response.value?.error)!)
        }
        return .result(res)
    }
    
    /// getBlockByHash
    ///
    /// - Parameters:
    ///   - hash: A hash of block.
    /// - Returns: `.error(Response.ResponseError)` or `.result(Response.ResultInfo)`.
    public func getBlock(hash: String) -> Foo<Response.ResultInfo> {
        let response = Request<Response.Block>(id: self.getID(), provider: self.provider, method: .getBlockByHash, params: ["hash": hash]).execute()
        guard let res = response.value?.result else {
            return .error((response.value?.error)!)
        }
        return .result(res)
    }
    
    /// getBalance
    ///
    /// - Parameters:
    ///   - address: A address.
    /// - Returns: `.error(Response.ResponseError)` or `.result(String)`.
    public func getBalance(address: String) -> Foo<String> {
        let response = Request<Response.Balance>(id: self.getID(), provider: self.provider, method: .getBalance, params: ["address": address]).execute()
        guard let res = response.value?.result else {
            return .error((response.value?.error)!)
        }
        return .result(res)
    }
    
    /// getBalance Asynchronously
    ///
    /// - Parameters:
    ///   - address: A address.
    public func getBalanceAsync(address: String, _ completion: @escaping(Foo<String>) -> Void) {
        Request<Response.Balance>(id: self.getID(), provider: self.provider, method: .getBalance, params: ["address": address]).async { (response) in
            if let res = response.value?.result {
                completion(.result(res))
                return
            } else {
                completion(.error((response.value?.error)!))
                return
            }
        }
    }
    
    /// getScoreApi
    ///
    /// - Parameters:
    ///   - scoreAddress: A String
    /// - Returns: `.error(Response.ResponseError)` or `.result(String)`
    public func getScoreAPI(scoreAddress: String) -> Foo<[String: Response.ScoreAPI.API]> {
        let response = Request<Response.ScoreAPI>(id: self.getID(), provider: self.provider, method: .getScoreAPI, params: ["address": scoreAddress]).execute()
        guard let res = response.value?.result else {
            return .error((response.value?.error)!)
        }
        return .result(res)
    }
    
    /// getTotalSupply
    ///
    /// - Returns: `BigUInt` or `nil`
    public func getTotalSupply() -> BigUInt? {
        let response = Request<Response.IntValue>(id: self.getID(), provider: self.provider, method: .getTotalSupply, params: nil).execute()
        guard let res = response.value?.result else {
            return nil
        }
        return res
    }
    
    /// getTransactionResult
    ///
    /// - Parameters:
    ///   - hash: A hash of transaction.
    /// - Returns: `.error(Response.ResponseError)` or `.result(Response.Result)`.
    public func getTransactionResult(hash: String) -> Foo<Response.Result> {
        let response = Request<Response.TransactionResult>(id: self.getID(), provider: self.provider, method: .getTransactionResult, params: ["txHash": hash]).execute()
        guard let res = response.value?.result else {
            return .error((response.value?.error)!)
        }
        return .result(res)
    }
    
    /// getTransactionByHash
    ///
    /// - Parameters:
    ///   - hash: A hash of transaction.
    /// - Returns: `.error(Response.ResponseError)` or `.result(Response.Transaction.Result)`.
    public func getTransaction(hash: String) -> Foo<Response.Transaction.Result> {
        let response = Request<Response.Transaction>(id: self.getID(), provider: self.provider, method: .getTransactionByHash, params: ["txHash": hash]).execute()
        guard let res = response.value?.result else {
            return .error((response.value?.error)!)
        }
        return .result(res)
    }
}
