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
}

extension Response {
    open class Block: Decodable {
        public var result: ResultInfo
        
        open class ResultInfo: Decodable {
            public var version: String
            public var prevBlockHash: String
            public var merkleTreeRootHash: String
            public var timeStamp: Double
            public var confirmedTransactionList: [ConfirmedTransactionList]
            public var blockHash: String
            public var height: UInt
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
                
                // https://stackoverflow.com/a/47319012
                // https://stackoverflow.com/a/50067514
                public var data: DataValue?
                
                public var fee: String?
                public var method: String?
                
                public enum DataValue: Decodable {
                    case string(String)
                    case dataInfo(DataInfo)
                    
                    public init(from decoder: Decoder) throws {
                        if let string = try? decoder.singleValueContainer().decode(String.self) {
                            self = .string(string)
                            return
                        }

                        if let dataInfo = try? decoder.singleValueContainer().decode(DataInfo.self) {
                            self = .dataInfo(dataInfo)
                            return
                        }
                        throw DataValueError.missingValue
                    }
                    public enum DataValueError: Error {
                        case missingValue

                    }
                }
                
                open class DataInfo: Decodable {
                    public var method: String?
                    public var params: [String: String]?
                }
            }
        }
    }
}

extension Response {
    open class IntValue: Decodable {
        public var result: BigUInt
        
        public required init(from decoder: Decoder) throws {
            
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            let value = try container.decode(String.self, forKey: .result)
            let removed = value.prefix0xRemoved()
            guard let bigValue = BigUInt(removed, radix: 16) else {
                throw ICError.fail(reason: .parsing)
            }
            self.result = bigValue
        }
    }
}

extension Response {
    open class TxHash: Decodable {
        public var result: String
    }
}

extension Response {
    open class ScoreAPI: Decodable {
        public var result: [String: API]
        
        open class API: Decodable {
            public var type: String
            public var name: String
            public var inputs: [[String: String?]]
            public var outputs: [[String: String]]?
            public var readonly: String?
            public var payable: String?
        }
        
        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            let resultList = try container.decode([API].self, forKey: .result)
            
            var dic = [String: API]()
            
            for api in resultList {
                dic[api.name] = api
            }
            
            self.result = dic
        }
    }
}

extension Response {
    open class Balance: Decodable {
        public var result: String
    }
}

extension Response {
    open class Transaction: Decodable {
        public var result: Result
        
        open class Result: Decodable {
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
            
            open class DataInfo: Decodable {
                public var method: String
                public var params: [String: String]?
            }
            
            public enum DataValue: Decodable {
                case string(String)
                case dataInfo(DataInfo)
                
                public init(from decoder: Decoder) throws {
                    if let string = try? decoder.singleValueContainer().decode(String.self) {
                        self = .string(string)
                        return
                    }
                    
                    if let dataInfo = try? decoder.singleValueContainer().decode(DataInfo.self) {
                        self = .dataInfo(dataInfo)
                        return
                    }
                    throw DataValueError.missingValue
                }
                public enum DataValueError: Error {
                    case missingValue
                    
                }
            }
        }
    }
}


extension Response {
    open class TransactionResult: Decodable {
        public var result: Result
        
        open class Result: Decodable {
            public var txHash: String?
            public var blockHeight: String?
            public var blockHash: String?
            public var txIndex: String?
            public var to: String?
            public var stepUsed: String?
            public var stepPrice: String?
            public var cumulativeStepUsed: String?
            public var eventLogs: [EventLog]?
            public var logsBloom: String?
            public var status: String?
            public var failure: Failure?
            
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
}

extension Response {
    
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
