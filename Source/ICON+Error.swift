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

public enum ICError: Error {
    
    /// Keys for Transaction
    ///
    public enum JSONParameterKey {
        /// Required
        case version, from, to, stepLimit, timestamp, nid, signature
        /// Optional
        case value, nonce, dataType, data
    }
    
    public enum InvalidReason {
        case missing(parameter: JSONParameterKey)
        case malformedKeystore
        case wrongPassword
    }
    
    public enum FailureReason {
        
        public enum ConvertFailure {
            case data
            case url(string: String)
        }
        
        case generateKey
        case sign
        case parsing
        case decrypt
        case convert(to: ConvertFailure)
    }
    
    case emptyKeystore
    case invalid(reason: InvalidReason)
    case fail(reason: FailureReason)
    case error(error: Error)
    case message(error: String)
}

extension ICError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .emptyKeystore:
            return "Empty keystore. Password required."
            
        case .invalid(reason: let reason):
            return "Invalid: \(reason)"
            
        case .fail(reason: let reason):
            return "Failed: \(reason)"
            
        case .message(error: let msg):
            return "Error occured. \(msg)"
            
        case .error(error: let error):
            return error.localizedDescription
        }
    }
}

extension ICError.JSONParameterKey {
    var localizedDescription: String {
        return "parameter. \(self)"
    }
}

extension ICError.InvalidReason {
    var localizedDescription: String {
        switch self {
        case .missing(parameter: let key):
            return "missing \(key.localizedDescription)"
            
        case .malformedKeystore:
            return "keystore data malformed."
            
        case .wrongPassword:
            return "wrong password."
        }
    }
}

extension ICError.FailureReason {
    var localizedDescription: String {
        switch self {
        case .generateKey:
            return "generate key"
            
        case .parsing:
            return "parsing"
            
        case .sign:
            return "signing"
            
        case .decrypt:
            return "decrypt"
            
        case .convert(to: let to):
            return "convert to \(to)"
        }
    }
}
