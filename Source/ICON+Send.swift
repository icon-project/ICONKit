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
    
    func checkMethod(provider: URL) -> URL {
        var provider = provider
        
        while provider.lastPathComponent != ICONService.API_VER {
            provider = provider.deletingLastPathComponent()
        }
        provider = provider.deletingLastPathComponent()
        provider = provider.appendingPathComponent("debug")
        provider = provider.appendingPathComponent(ICONService.API_VER)
        
        return provider
    }
    
    func send() -> Result<Data, ICError> {
        guard var provider = URL(string: self.provider) else { return .failure(ICError.fail(reason: .convert(to: .url(string: self.provider)))) }
        
        if method == .estimateStep {
            provider = checkMethod(provider: provider)
        }
        
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
        if let connectError = error {
            return .failure(ICError.error(error: connectError))
        }
        
        guard let value = data else { return .failure(ICError.message(error: "Unknown Error")) }
        guard response?.statusCode == 200 || response?.statusCode == 400 || response?.statusCode == 500 else {
            let message = String(data: value, encoding: .utf8)
            return .failure(ICError.message(error: message ?? "Unknown Error"))
        }
        
        return .success(value)
    }
    
    func send(_ completion: @escaping ((Result<Data, ICError>) -> Void)) {
        guard var provider = URL(string: self.provider) else {
            completion(.failure(ICError.fail(reason: .convert(to: .url(string: self.provider)))))
            return
        }
        
        if method == .estimateStep {
            provider = checkMethod(provider: provider)
        }
        
        let request = ICONRequest(provider: provider, method: method, params: params, id: self.getID())
        
        let task = URLSession.shared.dataTask(with: request.asURLRequest()) { (data, response, error) in
            
            if let connectError = error {
                completion(.failure(ICError.error(error: connectError)))
            }
            
            guard let value = data else {
                completion(.failure(ICError.message(error: "Unknown Error")))
                return
            }
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 || response.statusCode == 400 || response.statusCode == 500 else {
                let message = String(data: value, encoding: .utf8)
                completion(.failure(ICError.message(error: message ?? "Unknown Error")))
                return
            }
            completion(.success(value))
            return
        }
        task.resume()
    }
}

private class ICONRequest {
    
    var provider: URL
    var method: ICON.METHOD
    var params: [String: Any]?
    var id: Int
    var timestamp: String
    
    public func asURLRequest() -> URLRequest {
        var request = URLRequest(url: self.provider, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 60)
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
