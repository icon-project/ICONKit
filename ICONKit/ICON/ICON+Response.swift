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


// ICON Response Decodable
extension ICON {
    
    public struct Response {
        open class DecodableResponse: Decodable {
            public var jsonrpc: String = "2.0"
            public var id: Int = 0
            public var error: ResponseError?
            
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
        
        open class TxHash: DecodableResponse {
            public var result: String?
            
            public required init(from decoder: Decoder) throws {
                try super.init(from: decoder)
                
                let container = try decoder.container(keyedBy: CodingKeys.self)
                
                if container.contains(.result) {
                    self.result = try container.decode(String.self, forKey: .result)
                } else {
                    self.result = nil
                }
            }
        }
        
        open class ScoreAPI: DecodableResponse {
            public var result: [ApiResult]?
            
            open class ApiResult: Decodable {
                public var type: String
                public var name: String
                public var inputs: [[String: String?]]
                public var outputs: [[String: String]]?
                public var readonly: String?
                public var payable: String?
                
                enum ApiCodingKeys: String, CodingKey {
                    case type
                    case name
                    case inputs
                    case outputs
                    case readonly
                    case payable
                }
                
                public required init(from decoder: Decoder) throws {
                    let container = try decoder.container(keyedBy: ApiCodingKeys.self)
                    
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
                try super.init(from: decoder)
                
                let container = try decoder.container(keyedBy: CodingKeys.self)
                
                if container.contains(.result) {
                    self.result = try container.decode([ApiResult].self, forKey: .result)
                } else {
                    self.result = nil
                }
            }
        }
        
        open class Balance: DecodableResponse {
            public var result: String?
            
            public required init(from decoder: Decoder) throws {
                try super.init(from: decoder)
                
                let container = try decoder.container(keyedBy: CodingKeys.self)
                
                if container.contains(.result) {
                    self.result = try container.decode(String.self, forKey: .result)
                } else {
                    self.result = nil
                }
            }
        }
        
        open class StepPrice: DecodableResponse {
            public var result: String?
            
            public required init(from decoder: Decoder) throws {
                try super.init(from: decoder)
                
                let container = try decoder.container(keyedBy: CodingKeys.self)
                
                if container.contains(.result) {
                    self.result = try container.decode(String.self, forKey: .result)
                } else {
                    self.result = nil
                }
            }
        }
        
        open class StepCosts: DecodableResponse {
            public var result: CostResult?
            
            open class CostResult: Decodable {
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
                }
            }
            
            public required init(from decoder: Decoder) throws {
                try super.init(from: decoder)
                
                let container = try decoder.container(keyedBy: CodingKeys.self)
                
                if container.contains(.result) {
                    self.result = try container.decode(CostResult.self, forKey: .result)
                } else {
                    self.result = nil
                }
            }
        }
        
        open class MaxStepLimit: DecodableResponse {
            public var result: String?
            
            public required init(from decoder: Decoder) throws {
                try super.init(from: decoder)
                
                let container = try decoder.container(keyedBy: CodingKeys.self)
                
                if container.contains(.result) {
                    self.result = try container.decode(String.self, forKey: .result)
                } else {
                    self.result = nil
                }
            }
        }
        
        open class Call: DecodableResponse {
            public var result: Any?
            
            public required init(from decoder: Decoder) throws {
                try super.init(from: decoder)
                
                let container = try decoder.container(keyedBy: CodingKeys.self)
                
                if container.contains(.result) {
                    if let result = try? container.decode(String.self, forKey: .result) {
                        self.result = result
                    } else if let result = try? container.decode(Int.self, forKey: .result) {
                        self.result = result
                    }
                } else {
                    self.result = nil
                }
            }
        }
    }
}

