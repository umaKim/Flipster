//
//  TradeFeatureTests.swift
//  TradeFeatureTests
//
//  Created by 김윤석 on 2023/08/20.
//
import Mock
import Models
import Combine
import Service
import XCTest
@testable import TradeFeature

final class TradeFeatureTests: XCTestCase {
    
    var mockREST: MockRESTApiManager!
    var mockSocket: MockWebSocketApiManger!
    var vm: TradeFeatureViewModel!
    
    override func setUpWithError() throws {
        mockREST = MockRESTApiManager()
        mockSocket = MockWebSocketApiManger()
        vm = TradeFeatureViewModel(
            repository: MockTradeViewRepositoryImp(
                networkManager: mockREST,
                websocket: mockSocket
            )
        )
    }

    override func tearDownWithError() throws {
        vm = nil
    }
    
    func test_MostTraded() {
        let expectation = expectation(description: "Fetch mostTraded data")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(self.vm.mostTraded, [MockData.crypto])
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func test_TopMovers() {
        let expectation = expectation(description: "Fetch topMovers data")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(self.vm.topMovers, [MockData.crypto])
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func test_FilteredCryptos() {
        let expectation = expectation(description: "Fetch filteredCryptos data")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(self.vm.filteredCryptos, [MockData.crypto])
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func test_FilteredCryptosWhenSearching() {
        let expectation = expectation(description: "Filter searched crypto data")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.vm.viewStatus = .searching
            self.vm.searchText = "b"
            XCTAssertEqual(self.vm.filteredCryptos, [MockData.crypto])
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func test_WsValue() {
        let expectation = expectation(description: "Fetch changed web socket coin price")
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            XCTAssertEqual(
                self.vm.filteredCryptos[0].currentPrice,
                MockData.coinPriceData.price
            )
            print(self.vm.filteredCryptos[0].currentPrice)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 4, handler: nil)
    }
    
    func test_selectedCrypto_whenOnAppearIsCalled() {
        vm.onAppear()
        XCTAssertNil(vm.selectedCrypto)
    }
    
    func test_nextState_whenOnAppearIsCalled() {
        vm.onAppear()
        XCTAssertNil(vm.nextState)
    }
    
    func test_WSisDisconnectedWhenOnDisappearIsCalled() {
        vm.onDisappear()
        XCTAssertTrue(mockSocket.isDisconnected)
    }
}
