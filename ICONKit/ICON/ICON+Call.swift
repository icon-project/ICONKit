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

public protocol CallProtocol {
}

public extension CallProtocol {
    
}

extension ICON {
    public struct CallData: Encodable, CallProtocol {
        var from: String?
        var to: String?
        var dataType: String?
        var data: Data?
        
        public struct Data: Encodable {
            var method: String
            var params: String
            
            enum DataCodingKeys: String, CodingKey {
                case method
                case params
            }
        }
    }
    
    open class Call {
        var callData = CallData()

        public func to(_ address: String) -> Call {
            self.callData.to = address

            return self
        }

        public func from(_ address: String) -> Call {
            self.callData.from = address

            return self
        }

        public func dataType(_ type: String) -> Call {
            self.callData.dataType = type

            return self
        }

        public func method(_ method: String) -> Call {
            self.callData.data?.method = method

            return self
        }

        public func data(_ data: ICON.CallData.Data) -> Call {
            self.callData.data = data

            return self
        }
    }
    
    open class NameCall: Call, CallProtocol {
        public var result: returnType = ""
        public typealias returnType = String
        
    }
}
