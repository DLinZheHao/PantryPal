//
//  PantryPalTests.swift
//  PantryPalTests
//
//  Created by 林哲豪 on 2023/6/27.
//

import XCTest
import Firebase

@testable import PantryPal

final class PantryPalTests: XCTestCase {
    var ingredientsViewController: IngredientsViewController!
    
    override func setUp() {
        super.setUp()
        
        let emallAddress = "a8570870z@gmail.com"
        let password = "0917652683c"
        Auth.auth().signIn(withEmail: emallAddress, password: password)
        
        let storyboard = UIStoryboard.ingredients
        ingredientsViewController = storyboard.instantiateInitialViewController() as? IngredientsViewController
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testFetchFridgeData() {
        let expectation = XCTestExpectation(description: "fridgeDataFetchCompletion should be called")
        
        fetchData(fridgeDataFetchCompletion: { _, _ in
            expectation.fulfill()
        }, memberDataFetchCompletion: { _ in
        }, ingredientDataFetchCompletion: { _ in
        }, fallHandler: {
        }, loadingHandler: {
        })
        
        wait(for: [expectation], timeout: 15.0)
    }
    
    func testGetRemainingTime() {
        
        let calendar = Calendar.current
        let components = DateComponents(year: 2023, month: 6, day: 26, hour: 10, minute: 30)
        let date = calendar.date(from: components) ?? Date()

        let expectationResult = "已過期"
        let result = getRemainingTime(date)
        
        XCTAssertEqual(result, expectationResult, "Fridge data mismatch")

    }
}
