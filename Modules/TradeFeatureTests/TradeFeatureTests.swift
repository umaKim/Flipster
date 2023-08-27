//
//  TradeFeatureTests.swift
//  TradeFeatureTests
//
//  Created by 김윤석 on 2023/08/20.
//

import Service
import XCTest
@testable import TradeFeature

final class TradeFeatureTests: XCTestCase {

    var vm: TradeFeatureViewModel?
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        vm = TradeFeatureViewModel(
            socketService: RealTimeCoinPriceRepositoryImp(StarScreamWebSocket()),
            restApiService: <#T##NetworkManager#>
        )
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        vm = nil
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
        
        vm?.onAppear()
        
        vm?.onDisappear()
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
