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
    @Published var createChronoMirroredInAW = false
    @Published var isFetchingAW = false
    @State private var isRestOn = false
    var selectedWorkMins = 0
    var selectedWorkSecs = 3
    var selectedRestMins = 0
    var selectedRestSecs = 1
    var selectedIndexRounds = 0
    
    // MARK :- Lifecycle
    func onAppearActions() async {
            let result = await HealthkitManager.shared.startWorkoutSession()
            await setIsLinkedToAW(result)
    }
    
    // MARK: - Presentation logic
    func imageConnectionAW() -> String {
        createChronoMirroredInAW ? "checkmark.applewatch" : "applewatch.slash"
    }

    func buildCustomTimer(isMirroredOnAW: Bool) -> CustomTimer? {
        let workSecs = selectedWorkMins * 60 + selectedWorkSecs
        guard workSecs > 0 else { return nil }
        let restSecs = selectedRestMins * 60 + selectedRestSecs
      //  let rounds = /*minRounds +*/ selectedIndexRounds
        let rounds = max(minRounds, selectedIndexRounds)
        return CustomTimer(timerType: .emom,
                           rounds: rounds,
                           workSecs: workSecs,
                           restSecs: restSecs,
                           isMirroredOnAW: isMirroredOnAW)

    }
    
    @MainActor func createCustomTimer() async -> CustomTimer? {
        if createChronoMirroredInAW {
            isFetchingAW = true
            _ = await HealthkitManager.shared.startWorkoutSession()
            LocalLogger.log("CreateCustomTimerView2.Button(action:)")
            isFetchingAW = false
            return buildCustomTimer(isMirroredOnAW: true)
        } else {
            return buildCustomTimer(isMirroredOnAW: false)
        }
    }
    
    // MARK: - Private/Internal
    @MainActor private func setIsLinkedToAW(_ value: Bool) {
            self.createChronoMirroredInAW = value
    }
}
