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
    private var privateKey: PrivateKey
    public var address: String {
        guard let publicKey = self.createPublicKey(privateKey: self.privateKey) else { assertionFailure("Empty wallet")
            return ""
        }
        
        return self.makeAddress(self.privateKey, publicKey)
    }
    
    private init(privateKey: PrivateKey) {
        self.privateKey = privateKey
    }
}

extension Wallet {
    
    public convenience init(privateKey prvKey: PrivateKey?) {
        if let key = prvKey {
            self.init(privateKey: key)
        } else {
            let prvKey = Wallet.generatePrivateKey()
            self.init(privateKey: prvKey)
        }
    }
    
    class func generatePrivateKey() -> PrivateKey {
        var key = ""
        
        for _ in 0..<64 {
            let code = arc4random() % 16
            
            key += String(format: "%x", code)
        }
        let data = key.hexToData()!.sha3(.sha256)
        let privateKey = PrivateKey(hexData: data)
        return privateKey
    }
    
    /// Signing
    ///
    /// - Parameters:
    ///   - password: Wallet's password
    ///   - data: Data
    /// - Returns: Signed.
    /// - Throws: exceptions
    public func getSignature(password: String, data: Data) throws -> String {
        let hash = data.sha3(.sha256)
        
        let sign = try signECDSA(hashedMessage: hash, privateKey: privateKey)
        
        return sign.base64EncodedString()
        
    }
}

