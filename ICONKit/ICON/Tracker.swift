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
import Result

open class Tracker {
    public enum TrackerHost: String {
        case main = "https://tracker.icon.foundation"
        case dev = "https://trackerdev.icon.foundation"
        case local = "https://trackerlocaldev.icon.foundtaion"
    }
    
    var provider: TrackerHost
    
    init(provider: TrackerHost) {
        self.provider = provider
    }
    
    convenience init(_ provider: TrackerHost) {
        self.init(provider)
    }
    
    open static func main() -> Tracker {
        return Tracker(.main)
    }
    
    open static func dev() -> Tracker {
        return Tracker(.dev)
    }
    
    open static func local() -> Tracker {
        return Tracker(.local)
    }
}
