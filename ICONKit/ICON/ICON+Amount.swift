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

open class IconAmount {
    private var _value: BigUInt
    private var _unit: Unit
    
    init(amount: BigUInt, unit: Unit) {
        _value = amount
        _unit = unit
    }
    
    convenience init?(hexString: String, _ unit: Unit = .loop) {
        guard let value = BigUInt(hexString.prefix0xRemoved(), radix: 16) else {
            return nil
        }
        self.init(amount: value, unit: unit)
    }
    
    public var current: BigUInt {
        return _value * BigUInt(10).power(_unit.rawValue)
    }
    
    public var hex: String {
        return current.toHex
    }
    
    func convert(unit: Unit) -> BigUInt {
        return _value * BigUInt(10).power(Unit.icx.rawValue - unit.rawValue)
    }
}
