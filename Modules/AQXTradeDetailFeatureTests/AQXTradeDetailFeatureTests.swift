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

final class AQXTradingDetailViewModelTests: XCTestCase {
    
    var viewModel: AQXTradingDetailViewModel!
    
    override func setUpWithError() throws {
        viewModel = AQXTradingDetailViewModel(
            crypto: MockData.crypto,
            repository: MockAQXTradingDetailRepositoryImp(
                networkManager: MockRESTApiManager()
            )
        )
    }

    override func tearDownWithError() throws {
        viewModel = nil
    }
    
    func test_reviewYourOrderButtonDisable() {
        viewModel.priceInput = ""
        XCTAssertTrue(viewModel.reviewYourOrderButtonDisabled)
    }
    
    func test_FetchChartData() {
        let expectation = expectation(description: "Fetch chart data")
        viewModel.onAppear()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertNotNil(self.viewModel.chartStatus)
            
            switch self.viewModel.chartStatus {
            case .data(let data):
                XCTAssertEqual(data, MockData.chartData)
            default:
                XCTAssertEqual(nil, MockData.chartData)
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }

    func test_OnDisappear() {
        viewModel.onDisappear()
        XCTAssertNil(viewModel.chartStatus)
    }
}

