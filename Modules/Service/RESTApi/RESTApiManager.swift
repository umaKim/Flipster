//
//  NetworkManager.swift
//  AQX
//
//  Created by 김윤석 on 2023/08/15.
//
import Utils
import Combine
import Foundation

public protocol RESTApiProtocol {
    func request<T: Decodable>(url: URL) async -> Result<T, APIError>
}

public final actor RESTApiManager: RESTApiProtocol {
    public init() { }
    
    public func request<T: Decodable>(url: URL) async -> Result<T, APIError> {
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let response = response as? HTTPURLResponse else {return .failure(.noResponse)}
            if response.statusCode == 429 { return .failure(.exceededTheRateLimit) }
            
            if let result = try? JSONDecoder().decode(T.self, from: data) {
                return .success(result)
            } else {
                return .failure(.noDataReturned)
            }
        } catch {
            return .failure(.noDataReturned)
        }
    }
}

/// API Errors
public enum APIError: Error {
    case noResponse
    case noDataReturned
    case invalidUrl
    case exceededTheRateLimit
}
