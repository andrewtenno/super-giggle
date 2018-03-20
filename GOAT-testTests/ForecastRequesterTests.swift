//
//  ForecastRequesterTests.swift
//  GOAT-testTests
//
//  Created by Andrew Tenno on 3/20/18.
//  Copyright © 2018 Andrew Tenno. All rights reserved.
//

import XCTest

@testable import GOAT_test

class ForecastRequesterTests: XCTestCase {
    func testCanCreateModel() {
        let requester = ForecastRequester(apiKey: "foo", dataFetcher: LocalDataFetcher())
        let location = Location(latitude: 45.0,
                                longitude: 23.0)
        let expectation = self.expectation(description: "Called completion handler")

        requester.performForecastFetchRequest(forLocation: location) { (result) in
            switch result {
            case .success(_): ()
            case .failure(let error):
                XCTFail("Got unexpected error of type \(error)")
            }
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 0.1, handler: nil)
    }
}
