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

// MARK: Date
extension Date {
    public static var timestampString: String {
        let date = Date()
        let time = floor(date.timeIntervalSince1970)
        
        return String(format: "%.0f", time)
    }
    
    public static var millieTimestamp: String {
        let date = Date()
        let time = (date.timeIntervalSince1970 * 1000.0).rounded()
        
        return String(format: "%.0f", time)
    }
    
    public static var millieTimestampHex: String {
        let date = Date()
        let time = (date.timeIntervalSince1970 * 1000.0)
        
        return "0x" + String(format: "%02x", time)
    }
    
    public static var microTimestamp: String {
        let date = Date()
        let time = (date.timeIntervalSince1970 * 1000 * 1000)
        
        return String(format: "%.0f", time)
    }
    
    public static var microTimestampHex: String {
        let date = Date()
        let time = UInt64(date.timeIntervalSince1970 * 1000 * 1000)
        
        return "0x" + String(format: "%llx", time)
    }
    
    public static var currentZuluTime: String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = "yyyy-MM-dd"
        var result = formatter.string(from: date)
        formatter.dateFormat = "HH-mm-ss.SSS"
        result = result + "T" + formatter.string(from: date) + "Z"
        
        return result
    }
    
    public var timestampString: String {
        return String(format: "%.0f", self.timeIntervalSince1970)
    }
    
    public var millieTimestamp: String {
        return String(format: "%.0f", self.timeIntervalSince1970 * 1000)
    }
    
    public var microTimestamp: String {
        return String (format: "%.0f", self.timeIntervalSince1970 * 1000 * 1000)
    }
    
    public func toString(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        
        return formatter.string(from: self)
    }
}

extension String {
    
    public func hexToData() -> Data? {
        let decimalSet = CharacterSet.decimalDigits
        let charSet = decimalSet.union(CharacterSet(charactersIn: "abcdefABCDEF"))
        
        if self.unicodeScalars.filter({ charSet.inverted.contains($0) }).count > 0 {
            return nil
        }
        
        var data = Data(capacity: self.count / 2)
        
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: self, range: NSMakeRange(0, utf16.count)) { match, flags, stop in
            let byteString = (self as NSString).substring(with: match!.range)
            var num = UInt8(byteString, radix: 16)!
            data.append(&num, count: 1)
        }
        
        guard data.count > 0 else { return nil }
        
        return data
    }
    
    public func prefix0xRemoved() -> String {
        var number = self
        if number.hasPrefix("0x") {
            number = String(number[number.index(number.startIndex, offsetBy: 2)..<number.endIndex])
        }
        
        return number
    }
    
    public func add0xPrefix() -> String {
        return "0x" + self
    }
    
    /// Convert string to Hex String
    ///
    /// - Returns: The `String` value.
    public func hexEncodedString() -> String? {
        guard let dataType = self.data(using: .utf8) else {
            return nil
        }
        let format = "%02hhx"
        let tmp = dataType.map { String(format: format, $0) }.joined()
        return tmp.add0xPrefix()
    }
}

// MARK : Data
extension Data {
    public func subdata(in range: ClosedRange<Index>) -> Data {
        return subdata(in: range.lowerBound ..< range.upperBound + 1)
    }
    
    public struct HexEncodingOptions: OptionSet {
        public let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
    
    public func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return map { String(format: format, $0) }.joined()
    }
}

extension Dictionary {
    public func toString() -> String? {
        do {
            let data = try JSONSerialization.data(withJSONObject: self, options: [])
            return String(data: data, encoding: .utf8)
        } catch {
            return nil
        }
    }
    
    public func toHexString() -> String? {
        do {
            let data = try JSONSerialization.data(withJSONObject: self, options: [])
            return data.hexEncodedString()
        } catch {
            return nil
        }
    }
}

// https://stackoverflow.com/a/46049763/1648275
struct JSONCodingKeys: CodingKey {
    var stringValue: String
    
    init?(stringValue: String) {
        self.stringValue = stringValue
    }
    
    var intValue: Int?
    
    init?(intValue: Int) {
        self.init(stringValue: "\(intValue)")
        self.intValue = intValue
    }
}

extension KeyedDecodingContainer {
    
    func decode(_ type: Dictionary<String, Any>.Type, forKey key: K) throws -> Dictionary<String, Any> {
        let container = try self.nestedContainer(keyedBy: JSONCodingKeys.self, forKey: key)
        return try container.decode(type)
    }
    
    func decodeIfPresent(_ type: Dictionary<String, Any>.Type, forKey key: K) throws -> Dictionary<String, Any>? {
        guard contains(key) else {
            return nil
        }
        guard try decodeNil(forKey: key) == false else {
            return nil
        }
        return try decode(type, forKey: key)
    }
    
    func decode(_ type: Array<Any>.Type, forKey key: K) throws -> Array<Any> {
        var container = try self.nestedUnkeyedContainer(forKey: key)
        return try container.decode(type)
    }
    
    func decodeIfPresent(_ type: Array<Any>.Type, forKey key: K) throws -> Array<Any>? {
        guard contains(key) else {
            return nil
        }
        guard try decodeNil(forKey: key) == false else {
            return nil
        }
        return try decode(type, forKey: key)
    }
    
    func decode(_ type: Dictionary<String, Any>.Type) throws -> Dictionary<String, Any> {
        var dictionary = Dictionary<String, Any>()
        
        for key in allKeys {
            if let boolValue = try? decode(Bool.self, forKey: key) {
                dictionary[key.stringValue] = boolValue
            } else if let stringValue = try? decode(String.self, forKey: key) {
                dictionary[key.stringValue] = stringValue
            } else if let intValue = try? decode(Int.self, forKey: key) {
                dictionary[key.stringValue] = intValue
            } else if let doubleValue = try? decode(Double.self, forKey: key) {
                dictionary[key.stringValue] = doubleValue
            } else if let nestedDictionary = try? decode(Dictionary<String, Any>.self, forKey: key) {
                dictionary[key.stringValue] = nestedDictionary
            } else if let nestedArray = try? decode(Array<Any>.self, forKey: key) {
                dictionary[key.stringValue] = nestedArray
            }
        }
        return dictionary
    }
}

extension UnkeyedDecodingContainer {
    
    mutating func decode(_ type: Array<Any>.Type) throws -> Array<Any> {
        var array: [Any] = []
        while isAtEnd == false {
            // See if the current value in the JSON array is `null` first and prevent infite recursion with nested arrays.
            if try decodeNil() {
                continue
            } else if let value = try? decode(Bool.self) {
                array.append(value)
            } else if let value = try? decode(Double.self) {
                array.append(value)
            } else if let value = try? decode(String.self) {
                array.append(value)
            } else if let nestedDictionary = try? decode(Dictionary<String, Any>.self) {
                array.append(nestedDictionary)
            } else if let nestedArray = try? decode(Array<Any>.self) {
                array.append(nestedArray)
            }
        }
        return array
    }
    
    mutating func decode(_ type: Dictionary<String, Any>.Type) throws -> Dictionary<String, Any> {
        
        let nestedContainer = try self.nestedContainer(keyedBy: JSONCodingKeys.self)
        return try nestedContainer.decode(type)
    }
}

extension BigUInt {
    var toHex: String {
        return "0x" + String(self, radix: 16)
    }
}
