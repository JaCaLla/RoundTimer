import SwiftUI

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
        state = .cancelled
        removeTimers()
    }
}

final class EMOMViewModel: NSObject, ObservableObject {

    // MARK: - Emom timer states
    enum State: String {
        case notStarted, countdown, startedWork, startedRest, finished, cancelled
    }

    @Published var mmss = "--:--"

    internal var timerWork: Timer?
    internal var timerRest: Timer?
    internal var timerCountdown: Timer?
    internal var refreshProgressTimer: Timer?
    
    internal var state: State = .notStarted
    private var startWorkTimeStamp: Date?
    internal var previousStateBeforePausing: State = .startedWork
    internal var secsToFinishAfterPausing: TimeInterval = 0
    internal var secsToFinishRestAfterPausing: TimeInterval = 0
    internal var roundsLeftAfterPausing: Int?
    internal var roundsLeft = 0
    static let coundownValue = 10
    var countdownCurrentValue = coundownValue
    /*@Published*/ var customTimer: CustomTimer?


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
        if state == .finished {
            return 1.0
        } else if state == .startedWork || state == .startedRest {
            return Double(customTimer.rounds - roundsLeft + 1) / Double(customTimer.rounds)
        } else if state == .countdown {
            return 1.0 - Double(countdownCurrentValue) / Double(EMOMViewModel.coundownValue)
        } else {
            return 0.0
        }
    }

    //MARK: - Helpers
    func getForegroundTextColor() -> Color {
        if [.notStarted, .finished].contains(where: { $0 == state }) {
            return .timerNotStartedColor
        } else if state == .startedWork {
            return .timerStartedColor
        } else if state == .startedRest {
            return .timerRestStartedColor
        } else if state == .countdown {
            return countdownCurrentValue > 3 ? .countdownColor : .countdownInminentColor
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

    func hasToShow(work: Bool = true) -> Bool {
        return work ? state == .startedWork: state == .startedRest
    }

    func getCurrentRound() -> String {
        guard let customTimer, [.countdown].allSatisfy({ state != $0 }) else { return "" }
        if [.notStarted].contains(where: { state == $0 }) {
            return "1"
        } else if [.finished].contains(where: { state == $0 }) {
            return String(format: "%0d", customTimer.rounds)
        } else if state == .startedWork {
            return String(format: "%0d", customTimer.rounds - roundsLeft + 1)
        } else if state == .startedRest {
            return String(format: "%0d", customTimer.rounds - roundsLeft + 1)
        } else {
            return "00"
        }
    }
    
    func getRounds() -> String {
        guard let customTimer, [.countdown].allSatisfy({ state != $0 }) else { return "" }
        return String(format: "/%0d", customTimer.rounds)
    }

    func getCurrentMessage() -> String {
        if state == .finished {
            return String(localized: "chrono_message_finished")
        } else if state == .notStarted {
            return String(localized: "chrono_message_press_play")
        } else if state == .startedWork {
            return roundsLeft <= 1 ? String(localized: "chrono_message_last_round") : String(localized: "chrono_message_work")
        } else if state == .startedRest {
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
         if state == .notStarted {
            set(state: .startedWork)
        }
    }

    internal func startCountdown() {
        let blockTimerCountdown: (Timer) -> Void = { [weak self] _ in
            guard let self else { return }
            countdownCurrentValue -= 1

            if countdownCurrentValue < 1 {
                timerCountdown?.invalidate()
                dropTimer(&timerCountdown)
                self.set(state: .notStarted)
                startWorkTime()
                return
            }
            self.mmss = "\(countdownCurrentValue)"
        }
        timerCountdown = Timer(
            fire: Date.now,
            interval: 1,
            repeats: true,
            block: blockTimerCountdown)
        
        guard let timerCountdown else { return }
        RunLoop.main.add(timerCountdown, forMode: .common)
    }
    
    internal func startRefreshTimer() {
        let blockTimerRefresh: (Timer) -> Void = { [weak self] _ in
            guard let self, let customTimer else { return }
            if state == .countdown,
               customTimer.isMirroredOnAW,
                let mirroredTimer = getMirroredCustomTimer() {
                TimerStore.shared.send(mirroredTimer: mirroredTimer)
                LocalLogger.log("EmomViewModel.blockTimerRefresh state:\(state) value:\(countdownCurrentValue)")
            } else if  [.startedWork, .startedRest, .finished].contains(where: { self.state == $0 }),
                       customTimer.isMirroredOnAW,
                        let mirroredTimer = getMirroredCustomTimer() {
                TimerStore.shared.send(mirroredTimer: mirroredTimer)
                LocalLogger.log("EmomViewModel.blockTimerRefresh state:\(state) value:\(countdownCurrentValue)")
                
                
            }
            if  [.startedWork, .startedRest ].contains(where: { self.state == $0 }) {
                mmss = getMMSS()
            }
        }
         refreshProgressTimer = Timer(
            fire: Date.now,
            interval: 1,
            repeats: true,
            block: blockTimerRefresh)
        
        guard let refreshProgressTimer else { return }
        RunLoop.main.add(refreshProgressTimer, forMode: .common)
    }
    
    private func getMirroredCustomTimer() -> MirroredTimer? {
        guard let customTimer else { return nil }
        if state == .countdown {
            let mirroredTimerCountdown = MirroredTimerCountdown(value: countdownCurrentValue)
            let mirroredTimer = MirroredTimer(mirroredTimerType: .countdown, mirroredTimerCountdown: mirroredTimerCountdown)
            return mirroredTimer
        } else if [ .startedWork,.startedRest].contains(where: { $0 == state}) /*,
                  let chronoOnMove*/ {
            let isWork =  state == .startedWork
            let message =  String(localized: isWork ? "chrono_message_work" : "chrono_message_rest")
            let mirroredTimerWorking = MirroredTimerWorking(rounds: customTimer.rounds,
                                                            currentRounds: customTimer.rounds - roundsLeft + 1,
                                                            date: getChronoOnLowEnergyMode(customTimer: customTimer),
                                                            isWork: state == .startedWork,
                                                            message: message)
            let mirroredTimer = MirroredTimer(mirroredTimerType: .working, mirroredTimerWorking: mirroredTimerWorking)
            return mirroredTimer
        } else if [ .finished].contains(where: { $0 == state}) {
           let mirroredTimerFinished = MirroredTimerFinished(rounds: customTimer.rounds,
                                                           currentRounds: customTimer.rounds - roundsLeft + 1,
                                                           date: mmss,
                                                            isWork: state == .startedWork, message: String(localized: "chorno_message_finished"))
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

    private func set(state to: State) {
        self.state = to
    }
    
    private func set(roundsLeft: Int) {
        self.roundsLeft = roundsLeft
    }
    
    private func decreaseBy1RoundsLeft() {
        self.roundsLeft -= 1
    }
    
    // MARK :- Private/Internal
    private func processWorktime(emom: CustomTimer, timerWork: inout Timer?) {
        guard var fireWork = endOfRound(emom: emom) else { return }
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
        
        let blockTimerWork: (Timer) -> Void = { [weak self] _ in
            guard let self else { return }
            self.decreaseBy1RoundsLeft()
            
            if roundsLeft > 0 {
                self.set(state: .startedWork)
                //self.chronoOnMove = Date.now
                mmss = getMMSS()
            } else {
                self.set(state: .finished)
                self.timerFinished()
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
    
    private func timerFinished() {
        removeTimers()
        //chronoOnMove = nil

        if state == .finished {
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
        guard var fireRest = endOfWork(emom: emom) else { return }
        createAndRunRestTimer(emom, fireRest, timerRest: &timerRest)
    }
    
    fileprivate func createAndRunRestTimer(_ emom: CustomTimer, _ fireRest: Date,
                                           timerRest: inout Timer?) {
        
        let blockRestTimer: (Timer) -> Void = { [weak self] _ in
            guard let self else { return }
            self.set(state: .startedRest)
            if roundsLeft > 1 {
               //  self.chronoOnMove = Date.now
               // chronoFrozen = getChronoOnLowEnergyMode()
            }else /*if emom.restSecs == 0*/ {
                self.set(state: .finished)
                self.timerFinished()
            }
        }
        let secondsPerRound = Double(emom.workSecs /*+ 1*/ + emom.restSecs)
        timerRest = Timer(fire: fireRest, interval: secondsPerRound, repeats: true, block: blockRestTimer)
        guard let timerRest else { return }
        RunLoop.main.add(timerRest, forMode: .common)
    }
}
