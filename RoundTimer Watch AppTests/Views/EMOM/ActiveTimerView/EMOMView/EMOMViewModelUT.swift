//
//  EMOMViewModelUT.swift
//  RoundTimer Watch AppTests
//
//  Created by Javier Calartrava on 25/1/24.
//
@testable import RoundTimer_Watch_App
import XCTest

final class EMOMViewModelUT: XCTestCase {

//    var sut: EMOMViewModel!
//
//    override func setUpWithError() throws {
//        sut = EMOMViewModel()
//        sut.set(emom: .sample16rounds50Work10Rest)
//    }
//
//    override func tearDownWithError() throws {
//        sut = nil
//    }

    func testInit() throws {
        let sut = EMOMViewModel()
        sut.set(emom: .sample1rounds1Work0Rest)

        //  XCTAssertNil(sut.timer)
        //   XCTAssertEqual(sut.tics, 0)
        //  XCTAssertEqual(sut.currentRound, 0)
        XCTAssertEqual(sut.chronoFrozen, "0:01")
        //XCTAssertEqual(sut.totalSegment, "1 s")
        XCTAssertEqual(sut.actionIcon, "play")

        XCTAssertEqual(sut.emom?.rounds, 1)
        XCTAssertEqual(sut.emom?.workSecs, 1)
        XCTAssertEqual(sut.emom?.restSecs, 0)
    }

//    func testDeInit() {
//        let sut = EMOMViewModel()
//        sut.set(emom: .sample16rounds50Work10Rest)
//     //   XCTAssertNil(sut.timer)
//        sut = nil
//    }

    func testSetEmom() {
        let sut = EMOMViewModel()
        sut.set(emom: .sample1rounds5Work0Rest)


        XCTAssertEqual(sut.state, .notStarted)
        XCTAssertEqual(sut.showCountDownView, false)
        let timeInterval = sut.chronoOnMove?.timeIntervalSinceNow ?? 0.0
        XCTAssertEqual(timeInterval.rounded(.down), 0.0)
        XCTAssertNil(sut.timerWork)
        XCTAssertNil(sut.timerRest)
        XCTAssertNil(sut.extendedRuntimeSession)
        XCTAssertEqual(sut.roundsLeft, 0)
        XCTAssertEqual(sut.getActionIcon(), "play.circle")
        XCTAssertEqual(sut.getCurrentMessage(), "PRESS PLAY!")

        // Tear down
        sut.close()
        // Allow WKExtendedRuntimeSession delegate class unlink from sut

    }


    func testStartAnimationFlag() {
        let expectation = XCTestExpectation(description: "testStart")
        let sut = EMOMViewModel()
        sut.set(emom: .sample1rounds5Work0Rest)
        //  XCTAssertNil(sut.timer)
        XCTAssertEqual(sut.state, .notStarted)
        XCTAssertEqual(sut.showCountDownView, false)
        sut.action()
        XCTAssertEqual(sut.state, .notStarted)
        XCTAssertEqual(sut.showCountDownView, true)
        XCTAssertEqual(sut.getActionIcon(), "play.circle")
        XCTAssertEqual(sut.getCurrentMessage(), "PRESS PLAY!")
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) { [weak self] in
            XCTAssertEqual(sut.getActionIcon(), "play.circle")
            XCTAssertEqual(sut.getCurrentMessage(), "PRESS PLAY!")
            sut.startWorkTime()
            // Execute after delay because startWorTime set ups a delegate and our test is
            // validating the delegate actions
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                XCTAssertEqual(sut.getActionIcon(), "pause.circle")
                XCTAssertEqual(sut.getCurrentMessage(), "LAST ROUND!!!")
                XCTAssertEqual(sut.state, .startedWork)
                XCTAssertEqual(sut.showCountDownView, false)
                sut.close()
                // Allow WKExtendedRuntimeSession delegate class unlink from sut
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    expectation.fulfill()
                }
            }
        }
        wait(for: [expectation], timeout: 6.0)
    }

    func testStart() {
        let expectation = XCTestExpectation(description: "testStart")
        let sut = EMOMViewModel()
        sut.set(emom: .sample1rounds5Work0Rest)

        sut.action()
        sut.startWorkTime()
        // Execute after delay because startWorTime set ups a delegate and our test is
        // validating the delegate actions
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            XCTAssertEqual(sut.state, .startedWork)
            XCTAssertEqual(sut.showCountDownView, false)
            let timeInterval = sut.chronoOnMove?.timeIntervalSinceNow ?? 0.0
            XCTAssertEqual(timeInterval.rounded(.down), 5.0)
            XCTAssertEqual(sut.timerWork?.timeInterval, 5.0)
            XCTAssertNil(sut.timerRest)
            XCTAssertNotNil(sut.extendedRuntimeSession)
            XCTAssertEqual(sut.roundsLeft, 1)
            XCTAssertEqual(sut.getCurrentMessage(), "LAST ROUND!!!")

            // Tear down
            sut.close()
            // Allow WKExtendedRuntimeSession delegate class unlink from sut
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 6.0)
    }

    func testStartAndCheckAfter3Secs() {
        let expectation = XCTestExpectation(description: "testStart")
        let sut = EMOMViewModel()
        sut.set(emom: .sample1rounds5Work0Rest)

        sut.action()
        sut.startWorkTime()
        // Execute after delay because startWorTime set ups a delegate and our test is
        // validating the delegate actions
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            XCTAssertEqual(sut.state, .startedWork)
            XCTAssertEqual(sut.showCountDownView, false)
            XCTAssertEqual(sut.getActionIcon(), "pause.circle")
            XCTAssertEqual(sut.getCurrentMessage(), "LAST ROUND!!!")
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                let timeInterval = sut.chronoOnMove?.timeIntervalSinceNow ?? 0.0
                XCTAssertEqual(timeInterval.rounded(.down), 2.0)
                XCTAssertEqual(sut.getActionIcon(), "pause.circle")
                XCTAssertEqual(sut.getCurrentMessage(), "LAST ROUND!!!")
                XCTAssertEqual(sut.roundsLeft, 1)
                // Tear down unit test
                sut.close()
                // Allow WKExtendedRuntimeSession delegate class unlink from sut
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    expectation.fulfill()
                }
            }
        }
        wait(for: [expectation], timeout: 6.0)
    }

    func testStartAndCheckAfterReachLastRound() {
        let expectation = XCTestExpectation(description: "testStartAndCheckAfterReachLastRound")
        // Given
        let sut = EMOMViewModel()
        sut.set(emom: .sample2rounds5Work0Rest)

        sut.action()
        sut.startWorkTime()
        // Execute after delay because startWorTime set ups a delegate and our test is
        // validating the delegate actions
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(sut.state, .startedWork)
            XCTAssertEqual(sut.showCountDownView, false)
            XCTAssertEqual(sut.getActionIcon(), "pause.circle")
            XCTAssertEqual(sut.getCurrentMessage(), "WORK!")
            XCTAssertEqual(sut.roundsLeft, 2)
            // When
            DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) {
                let timeInterval = sut.chronoOnMove?.timeIntervalSinceNow ?? 0.0
                XCTAssertEqual(timeInterval.rounded(.down), 2.0)
                XCTAssertEqual(sut.getActionIcon(), "pause.circle")
                XCTAssertEqual(sut.getCurrentMessage(), "LAST ROUND!!!")
                // Then
                XCTAssertEqual(sut.roundsLeft, 1)
                // Tear down unit test
                sut.close()
                // Allow WKExtendedRuntimeSession delegate class unlink from sut
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    expectation.fulfill()
                }
            }
        }
        wait(for: [expectation], timeout: 12.0)
    }
    
    func testStartAndCheckPauseAfter3Secs() {
        let expectation = XCTestExpectation(description: "testStart")
        let sut = EMOMViewModel()
        sut.set(emom: .sample1rounds5Work0Rest)

        sut.action()
        sut.startWorkTime()
        // Execute after delay because startWorTime set ups a delegate and our test is
        // validating the delegate actions
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(sut.state, .startedWork)
            XCTAssertEqual(sut.showCountDownView, false)
            XCTAssertEqual(sut.getActionIcon(), "pause.circle")
            XCTAssertEqual(sut.getCurrentMessage(), "LAST ROUND!!!")
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                // When: Pause
                sut.action()
                // On pause timers are dropped
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    XCTAssertEqual(sut.getActionIcon(), "play.circle")
                    XCTAssertEqual(sut.getCurrentMessage(), "PAUSED!")
                    XCTAssertEqual(sut.roundsLeft, 1)
                    XCTAssertNil(sut.timerWork)
                    XCTAssertNil(sut.timerRest)
                    XCTAssertNotNil(sut.extendedRuntimeSession)
                    // Tear down unit test
                    sut.close()
                    // Allow WKExtendedRuntimeSession delegate class unlink from sut
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        expectation.fulfill()
                    }
                }
            }
        }
        wait(for: [expectation], timeout: 6.0)
    }
    
    func testStartAndCheckPauseAndPlayAfter3Secs() {
        let expectation = XCTestExpectation(description: "testStart")
        let sut = EMOMViewModel()
        sut.set(emom: .sample1rounds5Work0Rest)

        sut.action()
        sut.startWorkTime()
        // Execute after delay because startWorTime set ups a delegate and our test is
        // validating the delegate actions
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { 
            XCTAssertEqual(sut.state, .startedWork)
            XCTAssertEqual(sut.showCountDownView, false)
            XCTAssertEqual(sut.getActionIcon(), "pause.circle")
            XCTAssertEqual(sut.getCurrentMessage(), "LAST ROUND!!!")
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                sut.action()
                // When: Play
                sut.action()
                // On pause timers are dropped
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    XCTAssertEqual(sut.getActionIcon(), "pause.circle")
                    XCTAssertEqual(sut.getCurrentMessage(), "LAST ROUND!!!")
                    XCTAssertEqual(sut.roundsLeft, 1)
                    XCTAssertNotNil(sut.timerWork)
                    XCTAssertNil(sut.timerRest)
                    XCTAssertNotNil(sut.extendedRuntimeSession)
                    // Tear down unit test
                    sut.close()
                    // Allow WKExtendedRuntimeSession delegate class unlink from sut
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        expectation.fulfill()
                    }
                }
            }
        }
        wait(for: [expectation], timeout: 6.0)
    }
    
    func testFinish() {
        let expectation = XCTestExpectation(description: "testStart")
        let sut = EMOMViewModel()
        sut.set(emom: .sample1rounds5Work0Rest)

        sut.action()
        sut.startWorkTime()
        // Execute after delay because startWorTime set ups a delegate and our test is
        // validating the delegate actions
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            XCTAssertEqual(sut.state, .startedWork)
            XCTAssertEqual(sut.showCountDownView, false)
            XCTAssertEqual(sut.getActionIcon(), "pause.circle")
            XCTAssertEqual(sut.getCurrentMessage(), "LAST ROUND!!!")
            DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
                // When: Pause
           //     sut.action()
                // On pause timers are dropped
          //      DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    XCTAssertEqual(sut.getActionIcon(), "arrow.uturn.left.circle")
                    XCTAssertEqual(sut.getCurrentMessage(), "FINISHED!")
                    XCTAssertEqual(sut.roundsLeft, 0)
                    XCTAssertNil(sut.timerWork)
                    XCTAssertNil(sut.timerRest)
                    XCTAssertNotNil(sut.extendedRuntimeSession)
                    // Tear down unit test
                    sut.close()
                    // Allow WKExtendedRuntimeSession delegate class unlink from sut
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        expectation.fulfill()
                    }
           //     }
            }
        }
        wait(for: [expectation], timeout: 8.0)
    }
    
    func testFinishAndRestart() {
        let expectation = XCTestExpectation(description: "testStart")
        let sut = EMOMViewModel()
        sut.set(emom: .sample1rounds5Work0Rest)

        sut.action()
        sut.startWorkTime()
        // Execute after delay because startWorTime set ups a delegate and our test is
        // validating the delegate actions
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { 
            XCTAssertEqual(sut.state, .startedWork)
            XCTAssertEqual(sut.showCountDownView, false)
            XCTAssertEqual(sut.getActionIcon(), "pause.circle")
            XCTAssertEqual(sut.getCurrentMessage(), "LAST ROUND!!!")
            DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
                sut.action()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    XCTAssertEqual(sut.getActionIcon(), "play.circle")
                    XCTAssertEqual(sut.getCurrentMessage(), "PRESS PLAY!")
                    sut.action()
                    sut.startWorkTime()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        XCTAssertEqual(sut.getActionIcon(), "pause.circle")
                        XCTAssertEqual(sut.getCurrentMessage(), "LAST ROUND!!!")
                        XCTAssertEqual(sut.roundsLeft, 1)
                        XCTAssertNotNil(sut.timerWork)
                        XCTAssertNil(sut.timerRest)
                        XCTAssertNotNil(sut.extendedRuntimeSession)
                        // Tear down unit test
                        sut.close()
                        // Allow WKExtendedRuntimeSession delegate class unlink from sut
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            expectation.fulfill()
                        }
                    }
                }
            }
        }
        wait(for: [expectation], timeout: 8.0)
    }
 
    func testStartAndCheckAfter8Secs() {
        let expectation = XCTestExpectation(description: "testStart")
        let sut = EMOMViewModel()
        sut.set(emom: .sample2rounds5Work5Rest)

        sut.action()
        sut.startWorkTime()
        // Execute after delay because startWorTime set ups a delegate and our test is
        // validating the delegate actions
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(sut.state, .startedWork)
            XCTAssertEqual(sut.showCountDownView, false)
            XCTAssertEqual(sut.getActionIcon(), "pause.circle")
            XCTAssertEqual(sut.getCurrentMessage(), "WORK!")
            DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) {
                 XCTAssertEqual(sut.getActionIcon(), "pause.circle")
                XCTAssertEqual(sut.getCurrentMessage(), "REST!")
                XCTAssertEqual(sut.roundsLeft, 2)
                // Tear down unit test
                sut.close()
                // Allow WKExtendedRuntimeSession delegate class unlink from sut
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    expectation.fulfill()
                }
            }
        }
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testStartAndCheckAfterPause8Secs() {
        let expectation = XCTestExpectation(description: "testStart")
        let sut = EMOMViewModel()
        sut.set(emom: .sample2rounds5Work5Rest)

        sut.action()
        sut.startWorkTime()
        // Execute after delay because startWorTime set ups a delegate and our test is
        // validating the delegate actions
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(sut.state, .startedWork)
            XCTAssertEqual(sut.showCountDownView, false)
            XCTAssertEqual(sut.getActionIcon(), "pause.circle")
            XCTAssertEqual(sut.getCurrentMessage(), "WORK!")
            DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) {
                 XCTAssertEqual(sut.getActionIcon(), "pause.circle")
                XCTAssertEqual(sut.getCurrentMessage(), "REST!")
                XCTAssertEqual(sut.roundsLeft, 2)
                sut.action()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    XCTAssertEqual(sut.getActionIcon(), "play.circle")
                   XCTAssertEqual(sut.getCurrentMessage(), "PAUSED!")
                   XCTAssertEqual(sut.roundsLeft, 2)
                    
                    // Tear down unit test
                    sut.close()
                    // Allow WKExtendedRuntimeSession delegate class unlink from sut
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        expectation.fulfill()
                    }
                }
            }
        }
        wait(for: [expectation], timeout: 10.0)
    }
   //*
    func testStartAndCheckAfterPauseAndPlay8Secs() {
        let expectation = XCTestExpectation(description: "testStart")
        let sut = EMOMViewModel()
        sut.set(emom: .sample2rounds5Work5Rest)

        sut.action()
        sut.startWorkTime()
        // Execute after delay because startWorTime set ups a delegate and our test is
        // validating the delegate actions
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(sut.state, .startedWork)
            XCTAssertEqual(sut.showCountDownView, false)
            XCTAssertEqual(sut.getActionIcon(), "pause.circle")
            XCTAssertEqual(sut.getCurrentMessage(), "WORK!")
            DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) {
                 XCTAssertEqual(sut.getActionIcon(), "pause.circle")
                XCTAssertEqual(sut.getCurrentMessage(), "REST!")
                XCTAssertEqual(sut.roundsLeft, 2)
                sut.action()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    XCTAssertEqual(sut.getActionIcon(), "play.circle")
                   XCTAssertEqual(sut.getCurrentMessage(), "PAUSED!")
                   XCTAssertEqual(sut.roundsLeft, 2)
                    
                    sut.action()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        XCTAssertEqual(sut.getActionIcon(), "pause.circle")
                        XCTAssertEqual(sut.getCurrentMessage(), "REST!")
                        XCTAssertEqual(sut.roundsLeft, 2)
                        // Tear down unit test
                        sut.close()
                        // Allow WKExtendedRuntimeSession delegate class unlink from sut
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            expectation.fulfill()
                        }
                    }
                    

                }
            }
        }
        wait(for: [expectation], timeout: 12.0)
    }
    
    
    func testStartAndCheckAfterPause3Secs() {
        let expectation = XCTestExpectation(description: "testStart")
        let sut = EMOMViewModel()
        sut.set(emom: .sample2rounds5Work5Rest)

        sut.action()
        sut.startWorkTime()
        // Execute after delay because startWorTime set ups a delegate and our test is
        // validating the delegate actions
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(sut.state, .startedWork)
            XCTAssertEqual(sut.showCountDownView, false)
            XCTAssertEqual(sut.getActionIcon(), "pause.circle")
            XCTAssertEqual(sut.getCurrentMessage(), "WORK!")
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                 XCTAssertEqual(sut.getActionIcon(), "pause.circle")
                XCTAssertEqual(sut.getCurrentMessage(), "WORK!")
                XCTAssertEqual(sut.roundsLeft, 2)
                sut.action()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    XCTAssertEqual(sut.getActionIcon(), "play.circle")
                   XCTAssertEqual(sut.getCurrentMessage(), "PAUSED!")
                   XCTAssertEqual(sut.roundsLeft, 2)
                    
                    // Tear down unit test
                    sut.close()
                    // Allow WKExtendedRuntimeSession delegate class unlink from sut
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        expectation.fulfill()
                    }
                }
            }
        }
        wait(for: [expectation], timeout: 10.0)
    }
 //*
    func testStartAndCheckAfterPauseAndPlay3Secs() {
        let expectation = XCTestExpectation(description: "testStart")
        let sut = EMOMViewModel()
        sut.set(emom: .sample2rounds5Work5Rest)

        sut.action()
        sut.startWorkTime()
        // Execute after delay because startWorTime set ups a delegate and our test is
        // validating the delegate actions
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(sut.state, .startedWork)
            XCTAssertEqual(sut.showCountDownView, false)
            XCTAssertEqual(sut.getActionIcon(), "pause.circle")
            XCTAssertEqual(sut.getCurrentMessage(), "WORK!")
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                 XCTAssertEqual(sut.getActionIcon(), "pause.circle")
                XCTAssertEqual(sut.getCurrentMessage(), "WORK!")
                XCTAssertEqual(sut.roundsLeft, 2)
                sut.action()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    XCTAssertEqual(sut.getActionIcon(), "play.circle")
                   XCTAssertEqual(sut.getCurrentMessage(), "PAUSED!")
                   XCTAssertEqual(sut.roundsLeft, 2)
                    sut.action()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        XCTAssertEqual(sut.getActionIcon(), "pause.circle")
                        XCTAssertEqual(sut.getCurrentMessage(), "WORK!")
                        XCTAssertEqual(sut.roundsLeft, 2)
                        // Tear down unit test
                        sut.close()
                        // Allow WKExtendedRuntimeSession delegate class unlink from sut
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            expectation.fulfill()
                        }
                    }
                }
            }
        }
        wait(for: [expectation], timeout: 10.0)
    }
   
    func testStartAndCloseAfter3Secs() {
        let expectation = XCTestExpectation(description: "testStart")
        let sut = EMOMViewModel()
        sut.set(emom: .sample1rounds5Work0Rest)

        sut.action()
        sut.startWorkTime()
        // Execute after delay because startWorTime set ups a delegate and our test is
        // validating the delegate actions
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(sut.state, .startedWork)
            XCTAssertEqual(sut.showCountDownView, false)
            XCTAssertEqual(sut.getActionIcon(), "pause.circle")
            XCTAssertEqual(sut.getCurrentMessage(), "LAST ROUND!!!")
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                sut.close()
                // Allow WKExtendedRuntimeSession delegate class unlink from sut
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    XCTAssertEqual(sut.state, .cancelled)
                    XCTAssertEqual(sut.showCountDownView, false)
                    let timeInterval = sut.chronoOnMove?.timeIntervalSinceNow ?? 0.0
                    XCTAssertEqual(timeInterval.rounded(.down), 0.0)
                    XCTAssertNil(sut.timerWork)
                    XCTAssertNil(sut.timerRest)
                    XCTAssertNotNil(sut.extendedRuntimeSession)
                    XCTAssertEqual(sut.roundsLeft, 1)
                    XCTAssertEqual(sut.getActionIcon(), "play.circle")
                    XCTAssertEqual(sut.getCurrentMessage(), "")
                    expectation.fulfill()
                }
            }
        }
        wait(for: [expectation], timeout: 6.0)
    }

    func testStop() {
        // Given
        let sut = EMOMViewModel()
        sut.set(emom: .sample16rounds50Work10Rest)
        //XCTAssertNil(sut.timer)
        sut.action()
        // When
        sut.close()
        // Then
        //XCTAssertNil(sut.timer)
        //XCTAssertEqual(sut.state, .cancelled)
    }

    func testGetChrono() {
        let sut = EMOMViewModel()
        sut.set(emom: .sample1rounds1Work0Rest)
//        XCTAssertEqual(sut.getChrono(state: .notStarted, emom: .sample10rounds3720Work10Rest), "01:02:00")
//        XCTAssertEqual(sut.getChrono(state: .startedWork, emom: .sample16rounds50Work10Rest), "00:50")
//        XCTAssertEqual(sut.getChrono(state: .startedWork, emom: .sample16rounds50Work10Rest, secsEllapsed: 10), "00:40")
//        XCTAssertEqual(sut.getChrono(state: .startedRest, emom: .sample16rounds50Work10Rest), "00:10")
//        XCTAssertEqual(sut.getChrono(state: .startedRest, emom: .sample16rounds50Work10Rest, secsEllapsed: 2), "00:08")
//        XCTAssertEqual(sut.getChrono(state: .finished, emom: .sample16rounds50Work10Rest), "16:00")
//        XCTAssertEqual(sut.getChrono(state: .finished, emom: .sample16rounds50Work10Rest, secsEllapsed: 2), "16:00")
    }
}
