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

extension ICON {
    open class Keystore: Codable {
        public var version: Int = 3
        public var id: String = UUID().uuidString
        public var address: String
        public var crypto: Crypto
        public var coinType: String?
        
        enum KeystoreCodingKey: String, CodingKey {
            case version
            case id
            case address
            case crypto
            case Crypto
            case coinType
        }
        
        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: ICON.Keystore.KeystoreCodingKey.self)
            
            self.version = try container.decode(Int.self, forKey: .version)
            self.id = try container.decode(String.self, forKey: .id)
            self.address = try container.decode(String.self, forKey: .address)
            if container.contains(.crypto) {
                self.crypto = try container.decode(Crypto.self, forKey: .crypto)
            } else {
                self.crypto = try container.decode(Crypto.self, forKey: .Crypto)
            }
            
            if container.contains(.coinType) {
                self.coinType = try container.decode(String.self, forKey: .coinType)
            }
            self.coinType = nil
        }
        
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
}
