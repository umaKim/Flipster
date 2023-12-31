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
import TradeFeature

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
        convertMessage(with: symbols, to: {[weak self] message in
            self?.websocket.write(message)
        })
    }
    
    public func didReceive(_ text: String) {
        convertTickData(with: text, to: {[weak self] tickData in
            self?.dataSubject.send(tickData)
        })
    }
}

//MARK: - Rest API
extension MockTradeViewRepositoryImp: UrlConfigurable {
    public func fetchCoins() async -> Result<[Models.CoinCapAsset], Service.APIError> {
        return .success([MockData.crypto])
    }
}
