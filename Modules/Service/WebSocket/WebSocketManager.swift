//
//  WebSocketManager.swift
//  AQX
//
//  Created by 김윤석 on 2023/08/17.
//

import Combine
import Starscream
import Foundation

public protocol WebSocketApiManagerDelegate: AnyObject {
    func didReceive(_ text: String)
    func connected()
    func cancelled()
}

public protocol WebSocketApiProtocol {
    func register(delegate: WebSocketApiManagerDelegate)
    func write(_ text: String)
    func connect(to wsRequestable: WebsocketRequestable)
    func disconnect()
}

public final class WebSocketApiManager {
    private var socket: WebSocket?
    
    private weak var delegate: WebSocketApiManagerDelegate?
    
    public init() { }
    
    private func configure(with websocketRequestable: WebsocketRequestable) {
        var request = URLRequest(url: websocketRequestable.urlMaker())
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket?.delegate = self
    }
}

//MARK: - WebSocketApiProtocol
extension WebSocketApiManager: WebSocketApiProtocol {
    public func register(delegate: WebSocketApiManagerDelegate) {
        self.delegate = delegate
    }
    
    public func connect(to wsRequestable: WebsocketRequestable) {
        configure(with: wsRequestable)
        socket?.connect()
    }
    
    public func disconnect() {
        socket?.disconnect()
        socket?.delegate = nil
    }
    
    public func write(_ text: String) {
        socket?.write(string: text)
    }
}

//MARK: - Starscream.WebSocketDelegate
extension WebSocketApiManager: Starscream.WebSocketDelegate {
    public func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient) {
        switch event {
        case .connected:
            self.delegate?.connected()
        case .disconnected(let reason, _):
            delegate = nil
            socket = nil
            print(reason)
        case .text(let text):
            self.delegate?.didReceive(text)
        case .binary:
            break
        case .ping:
            break
        case .pong:
            break
        case .viabilityChanged:
            break
        case .reconnectSuggested:
            break
        case .cancelled:
            delegate?.cancelled()
        case .error(let error):
            print(error?.localizedDescription ?? "")
            break
        case .peerClosed:
            break
        }
    }
}
