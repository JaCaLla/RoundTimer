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
        XCTAssertEqual(sut.chronoFrozen, "--:--")
        XCTAssertNil(sut.chronoOnMove)
        XCTAssertEqual(sut.percentage, 0.0)
        XCTAssertEqual(sut.actionIcon, "--:--")
        
        sut.set(emom: .sample1rounds5Work0Rest)
        XCTAssertEqual(sut.state, .notStarted)
        XCTAssertEqual(sut.chronoFrozen, "--:--")
        XCTAssertNil(sut.chronoOnMove)
        XCTAssertEqual(sut.percentage, 0.0)
        XCTAssertEqual(sut.actionIcon, "--:--")
        
    }

    
    /*
     @Published var roundsLeft = 0
     @Published var timerDisplayed: Date?
     @Published var endOfBrushing: Date?
     @Published var chrono = "--:--"
     @Published var percentage = 0.0

     private (set) var actionIcon = "play"
     private var timerWork: Timer!
     private var timerRest: Timer!
     private var session: WKExtendedRuntimeSession!
     internal var state: State = .notStarted
     internal var previousState: State = .startedWork
     private var startedRound: Int = 0
     private var secsToFinishAfterPausing: TimeInterval = 0
     private var secsToFinishRestAfterPausing: TimeInterval = 0
     private var roundsLeftAfterPausing: Int?
     */
}
