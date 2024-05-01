import SwiftUI

final class EMOMViewModel: NSObject, ObservableObject {

    // MARK: - Emom timer states
    enum State: Int {
        case notStarted, startedWork, startedRest, paused, finished, cancelled
    }

    @Published var chronoOnMove: Date?
    @Published var chronoFrozen = "--:--"

    internal var actionIcon = "play"
    internal var timerWork: Timer?
    internal var timerRest: Timer?
    internal var extendedRuntimeSession: WKExtendedRuntimeSession?
    internal var state: State = .notStarted
    internal var previousStateBeforePausing: State = .startedWork
    internal var secsToFinishAfterPausing: TimeInterval = 0
    internal var secsToFinishRestAfterPausing: TimeInterval = 0
    internal var roundsLeftAfterPausing: Int?
    internal var roundsLeft = 0
    @Published var emom: CustomTimer?

    internal func startWorkTime() {
        if let roundsLeftAfterPausing {
            set(roundsLeft: roundsLeftAfterPausing)
        } else if let emom {
            set(roundsLeft: emom.rounds)
        }
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

    private func pause() {
        HapticManager.shared.pause()
        extendedRuntimeSession?.invalidate()
        if let timerWork,
            previousStateBeforePausing == .startedWork {
            secsToFinishAfterPausing = abs(timerWork.fireDate.timeIntervalSinceNow) - Double((emom?.restSecs ?? 0))
            roundsLeftAfterPausing = roundsLeft
            let secsChronoFrozen = Double((emom?.workSecs ?? 0)) - secsToFinishAfterPausing
            chronoFrozen = CustomTimer.getHHMMSS(seconds: Int(secsChronoFrozen))
        } else if let timerWork,
            previousStateBeforePausing == .startedRest {
            secsToFinishRestAfterPausing = abs(timerWork.fireDate.timeIntervalSinceNow)
            roundsLeftAfterPausing = roundsLeft
            let secsChronoFrozen = Double((emom?.restSecs ?? 0)) - secsToFinishRestAfterPausing
            chronoFrozen = CustomTimer.getHHMMSS(seconds: Int(secsChronoFrozen))
        }
    }

    func action() {
        if [.notStarted].contains(where: { $0 == state }) {
            startWorkTime()
            HapticManager.shared.pause()
        } else if [.paused].contains(where: { $0 == state }) {
            startWorkTime()
        } else if state == .startedRest || state == .startedWork {
            previousStateBeforePausing = state
            set(state: .paused)
            pause()
        } else if state == .finished {
            set(state: .notStarted)
            set(emom: emom)
            roundsLeftAfterPausing = nil
        }
    }

    func set(emom: CustomTimer?) {
        guard let emom else { return }
        self.emom = emom
        state = .notStarted
        chronoFrozen = CustomTimer.getHHMMSS(seconds: emom.workSecs)
    }

    private func endOfRound(emom: CustomTimer) -> Date? {
        Date.now.addingTimeInterval(Double(emom.workSecs + emom.restSecs))
    }

    private func endOfWork(emom: CustomTimer) -> Date? {
        Date.now.addingTimeInterval(Double(emom.workSecs /*+ 1*/))
    }

    private func endOfRest(emom: CustomTimer) -> Date? {
        Date.now.addingTimeInterval(Double(emom.restSecs /*+ 1*/))
    }

    internal func getRoundsProgress() -> Double {
        guard let emom else { return 0.0 }
        if state == .finished {
            return 1.0
        } else if state == .startedWork || state == .startedRest {
            return Double(emom.rounds - roundsLeft + 1) / Double(emom.rounds)
        } else {
            return 0.0
        }
    }

    internal func getActionIcon() -> String {
        if state == .finished {
            return "arrow.uturn.left.circle"
        } else if state == .startedWork || state == .startedRest {
            return "pause.circle"
        } else {
            return "play.circle"
        }
    }

    func actionButtonColor() -> Color {
        if state == .finished {
            return .timerNotStartedColor
        } else if state == .startedWork || state == .startedRest {
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
        } else if state == .startedRest {
            return .timerRestStartedColor
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

    func hasToShow(work: Bool = true) -> Bool {
        return work ? state == .startedWork: state == .startedRest
    }

    func getCurrentRound() -> String {
        guard let emom else { return "" }
        if [.notStarted].contains(where: { state == $0 }) {
            return "1"
        } else if [.finished].contains(where: { state == $0 }) {
            return String(format: "%0d", emom.rounds)
        } else if state == .startedWork || state == .paused {
            return String(format: "%0d", emom.rounds - roundsLeft + 1)
        } else if state == .startedRest || state == .paused {
            return String(format: "%0d", emom.rounds - roundsLeft + 1)
        } else {
            return "00"
        }
    }
    
    func getRounds() -> String {
        guard let emom else { return "" }
        return String(format: "/%0d", emom.rounds)
    }

    func getCurrentMessage() -> String {
        if state == .finished {
            return "FINISHED!"
        } else if state == .notStarted {
            return "PRESS PLAY!"
        } else if state == .startedWork {
            return roundsLeft <= 1 ? "LAST ROUND!!!" : "WORK!"
        } else if state == .startedRest {
            return roundsLeft <= 1 ? "LAST ROUND!!!" : "REST!"
        } else if state == .paused {
            return "PAUSED!"
        } else {
            return ""
        }
    }


    private func removeTimers() {
        dropTimer(&timerWork)
        dropTimer(&timerRest)
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

    private func set(state to: State) {
        self.state = to
    }
    
    private func set(roundsLeft: Int) {
        self.roundsLeft = roundsLeft
    }
    
    private func decreaseBy1RoundsLeft() {
        self.roundsLeft -= 1
    }
}


// MARK: - WKExtendedRuntimeSessionDelegate
extension EMOMViewModel: WKExtendedRuntimeSessionDelegate {
    func extendedRuntimeSessionDidStart(
        _ extendedRuntimeSession: WKExtendedRuntimeSession
    ) {
        guard let emom else { return }
        processWorktime(extendedRuntimeSession: extendedRuntimeSession, emom: emom, timerWork: &timerWork)
        
        HapticManager.shared.start()
                
        if emom.restSecs > 0 {
            processResttime(extendedRuntimeSession: extendedRuntimeSession, emom: emom, timerRest: &timerRest)
        }
        // Do set state after setting timers
        if state == .paused {
            if previousStateBeforePausing == .startedWork {
                self.set(state: .startedWork)
            } else if previousStateBeforePausing == .startedRest {
                set(state: .startedRest)
            }
        } else if state == .notStarted {
            set(state: .startedWork)
        }
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

        if state == .finished {
            set(roundsLeft: 0)
            if let emom {
                chronoFrozen = CustomTimer.getHHMMSS(seconds: CustomTimer.getTotal(emom: emom))
            }
        }
    }

    // MARK :- Private/Internal
    private func processWorktime(extendedRuntimeSession: WKExtendedRuntimeSession, emom: CustomTimer, timerWork: inout Timer?) {
        // LOOK OUT! DO NOT SET STATE IN THIS FUNCTION!!
        guard var fireWork = endOfRound(emom: emom) else { return }
        chronoOnMove = Date.now
        if state == .paused {
            if previousStateBeforePausing == .startedWork {
                let secsChronoFrozen = Double(emom.workSecs) - secsToFinishAfterPausing
                chronoOnMove = Date.now.addingTimeInterval(-secsChronoFrozen)
                fireWork = Date.now.addingTimeInterval(secsToFinishAfterPausing + Double(emom.restSecs))
            } else if previousStateBeforePausing == .startedRest {
                let secsChronoFrozen = Double(emom.restSecs) - secsToFinishRestAfterPausing
                chronoOnMove = Date.now.addingTimeInterval(-secsChronoFrozen)
                fireWork = Date.now.addingTimeInterval(secsToFinishRestAfterPausing)
            }
        }
        createAndRunTimerWork(emom, extendedRuntimeSession, fireWork, timerWork: &timerWork)
    }
    
    fileprivate func createAndRunTimerWork(_ emom: CustomTimer, _ extendedRuntimeSession: WKExtendedRuntimeSession, _ fireWork: Date, timerWork: inout Timer?) {

        HapticManager.shared.start()
        
        let blockTimerWork: (Timer) -> Void = { [weak self] _ in
            guard let self else { return }
            self.decreaseBy1RoundsLeft()
            
            if roundsLeft > 0 {
                AudioManager.shared.work()
                self.set(state: .startedWork)
                self.chronoOnMove = Date.now
                HapticManager.shared.work()
            } else {
                AudioManager.shared.finish()
                self.set(state: .finished)
                extendedRuntimeSession.invalidate()
                HapticManager.shared.finish()
            }
        }
        let secondsPerRound = Double(emom.workSecs /*+ 1 */+ emom.restSecs)
        timerWork = Timer(
            fire: fireWork,
            interval: secondsPerRound,
            repeats: true,
            block: blockTimerWork)
        
        guard let timerWork else { return }
        RunLoop.main.add(timerWork, forMode: .common)
    }
    
    private func processResttime(extendedRuntimeSession: WKExtendedRuntimeSession, emom: CustomTimer, timerRest: inout Timer?) {
        guard var fireRest = endOfWork(emom: emom) else { return }
        // LOOK OUT! DO NOT SET STATE IN THIS FUNCTION!!
        if state == .paused {
            if previousStateBeforePausing == .startedWork {
                fireRest = Date.now.addingTimeInterval(secsToFinishAfterPausing)
                AudioManager.shared.work()
                
            } else if previousStateBeforePausing == .startedRest {
                fireRest = Date.now.addingTimeInterval(secsToFinishRestAfterPausing + Double(emom.workSecs))
                AudioManager.shared.rest()
            }
        }

        createAndRunRestTimer(emom, fireRest, extendedRuntimeSession, timerRest: &timerRest)
    }
    
    fileprivate func createAndRunRestTimer(_ emom: CustomTimer, _ fireRest: Date, _ extendedRuntimeSession: WKExtendedRuntimeSession, timerRest: inout Timer?) {
        
        let blockRestTimer: (Timer) -> Void = { [weak self] _ in
            guard let self else { return }
            self.set(state: .startedRest)
            if roundsLeft > 0 {
                self.chronoOnMove = Date.now
                AudioManager.shared.rest()
                HapticManager.shared.rest()
            } else {
                extendedRuntimeSession.invalidate()
                HapticManager.shared.finish()
            }
        }
        let secondsPerRound = Double(emom.workSecs /*+ 1*/ + emom.restSecs)
        timerRest = Timer(fire: fireRest, interval: secondsPerRound, repeats: true, block: blockRestTimer)
        guard let timerRest else { return }
        RunLoop.main.add(timerRest, forMode: .common)
    }
}
