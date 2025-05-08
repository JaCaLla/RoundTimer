//
//  CreateCustomTimerViewModel.swift
//  EMOM timers
//
//  Created by Javier Calartrava on 4/7/24.
//

import SwiftUI

@MainActor
final class CreateCustomTimerViewModel: ObservableObject {

    @Published var timerType: TimerType = .emom
 
    @State private var isRestOn = false
    
    var selectedWorkMins = 1
    var selectedWorkSecs = 0
    var selectedRestMins = 0
    var selectedRestSecs = 0
    var selectedIndexRounds = 0
    
    let minRounds = 2
    let maxRounds = 50
    
    @MainActor func createCustomTimer() async -> CustomTimer? {
        let workSecs = selectedWorkMins * 60 + selectedWorkSecs
        guard workSecs > 0 else { return nil }
        let restSecs = selectedRestMins * 60 + selectedRestSecs
        let rounds = getRounds(timerType)
        return CustomTimer(timerType: timerType,
                           rounds: rounds,
                           workSecs: workSecs,
                           restSecs: restSecs)
    }
    
    private func getRounds(_ timerType: TimerType) -> Int {
        switch timerType {
        case .emom: max(minRounds, selectedIndexRounds)
        case .upTimer: 1
        }
    }
}
