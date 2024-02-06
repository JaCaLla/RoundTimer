//
//  EMOMViewModelUT.swift
//  RoundTimer Watch AppTests
//
//  Created by Javier Calartrava on 25/1/24.
//
@testable import RoundTimer_Watch_App
import XCTest

final class EMOMViewModelUT: XCTestCase {
    
    var sut: EMOMViewModel!

    override func setUpWithError() throws {
        sut = EMOMViewModel()
        sut.set(emom: .sample16rounds50Work10Rest)
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testInit() throws {
        sut = EMOMViewModel()
        sut.set(emom: .sample1rounds1Work0Rest)
        
        XCTAssertNil(sut.timer)
        XCTAssertEqual(sut.tics, 0)
        XCTAssertEqual(sut.currentRound, 0)
        XCTAssertEqual(sut.chrono, "00:01")
        XCTAssertEqual(sut.percentage, 0.0)
        XCTAssertEqual(sut.totalSegment, "1 s")
        XCTAssertEqual(sut.actionIcon, "play.circle")
        
        XCTAssertEqual(sut.emom?.rounds, 1)
        XCTAssertEqual(sut.emom?.workSecs, 1)
        XCTAssertEqual(sut.emom?.restSecs, 0)
    }
    
    func testDeInit() {
        sut = EMOMViewModel()
        sut.set(emom: .sample16rounds50Work10Rest)
        XCTAssertNil(sut.timer)
        sut = nil
    }
    
    func testStart() {
        sut = EMOMViewModel()
        sut.set(emom: .sample16rounds50Work10Rest)
        XCTAssertNil(sut.timer)
        XCTAssertEqual(sut.state, .notStarted)
        sut.action()
        XCTAssertEqual(sut.timer?.isValid, true)
        XCTAssertEqual(sut.timer?.timeInterval, 1.0 / 20.0)
        XCTAssertEqual(sut.state, .startedWork)
    }
    
    func testStop() {
        // Given
        sut = EMOMViewModel()
        sut.set(emom: .sample16rounds50Work10Rest)
        XCTAssertNil(sut.timer)
        sut.action()
        // When
        sut.close()
        // Then
        XCTAssertNil(sut.timer)
        XCTAssertEqual(sut.state, .cancelled)
    }
    
    func testGetChrono() {
        sut = EMOMViewModel()
        sut.set(emom: .sample1rounds1Work0Rest)
        XCTAssertEqual(sut.getChrono(state: .notStarted, emom: .sample10rounds3720Work10Rest), "01:02:00")
        XCTAssertEqual(sut.getChrono(state: .startedWork, emom: .sample16rounds50Work10Rest), "00:50")
        XCTAssertEqual(sut.getChrono(state: .startedWork, emom: .sample16rounds50Work10Rest, secsEllapsed: 10), "00:40")
        XCTAssertEqual(sut.getChrono(state: .startedRest, emom: .sample16rounds50Work10Rest), "00:10")
        XCTAssertEqual(sut.getChrono(state: .startedRest, emom: .sample16rounds50Work10Rest, secsEllapsed: 2), "00:08")
        XCTAssertEqual(sut.getChrono(state: .finished, emom: .sample16rounds50Work10Rest), "16:00")
        XCTAssertEqual(sut.getChrono(state: .finished, emom: .sample16rounds50Work10Rest, secsEllapsed: 2), "16:00")
    }
}
