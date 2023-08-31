//
//  URLConfigurable.swift
//  AQX
//
//  Created by 김윤석 on 2023/08/23.
//

import Foundation

public protocol UrlConfigurable { }

extension UrlConfigurable {
    /// Try to create url for endpoint
    /// - Parameters:
    ///   - endpoint: Endpoint to create for
    ///   - queryParams: Additional query arguments
    /// - Returns: Optional URL
    public func url(for baseUrl: String, queryParams: [String: String] = [:], with apiKey: [String : String] = [:]) -> URL? {
        var urlString = baseUrl
        
        var queryItems = [URLQueryItem]()
        // Add any parameters
        for (name, value) in queryParams {
            queryItems.append(.init(name: name, value: value))
        }
        
        // Add token
        if !apiKey.isEmpty {
            queryItems.append(.init(name: "\(apiKey.keys.first ?? "")", value: "\(apiKey.values.first ?? "")"))
        }
        // Convert queri items to suffix string
        urlString += "?" + queryItems.map { "\($0.name)=\($0.value ?? "")" }.joined(separator: "&")
        
        return URL(string: urlString)
    }
}
