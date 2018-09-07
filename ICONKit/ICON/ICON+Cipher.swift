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
import Security
import CryptoSwift
import scrypt

let PBE_DKLEN: Int = 32

public protocol Cipher {
    
}

extension Cipher {
    public func pbkdf2SHA1(password: String, salt: Data, keyByteCount: Int, round: Int) -> Data? {
        return pbkdf2(hash: .sha1, password: password, salt: salt, keyByteCount: keyByteCount, round: round)
    }
    
    public func pbkdf2SHA256(password: String, salt: Data, keyByteCount: Int, round: Int) -> Data? {
        return pbkdf2(hash: .sha256, password: password, salt: salt, keyByteCount: keyByteCount, round: round)
    }
    
    public func pbkdf2SHA512(password: String, salt: Data, keyByteCount: Int, round: Int) -> Data? {
        return pbkdf2(hash: .sha512, password: password, salt: salt, keyByteCount: keyByteCount, round: round)
    }
    
    public func pbkdf2(hash: HMAC.Variant, password: String, salt: Data, keyByteCount: Int, round: Int) -> Data? {
        let passwordData = password.data(using: .utf8)!

        print("begins \(Date.timestampString)")
        guard let key = try? PKCS5.PBKDF2(password: passwordData.bytes, salt: salt.bytes, iterations: round, keyLength: keyByteCount, variant: hash).calculate() else { return nil }
        print("ends \(Date.timestampString)")
        return Data(bytes: key)
    }
    
    public func encrypt(devKey:Data, data: Data, salt: Data) throws -> (cipherText: String, mac: String, iv: String) {
        let eKey: [UInt8] = Array(devKey.bytes[0..<PBE_DKLEN/2])
        let mKey: [UInt8] = Array(devKey.bytes[PBE_DKLEN/2..<PBE_DKLEN])
        
        let iv = AES.randomIV(AES.blockSize)
        
        let encrypted: [UInt8] = try AES(key: eKey, blockMode: CTR(iv: iv), padding: .noPadding).encrypt(data.bytes)
        
        let mac = mKey + encrypted
        let digest = mac.sha3(.keccak256)
        
        return (Data(bytes: encrypted).toHexString(), Data(bytes: digest).toHexString(), Data(iv).toHexString())
    }
    
    public func decrypt(devKey: Data, enc: Data, dkLen: Int, iv: Data) throws -> (decryptText: String, mac: String) {
        let eKey: [UInt8] = Array(devKey.bytes[0..<PBE_DKLEN/2])
        let mKey: [UInt8] = Array(devKey.bytes[PBE_DKLEN/2..<PBE_DKLEN])
        
        let decrypted: [UInt8] = try AES(key: eKey, blockMode: CTR(iv: iv.bytes), padding: .noPadding).decrypt(enc.bytes)
        
        let mac: [UInt8] = mKey + enc.bytes
        let digest = mac.sha3(.keccak256)
        
        return (Data(bytes: decrypted).toHexString(), Data(bytes: digest).toHexString())
    }
    
    public func scrypt(password: String, saltData: Data? = nil, dkLen: Int = 32, N: Int = 4096, R: Int = 6, P: Int = 1) -> Data? {
        let passwordData = password.data(using: .utf8)!
        var salt = Data()
        if let saltValue = saltData {
            salt = saltValue
        } else {
            let saltCount = 32
            var randomBytes = Array<UInt8>(repeating: 0, count: saltCount)
            let err = SecRandomCopyBytes(kSecRandomDefault, saltCount, &randomBytes)
            if err != errSecSuccess { return nil }
            salt = Data(bytes: randomBytes)
        }

        guard let scrypt = try? Scrypt(password: passwordData.bytes, salt: salt.bytes, dkLen: dkLen, N: N, r: R, p: P) else { return nil }
        guard let result = try? scrypt.calculate() else { return nil }

        return Data(bytes: result)
    }
    
    public func getHash(_ value: String) -> String {
        return value.sha3(.sha256)
    }
    
    public func getHash(_ value: Data) -> Data {
        return value.sha3(.sha256)
    }
}
