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
    public enum METHOD: String {
        case sendTransaction = "icx_sendTransaction"
        case getBalance = "icx_getBalance"
        case getTransactionResult = "icx_getTransactionResult"
        case getLastBlock = "icx_getLastBlock"
        case getBlockByHash = "icx_getBlockByHash"
        case getBlockByHeight = "icx_getBlockByHeight"
        case getTotalSupply = "icx_getTotalSupply"
        case getTransactionByHash = "icx_getTransactionByHash"
        case callMethod = "icx_call"
        case getScoreAPI = "icx_getScoreApi"
        case estimateStep = "debug_estimateStep"
    }
    
    public struct Util {
        static let PBE_DKLEN: Int = 32
    
    }
}
