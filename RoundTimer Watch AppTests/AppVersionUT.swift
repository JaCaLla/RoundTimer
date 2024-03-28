//
//  AppVersionUT.swift
//  RoundTimer Watch AppTests
//
//  Created by Javier Calartrava on 23/3/24.
//

import XCTest

final class AppVersionUT: XCTestCase {

    func testAppVersionAndBuild() throws {
        guard let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
            let appBuild = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String else {
            XCTFail("testAppVersionAndBuild failed on fetching keys from dictionary")
            return
        }
        XCTAssertEqual(appVersion, "1.4")
        XCTAssertEqual(appBuild, "13")
    }

}
