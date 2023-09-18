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
        self.vm.onAppear()
        let expectation = expectation(description: "Fetch mostTraded data")
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            XCTAssertEqual(self.vm.mostTraded, [MockData.crypto])
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func test_TopMovers() {
        self.vm.onAppear()
        let expectation = expectation(description: "Fetch topMovers data")
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            XCTAssertEqual(self.vm.topMovers, [MockData.crypto])
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func test_FilteredCryptos() {
        self.vm.onAppear()
        let expectation = expectation(description: "Fetch filteredCryptos data")
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            XCTAssertEqual(self.vm.filteredCryptos, [MockData.crypto])
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func test_FilteredCryptosWhenSearching() {
        self.vm.onAppear()
        let expectation = expectation(description: "Filter searched crypto data")
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.vm.viewStatus = .searching
            self.vm.searchText = "b"
            XCTAssertEqual(self.vm.filteredCryptos, [MockData.crypto])
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func test_WsValue() {
        self.vm.onAppear()
        let expectation = expectation(description: "Fetch changed web socket coin price")
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            XCTAssertEqual(
                self.vm.filteredCryptos[0].currentPrice,
                MockData.coinPriceData.price
            )
            print(self.vm.filteredCryptos[0].currentPrice)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
}
