//
//  NetworkManager.swift
//  AQX
//
//  Created by 김윤석 on 2023/08/15.
//

import Combine
import Foundation

struct CoinCapAssetResponse: Codable  {
    let data: [CoinCapAsset]
}

struct SparklineIn7D: Codable {
    let price: [Double]
}

struct CoinCapAsset: Codable, Identifiable {
    let id, symbol, name: String
    let image: String
    let currentPrice : Double
    let marketCapRank : Int
    let marketCap, fullyDilutedValuation: Double?
    let totalVolume, high24H, low24H: Double?
    let priceChange24H, priceChangePercentage24H: Double
    let marketCapChange24H: Double?
    let marketCapChangePercentage24H: Double?
    let circulatingSupply, totalSupply, maxSupply, ath: Double?
    let athChangePercentage: Double?
    let athDate: String?
    let atl, atlChangePercentage: Double?
    let atlDate: String?
    let lastUpdated: String?
    let sparklineIn7D: SparklineIn7D?
    let priceChangePercentage24HInCurrency: Double?

    enum CodingKeys: String, CodingKey {
        case id, symbol, name, image
        case currentPrice = "current_price"
        case marketCap = "market_cap"
        case marketCapRank = "market_cap_rank"
        case fullyDilutedValuation = "fully_diluted_valuation"
        case totalVolume = "total_volume"
        case high24H = "high_24h"
        case low24H = "low_24h"
        case priceChange24H = "price_change_24h"
        case priceChangePercentage24H = "price_change_percentage_24h"
        case marketCapChange24H = "market_cap_change_24h"
        case marketCapChangePercentage24H = "market_cap_change_percentage_24h"
        case circulatingSupply = "circulating_supply"
        case totalSupply = "total_supply"
        case maxSupply = "max_supply"
        case ath
        case athChangePercentage = "ath_change_percentage"
        case athDate = "ath_date"
        case atl
        case atlChangePercentage = "atl_change_percentage"
        case atlDate = "atl_date"
        case lastUpdated = "last_updated"
        case sparklineIn7D = "sparkline_in_7d"
        case priceChangePercentage24HInCurrency = "price_change_percentage_24h_in_currency"
    }
}

final class NetworkManager {
    static let shared = NetworkManager()
    
    func request<T: Decodable>(url: URL?, expecting: T.Type) -> AnyPublisher<T, Error> {
        Future { promise in
            guard let url = url else { return
                promise(.failure(APIError.invalidUrl))}
            
            URLSession.shared.dataTask(with: url) { data, _, error in
                guard
                    let data = data,
                        error == nil
                else {
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        promise(.failure(APIError.noDataReturned))
                    }
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(expecting, from: data)
                    promise(.success(result))
                } catch {
                    promise(.failure(error))
                }
            }
            .resume()
        }
        .eraseToAnyPublisher()
    }
    
    /// API Errors
    private enum APIError: Error {
        case noDataReturned
        case invalidUrl
    }
}

extension NetworkManager {
    func url(for baseUrl: String, queryParams: [String: String] = [:], with apiKey: [String : String] = [:]) -> URL? {
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
