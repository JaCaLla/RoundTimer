import SwiftUI

@MainActor
protocol EMOMViewModelProtocol {
    func setAndStart(emom: CustomTimer?)
    func close()
}
// MARK :- EMOMViewModelProtocol
extension EMOMViewModel: EMOMViewModelProtocol {
    
    func setAndStart(emom: CustomTimer?) {
        guard let emom else { return }
        self.customTimer = emom
        self.set(state: .countdown)
        
        ApplicationManager.setInForeground(true)
        startRefreshTimer()
        startCountdown()
    }
    
    func close() {
        if let customTimer,
           customTimer.isMirroredOnAW {
            TimerStore.shared.send(mirroredTimer: .removedFromCompanion)
        }
        customTimer = nil
        set(state: .cancelled)
        removeTimers()
    }
}

@MainActor
final class EMOMViewModel: NSObject, ObservableObject {

    // MARK: - Emom timer states
//    enum State: String {
//        case notStarted, countdown, startedWork, startedRest, finished, cancelled
//    }

    @Published var mmss = "--:--"

    internal var timerWork: Timer?
    internal var timerRest: Timer?
    internal var timerCountdown: Timer?
    internal var refreshProgressTimer: Timer?
    
   // internal var state: State = .notStarted
    private(set) var state: EMOMViewModelState = EMOMViewModelState()
    private var startWorkTimeStamp: Date?
    internal var previousStateBeforePausing: EMOMViewModelState.State = .startedWork
    internal var secsToFinishAfterPausing: TimeInterval = 0
    internal var secsToFinishRestAfterPausing: TimeInterval = 0
    internal var roundsLeftAfterPausing: Int?
    internal var roundsLeft = 0
    static let coundownValue = 10
    var countdownCurrentValue = coundownValue
    /*@Published*/ var customTimer: CustomTimer?
    private(set) var audioManager: AudioManagerProtocol = AudioManager.shared

    init(audioManager: AudioManagerProtocol? = nil) {
        self.audioManager = audioManager ?? AudioManager.shared
    }
    
    private func endOfRound(emom: CustomTimer) -> Date? {
        Date.now.addingTimeInterval(Double(emom.workSecs + emom.restSecs))
    }

    private func endOfWork(emom: CustomTimer) -> Date? {
        Date.now.addingTimeInterval(Double(emom.workSecs ))
    }

    private func endOfRest(emom: CustomTimer) -> Date? {
        Date.now.addingTimeInterval(Double(emom.restSecs ))
    }

    internal func getRoundsProgress() -> Double {
        guard let customTimer else { return 0.0 }
        if state.value == .finished {
            return 1.0
        } else if state.value == .startedWork || state.value == .startedRest {
            return Double(customTimer.rounds - roundsLeft + 1) / Double(customTimer.rounds)
        } else if state.value == .countdown {
            return 1.0 - Double(countdownCurrentValue) / Double(EMOMViewModel.coundownValue)
        } else {
            return 0.0
        }
    }

    //MARK: - Helpers
    func getForegroundTextColor() -> Color {
        if [.notStarted, .finished].contains(where: { $0 == state.value }) {
            return .timerNotStartedColor
        } else if state.value == .startedWork {
            return .timerStartedColor
        } else if state.value == .startedRest {
            return .timerRestStartedColor
        } else if state.value == .countdown {
            return countdownCurrentValue > 3 ? .countdownColor : .countdownInminentColor
        } else {
            return .green
        }
    }

    func getTimerAndRoundFont(isLuminanceReduced: Bool = false) -> Font {
        guard let customTimer else { return .timerAndRoundLargeFont }
        let isRound2Digits = customTimer.rounds > 9
        let isWork2MMDigits = [customTimer.workSecs, customTimer.restSecs].contains(where: { $0 >= 10 * 60 }) ||
        (state.value == .finished && ((customTimer.workSecs + customTimer.restSecs) * customTimer.rounds) > 10 * 60)
        if isRound2Digits && isWork2MMDigits {
            return isLuminanceReduced && state.value != .finished ? .timerAndRoundLRSmallFont : .timerAndRoundSmallFont
        } else if isRound2Digits || isWork2MMDigits {
            return isLuminanceReduced && state.value != .finished ?  .timerAndRoundLRMediumFont : .timerAndRoundMediumFont
        } else {
            return isLuminanceReduced && state.value != .finished ? .timerAndRoundLRLargeFont : .timerAndRoundLargeFont
        }
    }

    func hasToShow(work: Bool = true) -> Bool {
        return work ? state.value == .startedWork: state.value == .startedRest
    }

    func getCurrentRound() -> String {
        guard let customTimer, [.countdown].allSatisfy({ state.value != $0 }) else { return "" }
        if [.notStarted].contains(where: { state.value == $0 }) {
            return "1"
        } else if [.finished].contains(where: { state.value == $0 }) {
            return String(format: "%0d", customTimer.rounds)
        } else if state.value == .startedWork {
            return String(format: "%0d", customTimer.rounds - roundsLeft + 1)
        } else if state.value == .startedRest {
            return String(format: "%0d", customTimer.rounds - roundsLeft + 1)
        } else {
            return "00"
        }
    }
    
    func getRounds() -> String {
        guard let customTimer, [.countdown].allSatisfy({ state.value != $0 }) else { return "" }
        return String(format: "/%0d", customTimer.rounds)
    }

    func getCurrentMessage() -> String {
        if state.value == .finished {
            return String(localized: "chrono_message_finished")
        } else if state.value == .notStarted {
            return String(localized: "chrono_message_press_play")
        } else if state.value == .startedWork {
            return roundsLeft <= 1 ? String(localized: "chrono_message_last_round") : String(localized: "chrono_message_work")
        } else if state.value == .startedRest {
            return roundsLeft <= 1 ? String(localized: "chrono_message_last_round") : String(localized: "chrono_message_rest")
        } else {
            return ""
        }
    }
    
    internal func startWorkTime() {
        startWorkTimeStamp = Date.now
        mmss = getMMSS()
        
        if let customTimer {
            set(roundsLeft: customTimer.rounds)
        }

        guard let customTimer else { return }
        processWorktime( emom: customTimer, timerWork: &timerWork)
                
        if customTimer.restSecs > 0 {
            processResttime(emom: customTimer, timerRest: &timerRest)
        }
         if state.value == .notStarted {
            set(state: .startedWork)
        }
    }

    internal func startCountdown() {
        timerCountdown = Timer(
            fire: Date.now,
            interval: 1,
            repeats: true) {_ in 
                DispatchQueue.main.async { [weak self] in
                    MainActor.assumeIsolated {
                        guard let self else { return }
                        self.countdownCurrentValue -= 1

                        if self.countdownCurrentValue < 1 {
                            self.timerCountdown?.invalidate()
                            self.dropTimer(&self.timerCountdown)
                            self.set(state: .notStarted)
                            self.startWorkTime()
                            return
                        }
                        self.mmss = "\(self.countdownCurrentValue)"
                    }
                }
            }
        
        guard let timerCountdown else { return }
        RunLoop.main.add(timerCountdown, forMode: .common)
    }
    
    internal func startRefreshTimer() {
         refreshProgressTimer = Timer(
            fire: Date.now,
            interval: 1,
            repeats: true) {_ in
                DispatchQueue.main.async { [weak self] in
                    MainActor.assumeIsolated {
                        guard let customTimer = self?.customTimer else { return }
                        if self?.state.value == .countdown,
                           customTimer.isMirroredOnAW,
                           let mirroredTimer = self?.getMirroredCustomTimer() {
                            TimerStore.shared.send(mirroredTimer: mirroredTimer)
                        } else if  [.startedWork, .startedRest, .finished].contains(where: { self?.state.value == $0 }),
                                   customTimer.isMirroredOnAW,
                                   let mirroredTimer = self?.getMirroredCustomTimer() {
                            TimerStore.shared.send(mirroredTimer: mirroredTimer)
                        }
                        if  [.startedWork, .startedRest ].contains(where: { self?.state.value == $0 }) {
                            self?.mmss = self?.getMMSS() ?? "??:??"
                        }
                    }
                }
            }
        guard let refreshProgressTimer else { return }
        RunLoop.main.add(refreshProgressTimer, forMode: .common)
    }
    
    private func getMirroredCustomTimer() -> MirroredTimer? {
        guard let customTimer else { return nil }
        if state.value == .countdown {
            let mirroredTimerCountdown = MirroredTimerCountdown(value: countdownCurrentValue)
            let mirroredTimer = MirroredTimer(mirroredTimerType: .countdown, mirroredTimerCountdown: mirroredTimerCountdown)
            return mirroredTimer
        } else if [ .startedWork,.startedRest].contains(where: { $0 == state.value}) /*,
                  let chronoOnMove*/ {
            let isWork =  state.value == .startedWork
            let message =  String(localized: isWork ? "chrono_message_work" : "chrono_message_rest")
            let mirroredTimerWorking = MirroredTimerWorking(rounds: customTimer.rounds,
                                                            currentRounds: customTimer.rounds - roundsLeft + 1,
                                                            date: getChronoOnLowEnergyMode(customTimer: customTimer),
                                                            isWork: state.value == .startedWork,
                                                            message: message)
            let mirroredTimer = MirroredTimer(mirroredTimerType: .working, mirroredTimerWorking: mirroredTimerWorking)
            return mirroredTimer
        } else if [ .finished].contains(where: { $0 == state.value}) {
           let mirroredTimerFinished = MirroredTimerFinished(rounds: customTimer.rounds,
                                                           currentRounds: customTimer.rounds - roundsLeft + 1,
                                                           date: mmss,
                                                            isWork: state.value == .startedWork, message: String(localized: "chorno_message_finished"))
            let mirroredTimer = MirroredTimer(mirroredTimerType: .finished,
                                              mirroredTimerFinished: mirroredTimerFinished)
           return mirroredTimer
       } else {
            return nil
        }
    }
        
    private func getChronoOnLowEnergyMode(customTimer: CustomTimer) -> String {
        guard let startWorkTimeStamp  else { return "--:--" }
        let ellapsedSecs = abs(Int(startWorkTimeStamp.timeIntervalSinceNow))
        
        let secsPerRound = customTimer.workSecs + customTimer.restSecs
        
        let ellapsedRounds = Int((Double(ellapsedSecs) / Double(secsPerRound)).rounded(.towardZero))
        
        var remainigSecs = ellapsedSecs - ellapsedRounds * secsPerRound
        if remainigSecs >= customTimer.workSecs {
            remainigSecs -= customTimer.workSecs
        }
        return String(format: "%0.1d:%0.2d", remainigSecs / 60, remainigSecs % 60)
   }

    
    private func removeTimers() {
        dropTimer(&timerWork)
        dropTimer(&timerRest)
        dropTimer(&timerCountdown)
        dropTimer(&refreshProgressTimer)
    }
    
    private func dropTimer(_ timer: inout Timer?) {
        if let timer {
            timer.invalidate()
        }
        timer = nil
    }

    private func set(state to: EMOMViewModelState.State) {
        //self.state = to
        changeStateAndSpeechWhenApplies(to: to)
    }
    
    internal func changeStateAndSpeechWhenApplies(to: EMOMViewModelState.State) {
        state = state.set(state: to)
        speech(state: state)
    }
    
    private func speech(state: EMOMViewModelState) {
        guard state.didChanged else { return }
        audioManager.speech(state: state)
    }
    
    private func set(roundsLeft: Int) {
        self.roundsLeft = roundsLeft
    }
    
    private func decreaseBy1RoundsLeft() {
        self.roundsLeft -= 1
    }
    
    // MARK :- Private/Internal
    private func processWorktime(emom: CustomTimer, timerWork: inout Timer?) {
        guard let fireWork = endOfRound(emom: emom) else { return }
       // chronoOnMove = Date.now
      //  chronoFrozen = getChronoOnLowEnergyMode()

        createAndRunTimerWork(emom, fireWork, timerWork: &timerWork)
    }
    
    private func getMMSS() -> String {
        guard let startWorkTimeStamp, let customTimer  else { return "--:--" }
        let ellapsedSecs = abs(Int(startWorkTimeStamp.timeIntervalSinceNow))
        
        let secsPerRound = customTimer.workSecs + customTimer.restSecs
        
        let ellapsedRounds = Int((Double(ellapsedSecs) / Double(secsPerRound)).rounded(.towardZero))
        
        var remainigSecs = ellapsedSecs - ellapsedRounds * secsPerRound
        if remainigSecs >= customTimer.workSecs {
            remainigSecs -= customTimer.workSecs
        }
       // remainigSecs += 1
        return String(format: "%0.1d:%0.2d", remainigSecs / 60, remainigSecs % 60)
   }
    
    fileprivate func createAndRunTimerWork(_ emom: CustomTimer, _ fireWork: Date, timerWork: inout Timer?) {

        let secondsPerRound = Double(emom.workSecs + emom.restSecs)
        timerWork = Timer(
            fire: fireWork,
            interval: secondsPerRound,
            repeats: true) { _ in
                DispatchQueue.main.async { [weak self] in
                    MainActor.assumeIsolated {
                        guard let self else { return }
                        self.decreaseBy1RoundsLeft()
                        if self.roundsLeft > 0 {
                            self.set(state: .startedWork)
                            self.mmss = self.getMMSS()
                        } else {
                            self.set(state: .finished)
                            self.timerFinished()
                        }
                    }
                }
            }
        
        guard let timerWork else { return }
        RunLoop.main.add(timerWork, forMode: .common)
    }
    
    private func timerFinished() {
        removeTimers()

        if state.value == .finished {
            set(roundsLeft: 0)
            if let customTimer {
                mmss = CustomTimer.getHHMMSS(seconds: CustomTimer.getTotal(emom: customTimer))
            }
            if let mirroredTimer = getMirroredCustomTimer(),
                let customTimer,
                customTimer.isMirroredOnAW {
                TimerStore.shared.send(mirroredTimer: mirroredTimer)
            }
        }
    }
    
    private func processResttime( emom: CustomTimer, timerRest: inout Timer?) {
        guard let fireRest = endOfWork(emom: emom) else { return }
        createAndRunRestTimer(emom, fireRest, timerRest: &timerRest)
    }
    
    fileprivate func createAndRunRestTimer(_ emom: CustomTimer, _ fireRest: Date,
                                           timerRest: inout Timer?) {
        
        let secondsPerRound = Double(emom.workSecs + emom.restSecs)
        timerRest = Timer(fire: fireRest,
                          interval: secondsPerRound,
                          repeats: true) { _ in
            DispatchQueue.main.async { [weak self] in
                MainActor.assumeIsolated {
                    guard let self else { return }
                    self.set(state: .startedRest)
                    if self.roundsLeft <= 1 {
                        self.set(state: .finished)
                        self.timerFinished()
                    }
                }
            }
        }
        guard let timerRest else { return }
        RunLoop.main.add(timerRest, forMode: .common)
    }
}
