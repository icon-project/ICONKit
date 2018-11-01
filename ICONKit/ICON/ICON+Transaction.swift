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
    public var data: Codable?
    
    public init() {
        
    }
    
    convenience init(from: String, to: String, stepLimit: BigUInt, nid: String, value: BigUInt, nonce: String, dataType: String? = nil, data: Codable? = nil) {
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
    public func from(_ from: String) -> Transaction {
        self.from = from
        return self
    }
    
    @discardableResult
    public func to(_ to: String) -> Transaction {
        self.to = to
        return self
    }
    
    @discardableResult
    public func stepLimit(_ limit: BigUInt) -> Transaction {
        self.stepLimit = limit
        return self
    }
    
    @discardableResult
    public func nid(_ nid: String) -> Transaction {
        self.nid = nid
        return self
    }
    
    @discardableResult
    public func value(_ value: BigUInt) -> Transaction {
        self.value = value
        return self
    }
    
    @discardableResult
    public func nonce(_ nonce: String) -> Transaction {
        self.nonce = nonce
        return self
    }
    
    @discardableResult
    public func message(_ message: String) -> Transaction {
        self.dataType = "message"
        self.data = message
        return self
    }
    
    @discardableResult
    public func call(_ method: String) -> Transaction {
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
    public func params(_ params: [String: Any]) -> Transaction {
        if self.data == nil {
            self.data = ["params": params] as? Codable
        } else {
            if var dic = self.data as? [String: Any] {
                dic["params"] = params
                self.data = dic as? Codable
            }
        }
        return self
    }
}

extension Transaction: TransactionSigner {
    
}

open class SignedTransaction {
    public var transaction: Transaction
    public var key: String
    public var signature: String
    public var params: [String: Any]
    
    public init(transaction: Transaction, privateKey: String) throws {
        let value = try transaction.signTransaction(privateKey: privateKey)
        
        self.transaction = transaction
        self.key = privateKey
        self.signature = value.0
        self.params = value.1
    }
}

extension ICONService {
    public func sendTransaction(signedTransaction: SignedTransaction) -> Request<Response.TxHash> {
        return Request<Response.TxHash>(id: self.getID(), provider: self.provider, method: .sendTransaction, params: signedTransaction.params)
    }
}
