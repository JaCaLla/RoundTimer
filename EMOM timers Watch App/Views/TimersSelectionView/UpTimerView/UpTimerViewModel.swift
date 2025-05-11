//
//  UpTimerViewModel.swift
//  RoundTimer Watch App
//
//  Created by Javier Calartrava on 17/3/24.
//

@preconcurrency import SwiftUI

@MainActor
final class UpTimerViewModel: EMOMViewModel {
    
    override func getRoundsProgress() -> Double {
        guard let customTimer else { return 0.0 }
        if state.value == .countdown {
            return 1.0 - Double(countdownCurrentValue) / Double(EMOMViewModel.coundownValue)
        } else {
            guard let startWorkTimeStamp  else { return 0.0 }
            let ellapsedSecs = abs(Int(startWorkTimeStamp.timeIntervalSinceNow))
            let secsPerRound = customTimer.workSecs
         
            return Double(ellapsedSecs) / Double(secsPerRound)
        }
    }
}
