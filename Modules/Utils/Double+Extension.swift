//
//  Double+Extension.swift
//  Utils
//
//  Created by 김윤석 on 2023/08/21.
//

import Foundation

extension Double {
    public func decimalDigits(_ digits: Int) -> String {
        return String(format: "%.\(digits)f", self)
    }
}
