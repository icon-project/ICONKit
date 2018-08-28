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

open class ICONService {
    static let jsonrpc = "2.0"
    static let API_VER = "v3"
    
    var provider: String
    
    init(provider: String) {
        self.provider = provider
    }
    
    convenience init(_ provider: String) {
        self.init(provider: provider)
    }
    
    open static func localTest() -> ICONService {
        return ICONService("http://52.79.233.89:9000")
    }
    
    open static func testNet() -> ICONService {
        return ICONService("https://testwallet.icon.foundation")
    }
    
    open static func mainNet() -> ICONService {
        return ICONService("https://wallet.icon.foundation")
    }
}
