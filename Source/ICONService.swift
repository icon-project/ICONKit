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

open class ICONService {
    static let jsonrpc = "2.0"
    static let API_VER = "v3"
    static let ver = "0x3"
    
    public var nid: String
    
    public var provider: String
    
    public init(provider: String, nid: String) {
        self.provider = provider
        self.nid = nid
    }
}

extension ICONService {
    
}

extension ICONService {
    public func getID() -> Int {
        return Int(arc4random_uniform(9999))
    }    
}
