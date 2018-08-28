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


// MARK: Wallet

extension ICON.Wallet {
    
    public convenience init(keystore: ICON.Keystore) {
        self.init()
        self.keystore = keystore
    }
    
    public convenience init(privateKey: String?, password: String) {
        self.init()
        guard let keystore = self.createKeystore(privateKey, password) else { return }
        self.keystore = keystore
    }
    
    public convenience init?(rawData: Data) {
        do {
            let decoder = JSONDecoder()
            let keystore = try decoder.decode(ICON.Keystore.self, from: rawData)
            self.init(keystore: keystore)
        } catch {
            
        }
        return nil
    }
    
    private func generatePrivateKey() -> String {
        
        var key = ""
        
        for _ in 0..<64 {
            let code = arc4random() % 16
            
            key += String(format: "%x", code)
        }
        
        return key.sha3(.sha256)
    }
    
    private func createKeystore(_ privateKey: String?, _ password: String) -> ICON.Keystore? {
        do {
            var key: String
            if let prvKey = privateKey {
                key = prvKey
            } else {
                key = generatePrivateKey()
            }
            
            guard let publicKey = createPublicKey(privateKey: key), let pubData = publicKey.hexToData() else {
                return nil
            }
            
            let address = makeAddress(privateKey, pubData)
            
            let saltCount = 32
            var randomBytes = Array<UInt8>(repeating: 0, count: saltCount)
            let err = SecRandomCopyBytes(kSecRandomDefault, saltCount, &randomBytes)
            if err != errSecSuccess { return nil }
            let salt = Data(bytes: randomBytes)
            
            // HASH round
            let round = 16384
            
            guard let encKey = pbkdf2SHA256(password: password, salt: salt, keyByteCount: PBE_DKLEN, round: round) else {
                return nil
            }
            
            let result = try encrypt(devKey: encKey, data: key.hexToData()!, salt: salt)
            let kdfParam = ICON.Keystore.KDF(dklen: PBE_DKLEN, salt: salt.toHexString(), c: round, prf: "hmac-sha256")
            let crypto = ICON.Keystore.Crypto(ciphertext: result.cipherText, cipherparams: ICON.Keystore.CipherParams(iv: result.iv), cipher: "aes-128-ctr", kdf: "pbkdf2", kdfparams: kdfParam, mac: result.mac)
            let keyStore = ICON.Keystore(address: address, crypto: crypto)
            
            return keyStore
        } catch {
            return nil
        }
    }
    
    public func extractPrivateKey(password: String) throws -> String {
        guard let keystore = self.keystore else { throw ICError.empty }
        
        if keystore.crypto.kdf == "pbkdf2" {
            guard let enc = keystore.crypto.ciphertext.hexToData(),
                let iv = keystore.crypto.cipherparams.iv.hexToData(),
                let salt = keystore.crypto.kdfparams.salt.hexToData(),
                let count = keystore.crypto.kdfparams.c else { throw ICError.malformed }
            
            guard let devKey = pbkdf2SHA256(password: password, salt: salt, keyByteCount: ICON.Util.PBE_DKLEN, round: count) else { throw ICError.decrypt }
            
            let decrypted = try decrypt(devKey: devKey, enc: enc, dkLen: ICON.Util.PBE_DKLEN, iv: iv)
            let publicKey = createPublicKey(privateKey: decrypted.decryptText)
            let newAddress = makeAddress(decrypted.decryptText, publicKey!)
            
            if newAddress == keystore.address {
                return decrypted.decryptText
            }
            
            throw ICError.decrypt
        } else if keystore.crypto.kdf == "scrypt" {
            guard let n = keystore.crypto.kdfparams.n,
                let p = keystore.crypto.kdfparams.p,
                let r = keystore.crypto.kdfparams.r,
                let salt = keystore.crypto.kdfparams.salt.hexToData()
                else { throw ICError.malformed }
            
            guard let derived = scrypt(password: password, saltData: salt, dkLen: keystore.crypto.kdfparams.dklen, N: n, R: r, P: p) else { throw ICError.decrypt }
            let publicKey = createPublicKey(privateKey: derived)
            let newAddress = makeAddress(derived, publicKey!)
            
            if newAddress == keystore.address {
                return derived
            }
            
            throw ICError.decrypt
        }
        
        throw ICError.invalid(.notSupported)
    }
    
    public func changePassword(current: String, new: String) throws {
        let prvKey = try extractPrivateKey(password: current)
        
        guard let keystore = createKeystore(prvKey, new) else { throw ICError.encrypt }
        self.keystore = keystore
        
    }
    
    /// Signing
    ///
    /// - Parameters:
    ///   - password: Wallet's password
    ///   - data: Data
    /// - Returns: Signed.
    /// - Throws: exceptions
    public func getSignature(password: String, data: Data) throws -> String {
        
        let privateKey = try self.extractPrivateKey(password: password)
        
        let hash = data.sha3(.sha256)
        
        let sign = try signECDSA(hashedMessage: hash, privateKey: privateKey)
        
        return sign.base64EncodedString()
        
    }
    
    public func getID() -> Int {
        return Int(arc4random_uniform(6))
    }
    
}

