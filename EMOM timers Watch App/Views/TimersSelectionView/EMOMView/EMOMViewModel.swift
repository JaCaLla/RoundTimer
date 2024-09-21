import Combine
import SwiftUI
import AVFoundation

protocol EMOMViewModelProtocol {

    func set(emom: CustomTimer?)
    func close()
    func getRoundsProgress() -> Double
    func getForegroundTextColor() -> Color
    func getTimerAndRoundFont() -> Font
    func getCurrentRound() -> String
    func getRounds() -> String
    func getCurrentMessage() -> String
    func hasNotStarted() -> Bool
}


final class EMOMViewModel: NSObject, ObservableObject {

    @Published var chronoFrozen = ""

    private(set) var timerWork: Timer?
    private(set) var timerRest: Timer?
    private(set) var timerCountdown: Timer?
    private(set) var refreshProgressTimer: Timer?
    
    private(set) var extendedRuntimeSession: WKExtendedRuntimeSession?
    private(set) var extendedRuntimeSessionDelegate: WKExtendedRuntimeSessionDelegate?
   
    private(set) var state: EMOMViewModelState = EMOMViewModelState()
    private(set) var roundsLeft = 0
    static let coundownValue = 10//4
    private(set) var countdownCurrentValue = coundownValue
    private(set) var startWorkTimeStamp: Date?
    private(set) var customTimer: CustomTimer?
    private(set) var audioManager: AudioManagerProtocol = AudioManager.shared
    
    
    init(audioManager: AudioManagerProtocol = AudioManager.shared,
         extendedRuntimeSessionDelegate: WKExtendedRuntimeSessionDelegate? = nil) {
        self.audioManager = audioManager
        self.extendedRuntimeSessionDelegate = extendedRuntimeSessionDelegate
    }
}

// MARK :- EMOMViewModelProtocol
extension EMOMViewModel: EMOMViewModelProtocol {
    
    func set(emom: CustomTimer?) {
        guard let emom else { return }
        changeStateAndSpeechWhenApplies(to: .countdown)
        self.customTimer = emom
        set(roundsLeft: emom.rounds)
        setupExtendedRuntimeSession()
    }
    
    func close() {
        customTimer = nil
        changeStateAndSpeechWhenApplies(to: .cancelled)
        removeTimers()
        removeExtendedRuntimeSession()
    }
    
    private func removeExtendedRuntimeSession() {
        guard let extendedRuntimeSession else { return }
        extendedRuntimeSession.invalidate()
    }
    
    private func set(roundsLeft: Int) {
        self.roundsLeft = roundsLeft
    }
    
    private func setupExtendedRuntimeSession() {
        
        extendedRuntimeSession = WKExtendedRuntimeSession()
        extendedRuntimeSession?.delegate = extendedRuntimeSessionDelegate ?? self
        extendedRuntimeSession?.start()
    }
    
    func getRoundsProgress() -> Double {
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
    
    func getTimerAndRoundFont() -> Font {
        guard let customTimer else { return .timerAndRoundLargeFont }
        let isRound2Digits = customTimer.rounds > 9
        let isWork2MMDigits = [customTimer.workSecs, customTimer.restSecs].contains(where: { $0 >= 10 * 60 }) ||
        (state.value == .finished && ((customTimer.workSecs + customTimer.restSecs) * customTimer.rounds) > 10 * 60)
        if isRound2Digits && isWork2MMDigits {
            return  .timerAndRoundSmallFont
        } else if isRound2Digits || isWork2MMDigits {
            return  .timerAndRoundMediumFont
        } else {
            return  .timerAndRoundLargeFont
        }
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
            return roundsLeft <= 1 ? String(localized: "chorno_message_last_round") : String(localized: "chrono_message_work")
        } else if state.value == .startedRest {
            return roundsLeft <= 1 ? String(localized: "chorno_message_last_round") : String(localized: "chrono_message_rest")
        } else {
            return ""
        }
    }
    
    func hasNotStarted() -> Bool {
        state.value == .notStarted
    }
}


// MARK: - WKExtendedRuntimeSessionDelegate
extension EMOMViewModel: WKExtendedRuntimeSessionDelegate {
    
    func extendedRuntimeSessionDidStart(
        _ extendedRuntimeSession: WKExtendedRuntimeSession
    ) {
        guard let customTimer else { return }
        startRefreshProgressTimer(timer: &refreshProgressTimer)
        startCountdown(extendedRuntimeSession: extendedRuntimeSession,
                       customTimer: customTimer)
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

        if state.value == .finished {
            set(roundsLeft: 0)
            if let customTimer {
                chronoFrozen = CustomTimer.getHHMMSS(seconds: CustomTimer.getTotal(emom: customTimer))
            }
        }
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
    
    private func startRefreshProgressTimer(timer: inout Timer?) {
        
        let blockTimerWork: (Timer) -> Void = { [weak self] _ in
            guard let self, state.value != .cancelled else { return }
            if [.startedWork, .startedRest].contains(where: { $0 == self.state.value }) {
                chronoFrozen = getChronoOnLowEnergyMode()
            }
       }

       timer = Timer( fire: Date.now, interval: 1.0,repeats: true, block: blockTimerWork)
       guard let timer else { return }
       RunLoop.main.add(timer, forMode: .common)
    }
    
    private func getChronoOnLowEnergyMode() -> String {
        guard let startWorkTimeStamp, let customTimer  else { return "--:--" }
        let ellapsedSecs = abs(Int(startWorkTimeStamp.timeIntervalSinceNow))
        
        let secsPerRound = customTimer.workSecs + customTimer.restSecs
        
        let ellapsedRounds = Int((Double(ellapsedSecs) / Double(secsPerRound)).rounded(.towardZero))
        
        var remainigSecs = ellapsedSecs - ellapsedRounds * secsPerRound
        if remainigSecs >= customTimer.workSecs {
            remainigSecs -= customTimer.workSecs
        }
        remainigSecs += 1
        return String(format: "%0.1d:%0.2d", remainigSecs / 60, remainigSecs % 60)
   }
    
    private func startCountdown(extendedRuntimeSession: WKExtendedRuntimeSession,
                                 customTimer: CustomTimer) {
        let blockTimerCountdown: (Timer) -> Void = { [weak self] _ in
            guard let self, state.value != .cancelled else { return }
            countdownCurrentValue -= 1
            if countdownCurrentValue < 1 {
                timerCountdown?.invalidate()
                dropTimer(&timerCountdown)
                self.chronoFrozen = "--"
                changeStateAndSpeechWhenApplies(to: .startedWork)
                setupWorkAndRestTimers(extendedRuntimeSession, customTimer)
                return
            }
            self.chronoFrozen = "\(countdownCurrentValue)"
        }

        timerCountdown = Timer(
            fire: Date.now,
            interval: 1,
            repeats: true,
            block: blockTimerCountdown)
        
        timerCountdown = Timer(fire: Date.now,interval: 1,repeats: true, block: blockTimerCountdown)
        guard let timerCountdown else { return }
        RunLoop.main.add(timerCountdown, forMode: .common)
    }
    
    private func setupWorkAndRestTimers(_ extendedRuntimeSession: WKExtendedRuntimeSession,
                                            _ customTimer: CustomTimer) {
        
        startWorkTimeStamp = Date.now
    
        processWorktime(extendedRuntimeSession: extendedRuntimeSession, emom: customTimer, timerWork: &timerWork)
        
        if customTimer.restSecs > 0 {
            processResttime(extendedRuntimeSession: extendedRuntimeSession, emom: customTimer, timerRest: &timerRest)
        }
    }

    // MARK :- Private/Internal
    private func processWorktime(extendedRuntimeSession: WKExtendedRuntimeSession, emom: CustomTimer, timerWork: inout Timer?) {
        guard let fireWork = emom.endOfRound() else { return }
        chronoFrozen = getChronoOnLowEnergyMode()
        createAndRunTimerWork(emom, extendedRuntimeSession, fireWork, timerWork: &timerWork)
    }
        
    private func createAndRunTimerWork(_ emom: CustomTimer, _ extendedRuntimeSession: WKExtendedRuntimeSession, _ fireWork: Date, timerWork: inout Timer?) {

        let blockTimerWork: (Timer) -> Void = { [weak self] _ in
            guard let self, state.value != .cancelled else { return }
            self.decreaseBy1RoundsLeft()
            speakRound(audioManager)

            if roundsLeft > 0 {
                changeStateAndSpeechWhenApplies(to: .startedWork)
                chronoFrozen = getChronoOnLowEnergyMode()
            } else {
                changeStateAndSpeechWhenApplies(to: .finished)
                extendedRuntimeSession.invalidate()
            }
        }
        let secondsPerRound = emom.secondsPerRound()
        timerWork = Timer(
            fire: fireWork,
            interval: secondsPerRound,
            repeats: true,
            block: blockTimerWork)
        
        guard let timerWork else { return }
        RunLoop.main.add(timerWork, forMode: .common)
    }
    
    internal func changeStateAndSpeechWhenApplies(to: EMOMViewModelState.State) {
        state = state.set(state: to)
        speech(state: state)
    }

    private func speech(state: EMOMViewModelState) {
        guard state.didChanged else { return }
        audioManager.speech(state: state)
    }

    fileprivate func speakRound(_ audioManager: AudioManagerProtocol) {
        guard roundsLeft > 0 else { return }
        let text = roundsLeft == 1 ?
            String(localized: "chorno_message_last_round")
            : String(format: String(localized: "round_n"), self.getCurrentRound())
        audioManager.speak(text: text)
    }

    private func decreaseBy1RoundsLeft() {
        self.roundsLeft -= 1
    }
    
    private func processResttime(extendedRuntimeSession: WKExtendedRuntimeSession, emom: CustomTimer, timerRest: inout Timer?) {
        guard let fireRest = emom.endOfWork() else { return }
        // LOOK OUT! DO NOT SET STATE IN THIS FUNCTION!!

        createAndRunRestTimer(emom, fireRest, extendedRuntimeSession, timerRest: &timerRest)
    }
    
    private func createAndRunRestTimer(_ emom: CustomTimer, _ fireRest: Date, _ extendedRuntimeSession: WKExtendedRuntimeSession, timerRest: inout Timer?) {
        
        let blockRestTimer: (Timer) -> Void = { [weak self] _ in
            guard let self, state.value != .cancelled else { return }
            changeStateAndSpeechWhenApplies(to: .startedRest)
            if roundsLeft > 1 {
                chronoFrozen = getChronoOnLowEnergyMode()
            } else /*if emom.restSecs == 0*/ {
                changeStateAndSpeechWhenApplies(to: .finished)
                extendedRuntimeSession.invalidate()
            }
        }
        let secondsPerRound = Double(emom.workSecs + emom.restSecs)
        timerRest = Timer(fire: fireRest, interval: secondsPerRound, repeats: true, block: blockRestTimer)
        guard let timerRest else { return }
        RunLoop.main.add(timerRest, forMode: .common)
    }
}
