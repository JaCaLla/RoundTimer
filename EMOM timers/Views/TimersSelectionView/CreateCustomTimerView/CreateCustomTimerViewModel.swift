//
//  CreateCustomTimerViewModel.swift
//  EMOM timers
//
//  Created by Javier Calartrava on 4/7/24.
//

import SwiftUI

final class CreateCustomTimerViewModel: ObservableObject {
    let minRounds = 2
    let maxRounds = 50
    
    @Published var isLinkedToAW = false
    @State private var isRestOn = false
    var selectedWorkMins = 0
    var selectedWorkSecs = 3
    var selectedRestMins = 0
    var selectedRestSecs = 1
    var selectedIndexRounds = 0
    
    // MARK :- Lifecycle
    func onAppearActions() async {
            let result = await HealthkitManager.shared.startWorkoutSession()
            await setisLinkedToAW(result)
    }
    
    // MARK: - Presentation logic
    func imageConnectionAW() -> String {
        isLinkedToAW ? "checkmark.applewatch" : "applewatch.slash"
    }
    
    func buildCustomTimer(/*selectedWorkMins: Int,
                          selectedWorkSecs: Int,
                          selectedRestMins: Int,
                          selectedRestSecs: Int,
                          selectedIndexRounds: Int*/) -> CustomTimer {
        
        let workSecs = selectedWorkMins * 60 + selectedWorkSecs
        let restSecs = selectedRestMins * 60 + selectedRestSecs
        let rounds = minRounds + selectedIndexRounds
        return CustomTimer(timerType: .emom, rounds: rounds, workSecs: workSecs, restSecs: restSecs)

    }
    
    // MARK: - Private/Internal
    @MainActor private func setisLinkedToAW(_ value: Bool) {
            self.isLinkedToAW = value
    }
}