//
//  MirroredTimerViewModelUT.swift
//  EMOM timers Watch AppTests
//
//  Created by Javier Calartrava on 15/8/24.
//
@testable import EMOM_timers_Watch_App
import XCTest

final class MirroredTimerViewModelUT: XCTestCase {
    
    var sut: MirroredTimerViewModel!
    var         audioManagerMock: AudioManagerMock!

    override func setUpWithError() throws {
        audioManagerMock = AudioManagerMock()
        sut = MirroredTimerViewModel(audioManager: audioManagerMock)
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInit() throws {
        XCTAssertEqual(sut.state.value, .notStarted)
        XCTAssertEqual(sut.state.didChanged, false)
        XCTAssertNil(sut.mirroredTimer)
        
        let mirroredTimer = MirroredTimer(mirroredTimerType: .countdown)
        sut = MirroredTimerViewModel(mirroredTimer: mirroredTimer)
        XCTAssertEqual(mirroredTimer, sut.mirroredTimer)
    }
    
    func testSetMirroredTimer() {
        XCTAssertNil(sut.mirroredTimer)
        
        var mirroredTimer = MirroredTimer.countdown5
        sut.set(mirroredTimer: mirroredTimer)
        XCTAssertEqual(mirroredTimer, sut.mirroredTimer)
        XCTAssertEqual(sut.chronoFrozen, "5")
        XCTAssertEqual(sut.state.value, .countdown)
        XCTAssertEqual(sut.state.didChanged, true)
        XCTAssertEqual(audioManagerMock.speakStateCount, 1)
        
        mirroredTimer = MirroredTimer.work
        sut.set(mirroredTimer: mirroredTimer)
        XCTAssertEqual(mirroredTimer, sut.mirroredTimer)
        XCTAssertEqual(sut.chronoFrozen, "1723810036")
        XCTAssertEqual(sut.state.value, .startedWork)
        XCTAssertEqual(sut.state.didChanged, true)
        XCTAssertEqual(audioManagerMock.speakStateCount, 2)
        
        mirroredTimer = MirroredTimer.rest
        sut.set(mirroredTimer: mirroredTimer)
        XCTAssertEqual(mirroredTimer, sut.mirroredTimer)
        XCTAssertEqual(sut.chronoFrozen, "1723810036")
        XCTAssertEqual(sut.state.value, .startedRest)
        XCTAssertEqual(sut.state.didChanged, true)
        XCTAssertEqual(audioManagerMock.speakStateCount, 3)
        
        mirroredTimer = MirroredTimer.finished
        sut.set(mirroredTimer: mirroredTimer)
        XCTAssertEqual(mirroredTimer, sut.mirroredTimer)
        XCTAssertEqual(sut.chronoFrozen, "1723810036")
        XCTAssertEqual(sut.state.value, .finished)
        XCTAssertEqual(sut.state.didChanged, true)
        XCTAssertEqual(audioManagerMock.speakStateCount, 4)
    }
    
    func testSpeechWhenStateDidNotChanged() {
        let mirroredTimer = MirroredTimer.work
        sut.set(mirroredTimer: mirroredTimer)
        XCTAssertEqual(audioManagerMock.speakStateCount, 1)
        
        sut.set(mirroredTimer: mirroredTimer)
        XCTAssertEqual(audioManagerMock.speakStateCount, 1)
    }
    
    func testGetCurrentRound() {
        XCTAssertEqual(sut.getCurrentRound(), "")
        
        var mirroredTimer = MirroredTimer.countdown5
        sut.set(mirroredTimer: mirroredTimer)
        XCTAssertEqual(sut.getCurrentRound(), "")
        
        mirroredTimer = MirroredTimer.work
        sut.set(mirroredTimer: mirroredTimer)
        XCTAssertEqual(sut.getCurrentRound(), "3")
        
        mirroredTimer = MirroredTimer.rest
        sut.set(mirroredTimer: mirroredTimer)
        XCTAssertEqual(sut.getCurrentRound(), "3")
        
        mirroredTimer = MirroredTimer.finished
        sut.set(mirroredTimer: mirroredTimer)
        XCTAssertEqual(sut.getCurrentRound(), "5")
        
        mirroredTimer = MirroredTimer(mirroredTimerType: .working, 
                                      mirroredTimerWorking: nil)
        sut.set(mirroredTimer: mirroredTimer)
        XCTAssertEqual(sut.getCurrentRound(), "")
    }

    func testGetCurrentMessage() {
        XCTAssertEqual(sut.getCurrentMessage(), "")
        
        var mirroredTimer = MirroredTimer.countdown5
        sut.set(mirroredTimer: mirroredTimer)
        XCTAssertEqual(sut.getCurrentMessage(), "")
        
        mirroredTimer = MirroredTimer.work
        sut.set(mirroredTimer: mirroredTimer)
        XCTAssertEqual(sut.getCurrentMessage(), String(localized: "chrono_message_work"))
        
        mirroredTimer = MirroredTimer.rest
        sut.set(mirroredTimer: mirroredTimer)
        XCTAssertEqual(sut.getCurrentMessage(), String(localized: "chrono_message_rest"))
        
        mirroredTimer = MirroredTimer.finished
        sut.set(mirroredTimer: mirroredTimer)
        XCTAssertEqual(sut.getCurrentMessage(), String(localized: "chrono_message_finished"))
        
        mirroredTimer = MirroredTimer(mirroredTimerType: .working,
                                      mirroredTimerWorking: nil)
        sut.set(mirroredTimer: mirroredTimer)
        XCTAssertEqual(sut.getCurrentMessage(), "")
    }
    
    func testGetRounds() {
        XCTAssertEqual(sut.getRounds(), "")
        
        var mirroredTimer = MirroredTimer.countdown5
        sut.set(mirroredTimer: mirroredTimer)
        XCTAssertEqual(sut.getRounds(), "")
        
        mirroredTimer = MirroredTimer.work
        sut.set(mirroredTimer: mirroredTimer)
        XCTAssertEqual(sut.getRounds(), "/5")
        
        mirroredTimer = MirroredTimer.rest
        sut.set(mirroredTimer: mirroredTimer)
        XCTAssertEqual(sut.getRounds(), "/5")
        
        mirroredTimer = MirroredTimer.finished
        sut.set(mirroredTimer: mirroredTimer)
        XCTAssertEqual(sut.getRounds(), "")
        
        mirroredTimer = MirroredTimer(mirroredTimerType: .working,
                                      mirroredTimerWorking: nil)
        sut.set(mirroredTimer: mirroredTimer)
        XCTAssertEqual(sut.getRounds(), "")
    }
    
    func testGetTimerAndRoundFont() {
        XCTAssertEqual(sut.getTimerAndRoundFont(), .timerAndRoundLargeFont)
    }
    
    func testGetForegroundTextColor() {
        XCTAssertEqual(sut.getForegroundTextColor(), .green)
        
        var mirroredTimer = MirroredTimer.countdown5
        sut.set(mirroredTimer: mirroredTimer)
        XCTAssertEqual(sut.getForegroundTextColor(), .countdownColor)
        
         mirroredTimer = MirroredTimer.countdown2
        sut.set(mirroredTimer: mirroredTimer)
        XCTAssertEqual(sut.getForegroundTextColor(), .countdownInminentColor)
        
        mirroredTimer = MirroredTimer.work
        sut.set(mirroredTimer: mirroredTimer)
        XCTAssertEqual(sut.getForegroundTextColor(), .timerStartedColor)
        
        mirroredTimer = MirroredTimer.rest
        sut.set(mirroredTimer: mirroredTimer)
        XCTAssertEqual(sut.getForegroundTextColor(), .timerRestStartedColor)
        
        mirroredTimer = MirroredTimer.finished
        sut.set(mirroredTimer: mirroredTimer)
        XCTAssertEqual(sut.getForegroundTextColor(), .timerNotStartedColor)
        
        mirroredTimer = MirroredTimer(mirroredTimerType: .working,
                                      mirroredTimerWorking: nil)
        sut.set(mirroredTimer: mirroredTimer)
        XCTAssertEqual(sut.getForegroundTextColor(), .green)
    }
    
    func testgetRoundsProgress() {
        XCTAssertEqual(sut.getRoundsProgress(), 0.0)
        
        var mirroredTimer = MirroredTimer.countdown5
        sut.set(mirroredTimer: mirroredTimer)
        XCTAssertEqual(sut.getRoundsProgress(), 0.5)
        
         mirroredTimer = MirroredTimer.countdown2
        sut.set(mirroredTimer: mirroredTimer)
        XCTAssertEqual(sut.getRoundsProgress(), 0.8)
        
        mirroredTimer = MirroredTimer.work
        sut.set(mirroredTimer: mirroredTimer)
        XCTAssertEqual(sut.getRoundsProgress(), 0.4)
        
        mirroredTimer = MirroredTimer.rest
        sut.set(mirroredTimer: mirroredTimer)
        XCTAssertEqual(sut.getRoundsProgress(), 0.4)
        
        mirroredTimer = MirroredTimer.finished
        sut.set(mirroredTimer: mirroredTimer)
        XCTAssertEqual(sut.getRoundsProgress(), 1.0)
        
        mirroredTimer = MirroredTimer(mirroredTimerType: .working,
                                      mirroredTimerWorking: nil)
        sut.set(mirroredTimer: mirroredTimer)
        XCTAssertEqual(sut.getRoundsProgress(), 0.0)
    }
    
    func testClose() {
        sut.close()
        XCTAssertNil(sut.mirroredTimer)
    }
}

extension MirroredTimerCountdown {
    static let mirroredTimerCountdown5 = MirroredTimerCountdown(value: 5)
    static let mirroredTimerCountdown2 = MirroredTimerCountdown(value: 2)
}

extension MirroredTimerWorking {
    static let mirroredTimerWorking = MirroredTimerWorking(rounds: 5,
                                                           currentRounds: 3,
                                                           date: "1723810036",
                                                           isWork: true,
                                                           message: "WORK")
    static let mirroredTimerRest = MirroredTimerWorking(rounds: 5,
                                                           currentRounds: 3,
                                                           date: "1723810036",
                                                           isWork: false,
                                                           message: "REST")
}

extension MirroredTimerFinished {
    static let mirroredTimerFinished = MirroredTimerFinished(rounds: 5,
                                                             currentRounds: 5,
                                                             date: "1723810036",
                                                             isWork: true,
                                                             message: "FINISHED!")
}

extension MirroredTimer {
    static let countdown5 = MirroredTimer(mirroredTimerType: .countdown,
                                         mirroredTimerCountdown: .mirroredTimerCountdown5)
    static let countdown2 = MirroredTimer(mirroredTimerType: .countdown, mirroredTimerCountdown: .mirroredTimerCountdown2)
    
    static let work = MirroredTimer(mirroredTimerType: .working,
                                    mirroredTimerWorking: .mirroredTimerWorking)
    
    static let rest = MirroredTimer(mirroredTimerType: .working,
                                    mirroredTimerWorking: .mirroredTimerRest)
    
    static let finished = MirroredTimer(mirroredTimerType: .finished,
                                        mirroredTimerFinished: .mirroredTimerFinished)
}
