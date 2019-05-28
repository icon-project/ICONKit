//
//  Extensions.swift
//  ICONKit-example
//
//  Created by Seungyeon Lee on 28/05/2019.
//  Copyright © 2019 ICON Foundation. All rights reserved.
//

import Foundation
import BigInt

extension BigUInt {
    /// Convert loop to ICX
    public func convertToICX() -> BigUInt {
        return self / BigUInt(1000000000000000000)
    }
}
