//
//  HeartZoneCalculatorUT.swift
//  EMOM timersTests
//
//  Created by Javier Calartrava on 16/7/24.
//
@testable import EMOM_timers
import XCTest

final class HeartZoneCalculatorUT: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testHeartZoneCalculatorWhen48() throws {
        let sut = HeartZoneCalculator(age: 48)
       
        XCTAssertNil(sut.zone(heartRate: 85))
        XCTAssertEqual(sut.zone(heartRate: 86), 1)
        XCTAssertEqual(sut.zone(heartRate: 103), 1)
        XCTAssertEqual(sut.zone(heartRate: 104), 2)
        XCTAssertEqual(sut.zone(heartRate: 119), 2)
        XCTAssertEqual(sut.zone(heartRate: 120), 2)
        XCTAssertEqual(sut.zone(heartRate: 121), 3)
        XCTAssertEqual(sut.zone(heartRate: 137), 3)
        XCTAssertEqual(sut.zone(heartRate: 138), 4)
        XCTAssertEqual(sut.zone(heartRate: 154), 4)
        XCTAssertEqual(sut.zone(heartRate: 155), 5)
        XCTAssertEqual(sut.zone(heartRate: 172), 5)
        XCTAssertEqual(sut.zone(heartRate: 173), 5)
    }
    
    func testHeartZoneCalculatorWhen33() throws {
        let sut = HeartZoneCalculator(age: 33)
       
        XCTAssertNil(sut.zone(heartRate: 93))
        XCTAssertEqual(sut.zone(heartRate: 94), 1)
        XCTAssertEqual(sut.zone(heartRate: 112), 1)
        XCTAssertEqual(sut.zone(heartRate: 113), 2)
        XCTAssertEqual(sut.zone(heartRate: 119), 2)
        XCTAssertEqual(sut.zone(heartRate: 130), 2)
        XCTAssertEqual(sut.zone(heartRate: 131), 3)
        XCTAssertEqual(sut.zone(heartRate: 149), 3)
        XCTAssertEqual(sut.zone(heartRate: 150), 4)
        XCTAssertEqual(sut.zone(heartRate: 168), 4)
        XCTAssertEqual(sut.zone(heartRate: 169), 5)
        XCTAssertEqual(sut.zone(heartRate: 187), 5)
        XCTAssertEqual(sut.zone(heartRate: 189), 5)
    }
}
