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
        XCTAssertEqual(sut.actionIcon, "play.circle")
        
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) { [weak self] in
            sut.startWorkTime()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                XCTAssertEqual(sut.state, .startedWork)
                XCTAssertEqual(sut.showCountDownView, false)
//                let timeInterval = self?.sut.chronoOnMove?.timeIntervalSinceNow ?? 0.0
//                XCTAssertEqual(timeInterval, 5.0)
                /*
                 @Published var chronoOnMove: Date?
                 @Published var chronoFrozen = "--:--"
                 @Published var showCountDownView = false

                 private (set) var actionIcon = "play"
                 private var timerWork: Timer?
                 private var timerRest: Timer?
                 private var extendedRuntimeSession: WKExtendedRuntimeSession?
                 internal var state: State = .notStarted
                 internal var previousStateBeforePausing: State = .startedWork
                 private var secsToFinishAfterPausing: TimeInterval = 0
                 private var secsToFinishRestAfterPausing: TimeInterval = 0
                 private var roundsLeftAfterPausing: Int?
                 private var roundsLeft = 0
                 */
                sut.close()
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
            /*
             @Published var chronoOnMove: Date?
             @Published var chronoFrozen = "--:--"
             @Published var showCountDownView = false

             private (set) var actionIcon = "play"
             private var timerWork: Timer?
             private var timerRest: Timer?
             private var extendedRuntimeSession: WKExtendedRuntimeSession?
             internal var state: State = .notStarted
             internal var previousStateBeforePausing: State = .startedWork
             private var secsToFinishAfterPausing: TimeInterval = 0
             private var secsToFinishRestAfterPausing: TimeInterval = 0
             private var roundsLeftAfterPausing: Int?
             private var roundsLeft = 0
             */
            sut.close()
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                let timeInterval = sut.chronoOnMove?.timeIntervalSinceNow ?? 0.0
                XCTAssertEqual(timeInterval.rounded(.down), 2.0)
                sut.close()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    expectation.fulfill()
                }
            }

            /*
             @Published var chronoOnMove: Date?
             @Published var chronoFrozen = "--:--"
             @Published var showCountDownView = false

             private (set) var actionIcon = "play"
             private var timerWork: Timer?
             private var timerRest: Timer?
             private var extendedRuntimeSession: WKExtendedRuntimeSession?
             internal var state: State = .notStarted
             internal var previousStateBeforePausing: State = .startedWork
             private var secsToFinishAfterPausing: TimeInterval = 0
             private var secsToFinishRestAfterPausing: TimeInterval = 0
             private var roundsLeftAfterPausing: Int?
             private var roundsLeft = 0
             */
           
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
