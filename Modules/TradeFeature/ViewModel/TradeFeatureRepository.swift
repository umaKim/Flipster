//
//  TradeRepository.swift
//  AQXTradeDetailFeature
//
//  Created by 김윤석 on 2023/08/31.
//
import Models
import Service
import Combine
import Utils
import Foundation

public protocol TradeRepository {
    // MARK: - REST API
    func fetchCoins(url: URL) async -> Result<[CoinCapAsset], APIError>
    
    //MARK: - SOCKET API
    var dataPublisher: AnyPublisher<[WebSocketDatum], Never> { get }
    func set(symbols: [String])
    func disconnect()
    func connect()
}

public final class TradeRepositoryImp: TradeRepository {
    private let networkManager: RESTApiProtocol
    private let websocket: WebSocketApiProtocol
    
    public init(
        networkManager: RESTApiProtocol,
        websocket: WebSocketApiProtocol
    ) {
        self.networkManager = networkManager
        self.websocket = websocket
    }
    
    lazy public var dataPublisher: AnyPublisher<[WebSocketDatum], Never> = dataSubject.eraseToAnyPublisher()
    private var dataSubject = PassthroughSubject<[WebSocketDatum], Never>()
    
    private var symbols: [String] = []
}

//MARK: - WebSocket API
extension TradeRepositoryImp: WebSocketApiManagerDelegate {
    public func set(symbols: [String]) {
        self.symbols = symbols
    }
    
    public func connect() {
        websocket.register(delegate: self)
        websocket.connect(to: FinnHubSocket())
    }
    
    public func disconnect() {
        websocket.disconnect()
    }
    
    public func cancelled() {
        connected()
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

//MARK: - TradeRepositoryDataConvertible
extension TradeRepositoryImp: TradeRepositoryDataConvertible { }

//MARK: - REST API
extension TradeRepositoryImp {
    public func fetchCoins(url: URL) async -> Result<[Models.CoinCapAsset], Service.APIError> {
        await networkManager.request(url: url)
    }
}
