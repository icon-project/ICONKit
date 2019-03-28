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
import secp256k1_ios
import CommonCrypto

let PBE_DKLEN: Int = 32

public struct Cipher {
    public static func pbkdf2SHA1(password: String, salt: Data, keyByteCount: Int, round: Int) -> Data? {
        return pbkdf2(hash: CCPBKDFAlgorithm(kCCPRFHmacAlgSHA1), password: password, salt: salt, keyByteCount: keyByteCount, round: round)
    }
    
    public static func pbkdf2SHA256(password: String, salt: Data, keyByteCount: Int, round: Int) -> Data? {
        return pbkdf2(hash: CCPBKDFAlgorithm(kCCPRFHmacAlgSHA256), password: password, salt: salt, keyByteCount: keyByteCount, round: round)
    }
    
    public static func pbkdf2SHA512(password: String, salt: Data, keyByteCount: Int, round: Int) -> Data? {
        return pbkdf2(hash: CCPBKDFAlgorithm(kCCPRFHmacAlgSHA512), password: password, salt: salt, keyByteCount: keyByteCount, round: round)
    }
    
    public static func pbkdf2(hash: CCPBKDFAlgorithm, password: String, salt: Data, keyByteCount: Int, round: Int) -> Data? {
        let passwordData = password.data(using: .utf8)!
        var derivedKeyData = Data(count: keyByteCount)
        var localVariables = derivedKeyData
        let derivationStatus = localVariables.withUnsafeMutableBytes { derivedKeyBytes in
            salt.withUnsafeBytes { saltBytes in
                CCKeyDerivationPBKDF(CCPBKDFAlgorithm(kCCPBKDF2),
                                     password, passwordData.count, saltBytes, salt.count,
                                     hash, UInt32(round),
                                     derivedKeyBytes, derivedKeyData.count)
            }
        }
        
        if (derivationStatus != 0) {
            return nil;
        }
        
        return localVariables
    }
    
    public static func encrypt(devKey:Data, data: Data, salt: Data) throws -> (cipherText: String, mac: String, iv: String) {
        let eKey: [UInt8] = Array(devKey.bytes[0..<PBE_DKLEN/2])
        let mKey: [UInt8] = Array(devKey.bytes[PBE_DKLEN/2..<PBE_DKLEN])
        
        let iv = AES.randomIV(AES.blockSize)
        
        let encrypted: [UInt8] = try AES(key: eKey, blockMode: CTR(iv: iv), padding: .noPadding).encrypt(data.bytes)
        
        let mac = mKey + encrypted
        let digest = mac.sha3(.keccak256)
        
        return (Data(bytes: encrypted).toHexString(), Data(bytes: digest).toHexString(), Data(iv).toHexString())
    }
    
    public static func decrypt(devKey: Data, enc: Data, dkLen: Int, iv: Data) throws -> (decryptText: String, mac: String) {
        let eKey: [UInt8] = Array(devKey.bytes[0..<PBE_DKLEN/2])
        let mKey: [UInt8] = Array(devKey.bytes[PBE_DKLEN/2..<PBE_DKLEN])
        
        let decrypted: [UInt8] = try AES(key: eKey, blockMode: CTR(iv: iv.bytes), padding: .noPadding).decrypt(enc.bytes)
        
        let mac: [UInt8] = mKey + enc.bytes
        let digest = mac.sha3(.keccak256)
        
        return (Data(bytes: decrypted).toHexString(), Data(bytes: digest).toHexString())
    }
    
    public static func scrypt(password: String, saltData: Data? = nil, dkLen: Int = 32, N: Int = 4096, R: Int = 6, P: Int = 1) -> Data? {
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
    
    public static func getHash(_ value: String) -> String {
        return value.sha3(.sha256)
    }
    
    public static func getHash(_ value: Data) -> Data {
        return value.sha3(.sha256)
    }
    
    public static func signECDSA(hashedMessage: Data, privateKey: PrivateKey) throws -> Data {
        let flag = UInt32(SECP256K1_CONTEXT_SIGN | SECP256K1_CONTEXT_VERIFY)
        let privData = privateKey.data
        guard let ctx = secp256k1_context_create(flag) else { throw ICError.fail(reason: .convert(to: .data)) }
        
        var rsig = secp256k1_ecdsa_recoverable_signature()
        
        guard secp256k1_ecdsa_sign_recoverable(ctx, &rsig, hashedMessage.bytes, privData.bytes, nil, nil) == 1 else {
            secp256k1_context_destroy(ctx)
            throw ICError.fail(reason: .sign) }
        
        let ser_rsig = UnsafeMutablePointer<UInt8>.allocate(capacity: 65)
        var recid = Int32(0)
        guard secp256k1_ecdsa_recoverable_signature_serialize_compact(ctx, ser_rsig, &recid, &rsig) == 1 else {
            secp256k1_context_destroy(ctx)
            throw ICError.fail(reason: .sign)
        }
        
        let signature = Data(bytes: ser_rsig, count: 65)
        var bytes = signature.bytes
        let recovery = String(format: "%d", recid)
        bytes.removeLast()
        bytes.append(contentsOf: recovery.hexToData()!.bytes)
        
        return Data(bytes: bytes)
    }
    
    public static func createRecoveryKey(privateKey: PrivateKey) -> PublicKey? {
        let prvKey = privateKey.data
        let flag = UInt32(SECP256K1_CONTEXT_SIGN)
        guard let ctx = secp256k1_context_create(flag) else { return nil }
        var rawPubkey = secp256k1_pubkey()
        
        guard secp256k1_ec_pubkey_create(ctx, &rawPubkey, prvKey.bytes) == 1 else { return nil }
        
        let serializedPubkey = UnsafeMutablePointer<UInt8>.allocate(capacity: 65)
        var pubLen = 65
        
        guard secp256k1_ec_pubkey_serialize(ctx, serializedPubkey, &pubLen, &rawPubkey, UInt32(SECP256K1_EC_UNCOMPRESSED)) == 1 else {
            secp256k1_context_destroy(ctx)
            return nil }
        
        secp256k1_context_destroy(ctx)
        
        return PublicKey(hex: Data(bytes: serializedPubkey, count: pubLen))
    }
    
    public static func createPublicKey(privateKey: PrivateKey) -> PublicKey? {
        let prvKey = privateKey.data
        let flag = UInt32(SECP256K1_CONTEXT_SIGN)
        guard let ctx = secp256k1_context_create(flag) else { return nil }
        var rawPubkey = secp256k1_pubkey()
        
        guard secp256k1_ec_pubkey_create(ctx, &rawPubkey, prvKey.bytes) == 1 else { return nil }
        
        let serializedPubkey = UnsafeMutablePointer<UInt8>.allocate(capacity: 65)
        var pubLen = 65
        
        guard secp256k1_ec_pubkey_serialize(ctx, serializedPubkey, &pubLen, &rawPubkey, UInt32(SECP256K1_EC_UNCOMPRESSED)) == 1 else {
            secp256k1_context_destroy(ctx)
            return nil }
        
        secp256k1_context_destroy(ctx)
        
        
        
        let serialized = Data(bytes: serializedPubkey, count: 65).toHexString()
        let covered = String(serialized.suffix(serialized.count - 2))
        
        
        let pubKey = PublicKey(hex: Data(hex: covered))
        return pubKey
    }
    
    public static func makeAddress(_ privateKey: PrivateKey?, _ pubKey: PublicKey) -> String {
        var hash: Data
        let publicKey = pubKey.data
        if publicKey.count > 64 {
            hash = publicKey.subdata(in: 1...64)
            hash = hash.sha3(.sha256)
        } else {
            hash = publicKey.sha3(.sha256)
        }
        let sub = hash.suffix(20)
        let address = "hx" + String(sub.toHexString())
        
        if let privKey = privateKey {
            if Cipher.checkAddress(privateKey: privKey, address: address) {
                return address
            } else {
                return makeAddress(privKey, pubKey)
            }
        }
        
        return address
    }
    
    public static func checkAddress(privateKey: PrivateKey, address: String) -> Bool {
        let fixed = Date.timestampString.data(using: .utf8)!.sha3(.sha256)
        
        guard var rsign = Cipher.ecdsaRecoverSign(privateKey: privateKey, hashed: fixed) else { return false }
        
        guard let vPub = Cipher.verifyPublickey(hashedMessage: fixed, signature: &rsign), let hexPub = vPub.hexToData() else { return false }
        let pubKey = PublicKey(hex: hexPub)
        let vaddr = makeAddress(nil, pubKey)
        
        return address == vaddr
    }
    
    ///
    /// Reference from web3swift
    /// https://github.com/BANKEX/web3swift
    ///
    public static func verifyPublickey(hashedMessage: Data, signature: inout secp256k1_ecdsa_recoverable_signature) -> String? {
        let flag = UInt32(SECP256K1_CONTEXT_VERIFY)
        
        guard let ctx = secp256k1_context_create(flag) else { return nil }
        
        var pubkey = secp256k1_pubkey()
        
        let result = hashedMessage.withUnsafeBytes { (ptr: UnsafePointer<UInt8>) -> Int32 in
            withUnsafePointer(to: &signature, { (sigPtr: UnsafePointer<secp256k1_ecdsa_recoverable_signature>) -> Int32 in
                withUnsafeMutablePointer(to: &pubkey, { (pubPtr: UnsafeMutablePointer<secp256k1_pubkey>) -> Int32 in
                    secp256k1_ecdsa_recover(ctx, pubPtr, sigPtr, ptr)
                })
            })
        }
        
        guard result == 1 else { return nil }
        
        let serializedPubkey = UnsafeMutablePointer<UInt8>.allocate(capacity: 65)
        var pubLen = 65
        
        guard secp256k1_ec_pubkey_serialize(ctx, serializedPubkey, &pubLen, &pubkey, UInt32(SECP256K1_EC_UNCOMPRESSED)) == 1 else {
            secp256k1_context_destroy(ctx)
            return nil }
        
        secp256k1_context_destroy(ctx)
        
        let publicKey = Data(bytes: serializedPubkey, count: 65).toHexString()
        
        return publicKey
    }
    
    public static func ecdsaRecoverSign(privateKey: PrivateKey, hashed: Data) -> secp256k1_ecdsa_recoverable_signature? {
        let flag = UInt32(SECP256K1_CONTEXT_SIGN | SECP256K1_CONTEXT_VERIFY)
        let privData = privateKey.data
        guard let ctx = secp256k1_context_create(flag) else { return nil }
        var rsig = secp256k1_ecdsa_recoverable_signature()
        
        guard secp256k1_ecdsa_sign_recoverable(ctx, &rsig, hashed.bytes, privData.bytes, nil, nil) == 1 else {
            secp256k1_context_destroy(ctx)
            return nil }
        
        return rsig
    }

    public static func randomData(count: Int) throws -> Data {
        var randomBytes = [UInt8](repeating: 0, count: count)
        let err = SecRandomCopyBytes(kSecRandomDefault, count, &randomBytes)
        if err != errSecSuccess { throw ICError.message(error: "Fault!") }
        let salt = Data(bytes: randomBytes)
        return salt
    }
}
