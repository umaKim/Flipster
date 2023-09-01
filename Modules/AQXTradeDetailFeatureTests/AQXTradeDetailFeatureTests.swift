//
//  AQXTradeDetailFeatureTests.swift
//  AQXTradeDetailFeatureTests
//
//  Created by 김윤석 on 2023/08/21.
//
import Mock
import Models
import Service
import XCTest
@testable import AQXTradeDetailFeature

class AQXTradingDetailViewModelTests: XCTestCase {
    
    var viewModel: AQXTradingDetailViewModel!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        viewModel = AQXTradingDetailViewModel(
            crypto: MockData.crypto,
            repository: MockAQXTradingDetailRepositoryImp(
                networkManager: MockRESTApiManager()
            )
        )
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        viewModel = nil
    }
    
    func test_reviewYourOrderButtonDisable() {
        viewModel.priceInput = ""
        XCTAssertTrue(viewModel.reviewYourOrderButtonDisabled)
    }
    
    func test_FetchChartData() {
        let expectation = expectation(description: "Fetch chart data")

        viewModel.fetchChartData()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertNotNil(self.viewModel.chartData)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }

    func testOnDisappear() {
        viewModel.onDisappear()

        // Assert that the chartData is nil after calling onDisappear
        XCTAssertNil(viewModel.chartData)
    }
}

