//
//  EmomUT.swift
//  RoundTimer Watch AppTests
//
//  Created by Javier Calartrava on 20/1/24.
//
@testable import EMOM_timers_Watch_App
import XCTest

final class EmomUT: XCTestCase {

    func testTimeHHMMSS() {
        XCTAssertEqual(CustomTimer.sample1rounds10Work0Rest.timeHHMMSS(), "0:10")
        XCTAssertEqual(CustomTimer.sample1rounds10Work0Rest.timeHHMMSS(isWork: false), "0:00")
        XCTAssertEqual(CustomTimer.sample1rounds30Work30Rest.timeHHMMSS(), "0:30")
        XCTAssertEqual(CustomTimer.sample1rounds30Work30Rest.timeHHMMSS(isWork: false), "0:30")
        XCTAssertEqual(CustomTimer.sample16rounds50Work10Rest.timeHHMMSS(), "0:50")
        XCTAssertEqual(CustomTimer.sample16rounds50Work10Rest.timeHHMMSS(isWork: false), "0:10")
        XCTAssertEqual(CustomTimer.sample10rounds3720Work10Rest.timeHHMMSS(), "01:02:00")
        XCTAssertEqual(CustomTimer.sample10rounds3720Work10Rest.timeHHMMSS(isWork: false), "0:10")
    }
    
    func testGetSummary() {
        XCTAssertEqual(CustomTimer.getSummary(seconds: 0), "0 s")
        XCTAssertEqual(CustomTimer.getSummary(seconds: 1), "1 s")
        XCTAssertEqual(CustomTimer.getSummary(seconds: 59), "59 s")
        XCTAssertEqual(CustomTimer.getSummary(seconds: 60), "1 MIN")
        XCTAssertEqual(CustomTimer.getSummary(seconds: 120), "2 MIN")
        XCTAssertEqual(CustomTimer.getSummary(seconds: 3599), "59 MIN")
        XCTAssertEqual(CustomTimer.getSummary(seconds: 3600), "1 H")
        XCTAssertEqual(CustomTimer.getSummary(seconds: 7200), "2 H")
    }
    
    func testInit() {
        var emom = CustomTimer(timerType: .emom, rounds: 1, workSecs: 2, restSecs: 3)
        XCTAssertEqual(emom.rounds, 1)
        XCTAssertEqual(emom.workSecs, 2)
        XCTAssertEqual(emom.restSecs, 3)
        emom = CustomTimer(timerType: .emom, rounds: 10)
        XCTAssertEqual(emom.rounds, 10)
        XCTAssertEqual(emom.workSecs, 0)
        XCTAssertEqual(emom.restSecs, 0)
    }
    
    func testGetTotal() {
        XCTAssertEqual(CustomTimer.getTotal(emom: .sample1rounds10Work0Rest), 10)
        XCTAssertEqual(CustomTimer.getTotal(emom: .sample1rounds30Work30Rest), 60)
        XCTAssertEqual(CustomTimer.getTotal(emom: .sample16rounds50Work10Rest), 16 * 60)
        XCTAssertEqual(CustomTimer.getTotal(emom: .sample10rounds3720Work10Rest), 10 * ((1 * 3600 + 120) + 10))
    }

    func testGetRound() {
        XCTAssertEqual(CustomTimer.getRound(emom: .sample2rounds30Work0Rest, secsEllapsed: 0), 1)
        XCTAssertEqual(CustomTimer.getRound(emom: .sample2rounds30Work0Rest, secsEllapsed: 1), 1)
        XCTAssertEqual(CustomTimer.getRound(emom: .sample2rounds30Work0Rest, secsEllapsed: 29), 1)
        XCTAssertEqual(CustomTimer.getRound(emom: .sample2rounds30Work0Rest, secsEllapsed: 30), 2)
        XCTAssertEqual(CustomTimer.getRound(emom: .sample2rounds30Work0Rest, secsEllapsed: 31), 2)
        XCTAssertEqual(CustomTimer.getRound(emom: .sample2rounds30Work0Rest, secsEllapsed: 59), 2)
        XCTAssertEqual(CustomTimer.getRound(emom: .sample2rounds30Work0Rest, secsEllapsed: 60), 2)
        XCTAssertEqual(CustomTimer.getRound(emom: .sample2rounds30Work0Rest, secsEllapsed: 61), 2)
    }
    
    func testSecsToNextRound() {
        XCTAssertEqual(CustomTimer.secsToNextRoud(emom: .sample2rounds30Work0Rest, secsEllapsed: 0), 0)
        XCTAssertEqual(CustomTimer.secsToNextRoud(emom: .sample2rounds30Work0Rest, secsEllapsed: 20), 10)
        XCTAssertEqual(CustomTimer.secsToNextRoud(emom: .sample2rounds30Work0Rest, secsEllapsed: 29), 1)
        XCTAssertEqual(CustomTimer.secsToNextRoud(emom: .sample2rounds30Work0Rest, secsEllapsed: 30), 0)
        XCTAssertEqual(CustomTimer.secsToNextRoud(emom: .sample2rounds30Work0Rest, secsEllapsed: 31), 29)
        XCTAssertEqual(CustomTimer.secsToNextRoud(emom: .sample2rounds30Work0Rest, secsEllapsed: 59), 1)
        XCTAssertEqual(CustomTimer.secsToNextRoud(emom: .sample2rounds30Work0Rest, secsEllapsed: 60), 0)
        XCTAssertEqual(CustomTimer.secsToNextRoud(emom: .sample2rounds30Work0Rest, secsEllapsed: 61), 0)
        XCTAssertEqual(CustomTimer.secsToNextRoud(emom: .sample2rounds30Work0Rest, secsEllapsed: 62), 0)
        XCTAssertEqual(CustomTimer.secsToNextRoud(emom: .sample2rounds30Work0Rest, secsEllapsed: 99999), 0)
    }
    
    /*
     secsToNextRoud
    */
}

extension CustomTimer {
    static let sample1rounds1Work0Rest = CustomTimer(timerType: .emom, rounds: 1, workSecs: 1, restSecs: 0)
    static let sample1rounds5Work0Rest = CustomTimer(timerType: .emom, rounds: 1, workSecs: 5, restSecs: 0)
    static let sample2rounds5Work5Rest = CustomTimer(timerType: .emom, rounds: 2, workSecs: 5, restSecs: 5)
    static let sample2rounds5Work0Rest = CustomTimer(timerType: .emom, rounds: 2, workSecs: 5, restSecs: 0)
    static let sample1rounds30Work0Rest = CustomTimer(timerType: .emom, rounds: 1, workSecs: 30, restSecs: 0)
    static let sample2rounds30Work0Rest = CustomTimer(timerType: .emom, rounds: 2, workSecs: 30, restSecs: 0) // pass
    static let sample3rounds60Work0Rest = CustomTimer(timerType: .emom, rounds: 3, workSecs: 60, restSecs: 0)
    static let sample15rounds60Work0Rest = CustomTimer(timerType: .emom, rounds: 15, workSecs: 60, restSecs: 0)
    
    static let sample1rounds10Work0Rest = CustomTimer(timerType: .emom, rounds: 1, workSecs: 10, restSecs: 0)
    static let sample1rounds30Work30Rest = CustomTimer(timerType: .emom, rounds: 1, workSecs: 30, restSecs: 30)
    static let sample16rounds50Work10Rest = CustomTimer(timerType: .emom, rounds: 16, workSecs: 50, restSecs: 10)
    static let sample10rounds3720Work10Rest = CustomTimer(timerType: .emom, rounds: 10, workSecs: 3720, restSecs: 10)
}

extension Array where Element == CustomTimer {
    static var sampleEvenList: [CustomTimer] = [.sample1rounds10Work0Rest,
            .sample1rounds30Work30Rest,
            .sample16rounds50Work10Rest,
            .sample10rounds3720Work10Rest]
    static var sampleOddList: [CustomTimer] = [.sample1rounds10Work0Rest,
            .sample1rounds30Work30Rest,
            .sample16rounds50Work10Rest]

}
