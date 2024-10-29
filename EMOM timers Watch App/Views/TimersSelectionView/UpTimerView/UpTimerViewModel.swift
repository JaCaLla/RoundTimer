//
//  UpTimerViewModel.swift
//  RoundTimer Watch App
//
//  Created by Javier Calartrava on 17/3/24.
//

@preconcurrency import SwiftUI
@MainActor
final class UpTimerViewModel: NSObject, ObservableObject {

    // MARK: - Emom timer states
    enum State: Int {
        case notStarted, startedWork, paused, finished, cancelled
    }

    @Published var chronoOnMove: Date?
    @Published var chronoFrozen = "--:--"
    @Published var progress: Double = 0.0

    internal var actionIcon = "play"
    internal var timerWork: Timer?
    internal var refreshProgressTimer: Timer?
    internal var extendedRuntimeSession: WKExtendedRuntimeSession?
    internal var state: State = .notStarted
    internal var ellapsed = 0.0
    @Published var customTimer: CustomTimer?
    
    deinit {
        Task { [weak self] in
            await self?.removeTimers()
        }
    }

    private func startWorkTime() {
        extendedRuntimeSession = WKExtendedRuntimeSession()
        extendedRuntimeSession?.delegate = self
        extendedRuntimeSession?.start()
    }

    func close() {
        customTimer = nil
        state = .cancelled
        removeTimers()
        removeExtendedRuntimeSession()
    }

    private func pause() {
        HapticManager.shared.pause()
        extendedRuntimeSession?.invalidate()
        if let timerWork, let customTimer {
            ellapsed = getEllapedSecs(timerWork: timerWork, customTimer: customTimer)
            chronoFrozen = CustomTimer.getHHMMSS(seconds: Int(ellapsed))
        }
    }
    
    private func getEllapedSecs(timerWork: Timer?, customTimer: CustomTimer?) -> Double {
        guard let timerWork, let customTimer else { return 0.0 }
        let secsToFinishAfterPausing = abs(timerWork.fireDate.timeIntervalSinceNow)
        let ellapsed = Double(customTimer.workSecs - Int(secsToFinishAfterPausing)) - 1
        print("secsEllapsed: \(ellapsed) secs2Finish:\(Int(secsToFinishAfterPausing))")
        return ellapsed
    }

    func action() {
        if [.notStarted].contains(where: { $0 == state }) {
            startWorkTime()
            HapticManager.shared.pause()
        } else if [.paused].contains(where: { $0 == state }) {
            startWorkTime()
        } else if state == .startedWork {
            pause()
            set(state: .paused)
        } else if state == .finished {
            set(state: .notStarted)
            set(emom: customTimer)
        }
    }

    func set(emom: CustomTimer?) {
        guard let emom else { return }
        self.customTimer = emom
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
        guard let customTimer else { return .timerAndRoundLargeFont }
        let isRound2Digits = customTimer.rounds > 9
        let isWork2MMDigits = [customTimer.workSecs, customTimer.restSecs].contains(where: { $0 >= 10 * 60 }) ||
        (state == .finished && ((customTimer.workSecs + customTimer.restSecs) * customTimer.rounds) > 10 * 60)
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
        dropTimer(&refreshProgressTimer)
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
}


// MARK: - WKExtendedRuntimeSessionDelegate
extension UpTimerViewModel: WKExtendedRuntimeSessionDelegate {
    nonisolated func extendedRuntimeSessionDidStart(
        _ extendedRuntimeSession: WKExtendedRuntimeSession
    ) {
        DispatchQueue.main.async { [weak self] in
            MainActor.assumeIsolated {
                guard let self,
                      let customTimer = self.customTimer else { return }
                self.processWorktime(extendedRuntimeSession: extendedRuntimeSession, emom: customTimer, timerWork: &self.timerWork)
                
                HapticManager.shared.start()
                
                self.createAndRunProgressTimer(customTimer, timer: &self.refreshProgressTimer)
                
                self.set(state: .startedWork)
            }
        }

    }

    nonisolated func extendedRuntimeSessionWillExpire(
        _ extendedRuntimeSession: WKExtendedRuntimeSession
    ) {
    }

    nonisolated func extendedRuntimeSession(
        _ extendedRuntimeSession: WKExtendedRuntimeSession,
        didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason,
        error: Error?
    ) {
        DispatchQueue.main.async { [weak self] in
            MainActor.assumeIsolated {
                guard let self else { return }
                self.removeTimers()
                self.chronoOnMove = nil

                if self.state == .finished, let customTimer = self.customTimer {
                    self.chronoFrozen = CustomTimer.getHHMMSS(seconds: CustomTimer.getTotal(emom: customTimer))
                }
            }
        }

    }

    // MARK :- Private/Internal
    private func processWorktime(extendedRuntimeSession: WKExtendedRuntimeSession, emom: CustomTimer, timerWork: inout Timer?) {
        var fireWork = Date.now.addingTimeInterval(Double(emom.workSecs))
        chronoOnMove = Date.now
        if state == .paused {
                chronoOnMove = Date.now.addingTimeInterval(-ellapsed)
            let secsToFire = Double(emom.workSecs) - ellapsed
            print("secs2Fire: \(secsToFire)")
                fireWork = Date.now.addingTimeInterval(secsToFire)
        }

        createAndRunTimerWork(emom, extendedRuntimeSession, fireWork, timerWork: &timerWork)
    }
    
    fileprivate func createAndRunTimerWork(_ emom: CustomTimer, _ extendedRuntimeSession: WKExtendedRuntimeSession, _ fireWork: Date, timerWork: inout Timer?) {

        HapticManager.shared.start()
        
//        let blockTimerWork: (Timer) -> Void = { [weak self] _ in
//            guard let self else { return }
//               // AudioManager.shared.finish()
//                self.set(state: .finished)
//                extendedRuntimeSession.invalidate()
//                HapticManager.shared.finish()
//        }

        timerWork = Timer(
            fire: fireWork,
            interval: 0.0,
            repeats: true) {_ in 
                DispatchQueue.main.async { [weak self] in
                    MainActor.assumeIsolated {
                        guard let self else { return }
                           // AudioManager.shared.finish()
                            self.set(state: .finished)
                            extendedRuntimeSession.invalidate()
                            HapticManager.shared.finish()
                    }
                }
            }
        
        guard let timerWork else { return }
        RunLoop.main.add(timerWork, forMode: .common)
    }
    
    
    fileprivate func createAndRunProgressTimer(_ customTimer: CustomTimer,/* _ extendedRuntimeSession: WKExtendedRuntimeSession,*/ timer: inout Timer?) {

        timer = Timer(
            fire: Date.now.addingTimeInterval(1.0),
            interval: 1.0,
            repeats: true) { _ in
                DispatchQueue.main.async { [weak self] in
                    MainActor.assumeIsolated {
                        guard let self else { return }
                        let ellapsed = self.getEllapedSecs(timerWork: self.timerWork,
                                                      customTimer: self.customTimer)
                        self.progress = ellapsed / Double(customTimer.workSecs)
                    }
                }
            }
        
        guard let timer else { return }
        RunLoop.main.add(timer, forMode: .common)
    }
}

