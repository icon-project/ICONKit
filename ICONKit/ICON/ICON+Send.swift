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

protocol Sendable {
    var provider: String { get set }
    var method: ICON.METHOD { get set }
    var params: [String: Any]? { get set }
}

extension Sendable {
    public func getID() -> Int {
        return Int(arc4random_uniform(9999))
    }
    
    func send() -> Result<Data, ICONResult> {
        guard let provider = URL(string: self.provider) else { return .failure(.provider) }
        let request = ICONRequest(provider: provider, method: method, params: params, id: self.getID())
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        var data: Data?
        var response: HTTPURLResponse?
        var error: Error?
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let task = session.dataTask(with: request.asURLRequest()) {
            data = $0
            response = $1 as? HTTPURLResponse
            error = $2
            
            semaphore.signal()
        }
        task.resume()
        
        _ = semaphore.wait(timeout: .distantFuture)
        guard error == nil else {
            return .failure(ICONResult.httpError)
        }
        
        guard let value = data else { return .failure(ICONResult.httpError) }
        guard response?.statusCode == 200 else {
            return .failure(ICONResult.httpError)
        }
        
        return .success(value)
    }
}

private class ICONRequest {
    
    var provider: URL
    var method: ICON.METHOD
    var params: [String: Any]?
    var id: Int
    var timestamp: String
    
    public func asURLRequest() -> URLRequest {
        var url = provider.appendingPathComponent("api")
        url = url.appendingPathComponent("v3")
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 60)
        request.httpMethod = "POST"
        var req = ["jsonrpc": "2.0", "method": method.rawValue, "id": id] as [String: Any]
        if let param = params {
            req["params"] = param
        }
        do {
            let data = try JSONSerialization.data(withJSONObject: req, options: [])
            request.httpBody = data
        } catch {
            return request
        }
        if request.value(forHTTPHeaderField: "Content-Type") == nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        return request
    }
    
    init(provider: URL, method: ICON.METHOD, params: [String: Any]?, id: Int) {
        self.provider = provider
        self.method = method
        self.params = params
        self.id = id
        self.timestamp = Date.timestampString
    }
}
