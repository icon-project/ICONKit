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

extension BigUInt {
    /// Convert BigUInt value to HEX String.
    ///
    /// - Parameters:
    ///   - unit: The unit of BigUInt. default = `.loop`
    /// - Returns: The HEX `String` converted to loop from BigUInt.
    public func toHexString(unit: Unit = .loop) -> String {
        var val = self
        
        switch unit {
        case .gLoop:
            val = val.convert(unit: .gLoop)
        case .icx:
            val = val.convert()
        default: break
        }
        let valString = String(val, radix: 16)
        return "0x" + valString
    }
}

extension String {
    /// Convert HEX String to BigUInt.
    ///
    /// - Parameters:
    ///   - unit: The unit of String value.
    /// - Returns: Returns `BigUInt` or `nil`.
    public func hexToBigUInt(unit: Unit = .loop) -> BigUInt? {
        guard let value = BigUInt(self.prefix0xRemoved(), radix: 16) else {
            return nil
        }
        switch unit {
        case .gLoop:
            return value.convert(unit: .gLoop)
        case .icx:
            return value.convert(unit: .icx)
        default:
            return value
        }
    }
}

extension String {
    /// Convert HEX String to Date
    ///
    /// - Returns: `Date` or `nil`.
    public func hexToDate() -> Date? {
        guard let value = Int(self.prefix0xRemoved(), radix: 16) else {
            return nil
        }
        return Date(timeIntervalSince1970: Double(value)/1000000.0)
    }
}

extension BigUInt {
    /// Convert ICX or gLoop value to loop.
    ///
    /// - Parameters:
    ///   - unit: The Unit of value. default = `.icx`.
    /// - Returns: Returns `BigUInt` value converted to loop.
    public func convert(unit: Unit = .icx) -> BigUInt {
        let base: BigInt = 10
        let power: BigUInt = BigUInt(base.power(unit.rawValue))
        switch unit {
        case .gLoop:
            let result = self.multiplied(by: power)
            return result
        case .icx:
            let result = self.multiplied(by: power)
            return result
        default:
            return self
        }
    }
}


