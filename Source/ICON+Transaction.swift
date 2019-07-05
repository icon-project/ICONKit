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
import BigInt

/// `Transaction` is the common supperclass of all Transction types.
///
/// Sending ICX
/// ````
/// let coinTransfer = Transaction()
///     .from(from)
///     .to(to)
///     .value(BigUInt(15000000))
///     .stepLimit(BigUInt(1000000))
///     .nid(nid)
///     .nonce("0x1")
/// ````
open class Transaction {
    public var version: String { return ICONService.ver }
    public var from: String?
    public var to: String?
    public var stepLimit: BigUInt?
    public var timestamp: String = Date.microTimestampHex
    public var nid: String?
    public var value: BigUInt?
    public var nonce: String?
    public var dataType: String?
    public var data: Any?
    
    public init() {
        
    }
    
    convenience init(from: String, to: String, stepLimit: BigUInt, nid: String, value: BigUInt? = nil, nonce: String? = nil, dataType: String? = nil, data: Any? = nil) {
        self.init()
        self.from = from
        self.to = to
        self.stepLimit = stepLimit
        self.nid = nid
        self.value = value
        self.nonce = nonce
        self.dataType = dataType
        self.data = data
    }
    
    @discardableResult
    public func from(_ from: String) -> Self {
        self.from = from
        return self
    }
    
    @discardableResult
    public func to(_ to: String) -> Self {
        self.to = to
        return self
    }
    
    @discardableResult
    public func stepLimit(_ limit: BigUInt) -> Self {
        self.stepLimit = limit
        return self
    }
    
    @discardableResult
    public func nid(_ nid: String) -> Self {
        self.nid = nid
        return self
    }
    
    @discardableResult
    public func value(_ value: BigUInt) -> Self {
        self.value = value
        return self
    }
    
    @discardableResult
    public func nonce(_ nonce: String) -> Self {
        self.nonce = nonce
        return self
    }
    
    func generateParams() -> [String : Any] {
        var params = [String : Any]()
        
        params["version"] = self.version
        params["from"] = self.from
        params["to"] = self.to
        
        params["value"] = self.value?.toHexString()
        params["timestamp"] = self.timestamp
        params["nid"] = self.nid
        params["dataType"] = self.dataType
        
        if let nonce = self.nonce {
            params["nonce"] = nonce
        }
        
        if var dic = self.data as? [String: Any] {
            if let method = dic["method"], let parameters = dic["params"] {
                params["data"] = ["method": method, "params": parameters]
            }
        } else if let message = self.data as? String {
            params["data"] = message
        }
        
        return params
    }
}

extension Transaction: TransactionSigner {
    
}

extension Transaction {
    public func toJSON() throws -> Data {
        let dic = try makeDic()
        
        return try JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
    }
    
    public func toDic() throws -> [String: Any] {
        var dic = [String: Any]()
        guard let from = self.from else { throw ICError.invalid(reason: .missing(parameter: .from))}
        guard let to = self.to else { throw ICError.invalid(reason: .missing(parameter: .to))}
        guard let nid = self.nid else { throw ICError.invalid(reason: .missing(parameter: .nid))}
        
        dic["version"] = self.version
        dic["timestamp"] = self.timestamp
        dic["from"] = from
        dic["to"] = to
        dic["nid"] = nid
        if let nonce = self.nonce {
            dic["nonce"] = nonce
        }
        if let stepLimit = self.stepLimit {
            dic["stepLimit"] = "0x" + String(stepLimit, radix: 16)
        }
        if let value = self.value {
            let hexValue = "0x" + String(value, radix: 16)
            dic["value"] = hexValue
        }
        if let dataType = self.dataType {
            if let data = self.data {
                dic["data"] = data
            }
            dic["dataType"] = dataType
        }
        
        return dic
    }
}

/// Transfer SCORE function call.
///
/// `CallTransaction` is a subclass of `Transaction` class.
/// ````
/// let call = CallTransaction()
///     .from(wallet.address)
///     .to(scoreAddress)
///     .stepLimit(BigUInt(1000000))
///     .nid(iconService.nid)
///     .nonce("0x1")
///     .method("transfer")
///     .params(["_to": to, "_value": "0x1234"])
/// ````
open class CallTransaction: Transaction {
    @discardableResult
    public func method(_ method: String) -> Self {
        self.dataType = "call"
        if self.data == nil {
            self.data = ["method": method]
        } else {
            if var dic = self.data as? [String: Any] {
                dic["method"] = method
                self.data = dic as? Codable
            }
        }
        return self
    }
    
    @discardableResult
    public func params(_ params: [String: Any]) -> Self {
        if self.data == nil {
            self.data = ["params": params]
        } else {
            if var dic = self.data as? [String: Any] {
                dic["params"] = params
                self.data = dic
            }
        }
        return self
    }
}

/// Transfer Message.
///
/// `MessageTransaction` is a subclass of `Transaction` class.
/// ````
/// let message = MessageTransaction()
///     .from(from)
///     .to(to)
///     .stepLimit(BigUInt(15000000))
///     .nonce("0x1")
///     .nid(nid)
///     .message("Hello, ICON!")
/// ````
open class MessageTransaction: Transaction {
    @discardableResult
    public func message(_ message: String) -> Self {
        self.dataType = "message"
        self.data = message.hexEncodedString()!
        return self
    }
}

open class SignedTransaction {
    public var transaction: Transaction
    public var key: PrivateKey
    public var signature: String
    public var params: [String: Any]
    
    /// Create a signedTransaction instance with the given transaction and privateKey.
    ///
    /// - Parameters:
    ///   - transaction: A `Transaction` that will be signed.
    ///   - privateKey: A `PrivateKey` that will be used to signing.
    public init(transaction: Transaction, privateKey: PrivateKey) throws {
        let value = try transaction.signTransaction(privateKey: privateKey)
        
        self.transaction = transaction
        self.key = privateKey
        self.signature = value.0
        self.params = value.1
    }
}

extension ICONService {
    /// Estimate step cost.
    ///
    /// Returns an estimated step of how much step is necessary to allow the transaction to complete.
    /// - Note: The estimation can be larger than the actual amount of step to be used by
    ///     the transaction for several reasons such as node performance.
    /// - Parameters:
    ///   - transaction: The transaction without stepLimit and signature.
    /// - Returns: The amount of an estimated step.
    public func estimateStep(transaction: Transaction) -> Request<BigUInt> {
        return Request(id: self.getID(), provider: self.provider, method: .estimateStep, params: transaction.generateParams())
    }
    
    /// Send transaction.
    ///
    /// - Parameters:
    ///   - signedTransaction: Signed Transaction and private key.
    /// - Returns: `Request<String>`.
    public func sendTransaction(signedTransaction: SignedTransaction) -> Request<String> {
        return Request<String>(id: self.getID(), provider: self.provider, method: .sendTransaction, params: signedTransaction.params)
    }
}
