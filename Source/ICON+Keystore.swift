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
import scrypt
import CryptoSwift

public struct Keystore: Codable {
    public let version: Int = 3
    public var id: String = UUID().uuidString
    public var address: String
    public var crypto: Crypto
    public var coinType: String = "icx"
    
    public struct Crypto: Codable {
        public let ciphertext: String
        public let cipherparams: CipherParams
        public let cipher: String
        public let kdf: String
        public let kdfparams: KDF
        public let mac: String
    }
    
    public struct CipherParams: Codable {
        public let iv: String
    }
    
    public struct KDF: Codable {
        public let dklen: Int
        public let salt: String
        public var c: Int?
        public var n: Int?
        public var p: Int?
        public var r: Int?
        public var prf: String?
        
        init(dklen: Int, salt: String) {
            self.dklen = dklen
            self.salt = salt
        }
    }
    
    public init(address: String, crypto: Crypto) {
        self.address = address
        self.crypto = crypto
    }
}

extension Keystore {
    public func extract(password: String) throws -> PrivateKey {
        if crypto.kdf == "pbkdf2" {
            guard let enc = crypto.ciphertext.hexToData(),
                let iv = crypto.cipherparams.iv.hexToData(),
                let salt = crypto.kdfparams.salt.hexToData(),
                let count = crypto.kdfparams.c else { throw ICError.invalid(reason: .malformedKeystore) }
            
            guard let devKey = Cipher.pbkdf2SHA256(password: password, salt: salt, keyByteCount: PBE_DKLEN, round: count) else { throw ICError.fail(reason: .decrypt) }
            
            let decrypted = try Cipher.decrypt(devKey: devKey, enc: enc, dkLen: PBE_DKLEN, iv: iv)
            let decryptedText = decrypted.decryptText
            let prvKey = PrivateKey(hex: Data(hex: decryptedText))
            let pubKey = Cipher.createPublicKey(privateKey: prvKey)!
            let newAddress = Cipher.makeAddress(prvKey, pubKey)
            
            if newAddress == self.address {
                return prvKey
            }
            
            throw ICError.invalid(reason: .malformedKeystore)
        } else if crypto.kdf == "scrypt" {
            guard let n = crypto.kdfparams.n,
                let p = crypto.kdfparams.p,
                let r = crypto.kdfparams.r,
                let iv = crypto.cipherparams.iv.hexToData(),
                let cipherText = crypto.ciphertext.hexToData(),
                let salt = crypto.kdfparams.salt.hexToData() else { throw ICError.invalid(reason: .malformedKeystore) }
            
            guard let devKey = Cipher.scrypt(password: password, saltData: salt, dkLen: crypto.kdfparams.dklen, N: n, R: r, P: p) else { throw ICError.fail(reason: .decrypt) }
            let decryptionKey = devKey[0...15]
            let aesCipher = try AES(key: decryptionKey.bytes, blockMode: CTR(iv: iv.bytes), padding: .noPadding)
            let decryptedBytes = try aesCipher.decrypt(cipherText.bytes)
            let decrypted = Data(bytes: decryptedBytes)
            let prvKey = PrivateKey(hex: decrypted)
            let pubKey = Cipher.createPublicKey(privateKey: prvKey)!
            let newAddress = Cipher.makeAddress(prvKey, pubKey)
            
            if newAddress == self.address { return prvKey }
            
            throw ICError.invalid(reason: .malformedKeystore)
        }
        throw ICError.invalid(reason: .malformedKeystore)
    }
    
    public func jsonData() throws -> Data {
        let encoder = JSONEncoder()
        
        return try encoder.encode(self)
    }
}

extension Wallet {
    private var R_STANDARD: Int {
        return 8
    }
    private var N_STANDARD: Int {
        return 1 << 14
    }
    private var P_STANDARD: Int {
        return 1
    }
    
    public func generateKeystore(password: String) throws {
        let prvKey = self.key.privateKey.data
        let address = Cipher.makeAddress(self.key.privateKey, self.key.publicKey)
        
        let salt = try Cipher.randomData(count: 32)
        
        let scrypt = try Scrypt(password: password.bytes, salt: salt.bytes, dkLen: 32, N: N_STANDARD, r: R_STANDARD, p: P_STANDARD)
        let derivedKey = try scrypt.calculate()
        
        let encrypted = try Cipher.encrypt(devKey: Data(derivedKey), data: prvKey, salt: salt)
        
        let cipherParams = Keystore.CipherParams(iv: encrypted.iv)
        var kdfParams = Keystore.KDF(dklen: PBE_DKLEN, salt: salt.hexEncodedString())
        kdfParams.n = N_STANDARD
        kdfParams.p = P_STANDARD
        kdfParams.r = R_STANDARD
        let crypto = Keystore.Crypto(ciphertext: encrypted.cipherText, cipherparams: cipherParams, cipher: "aes-128-ctr", kdf: "scrypt", kdfparams: kdfParams, mac: encrypted.mac)
        
        let keystore = Keystore(address: address, crypto: crypto)
        
        self.keystore = keystore
    }
}
