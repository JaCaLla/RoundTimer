//
//  MirroredTimerViewModel.swift
//  EMOM timers
//
//  Created by Javier Calartrava on 13/7/24.
//

import SwiftUI

protocol MirroredTimerViewModelProtocol {
    func set(mirroredTimer: MirroredTimer)
    func getCurrentRound() -> String
    func getRounds() -> String
    func getTimerAndRoundFont() -> Font
    func getForegroundTextColor() -> Color 
    func getTimerAndRoundFont(isLuminanceReduced: Bool) -> Font
    func close() 
}

final class MirroredTimerViewModel:NSObject, ObservableObject {
    
    @Published var chronoFrozen = "--:--"
    @Published var chronoOnMove: Date?
    
    var mirroredTimer: MirroredTimer?
    
    init(mirroredTimer: MirroredTimer? = nil) {
        self.mirroredTimer = mirroredTimer
    }
}

// MARK :- MirroredTimerViewModelProtocol
extension MirroredTimerViewModel: MirroredTimerViewModelProtocol {
    
    func set(mirroredTimer: MirroredTimer) {
        self.mirroredTimer = mirroredTimer
        
        if let mirroredTimerCountdown =  mirroredTimer.mirroredTimerCountdown {
            chronoFrozen = "\(mirroredTimerCountdown.value)"
            chronoOnMove = nil
        } else if let mirroredTimerWorking =  mirroredTimer.mirroredTimerWorking {
            chronoOnMove = Date(timeIntervalSince1970: mirroredTimerWorking.date)//mirroredTimerWorking.date
        }else if let mirroredTimerStopped =  mirroredTimer.mirroredTimerStopped {
            chronoFrozen = mirroredTimerStopped.date//mirroredTimerWorking.date
            chronoOnMove = nil
        }
    }
    
    func getCurrentRound() -> String {
        guard let mirroredTimer else { return "" }
//        guard let emom, [.countdown].allSatisfy({ state != $0 }) else { return "" }
//        if [.notStarted].contains(where: { state == $0 }) {
//            return "1"
//        } else if [.finished].contains(where: { state == $0 }) {
//            return String(format: "%0d", emom.rounds)
//        } else if state == .startedWork || state == .paused {
//            return String(format: "%0d", emom.rounds - roundsLeft + 1)
//        } else if state == .startedRest || state == .paused {
//            return String(format: "%0d", emom.rounds - roundsLeft + 1)
//        } else {
        if mirroredTimer.mirroredTimerType == .countdown {
            return ""
        } else if let mirroredTimerWorking = mirroredTimer.mirroredTimerWorking {
            return  String(format: "%0d", mirroredTimerWorking.currentRound)
        } else if let mirroredTimerStopped = mirroredTimer.mirroredTimerStopped  {
            // TO DO: When is stopped due to pause (not finished) then is currentRound instead of rounds
            return  String(format: "%0d", mirroredTimerStopped.rounds)
        } else {
            return "00"
        }
           
//        }
    }
    
    func getRounds() -> String {
        guard let mirroredTimer, [.countdown].allSatisfy({ mirroredTimer.mirroredTimerType != $0 }) else { return "" }
      //  return String(format: "/%0d", emom.rounds)
      if let mirroredTimerWorking = mirroredTimer.mirroredTimerWorking {
           return  String(format: "/%0d", mirroredTimerWorking.rounds)
       }
        return ""
    }
    
    func getTimerAndRoundFont() -> Font {
//        guard let emom else { return .timerAndRoundLargeFont }
//        let isRound2Digits = emom.rounds > 9
//        let isWork2MMDigits = [emom.workSecs, emom.restSecs].contains(where: { $0 >= 10 * 60 }) ||
//        (state == .finished && ((emom.workSecs + emom.restSecs) * emom.rounds) > 10 * 60)
//        if isRound2Digits && isWork2MMDigits {
//            return isLuminanceReduced && state != .finished ? .timerAndRoundLRSmallFont : .timerAndRoundSmallFont
//        } else if isRound2Digits || isWork2MMDigits {
//            return isLuminanceReduced && state != .finished ?  .timerAndRoundLRMediumFont : .timerAndRoundMediumFont
//        } else {
//            return isLuminanceReduced && state != .finished ? .timerAndRoundLRLargeFont : .timerAndRoundLargeFont
//        }
        .timerAndRoundLargeFont
    }
    
    func getForegroundTextColor() -> Color {
        guard let mirroredTimer else { return .green }
//        if [.notStarted, .finished, .paused].contains(where: { $0 == state }) {
//            return .timerNotStartedColor
//        } else if state == .startedWork {
//            return .timerStartedColor
//        } else if state == .startedRest {
//            return .timerRestStartedColor
//        } else if state == .countdown {
//            return countdownCurrentValue > 3 ? .countdownColor : .countdownInminentColor
//        } else {
        if let mirroredTimerCountdown =  mirroredTimer.mirroredTimerCountdown {
            return mirroredTimerCountdown.value > 3 ? .countdownColor : .countdownInminentColor
        } else if let mirroredTimerWorking =  mirroredTimer.mirroredTimerWorking {
            return mirroredTimerWorking.isWork ? .timerStartedColor : .timerRestStartedColor
        }else if let mirroredTimerStopped =  mirroredTimer.mirroredTimerStopped {
            return .timerNotStartedColor
        }
            return .green
 //       }
    }
    
    func getTimerAndRoundFont(isLuminanceReduced: Bool) -> Font {
//        guard let emom else { return .timerAndRoundLargeFont }
//        let isRound2Digits = emom.rounds > 9
//        let isWork2MMDigits = [emom.workSecs, emom.restSecs].contains(where: { $0 >= 10 * 60 }) ||
//        (state == .finished && ((emom.workSecs + emom.restSecs) * emom.rounds) > 10 * 60)
//        if isRound2Digits && isWork2MMDigits {
//            return isLuminanceReduced && state != .finished ? .timerAndRoundLRSmallFont : .timerAndRoundSmallFont
//        } else if isRound2Digits || isWork2MMDigits {
//            return isLuminanceReduced && state != .finished ?  .timerAndRoundLRMediumFont : .timerAndRoundMediumFont
//        } else {
//            return isLuminanceReduced && state != .finished ? .timerAndRoundLRLargeFont : .timerAndRoundLargeFont
//        }
        return  .timerAndRoundLargeFont
    }
    
    internal func getRoundsProgress() -> Double {
        guard let mirroredTimer else { return 0.0 }
        if let mirroredTimerCountdown =  mirroredTimer.mirroredTimerCountdown {
            // TO DO: EMOMViewModel.coundownValue is total countdown secs and must be centralized in a common place
            return 1.0 - Double(mirroredTimerCountdown.value) / Double(EMOMViewModel.coundownValue)
        } else if let mirroredTimerWorking =  mirroredTimer.mirroredTimerWorking {
            return 1.0 - Double(mirroredTimerWorking.currentRound) / Double(mirroredTimerWorking.rounds)
        }
//        guard let emom else { return 0.0 }
//        if state == .finished {
//            return 1.0
//        } else if state == .startedWork || state == .startedRest {
//            return Double(emom.rounds - roundsLeft + 1) / Double(emom.rounds)
//        } else if state == .countdown {
//            return 1.0 - Double(countdownCurrentValue) / Double(EMOMViewModel.coundownValue)
//        } else {
            return 0.0
//        }
    }
    
    func close() {
        mirroredTimer = nil
    }
}
