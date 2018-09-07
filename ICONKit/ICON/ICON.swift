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

/// ICX Keystore struct
public struct ICON {
    public struct Keystore: Codable {
        let version: Int = 3
        let id: String = UUID().uuidString
        public var address: String
        public var crypto: Crypto
        public var coinType: String?
        
        init(address: String, crypto: Crypto) {
            self.address = address
            self.crypto = crypto
        }
        
        public struct Crypto: Codable {
            public var ciphertext: String
            public var cipherparams: CipherParams
            public var cipher: String
            public var kdf: String
            var kdfparams: KDF
            var mac: String
        }
        
        public struct CipherParams: Codable {
            public var iv: String
        }
        
        public struct KDF: Codable {
            public let dklen: Int
            public var salt: String
            public var c: Int?
            public var n: Int?
            public var p: Int?
            public var r: Int?
            public let prf: String?
            
            init(dklen: Int, salt: String, c: Int, prf: String) {
                self.dklen = dklen
                self.salt = salt
                self.c = c
                self.prf = prf
            }
        }
    }
    
    open class Wallet: SECP256k1, Cipher {
        public var keystore: ICON.Keystore?
        public var address: String? {
            guard let keystore = self.keystore else { return nil }
            
            return keystore.address
        }
        public var rawData: Data? {
            guard let keystore = self.keystore else { return nil }
            do {
                let encoder = JSONEncoder()
                return try encoder.encode(keystore)
            } catch {
                
            }
            return nil
        }
        
        init() {}
    }
}

