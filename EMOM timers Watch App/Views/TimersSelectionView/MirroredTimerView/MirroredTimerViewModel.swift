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
    func close()
    func getCurrentMessage() -> String
}

final class MirroredTimerViewModel:NSObject, ObservableObject {
    
    @Published var chronoFrozen = "--:--"
    private let audioManager: AudioManagerProtocol
    private(set) var state: EMOMViewModelState
    var mirroredTimer: MirroredTimer?
    
    init(mirroredTimer: MirroredTimer? = nil,
         audioManager : AudioManagerProtocol = AudioManager.shared,
         state: EMOMViewModelState = EMOMViewModelState()) {
        self.mirroredTimer = mirroredTimer
        self.audioManager = audioManager
        self.state = state
    }
}

// MARK :- MirroredTimerViewModelProtocol
extension MirroredTimerViewModel: MirroredTimerViewModelProtocol {
    
    func set(mirroredTimer: MirroredTimer) {
        self.mirroredTimer = mirroredTimer
        
        if let mirroredTimerCountdown =  mirroredTimer.mirroredTimerCountdown {
            chronoFrozen = "\(mirroredTimerCountdown.value)"
            changeStateAndSpeechWhenApplies(to: .countdown)
        } else if let mirroredTimerWorking =  mirroredTimer.mirroredTimerWorking {
            chronoFrozen = mirroredTimerWorking.date
            changeStateAndSpeechWhenApplies(to: mirroredTimerWorking.isWork ? .startedWork : .startedRest)
        } else if let mirroredTimerStopped =  mirroredTimer.mirroredTimerFinished {
            chronoFrozen = mirroredTimerStopped.date
            changeStateAndSpeechWhenApplies(to: .finished)
        }
    }

    private func changeStateAndSpeechWhenApplies(to: EMOMViewModelState.State) {
        state = state.set(state: to)
        speech(state: state)
    }
    
    private func speech(state: EMOMViewModelState) {
        guard state.didChanged else { return }
        audioManager.speech(state: state)
    }

    func getCurrentRound() -> String {
        guard let mirroredTimer else { return "" }
        if mirroredTimer.mirroredTimerType == .countdown {
            return ""
        } else if let mirroredTimerWorking = mirroredTimer.mirroredTimerWorking {
            return  String(format: "%0d", mirroredTimerWorking.currentRound)
        } else if let mirroredTimerFinished = mirroredTimer.mirroredTimerFinished  {
            return  String(format: "%0d", mirroredTimerFinished.rounds)
        } else {
            return ""
        }
    }
    
    func getCurrentMessage() -> String {
        guard let mirroredTimer else { return "" }
        if mirroredTimer.mirroredTimerType == .countdown {
            return ""
        } else if let mirroredTimerWorking = mirroredTimer.mirroredTimerWorking {
            return  mirroredTimerWorking.message
        } else if let mirroredTimerFinished = mirroredTimer.mirroredTimerFinished  {
            return  mirroredTimerFinished.message
        } else {
            return ""
        }
    }
    
    func getRounds() -> String {
        guard let mirroredTimer, [.countdown].allSatisfy({ mirroredTimer.mirroredTimerType != $0 }) else { return "" }
      if let mirroredTimerWorking = mirroredTimer.mirroredTimerWorking {
           return  String(format: "/%0d", mirroredTimerWorking.rounds)
       }
        return ""
    }
    
    func getTimerAndRoundFont() -> Font {
        .timerAndRoundLargeFont
    }
    
    func getForegroundTextColor() -> Color {
        guard let mirroredTimer else { return .green }
        if let mirroredTimerCountdown =  mirroredTimer.mirroredTimerCountdown {
            return mirroredTimerCountdown.value > 3 ? .countdownColor : .countdownInminentColor
        } else if let mirroredTimerWorking =  mirroredTimer.mirroredTimerWorking {
            return mirroredTimerWorking.isWork ? .timerStartedColor : .timerRestStartedColor
        } else if mirroredTimer.mirroredTimerFinished != nil {
            return .timerNotStartedColor
        }
            return .green
    }
    
    func getRoundsProgress() -> Double {
        guard let mirroredTimer else { return 0.0 }
        if let mirroredTimerCountdown =  mirroredTimer.mirroredTimerCountdown {
            return 1.0 - Double(mirroredTimerCountdown.value) / Double(EMOMViewModel.coundownValue)
        } else if let mirroredTimerWorking =  mirroredTimer.mirroredTimerWorking {
            return 1.0 - Double(mirroredTimerWorking.currentRound) / Double(mirroredTimerWorking.rounds)
        } else if mirroredTimer.mirroredTimerFinished != nil {
            return 1.0
        }
        return 0.0
    }
    
    func close() {
        mirroredTimer = nil
    }
}
