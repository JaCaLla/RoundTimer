//
//  AppGroupStoreTests.swift
//  EMOM timersTests
//
//  Created by Javier Calartrava on 27/7/24.
//
@testable import EMOM_timers
import XCTest

final class AppGroupStoreTests: XCTestCase {


    func testExample() throws {
        AppGroupStore.shared.setBool(value: true, forKey: .grantedPermissionForHeartRate)
        XCTAssertEqual(AppGroupStore.shared.get(forKey: .grantedPermissionForHeartRate), true)
        AppGroupStore.shared.setBool(value: false, forKey: .grantedPermissionForHeartRate)
        XCTAssertEqual(AppGroupStore.shared.get(forKey: .grantedPermissionForHeartRate), false)
        AppGroupStore.shared.setBool(value: true, forKey: .grantedPermissionForHeartRate)
        XCTAssertEqual(AppGroupStore.shared.get(forKey: .grantedPermissionForHeartRate), true)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
