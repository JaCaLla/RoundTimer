import SwiftUI

final class EMOMViewModel: NSObject, ObservableObject {

    // MARK: - Emom timer states
    enum State: Int {
        case notStarted, startedWork, startedRest, paused, finished, cancelled
    }

    @Published var roundsLeft = 0
    @Published var timerDisplayed: Date?
    @Published var endOfBrushing: Date?
    @Published var chrono = "--:--"
    @Published var percentage = 0.0

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
        VibrationManager.shared.pause()
        session.invalidate()
        if let timerWork,
            previousState == .startedWork {
            secsToFinishAfterPausing = abs(timerWork.fireDate.timeIntervalSinceNow) - Double((emom?.restSecs ?? 0))
            print("\(secsToFinishAfterPausing) rounds left: \(roundsLeft)")
            roundsLeftAfterPausing = roundsLeft
            chrono = Emom.getHHMMSS(seconds: Int(secsToFinishAfterPausing))
        } else if let timerWork,
            previousState == .startedRest {
            secsToFinishRestAfterPausing = abs(timerWork.fireDate.timeIntervalSinceNow)
            print("\(secsToFinishRestAfterPausing) rounds left: \(roundsLeft)")
            roundsLeftAfterPausing = roundsLeft
            chrono = Emom.getHHMMSS(seconds: Int(secsToFinishRestAfterPausing))
        }

    }

    func action() {
        if [.notStarted, .paused].contains(where: { $0 == state }) {
            startBrushing()
        } else if state == .startedRest || state == .startedWork {
            previousState = state
            state = .paused
            pause()
            refreshView()
        } else if state == .finished {
            state = .notStarted
            roundsLeftAfterPausing = nil
            refreshView()
        }
        }

        func set(emom: Emom?) {
            guard let emom else { return }
            self.emom = emom
            state = .notStarted
            refreshView()
            chrono = Emom.getHHMMSS(seconds: emom.workSecs + emom.restSecs)
        }

        private func endOfRound(emom: Emom) -> Date? {
            Date.now.addingTimeInterval(Double(emom.workSecs + emom.restSecs))
        }

        private func endOfWork(emom: Emom) -> Date? {
            Date.now.addingTimeInterval(Double(emom.workSecs))
        }

        private func endOfRest(emom: Emom) -> Date? {
            Date.now.addingTimeInterval(Double(emom.restSecs))
        }

        private func refreshView() {
            actionIcon = getPlayPauseButton(state: state)
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

        internal func getPlayPauseButton(state: State) -> String {
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
    }

// MARK: - WKExtendedRuntimeSessionDelegate
    extension EMOMViewModel: WKExtendedRuntimeSessionDelegate {
        func extendedRuntimeSessionDidStart(
            _ extendedRuntimeSession: WKExtendedRuntimeSession
        ) {
            guard let emom,
                  var fireWork = endOfRound(emom: emom) else { return }
           // roundsLeft = emom.rounds /// NOOOOO!!!
            // let now = Date.now
            let secondsPerRound = Double(emom.workSecs + emom.restSecs)
            timerDisplayed = endOfWork(emom: emom)
            if state == .paused {
                if previousState == .startedWork {
                    timerDisplayed = Date.now.addingTimeInterval(secsToFinishAfterPausing)
                    fireWork = Date.now.addingTimeInterval(secsToFinishAfterPausing + Double(emom.restSecs))
                } else if previousState == .startedRest {
                    //secsToFinishRestAfterPausing
                    fireWork = Date.now.addingTimeInterval(secsToFinishRestAfterPausing)
                }
            }
//            guard let fireWork = endOfRound(emom: emom) else { return }
//            roundsLeft = emom.rounds

//            guard let timerDisplayed else { return }

            
            VibrationManager.shared.start()

           // state = .startedWork
           // refreshView()
            print("fireWork: \(fireWork)")
            
            timerWork = Timer(
                fire: fireWork,
                interval: secondsPerRound,
                repeats: true
            ) { [weak self] _ in
                self?.state = .startedWork
             //   if emom.restSecs == 0 {
                    self?.roundsLeft -= 1
              //  }
                self?.startedRound = Int(Date.now.timeIntervalSince1970.rounded(.toNearestOrEven))

                guard self?.roundsLeft ?? 0 <= 0 else {
                    self?.timerDisplayed = Date.now.addingTimeInterval(TimeInterval(emom.workSecs)/*secondsPerRound*/)
                    self?.refreshView()
                    //WKInterfaceDevice.current().play(.notification)
                    VibrationManager.shared.work()
                    return
                }

                self?.state = .finished
                self?.refreshView()
                extendedRuntimeSession.invalidate()

               // WKInterfaceDevice.current().play(.notification)
                VibrationManager.shared.finish()
            }

            RunLoop.main.add(timerWork, forMode: .common)

            guard var fireRest = endOfWork(emom: emom) else { return }
            print("\(timerDisplayed)")

            if state == .paused {
                if previousState == .startedWork {
                    fireRest = Date.now.addingTimeInterval(secsToFinishAfterPausing)
                } else if previousState == .startedRest {
                    timerDisplayed = Date.now.addingTimeInterval(secsToFinishRestAfterPausing)
                    fireRest = Date.now.addingTimeInterval(secsToFinishRestAfterPausing + Double(emom.workSecs))
                }
            }
            print("fireRest: \(fireRest)")
            timerRest = Timer(fire: fireRest, interval: secondsPerRound, repeats: true, block: { [weak self] timer in
//                if emom.restSecs > 0 {
//                    self?.roundsLeft -= 1
//                }
                guard self?.roundsLeft ?? 0 <= 0 else {
                    self?.state = .startedRest
                    self?.timerDisplayed = self?.endOfRest(emom: emom)
                    self?.refreshView()
                    //WKInterfaceDevice.current().play(.notification)
                    VibrationManager.shared.rest()
                    return
                }
                self?.state = .finished
                self?.refreshView()
                extendedRuntimeSession.invalidate()

                //WKInterfaceDevice.current().play(.notification)
                VibrationManager.shared.finish()

            })
            RunLoop.main.add(timerRest, forMode: .common)
            
            state = previousState == .startedWork ? .startedWork : .startedRest
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

            timerDisplayed = nil
            endOfBrushing = nil

            if state == .finished {
                roundsLeft = 0
                if let emom {
                  //  let emomSecs = Emom.getTotal(emom: emom)
                    chrono = Emom.getHHMMSS(seconds: Emom.getTotal(emom: emom))
                }
            }
        }
    }
