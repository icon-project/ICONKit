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

extension ICON {
    public struct TransactionData {
        let version = "0x3"
        public var from: String?
        public var to: String?
        public var value: BigUInt?
        public var stepLimit: BigUInt?
        public var timestamp: String {
            return Date.millieTimestampHex
        }
        public var nid: String = "0x1"
        public var nonce: String?
        public var dataType: String?
    }
    
    open class Transaction {
        var transactionData = TransactionData()
        
        public func from(_ from: String) -> Transaction {
            transactionData.from = from
            
            return self
        }
        
        public func to(_ to: String) -> Transaction {
            transactionData.to = to
            
            return self
        }
        
        public func value(_ value: BigUInt) -> Transaction {
            transactionData.value = value
            
            return self
        }
        
        public func stepLimit(_ stepLimit: BigUInt) -> Transaction {
            transactionData.stepLimit = stepLimit
            
            return self
        }
        
        public func networkID(_ nid: String) -> Transaction {
            transactionData.nid = nid
            
            return self
        }
        
        
    }
}
