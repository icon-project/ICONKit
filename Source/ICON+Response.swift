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

// ICON Response Decodable

open class Response {
    
    enum CodingKeys: String, CodingKey {
        case jsonrpc
        case id
        case error
        case result
    }
    
    open class ResponseError: Decodable {
        var code: Int
        var message: String
    }
    
    open class CallData: Decodable {
        public var method: String
        public var params: [String: String]?
    }
    
    open class DeployData: Decodable {
        public var contentType: String
        public var content: String
        public var params: [String: String]?
    }
    
    public enum DataValue: Decodable {
        case call(CallData)
        case deploy(DeployData)
        case message(String)
        
        public init(from decoder: Decoder) throws {
            if let call = try? decoder.singleValueContainer().decode(CallData.self) {
                self = .call(call)
                return
            } else if let deploy = try? decoder.singleValueContainer().decode(DeployData.self) {
                self = .deploy(deploy)
                return
            } else if let message = try? decoder.singleValueContainer().decode(String.self) {
                self = .message(message)
                return
            }
            
            throw DataValueError.missingValue
        }
        
        public enum DataValueError: Error {
            case missingValue
        }
    }
}

extension Response {
    open class Block: Decodable {
        public var version: String
        public var prevBlockHash: String
        public var merkleTreeRootHash: String
        public var timeStamp: Double
        public var confirmedTransactionList: [ConfirmedTransactionList]
        public var blockHash: String
        public var height: UInt64
        public var peerId: String
        public var signature: String

        open class ConfirmedTransactionList: Decodable {
            public var from: String
            public var to: String
            public var timestamp: String
            public var signature: String
            public var txHash: String
            
            public var version: String?
            public var nid: String?
            public var stepLimit: String?
            public var value: String?
            
            public var nonce: String?
            public var dataType: String?
            public var data: DataValue?
            
            public var fee: String?
            public var method: String?
        }
    }
}

extension Response {
    open class ScoreAPI: Decodable {
        public var type: String
        public var name: String
        public var inputs: [[String: String?]]
        public var outputs: [[String: String]]?
        public var readonly: String?
        public var payable: String?
    }
}

extension Response {
    // icx_getTransactionByHash
    open class TransactionByHashResult: Decodable {
        public var version: String
        public var from: String
        public var to: String
        public var value: String?
        public var stepLimit: String
        public var timestamp: String
        public var nid: String?
        public var nonce: String?
        public var txHash: String
        public var txIndex: String
        public var blockHeight: String
        public var blockHash: String
        public var signature: String
        public var dataType: String?
        public var data: DataValue?
    }
}


extension Response {
    // icx_getTransactionResult
    open class TransactionResult: Decodable {
        public var txHash: String
        public var blockHeight: String
        public var blockHash: String
        public var txIndex: String
        public var to: String
        public var stepUsed: String
        public var stepPrice: String
        public var cumulativeStepUsed: String
        public var eventLogs: [EventLog]?
        public var logsBloom: String?
        public var status: String
        public var failure: Failure?
        public var scoreAddress: String?
        
        open class EventLog: Decodable {
            public var scoreAddress: String
            public var indexed: [String]
            public var data: [String]?
        }
        
        open class Failure: Decodable {
            public var code: String
            public var message: String
        }
    }
}

extension Response {
    @available(*, unavailable)
    open class Call<T: Decodable>: Decodable {
        public var result: T?
    }
}

extension Response {
    open class StepCosts: Decodable {
        public var defaultValue: String
        public var contractCall: String
        public var contractCreate: String
        public var contractDestruct: String
        public var contractSet: String
        public var set: String
        public var replace: String
        public var delete: String
        public var input: String
        public var eventLog: String
        public var apiCall: String
        
        enum CodingKeys: String, CodingKey {
            case defaultValue = "default"
            case contractCall
            case contractCreate
            case contractDestruct
            case contractSet
            case set
            case replace
            case delete
            case input
            case eventLog
            case apiCall
        }
    }
}
