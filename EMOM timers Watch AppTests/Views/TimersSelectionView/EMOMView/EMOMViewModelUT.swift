//
//  EMOMViewModelUT.swift
//  EMOM timers Watch AppTests
//
//  Created by Javier Calartrava on 18/8/24.
//
@testable import EMOM_timers_Watch_App

import XCTest

final class EMOMViewModelUT: XCTestCase {
    
    var sut: EMOMViewModel!

    override func setUpWithError() throws {
        sut = EMOMViewModel()
    }

    override func tearDownWithError() throws {
        sut.close()
    }

    func testInit() throws {
        XCTAssertNil(sut.timerWork)
        XCTAssertNil(sut.timerRest)
        XCTAssertNil(sut.timerCountdown)
        XCTAssertNil(sut.refreshProgressTimer)
        XCTAssertNil(sut.extendedRuntimeSession)
        XCTAssertEqual(sut.state.value, .notStarted)
        XCTAssertEqual(sut.state.didChanged, false)
        XCTAssertEqual(sut.roundsLeft, 0)
        XCTAssertEqual(sut.countdownCurrentValue, 10)
        XCTAssertNil(sut.startWorkTimeStamp)
        XCTAssertNil(sut.customTimer)
        guard let _ = sut.audioManager as? AudioManager else {
            XCTFail("audioManager is not instance of AudioManager")
            return
        }
    }
    
    func testSetNilCustomTimer() {
        XCTAssertNil(sut.customTimer)
        sut.set(emom: nil)
        XCTAssertNil(sut.customTimer)
    }
    
    func testSetCustomTimerAndCheckTimers() {

        sut.set(emom: .emom2r60w10r)
        
        XCTAssertNil(sut.timerWork)
        XCTAssertNil(sut.timerRest)
        XCTAssertNil(sut.timerCountdown)
        XCTAssertNil(sut.refreshProgressTimer)
        
        var delayExpectation = XCTestExpectation()
        delayExpectation.isInverted = true
        wait(for: [delayExpectation], timeout: 5)
        
        XCTAssertNil(sut.timerWork)
        XCTAssertNil(sut.timerRest)
        XCTAssertNotNil(sut.timerCountdown)
        XCTAssertNotNil(sut.refreshProgressTimer)
        
        delayExpectation = XCTestExpectation()
        delayExpectation.isInverted = true
        wait(for: [delayExpectation], timeout: 8)
        
        XCTAssertNotNil(sut.timerWork)
        XCTAssertNotNil(sut.timerRest)
        XCTAssertNil(sut.timerCountdown)
        XCTAssertNotNil(sut.refreshProgressTimer)

        XCTAssertNotNil(sut.customTimer)
        XCTAssertEqual(sut.roundsLeft, 2)
        if let _ = sut.extendedRuntimeSession?.delegate as? EMOMViewModel {
        } else {
            XCTFail("extendedRuntimeSession was not set to EMOMViewModel class")
        }
    }
    
    func testSetCustomTimerWhenMock() {
        let expectation = expectation(description: "testSetCustomTimerWhenMock")
        let mock = WKExtendedRuntimeSessionDelegateMock()
        mock.expectation = expectation
        sut = EMOMViewModel(extendedRuntimeSessionDelegate: mock)
        sut.set(emom: .customTimerDefault)
        waitForExpectations(timeout: 1)
        XCTAssertNotNil(sut.customTimer)
        XCTAssertEqual(sut.roundsLeft, 2)
        if let mock = sut.extendedRuntimeSession?.delegate as? WKExtendedRuntimeSessionDelegateMock {
            XCTAssertEqual(mock.extendedRuntimeSessionDidStartCount, 1)
            XCTAssertEqual(mock.extendedRuntimeSessionWillExpireCount, 0)
            XCTAssertEqual(mock.extendedRuntimeSessionCount, 0)
        } else {
            XCTFail("extendedRuntimeSession was not set to WKExtendedRuntimeSessionDelegateMock class")
        }
    }

    func testWhenRestTimerIsNotSet() {
        
        sut.set(emom: .emom2r60w0r)
        
        XCTAssertNil(sut.timerWork)
        XCTAssertNil(sut.timerRest)
        
        var delayExpectation = XCTestExpectation()
        delayExpectation.isInverted = true
        wait(for: [delayExpectation], timeout: 5)
        
        XCTAssertNil(sut.timerWork)
        XCTAssertNil(sut.timerRest)
    }
    
    func testRemoveAllTimersOnClose() {
        sut.set(emom: .emom2r60w10r)
        
        XCTAssertNil(sut.timerWork)
        XCTAssertNil(sut.timerRest)
        XCTAssertNil(sut.timerCountdown)
        XCTAssertNil(sut.refreshProgressTimer)
        
        var delayExpectation = XCTestExpectation()
        delayExpectation.isInverted = true
        wait(for: [delayExpectation], timeout: 5)
        
        XCTAssertNil(sut.timerWork)
        XCTAssertNil(sut.timerRest)
        XCTAssertNotNil(sut.timerCountdown)
        XCTAssertNotNil(sut.refreshProgressTimer)
        
        sut.close()
        delayExpectation = XCTestExpectation()
        delayExpectation.isInverted = true
        wait(for: [delayExpectation], timeout: 5)
        
        XCTAssertNil(sut.timerWork)
        XCTAssertNil(sut.timerRest)
        XCTAssertNil(sut.timerCountdown)
        XCTAssertNil(sut.refreshProgressTimer)
    }
    
    /*
     func set(emom: CustomTimer?) {
         guard let emom else { return }
         changeStateAndSpeechWhenApplies(to: .countdown)
         self.customTimer = emom
         
         if let customTimer {
             set(roundsLeft: customTimer.rounds)
         }
         setupExtendedRuntimeSession()
     }
     */
    
    func testClose() {
        sut.close()
        XCTAssertNil(sut.customTimer)
    }
    /*
     func close() {
         customTimer = nil
         changeStateAndSpeechWhenApplies(to: .cancelled)
         removeTimers()
         removeExtendedRuntimeSession()
     }
     */
}
