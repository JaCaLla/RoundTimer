//
//  EmomUT.swift
//  RoundTimer Watch AppTests
//
//  Created by Javier Calartrava on 20/1/24.
//
@testable import RoundTimer_Watch_App
import XCTest

final class EmomUT: XCTestCase {

    func testTimeHHMMSS() {
        XCTAssertEqual(Emom.sample1rounds10Work0Rest.timeHHMMSS(), "00:10")
        XCTAssertEqual(Emom.sample1rounds10Work0Rest.timeHHMMSS(isWork: false), "00:00")
        XCTAssertEqual(Emom.sample1rounds30Work30Rest.timeHHMMSS(), "00:30")
        XCTAssertEqual(Emom.sample1rounds30Work30Rest.timeHHMMSS(isWork: false), "00:30")
        XCTAssertEqual(Emom.sample16rounds50Work10Rest.timeHHMMSS(), "00:50")
        XCTAssertEqual(Emom.sample16rounds50Work10Rest.timeHHMMSS(isWork: false), "00:10")
        XCTAssertEqual(Emom.sample10rounds3720Work10Rest.timeHHMMSS(), "01:02:00")
        XCTAssertEqual(Emom.sample10rounds3720Work10Rest.timeHHMMSS(isWork: false), "00:10")
    }
    
    func testGetSummary() {
        XCTAssertEqual(Emom.getSummary(seconds: 0), "0 s")
        XCTAssertEqual(Emom.getSummary(seconds: 1), "1 s")
        XCTAssertEqual(Emom.getSummary(seconds: 59), "59 s")
        XCTAssertEqual(Emom.getSummary(seconds: 60), "1 MIN")
        XCTAssertEqual(Emom.getSummary(seconds: 120), "2 MIN")
        XCTAssertEqual(Emom.getSummary(seconds: 3599), "59 MIN")
        XCTAssertEqual(Emom.getSummary(seconds: 3600), "1 H")
        XCTAssertEqual(Emom.getSummary(seconds: 7200), "2 H")
    }
    
    func testInit() {
        var emom = Emom(rounds: 1, workSecs: 2, restSecs: 3)
        XCTAssertEqual(emom.rounds, 1)
        XCTAssertEqual(emom.workSecs, 2)
        XCTAssertEqual(emom.restSecs, 3)
        emom = Emom(rounds: 10)
        XCTAssertEqual(emom.rounds, 10)
        XCTAssertEqual(emom.workSecs, 0)
        XCTAssertEqual(emom.restSecs, 0)
    }
    
    func testGetTotal() {
        XCTAssertEqual(Emom.getTotal(emom: .sample1rounds10Work0Rest), 10)
        XCTAssertEqual(Emom.getTotal(emom: .sample1rounds30Work30Rest), 60)
        XCTAssertEqual(Emom.getTotal(emom: .sample16rounds50Work10Rest), 16 * 60)
        XCTAssertEqual(Emom.getTotal(emom: .sample10rounds3720Work10Rest), 10 * ((1 * 3600 + 120) + 10))
    }
    /*
     static func getTotal(emom: Emom) -> Int {
         emom.rounds * ( emom.workSecs + emom.restSecs)
     }
     */
}
