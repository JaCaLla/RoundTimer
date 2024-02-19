import SwiftUI

final class EMOMViewModel: NSObject, ObservableObject {

    // MARK: - Emom timer states
    enum State: Int {
        case notStarted, startedWork, startedRest, paused, finished, cancelled
    }

    @Published var roundsLeft = 0
    @Published var chronoOnMove: Date?
    @Published var endOfBrushing: Date?
    @Published var chronoFrozen = "--:--"
    @Published var percentage = 0.0
    @Published var showCountDownView = false

    private (set) var actionIcon = "play"
    private var timerWork: Timer!
    private var timerRest: Timer!
    private var session: WKExtendedRuntimeSession!
    internal var state: State = .notStarted
    internal var previousState: State = .startedWork
    private var startedRound: Int = 0
    private var secsToFinishAfterPausing: TimeInterval = 0
    private var secsToFinishRestAfterPausing: TimeInterval = 0
    private var roundsLeftAfterPausing: Int?

    @Published var emom: Emom?

    func startBrushing() {
        //showGettingReady = false
        session = WKExtendedRuntimeSession()
        session.delegate = self
        session.start()
        if let roundsLeftAfterPausing {
            roundsLeft = roundsLeftAfterPausing
        } else if let emom {
            roundsLeft = emom.rounds
        }
    }

    func close() {
        emom = nil
        state = .cancelled
        removeTimer()
        removeExtendedRuntimeSession()
    }

    func pause() {
        HapticManager.shared.pause()
        session.invalidate()
        if let timerWork,
            previousState == .startedWork {
            secsToFinishAfterPausing = abs(timerWork.fireDate.timeIntervalSinceNow) - Double((emom?.restSecs ?? 0))
            print("\(secsToFinishAfterPausing) rounds left: \(roundsLeft)")
            roundsLeftAfterPausing = roundsLeft
            chronoFrozen = Emom.getHHMMSS(seconds: Int(secsToFinishAfterPausing))
        } else if let timerWork,
            previousState == .startedRest {
            secsToFinishRestAfterPausing = abs(timerWork.fireDate.timeIntervalSinceNow)
            print("\(secsToFinishRestAfterPausing) rounds left: \(roundsLeft)")
            roundsLeftAfterPausing = roundsLeft
            chronoFrozen = Emom.getHHMMSS(seconds: Int(secsToFinishRestAfterPausing))
        }

    }

    func action() {
        if [.notStarted].contains(where: { $0 == state }) {
            showCountDownView = true
        } else if [.paused].contains(where: { $0 == state }) {
              startBrushing()
        } else if state == .startedRest || state == .startedWork {
            previousState = state
            set(to: .paused)
            pause()
            refreshView()
        } else if state == .finished {
            set(to: .notStarted)
            roundsLeftAfterPausing = nil
            refreshView()
        }
        }

        func set(emom: Emom?) {
            guard let emom else { return }
            self.emom = emom
            state = .notStarted
            refreshView()
            chronoFrozen = Emom.getHHMMSS(seconds: emom.workSecs + emom.restSecs)
        }

        private func endOfRound(emom: Emom) -> Date? {
            Date.now.addingTimeInterval(Double(emom.workSecs + emom.restSecs))
        }

        private func endOfWork(emom: Emom) -> Date? {
            Date.now.addingTimeInterval(Double(emom.workSecs + 1 ))
        }

        private func endOfRest(emom: Emom) -> Date? {
            Date.now.addingTimeInterval(Double(emom.restSecs + 1 ))
        }

        private func refreshView() {
            actionIcon = getPlayPauseButton()
            percentage = getProgress()
        }

        internal func getProgress() -> Double {
            guard let emom else { return 0.0 }
            if state == .finished {
                return 1.0
            } else if state == .startedWork || state == .startedRest {
                return Double(emom.rounds - roundsLeft + 1) / Double(emom.rounds)
            } else {
                return 0.0
            }
        }

        internal func getPlayPauseButton() -> String {
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

        func getTimerAndRoundFont() -> Font {
            guard let emom else { return .timerAndRoundLargeFont }
            let isRound2Digits = emom.rounds > 9
            let isWork2MMDigits = [emom.workSecs, emom.restSecs].contains(where: { $0 >= 10 * 60 })
            if isRound2Digits && isWork2MMDigits {
                return .timerAndRoundSmallFont
            } else if isRound2Digits || isWork2MMDigits {
                return .timerAndRoundMediumFont
            } else {
                return .timerAndRoundLargeFont
            }
        }

        func hasToShow(work: Bool = true) -> Bool {
            return work ? state == .startedWork: state == .startedRest
        }

        func getCurrentRound() -> String {
            guard let emom else { return "" }
            if [.notStarted, .finished].contains(where: { state == $0 }) {
                return String(format: "%0d", emom.rounds)
            } else if state == .startedWork || state == .paused {
                return String(format: "%0d", emom.rounds - roundsLeft + 1)
            } else if state == .startedRest || state == .paused {
                return String(format: "%0d", emom.rounds - roundsLeft + 1)
            } else {
                return "00"
            }
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


        private func removeTimer() {
            if timerWork != nil {
                timerWork.invalidate()
            }
            timerWork = nil
            if let timerRest {
                timerRest.invalidate()
            }
            timerRest = nil
        }

        private func removeExtendedRuntimeSession() {
            guard let session else { return }
            session.invalidate()
        }
    
    private func set(to state: State) {
        self.state = state
    }
    }

// MARK: - WKExtendedRuntimeSessionDelegate
    extension EMOMViewModel: WKExtendedRuntimeSessionDelegate {
        func extendedRuntimeSessionDidStart(
            _ extendedRuntimeSession: WKExtendedRuntimeSession
        ) {
            guard let emom,
                  var fireWork = endOfRound(emom: emom) else { return }
            let secondsPerRound = Double(emom.workSecs + emom.restSecs)
            chronoOnMove = endOfWork(emom: emom)
            if state == .paused {
                if previousState == .startedWork {
                    chronoOnMove = Date.now.addingTimeInterval(secsToFinishAfterPausing)
                    fireWork = Date.now.addingTimeInterval(secsToFinishAfterPausing + Double(emom.restSecs))
                    if  emom.restSecs == 0 {
                        self.set(to: .startedWork)
                        AudioManager.shared.work()
                    }
                } else if previousState == .startedRest {
                    fireWork = Date.now.addingTimeInterval(secsToFinishRestAfterPausing)
                    if  emom.restSecs == 0 {
                        self.set(to: .startedRest)
                    }
                }
            } else if state == .notStarted {
                set(to: .startedWork)
            }
            
            HapticManager.shared.start()

            timerWork = Timer(
                fire: fireWork,
                interval: secondsPerRound,
                repeats: true
            ) { [weak self] _ in
                    self?.roundsLeft -= 1
                self?.startedRound = Int(Date.now.timeIntervalSince1970.rounded(.toNearestOrEven))

                guard self?.roundsLeft ?? 0 <= 0 else {
                    AudioManager.shared.work()
                    self?.set(to: .startedWork)
                    self?.chronoOnMove = Date.now.addingTimeInterval(TimeInterval(emom.workSecs)/*secondsPerRound*/)
                    self?.refreshView()
                    HapticManager.shared.work()
                    return
                }
                AudioManager.shared.finish()
                self?.set(to: .finished)
                self?.refreshView()
                extendedRuntimeSession.invalidate()

                HapticManager.shared.finish()
            }

            RunLoop.main.add(timerWork, forMode: .common)

            guard emom.restSecs > 0,
                  var fireRest = endOfWork(emom: emom) else {
                refreshView()
                return
            }

            if state == .paused {
                if previousState == .startedWork {
                    fireRest = Date.now.addingTimeInterval(secsToFinishAfterPausing)
                    AudioManager.shared.work()
                    self.set(to: .startedWork)
                } else if previousState == .startedRest {
                    chronoOnMove = Date.now.addingTimeInterval(secsToFinishRestAfterPausing)
                    fireRest = Date.now.addingTimeInterval(secsToFinishRestAfterPausing + Double(emom.workSecs))
                    AudioManager.shared.rest()
                    self.set(to: .startedRest)
                }
            }
            
            print("fireRest: \(fireRest)")
            timerRest = Timer(fire: fireRest, interval: secondsPerRound, repeats: true, block: { [weak self] timer in
                self?.set(to: .startedRest)
                guard self?.roundsLeft ?? 0 <= 0 else {
                    AudioManager.shared.rest()
                    self?.set(to: .startedRest)
                    self?.chronoOnMove = self?.endOfRest(emom: emom)
                    self?.refreshView()
                    HapticManager.shared.rest()
                    return
                }
                
                self?.refreshView()
                extendedRuntimeSession.invalidate()

                HapticManager.shared.finish()

            })
            RunLoop.main.add(timerRest, forMode: .common)
             refreshView()
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
            timerWork?.invalidate()
            timerWork = nil

            timerRest?.invalidate()
            timerRest = nil

            chronoOnMove = nil
            endOfBrushing = nil

            if state == .finished {
                roundsLeft = 0
                if let emom {
                    chronoFrozen = Emom.getHHMMSS(seconds: Emom.getTotal(emom: emom))
                }
            }
        }
    }
