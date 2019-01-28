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
import CryptoSwift


// MARK: Wallet

open class Wallet: SECP256k1 {
    private var privateKey: String?
    public var address: String {
        guard let key = self.privateKey, let publicKey = self.createPublicKey(privateKey: key) else { assertionFailure("Empty wallet")
            return ""
        }
        
        return self.makeAddress(key, publicKey)
    }
    
    public init() {
        self.privateKey = self.generatePrivateKey()
    }
}

extension Wallet {
    
    public convenience init(privateKey: String) {
        self.init()
        self.privateKey = privateKey
    }
    
    private func generatePrivateKey() -> String {
        
        var key = ""
        
        for _ in 0..<64 {
            let code = arc4random() % 16
            
            key += String(format: "%x", code)
        }
        
        return key.sha3(.sha256)
    }
    
    /// Signing
    ///
    /// - Parameters:
    ///   - password: Wallet's password
    ///   - data: Data
    /// - Returns: Signed.
    /// - Throws: exceptions
    public func getSignature(password: String, data: Data) throws -> String {
        guard let privateKey = self.privateKey else { throw ICError.empty }
        let hash = data.sha3(.sha256)
        
        let sign = try signECDSA(hashedMessage: hash, privateKey: privateKey)
        
        return sign.base64EncodedString()
        
    }
}

