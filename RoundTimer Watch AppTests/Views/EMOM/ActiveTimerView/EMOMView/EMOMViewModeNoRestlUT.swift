//
//  EMOMViewModeNoRestlUT.swift
//  RoundTimer Watch AppTests
//
//  Created by Javier Calartrava on 15/2/24.
//

@testable import RoundTimer_Watch_App
import XCTest

final class EMOMViewModeNoRestlUT: XCTestCase {

    var sut: EMOMViewModel!

    override func setUpWithError() throws {
        sut = EMOMViewModel()
        sut.set(emom: .sample1rounds30Work0Rest)
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testExample() throws {
        XCTAssertEqual(sut.state, .notStarted)
        XCTAssertEqual(sut.chronoFrozen, "0:30")
        XCTAssertNil(sut.chronoOnMove)
        XCTAssertEqual(sut.actionIcon, "play.circle")
        
        sut.set(emom: .sample1rounds5Work0Rest)
        XCTAssertEqual(sut.state, .notStarted)
        XCTAssertEqual(sut.chronoFrozen, "0:05")
        XCTAssertNil(sut.chronoOnMove)
        XCTAssertEqual(sut.actionIcon, "play.circle")
    }
}
