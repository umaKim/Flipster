//
//  Double+Extension.swift
//  Utils
//
//  Created by 김윤석 on 2023/08/21.
//

import Foundation

extension Double {
    public func decimalDigits(_ digits: Int) -> String? {
        let price = Decimal(floatLiteral: self)
        
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = digits
        formatter.minimumFractionDigits = digits
        
        return formatter.string(for: price)
    }
}
