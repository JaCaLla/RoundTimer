//
//  WKExtendedRuntimeSessionDelegateMock.swift
//  EMOM timers Watch AppTests
//
//  Created by Javier Calartrava on 19/8/24.
//

import Foundation
import WatchKit
import XCTest

class WKExtendedRuntimeSessionDelegateMock: NSObject, WKExtendedRuntimeSessionDelegate {
    var extendedRuntimeSessionDidStartCount = 0
    var extendedRuntimeSessionWillExpireCount = 0
    var extendedRuntimeSessionCount = 0
    var expectation: XCTestExpectation?
    
    func extendedRuntimeSessionDidStart(
        _ extendedRuntimeSession: WKExtendedRuntimeSession
    ) {
        extendedRuntimeSessionDidStartCount += 1
        expectation?.fulfill()
    }
    
    func extendedRuntimeSessionWillExpire(
        _ extendedRuntimeSession: WKExtendedRuntimeSession
    ) {
        extendedRuntimeSessionWillExpireCount += 1
        expectation?.fulfill()
    }

    func extendedRuntimeSession(
        _ extendedRuntimeSession: WKExtendedRuntimeSession,
        didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason,
        error: Error?
    ) {
        extendedRuntimeSessionCount  += 1
        expectation?.fulfill()
    }
    
}
