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

open class Call {
    public var from: String
    public var to: String
    public var method: String
    public var params: [String: Any]?
    
    public init(from: String, to: String, method: String, params: [String: Any]?) {
        self.from = from
        self.to = to
        self.method = method
        self.params = params
    }
    
    public func getCallParams() -> [String: Any] {
        var params = [String: Any]()
        params["from"] = self.from
        params["to"] = self.to
        params["dataType"] = "call"
        var data = [String: Any]()
        data["method"] = self.method
        if let params = self.params {
            data["params"] = params
        }
        params["data"] = data
        
        return params
    }
}


extension ICONService {
    public func call(_ call: Call) -> Request<Response.Call> {
        return Request<Response.Call<T>>(id: self.getID(), provider: self.provider, method: .callMethod, params: call.getCallParams())
    }
}
