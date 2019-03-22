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

public protocol Storable {
    var keystore: Keystore? { get set }
}

extension Storable where Self: Wallet {
    /// Save keystore file as JSON
    ///
    /// - Parameter filepath: A path for file.
    /// - Throws: Throw an error if keystore is nil.
    public func save(filepath: URL) throws {
        guard let keystore = self.keystore else { throw ICError.emptyKeystore }
        
        let data = try keystore.jsonData()
        
        try data.write(to: filepath)
    }
    
    /// Load keystore from JSON data
    ///
    /// - Parameter keystore: Data encoded as JSON
    /// - Throws: Throw an error if keystore is malfored.
    public mutating func load(raw keystore: Data) throws {
        let decoder = JSONDecoder()
        
        self.keystore = try decoder.decode(Keystore.self, from: keystore)
    }
    
    public mutating func load(path: URL) throws {
        let data = try Data(contentsOf: path)
        
        try self.load(raw: data)
    }
}
