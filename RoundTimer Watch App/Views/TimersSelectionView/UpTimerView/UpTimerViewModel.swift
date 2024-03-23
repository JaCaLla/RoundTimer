//
//  UpTimerViewModel.swift
//  RoundTimer Watch App
//
//  Created by Javier Calartrava on 17/3/24.
//

import SwiftUI

final class UpTimerViewModel: NSObject, ObservableObject {

    // MARK: - Emom timer states
    enum State: Int {
        case notStarted, startedWork, paused, finished, cancelled
    }

    @Published var chronoOnMove: Date?
    @Published var chronoFrozen = "--:--"

    internal var actionIcon = "play"
    internal var timerWork: Timer?
    internal var extendedRuntimeSession: WKExtendedRuntimeSession?
    internal var state: State = .notStarted
    internal var ellapsed = 0.0
    @Published var emom: CustomTimer?

    private func startWorkTime() {
        extendedRuntimeSession = WKExtendedRuntimeSession()
        extendedRuntimeSession?.delegate = self
        extendedRuntimeSession?.start()
    }

    func close() {
        emom = nil
        state = .cancelled
        removeTimers()
        removeExtendedRuntimeSession()
    }

    func pause() {
        HapticManager.shared.pause()
        extendedRuntimeSession?.invalidate()
        if let timerWork, let emom {
            let secsToFinishAfterPausing = abs(timerWork.fireDate.timeIntervalSinceNow)
            ellapsed = Double(emom.workSecs - Int(secsToFinishAfterPausing)) - 1
            print("secsEllapsed: \(ellapsed) secs2Finish:\(Int(secsToFinishAfterPausing))")
            chronoFrozen = CustomTimer.getHHMMSS(seconds: Int(ellapsed))
        }
    }

    func action() {
        if [.notStarted].contains(where: { $0 == state }) {
            startWorkTime()
            HapticManager.shared.pause()
        } else if [.paused].contains(where: { $0 == state }) {
            startWorkTime()
        } else if state == .startedWork {
            pause()
            set(to: .paused)
        } else if state == .finished {
            set(to: .notStarted)
            set(emom: emom)
        }
    }

    func set(emom: CustomTimer?) {
        guard let emom else { return }
        self.emom = emom
        state = .notStarted
        chronoFrozen = CustomTimer.getHHMMSS(seconds: emom.workSecs)
    }

    internal func getActionIcon() -> String {
        if state == .finished {
            return "arrow.uturn.left.circle"
        } else if state == .startedWork {
            return "pause.circle"
        } else {
            return "play.circle"
        }
    }

    func actionButtonColor() -> Color {
        if state == .finished {
            return .timerNotStartedColor
        } else if state == .startedWork {
            return .timerNotStartedColor
        } else if state == .notStarted || state == .paused {
            return .timerStartedColor
        } else {
            return .green
        }
    }

    func getBackground() -> Color {
        state == .finished ? .timerFinishedBackgroundColor : .clear
    }

    //MARK: - Helpers
    func getForegroundTextColor() -> Color {
        if [.notStarted, .finished, .paused].contains(where: { $0 == state }) {
            return .timerNotStartedColor
        } else if state == .startedWork {
            return .timerStartedColor
        } else {
            return .green
        }
    }

    func getTimerAndRoundFont(isLuminanceReduced: Bool = false) -> Font {
        guard let emom else { return .timerAndRoundLargeFont }
        let isRound2Digits = emom.rounds > 9
        let isWork2MMDigits = [emom.workSecs, emom.restSecs].contains(where: { $0 >= 10 * 60 }) ||
        (state == .finished && ((emom.workSecs + emom.restSecs) * emom.rounds) > 10 * 60)
        if isRound2Digits && isWork2MMDigits {
            return isLuminanceReduced && state != .finished ? .timerAndRoundLRSmallFont : .timerAndRoundSmallFont
        } else if isRound2Digits || isWork2MMDigits {
            return isLuminanceReduced && state != .finished ?  .timerAndRoundLRMediumFont : .timerAndRoundMediumFont
        } else {
            return isLuminanceReduced && state != .finished ? .timerAndRoundLRLargeFont : .timerAndRoundLargeFont
        }
    }

    func hasToShow() -> Bool {
        state == .startedWork
    }
    
    internal func getRoundsProgress(customTimer: CustomTimer?) -> Double {
        guard let chronoOnMove,
              let customTimer else { return 0.0 }
        let ellapsed = Date.now.timeIntervalSince(chronoOnMove)
        return ellapsed / Double(customTimer.workSecs)
    }

    func getCurrentMessage(customTimer: CustomTimer?) -> String {
        guard let customTimer else { return "" }
        if state == .finished {
            return "FINISHED!"
        } else if state == .notStarted {
            return "PRESS PLAY!"
        } else if state == .startedWork {
            return "TIME UP \(CustomTimer.getHHMMSS(seconds: customTimer.workSecs))"
        } else if state == .paused {
            return "PAUSED!"
        } else {
            return ""
        }
    }


    private func removeTimers() {
        dropTimer(&timerWork)
    }
    
    private func dropTimer(_ timer: inout Timer?) {
        if let timer {
            timer.invalidate()
        }
        timer = nil
    }

    private func removeExtendedRuntimeSession() {
        guard let extendedRuntimeSession else { return }
        extendedRuntimeSession.invalidate()
    }

    private func set(to state: State) {
        self.state = state
    }
}


// MARK: - WKExtendedRuntimeSessionDelegate
extension UpTimerViewModel: WKExtendedRuntimeSessionDelegate {
    func extendedRuntimeSessionDidStart(
        _ extendedRuntimeSession: WKExtendedRuntimeSession
    ) {
        guard let emom else { return }
        processWorktime(extendedRuntimeSession: extendedRuntimeSession, emom: emom, timerWork: &timerWork)
        
        HapticManager.shared.start()
    }

    func extendedRuntimeSessionWillExpire(
        _ extendedRuntimeSession: WKExtendedRuntimeSession
    ) {
    }

    func extendedRuntimeSession(
        _ extendedRuntimeSession: WKExtendedRuntimeSession,
        didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason,
        error: Error?
    ) {
        removeTimers()
        chronoOnMove = nil

        if state == .finished, let emom {
                chronoFrozen = CustomTimer.getHHMMSS(seconds: CustomTimer.getTotal(emom: emom))
        }
    }

    // MARK :- Private/Internal
    private func processWorktime(extendedRuntimeSession: WKExtendedRuntimeSession, emom: CustomTimer, timerWork: inout Timer?) {
          // When: state == .notStarted
        var fireWork = Date.now.addingTimeInterval(Double(emom.workSecs))
        chronoOnMove = Date.now//endOfWork(emom: emom)
        if state == .paused {
                chronoOnMove = Date.now.addingTimeInterval(-ellapsed)
            let secsToFire = Double(emom.workSecs) - ellapsed
            print("secs2Fire: \(secsToFire)")
                fireWork = Date.now.addingTimeInterval(secsToFire)
        }
        set(to: .startedWork)

        createAndRunTimerWork(emom, extendedRuntimeSession, fireWork, timerWork: &timerWork)
    }
    
    fileprivate func createAndRunTimerWork(_ emom: CustomTimer, _ extendedRuntimeSession: WKExtendedRuntimeSession, _ fireWork: Date, timerWork: inout Timer?) {

        HapticManager.shared.start()
        
        let blockTimerWork: (Timer) -> Void = { [weak self] _ in
            guard let self else { return }
                AudioManager.shared.finish()
                self.set(to: .finished)
                extendedRuntimeSession.invalidate()
                HapticManager.shared.finish()
        }

        timerWork = Timer(
            fire: fireWork,
            interval: 0.0,
            repeats: true,
            block: blockTimerWork)
        
        guard let timerWork else { return }
        RunLoop.main.add(timerWork, forMode: .common)
    }
}

