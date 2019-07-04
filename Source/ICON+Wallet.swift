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
import scrypt


// MARK: Wallet

open class Wallet {
    public let key: KeyPair
    public let address: String
    public var keystore: Keystore?
    
    private init(privateKey: PrivateKey) {
        let publicKey = Cipher.createPublicKey(privateKey: privateKey)!
        
        self.address = Cipher.makeAddress(privateKey, publicKey)
        self.key = KeyPair(publicKey: publicKey, privateKey: privateKey)
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
    
    public convenience init(keystore: Keystore, password: String) throws {
        let extracted = try keystore.extract(password: password)
        guard let pubKey = Cipher.createPublicKey(privateKey: extracted) else { throw ICError.invalid(reason: .malformedKeystore) }
        let address = Cipher.makeAddress(extracted, pubKey)
        
        guard address == keystore.address else { throw ICError.invalid(reason: .wrongPassword) }
        
        self.init(privateKey: extracted)
        self.keystore = keystore
    }
    
    public class func generatePrivateKey() -> PrivateKey {
        var key = ""
        
        for _ in 0..<64 {
            let code = arc4random() % 16
            
            key += String(format: "%x", code)
        }
        let data = key.hexToData()!.sha3(.sha256)
        let privateKey = PrivateKey(hex: data)
        return privateKey
    }
    
    /// Signing
    ///
    /// - Parameters:
    ///   - data: Data
    /// - Returns: Signed.
    /// - Throws: exceptions
    public func getSignature(data: Data) throws -> String {
        let hash = data.sha3(.sha256)
        
        let sign = try Cipher.signECDSA(hashedMessage: hash, privateKey: key.privateKey)
        
        return sign.base64EncodedString()
        
    }
}

extension Wallet: Storable {
    
}
