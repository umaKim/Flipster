//
//  Decodable+Extension.swift
//  AQX
//
//  Created by 김윤석 on 2023/08/23.
//

import Foundation

extension Decodable {
    public static func decode(with decoder: JSONDecoder = JSONDecoder(), from data: Data) throws -> Self? {
        do {
            let newdata = try decoder.decode(Self.self, from: data)
            return newdata
        } catch {
            return nil
        }
    }
}
