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

open class ICONRequest {
    
    var provider: URL
    var method: ICON.METHOD
    var params: [String: Any]
    var id: Int
    
    public func asURLRequest() -> URLRequest {
        var url = provider.appendingPathComponent("api")
        url = url.appendingPathComponent("v3")
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 60)
        request.httpMethod = "POST"
        let req = ["jsonrpc": "2.0", "method": method.rawValue, "params": params, "id": id] as [String: Any]
        let data = try! JSONSerialization.data(withJSONObject: req, options: [])
        if request.value(forHTTPHeaderField: "Content-Type") == nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        request.httpBody = data
        
        return request
    }
    
    init(provider: URL, method: ICON.METHOD, params: [String: Any], id: Int) {
        self.provider = provider
        self.method = method
        self.params = params
        self.id = id
    }
    
    var timestamp: String {
        return Date.timestampString
    }
}
