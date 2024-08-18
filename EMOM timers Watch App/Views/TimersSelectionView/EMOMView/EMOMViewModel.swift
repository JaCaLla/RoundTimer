import Combine
import SwiftUI
import AVFoundation

protocol EMOMViewModelProtocol {

    func close()
    func set(emom: CustomTimer?)
    func getRoundsProgress() -> Double
    func getForegroundTextColor() -> Color
    func getTimerAndRoundFont() -> Font
    func getCurrentRound() -> String
    func getRounds() -> String
    func getCurrentMessage() -> String
    func hasNotStarted() -> Bool
}

//// MARK: - Emom timer states
//public enum EMOMViewModelState: String {
//    case countdown, notStarted,  startedWork, startedRest, finished, cancelled
//}

final class EMOMViewModel: NSObject, ObservableObject {

    @Published var chronoOnMove: Date?
    @Published var chronoFrozen = ""

    private var timerWork: Timer?
    private var timerRest: Timer?
    private var timerCountdown: Timer?
    private var refreshProgressTimer: Timer?
    
    private var extendedRuntimeSession: WKExtendedRuntimeSession?
   
    private var state: EMOMViewModelState = EMOMViewModelState()
    private var roundsLeft = 0
    static let coundownValue = 10//4
    private var countdownCurrentValue = coundownValue
    private var startWorkTimeStamp: Date?
    private var customTimer: CustomTimer?
    private let audioManager = AudioManager.shared
}

// MARK :- EMOMViewModelProtocol
extension EMOMViewModel: EMOMViewModelProtocol {
    
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
    
    func set(emom: CustomTimer?) {
        guard let emom else { return }
        changeStateAndSpeechWhenApplies(to: .countdown)
        self.customTimer = emom
        
        if let customTimer {
            set(roundsLeft: customTimer.rounds)
        }
        setupExtendedRuntimeSession()
       // HapticManager.shared.pause()
    }
    
//    private func set(state to: EMOMViewModelState) {
//        self.state = to
//    }
    
    private func set(roundsLeft: Int) {
        self.roundsLeft = roundsLeft
    }
    
    private func setupExtendedRuntimeSession() {
        
        extendedRuntimeSession = WKExtendedRuntimeSession()
        extendedRuntimeSession?.delegate = self
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
        chronoOnMove = nil

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
    //    audioManager.countdown()
        //let secondsPerRound = Double(emom.workSecs /*+ 1 */+ emom.restSecs)
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
        
      //  HapticManager.shared.start()
        
        if customTimer.restSecs > 0 {
            processResttime(extendedRuntimeSession: extendedRuntimeSession, emom: customTimer, timerRest: &timerRest)
        }
    }

    // MARK :- Private/Internal
    private func processWorktime(extendedRuntimeSession: WKExtendedRuntimeSession, emom: CustomTimer, timerWork: inout Timer?) {
        // LOOK OUT! DO NOT SET STATE IN THIS FUNCTION!!
        guard let fireWork = emom.endOfRound() else { return }
        chronoOnMove = Date.now
        createAndRunTimerWork(emom, extendedRuntimeSession, fireWork, timerWork: &timerWork)
    }
        
    private func createAndRunTimerWork(_ emom: CustomTimer, _ extendedRuntimeSession: WKExtendedRuntimeSession, _ fireWork: Date, timerWork: inout Timer?) {

        HapticManager.shared.start()
    
        let blockTimerWork: (Timer) -> Void = { [weak self] _ in
            guard let self, state.value != .cancelled else { return }
            self.decreaseBy1RoundsLeft()
            speakRound(audioManager)

            if roundsLeft > 0 {
                changeStateAndSpeechWhenApplies(to: .startedWork)
                self.chronoOnMove = Date.now
               // AudioManager.shared.work()
       //         audioManager.work()
         //       HapticManager.shared.work()
            } else {
                changeStateAndSpeechWhenApplies(to: .finished)
             //   audioManager.rest()
                extendedRuntimeSession.invalidate()
               // AudioManager.shared.finish()
            //    HapticManager.shared.finish()
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
    
    private func changeStateAndSpeechWhenApplies(to: EMOMViewModelState.State) {
        state = state.set(state: to)
        speech(state: state)
    }

    private func speech(state: EMOMViewModelState) {
        guard state.didChanged else { return }
        audioManager.speech(state: state)
    }

    fileprivate func speakRound(_ audioManager: AudioManager) {
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
            if roundsLeft > 0 {
                self.chronoOnMove = Date.now
             //   audioManager.rest()
            //    HapticManager.shared.rest()
            } else {
                extendedRuntimeSession.invalidate()
              //  audioManager.finished()
              //  HapticManager.shared.finish()
            }
        }
        let secondsPerRound = Double(emom.workSecs + emom.restSecs)
        timerRest = Timer(fire: fireRest, interval: secondsPerRound, repeats: true, block: blockRestTimer)
        guard let timerRest else { return }
        RunLoop.main.add(timerRest, forMode: .common)
    }
}
