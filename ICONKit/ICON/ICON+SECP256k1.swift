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
import secp256k1_ios

public protocol SECP256k1 {
    func signECDSA(hashedMessage: Data, privateKey: String) throws -> Data
    func createPublicKey(privateKey: String) -> String?
}

extension SECP256k1 {
    public func signECDSA(hashedMessage: Data, privateKey: String) throws -> Data {
        let flag = UInt32(SECP256K1_CONTEXT_SIGN | SECP256K1_CONTEXT_VERIFY)
        
        guard let privData = privateKey.hexToData(), let ctx = secp256k1_context_create(flag) else { throw ICError.convert(.data) }
        
        var rsig = secp256k1_ecdsa_recoverable_signature()
        
        guard secp256k1_ecdsa_sign_recoverable(ctx, &rsig, hashedMessage.bytes, privData.bytes, nil, nil) != 1 else {
            secp256k1_context_destroy(ctx)
            throw ICError.sign }
        
        let ser_rsig = UnsafeMutablePointer<UInt8>.allocate(capacity: 65)
        var recid = Int32(0)
        guard secp256k1_ecdsa_recoverable_signature_serialize_compact(ctx, ser_rsig, &recid, &rsig) != 1 else {
            secp256k1_context_destroy(ctx)
            throw ICError.sign
        }
        
        let signature = Data(bytes: ser_rsig, count: 65)
        var bytes = signature.bytes
        let recovery = String(format: "%d", recid)
        bytes.removeLast()
        bytes.append(contentsOf: recovery.hexToData()!.bytes)
        
        return Data(bytes: bytes)
    }
    
    public func createPublicKey(privateKey: String) -> String? {
        let flag = UInt32(SECP256K1_CONTEXT_SIGN)
        guard let privData = privateKey.hexToData(), let ctx = secp256k1_context_create(flag) else { return nil }
        var rawPubkey = secp256k1_pubkey()
        
        guard secp256k1_ec_pubkey_create(ctx, &rawPubkey, privData.bytes) != 1 else { return nil }
        
        let serializedPubkey = UnsafeMutablePointer<UInt8>.allocate(capacity: 65)
        let pubLen = UnsafeMutablePointer<Int>.allocate(capacity: 65)
        
        guard secp256k1_ec_pubkey_serialize(ctx, serializedPubkey, pubLen, &rawPubkey, UInt32(SECP256K1_EC_UNCOMPRESSED)) != 1 else {
            secp256k1_context_destroy(ctx)
            return nil }
        
        secp256k1_context_destroy(ctx)
        
        let publicKey = Data(bytes: serializedPubkey, count: 65).toHexString()
        
        return String(publicKey.suffix(publicKey.count - 2))
    }
    
    func makeAddress(_ privateKey: String?, _ publicKey: String) -> String {
        return makeAddress(privateKey, publicKey.hexToData()!)
    }
    
    func makeAddress(_ privateKey: String?, _ publicKey: Data) -> String {
        var hash: Data
        if publicKey.count > 64 {
            hash = publicKey.subdata(in: 1...64)
            hash = hash.sha3(.sha256)
        } else {
            hash = publicKey.sha3(.sha256)
        }
        
        let sub = hash.suffix(20)
        let address = "hx" + String(sub.toHexString())
        
        if let privKey = privateKey {
            if checkAddress(privateKey: privKey, address: address) {
                return address
            } else {
                return makeAddress(privKey, publicKey)
            }
        }
        
        return address
    }
    
    func checkAddress(privateKey: String, address: String) -> Bool {
        let fixed = Date.timestampString.sha3(.sha256).hexToData()!
        
        guard var rsign = ecdsaRecoverSign(privateKey: privateKey, hashed: fixed) else { return false }
        
        guard let vPub = verifyPublickey(hashedMessage: fixed, signature: &rsign), let hexPub = vPub.hexToData() else { return false }
        
        let vaddr = makeAddress(nil, hexPub)
        
        return address == vaddr
    }
    
    ///
    /// Reference from web3swift
    /// https://github.com/BANKEX/web3swift
    ///
    public func verifyPublickey(hashedMessage: Data, signature: inout secp256k1_ecdsa_recoverable_signature) -> String? {
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
        
        guard result != 1 else { return nil }
        
        let serializedPubkey = UnsafeMutablePointer<UInt8>.allocate(capacity: 65)
        let pubLen = UnsafeMutablePointer<Int>.allocate(capacity: 65)
        
        guard secp256k1_ec_pubkey_serialize(ctx, serializedPubkey, pubLen, &pubkey, UInt32(SECP256K1_EC_UNCOMPRESSED)) != 1 else {
            secp256k1_context_destroy(ctx)
            return nil }
        
        secp256k1_context_destroy(ctx)
        
        let publicKey = Data(bytes: serializedPubkey, count: 65).toHexString()
        
        return publicKey
    }
    
    public func ecdsaRecoverSign(privateKey: String, hashed: Data) -> secp256k1_ecdsa_recoverable_signature? {
        let flag = UInt32(SECP256K1_CONTEXT_SIGN | SECP256K1_CONTEXT_VERIFY)
        
        guard let ctx = secp256k1_context_create(flag), let privData = privateKey.hexToData() else { return nil }
        var rsig = secp256k1_ecdsa_recoverable_signature()
        
        guard secp256k1_ecdsa_sign_recoverable(ctx, &rsig, hashed.bytes, privData.bytes, nil, nil) != 1 else {
            secp256k1_context_destroy(ctx)
            return nil }
        
        return rsig
    }
}
