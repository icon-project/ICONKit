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
import BigInt

public enum Unit: Int {
    case icx = 18
    case gLoop = 9
    case loop = 0
}

public struct Converter {
    
}
extension Converter {
    /// Convert ICX or gLoop value to loop.
    ///
    /// - Parameters:
    ///   - value: The value convert to loop.
    ///   - unit: The Unit of value. `default = .icx`.
    /// - Returns: A value converted to loop.
    public static func convertToLoop(value: BigUInt, unit: Unit = .icx) -> BigUInt {
        let base: BigInt = 10
        let indices: BigUInt = BigUInt(base.power(unit.rawValue))
        switch unit {
        case .gLoop:
            let result = value.multiplied(by: indices)
            return result
        case .icx:
            let result = value.multiplied(by: indices)
            return result
        default:
            return value
        }
    }
}

extension BigUInt {
    /// Convert BigUInt to hexString.
    public var toHexString: String? {
        return "0x" + String(self, radix: 16)
    }
}

extension Data {
    /// Convert hexData to BigUInt.
    public var toBigUInt: BigUInt {
        return BigUInt(self)
    }

}


