//
//  MockRESTApiManager.swift
//  AQX
//
//  Created by 김윤석 on 2023/09/01.
//
import Models
import Service
import Foundation

public class MockRESTApiManager: RESTApiProtocol {
    public func request<T>(url: URL) async -> Result<T, Service.APIError> where T : Decodable {
        .success(MockData.crypto as! T)
    }
    
    public init() { }
}
