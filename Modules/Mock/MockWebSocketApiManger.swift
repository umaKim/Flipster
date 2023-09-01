//
//  MockWebSocketApiManger.swift
//  AQX
//
//  Created by 김윤석 on 2023/09/01.
//

import Service
import Models
import Foundation

public class MockWebSocketApiManger {
    private weak var delegate: WebSocketApiManagerDelegate?
    
    private func configure(with websocketRequestable: WebsocketRequestable) {
        triggerConnected()
    }
    
    public init() { }
}

//MARK: - WebSocketApiProtocol
extension MockWebSocketApiManger: WebSocketApiProtocol {
    public func register(delegate: Service.WebSocketApiManagerDelegate) {
        self.delegate = delegate
    }

    public func connect(to wsRequestable: Service.WebsocketRequestable) {
        configure(with: wsRequestable)
    }
    
    public func disconnect() {
        
    }
    
    public func write(_ text: String) {
        self.triggerDidReceive()
    }
}

extension MockWebSocketApiManger {
    private func triggerDidReceive() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.delegate?.didReceive(MockData.wsRawData)
        }
    }
    
    private func triggerConnected() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.delegate?.connected()
        }
    }
}
