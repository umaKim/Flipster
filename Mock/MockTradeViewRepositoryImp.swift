//
//  MockTradeViewRepositoryImp.swift
//  AQX
//
//  Created by 김윤석 on 2023/09/01.
//
import Combine
import Service
import Models
import Foundation
@testable import TradeFeature

struct MockSocket: WebsocketRequestable, UrlConfigurable {
    func urlMaker() -> URL {
        url(for: "")!
    }
}

public class MockTradeViewRepositoryImp: TradeRepository {
    private let networkManager: RESTApiProtocol
    private let websocket: WebSocketApiProtocol
    
    public init(
        networkManager: RESTApiProtocol = MockRESTApiManager(),
        websocket: WebSocketApiProtocol = MockWebSocketApiManger()
    ) {
        self.networkManager = networkManager
        self.websocket = websocket
    }
    
    lazy public var dataPublisher: AnyPublisher<[Models.WebSocketDatum], Never> = dataSubject.eraseToAnyPublisher()
    private var dataSubject = PassthroughSubject<[Models.WebSocketDatum], Never>()
    
    var symbols: [String] = []
}

extension MockTradeViewRepositoryImp: WebSocketApiManagerDelegate {
    public func set(symbols: [String]) {
        self.symbols = symbols
    }
    
    public func connect() {
        websocket.register(delegate: self)
        websocket.connect(to: MockSocket())
    }
    
    public func disconnect() {
        websocket.disconnect()
    }
    
    public func cancelled() {
        connect()
    }
    
    public func connected() {
        DispatchQueue.global().async {[weak self] in
            self?.symbols.forEach({ symbol in
                let symbolForFinHub = "BINANCE:\(symbol)USDT"
                let message = "{\"type\":\"subscribe\",\"symbol\":\"\(symbolForFinHub)\"}"
                self?.websocket.write(message)
            })
        }
    }
    
    public func didReceive(_ text: String) {
        if let data: Data = text.data(using: .utf8) {
            if let tickData = try? WebSocketResponse.decode(from: data)?.webSocketData {
                self.dataSubject.send(tickData)
            }
        }
    }
}

//MARK: - Rest API
extension MockTradeViewRepositoryImp {
    public func fetchCoins(url: URL) async -> Result<[Models.CoinCapAsset], Service.APIError> {
        return .success([MockData.crypto])
    }
}
