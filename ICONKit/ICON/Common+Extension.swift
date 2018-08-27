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

// MARK: Date
extension Date {
    public static var timestampString: String {
        let date = Date()
        let time = floor(date.timeIntervalSince1970)
        
        return String(format: "%.0f", time)
    }
    
    public static var millieTimestamp: String {
        let date = Date()
        let time = floor(date.timeIntervalSince1970)
        
        return String(format: "%.0f", time * 1000)
    }
    
    public static var microTimestamp: String {
        let date = Date()
        let time = floor(date.timeIntervalSince1970)
        
        return String(format: "%.0f", time * 1000 * 1000)
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
