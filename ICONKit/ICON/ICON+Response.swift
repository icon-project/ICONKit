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
    
    
    open class Response<T>: Decodable {
        public var jsonrpc: String
        public var id: Int
        public var error: ResponseError?
        public var result: T?
        
        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            self.jsonrpc = try container.decode(String.self, forKey: .jsonrpc)
            self.id = try container.decode(Int.self, forKey: .id)
            
            if container.contains(.error) {
                self.error = try container.decode(ResponseError.self, forKey: .error)
            } else {
                self.error = nil
            }
        }
    }
}

extension Response {
    open class Block: Decodable {
        
        public var version: String
        public var prevBlockHash: String
        public var merkleTreeRootHash: String
        public var timestamp: UInt
        public var confirmedTransactionList: [ConfirmedTransactionList]
        public var blockHash: String
        public var height: UInt
        public var perrID: String
        public var signature: String
        
        open class ConfirmedTransactionList: Decodable {
            
        }
    }
}

extension Response {
    open class IntValue: Decodable {
        public var value: BigUInt
        
        public required init(from decoder: Decoder) throws {
            
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            let result = try container.decode(String.self, forKey: .result)
            let removed = result.prefix0xRemoved()
            guard let bigValue = BigUInt(removed, radix: 16) else {
                throw ICONResult.parsing
            }
            self.value = bigValue
        }
    }
}

extension Response {
    open class TxHash: Decodable {
        public var value: String
        
        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            self.value = try container.decode(String.self, forKey: .result)
        }
    }
}

extension Response {
    open class ScoreAPI: Decodable {
        public var value: [String: API]
        
        open class API: Decodable {
            public var type: String
            public var name: String
            public var inputs: [[String: String?]]
            public var outputs: [[String: String]]?
            public var readonly: String?
            public var payable: String?
            
            enum ResultKeys: String, CodingKey {
                case type
                case name
                case inputs
                case outputs
                case readonly
                case payable
            }
            
            public required init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: ResultKeys.self)
                
                self.type = try container.decode(String.self, forKey: .type)
                self.name = try container.decode(String.self, forKey: .name)
                self.inputs = try container.decode([[String: String?]].self, forKey: .inputs)
                if container.contains(.outputs) {
                    self.outputs = try container.decode([[String: String]].self, forKey: .outputs)
                } else {
                    self.outputs = nil
                }
                if container.contains(.readonly) {
                    self.readonly = try container.decode(String.self, forKey: .readonly)
                } else {
                    self.readonly = nil
                }
                if container.contains(.payable) {
                    self.payable = try container.decode(String.self, forKey: .payable)
                } else {
                    self.payable = nil
                }
            }
        }
        
        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            let resultList = try container.decode([API].self, forKey: .result)
            
            var dic = [String: API]()
            
            for api in resultList {
                dic[api.name] = api
            }
            
            self.value = dic
        }
    }
}

extension Response {
    open class Balance: Decodable {
        public var value: String
        
        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            self.value = try container.decode(String.self, forKey: .result)
        }
    }
}

extension Response {
    open class Transaction: Decodable {
        public var value: Result
        
        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            self.value = try container.decode(Result.self, forKey: .result)
        }
        
        open class Result: Decodable {
            public var version: String
            public var from: String
            public var to: String
            public var value: String
            public var stepLimit: String
            public var timestamp: String
            public var nid: String
            public var nonce: String
            public var txHash: String
            public var txIndex: String
            public var blockHeight: String
            public var blockHash: String
            public var signature: String
            public var dataType: String?
            public var data: [String: Any]?
            public var dataString: String?
            
            public enum ResultKey: String, CodingKey {
                case version
                case from
                case to
                case value
                case stepLimit
                case timestamp
                case nid
                case nonce
                case txHash
                case txIndex
                case blockHeight
                case blockHash
                case signature
                case dataType
                case data
            }
            
            public required init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: ResultKey.self)
                
                self.version = try container.decode(String.self, forKey: .version)
                self.from = try container.decode(String.self, forKey: .from)
                self.to = try container.decode(String.self, forKey: .to)
                self.value = try container.decode(String.self, forKey: .value)
                self.stepLimit = try container.decode(String.self, forKey: .stepLimit)
                self.timestamp = try container.decode(String.self, forKey: .timestamp)
                self.nid = try container.decode(String.self, forKey: .nid)
                self.nonce = try container.decode(String.self, forKey: .nonce)
                self.txHash = try container.decode(String.self, forKey: .txHash)
                self.txIndex = try container.decode(String.self, forKey: .txIndex)
                self.blockHeight = try container.decode(String.self, forKey: .blockHeight)
                self.blockHash = try container.decode(String.self, forKey: .blockHash)
                self.signature = try container.decode(String.self, forKey: .signature)
                
                if container.contains(.dataType) {
                    self.dataType = try container.decode(String.self, forKey: .dataType)
                    
                    if container.contains(.data) {
                        if let dataString = try? container.decode(String.self, forKey: .data) {
                            self.dataString = dataString
                            self.data = nil
                        } else if let data = try? container.decode([String: Any].self, forKey: .data) {
                            self.data = data
                            self.dataString = nil
                        }
                    }
                } else {
                    self.dataType = nil
                    self.data = nil
                    self.dataString = nil
                }
            }
        }
    }
}

extension Response {
    open class TransactionResult: Decodable {
        public var value: Result
        
        open class Result: Decodable {
            public var status: String
            public var to: String
            public var txHash: String
            public var txIndex: String
            public var blockHeight: String
            public var blockHash: String
            public var cumulativeStepUsed: String
            public var stepUsed: String
            public var stepPrice: String
            public var scoreAddress: String?
            public var eventLogs: EventLog?
            public var logsBloom: String?
            public var failure: Failure?
            
            public enum ResultKey: String, CodingKey {
                case status, to, txHash, txIndex, blockHeight, blockHash, cumulativeStepUsed, stepUsed
                case stepPrice, scoreAddress, eventLogs, logsBloom, failure
            }
            
            open class EventLog: Decodable {
                public var scoreAddress: String
                public var indexed: [String]
                public var data: [String]
            }
            
            open class Failure: Decodable {
                public var code: String
                public var message: String
            }
            
            public required init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: ResultKey.self)
                
                self.status = try container.decode(String.self, forKey: .status)
                self.to = try container.decode(String.self, forKey: .to)
                self.txHash = try container.decode(String.self, forKey: .txHash)
                self.txIndex = try container.decode(String.self, forKey: .txIndex)
                self.blockHeight = try container.decode(String.self, forKey: .blockHeight)
                self.blockHash = try container.decode(String.self, forKey: .blockHash)
                self.cumulativeStepUsed = try container.decode(String.self, forKey: .cumulativeStepUsed)
                self.stepUsed = try container.decode(String.self, forKey: .stepUsed)
                self.stepPrice = try container.decode(String.self, forKey: .stepPrice)
                if container.contains(.scoreAddress) {
                    self.scoreAddress = try container.decode(String.self, forKey: .scoreAddress)
                }
                if container.contains(.eventLogs) {
                    self.eventLogs = try container.decode(EventLog.self, forKey: .eventLogs)
                }
                if container.contains(.logsBloom) {
                    self.logsBloom = try container.decode(String.self, forKey: .logsBloom)
                }
                if container.contains(.failure) {
                    self.failure = try container.decode(Failure.self, forKey: .failure)
                }
            }
        }
    }
}

extension Response {
    
    open class Call<T: Decodable>: Decodable {
        public var result: T?
        
        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            let result = try container.decode(T.self, forKey: .result)
            
            self.result = result
        }
    }
}

extension Response {
    
    open class StepCosts: Decodable {
        public var value: Result
        
        open class Result: Decodable {
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
        
        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            self.value = try container.decode(Result.self, forKey: .result)
        }
    }
}
