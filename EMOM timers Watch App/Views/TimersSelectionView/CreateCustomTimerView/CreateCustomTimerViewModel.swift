//
//  CreateCustomTimerViewModel.swift
//  RoundTimer Watch App
//
//  Created by Javier Calartrava on 19/3/24.
//

import Combine
import SwiftUI

final class CreateCustomTimerViewModel: ObservableObject {
    enum Screens: String {
        case ageStepView = "RoundsAgeView"
        case roundsStepView = "RoundsStepView"
        case timerPickerStepViewWork = "TimerPickerStepViewWork"
        case timerPickerStepViewRest = "TimerPickerStepViewRest"
    }
    
    // TO REFACTOR: Replace this by an Emom
    let roundsDefault = 5
    let workSecsDefault = 60
    let restSecsDefault = 0
    
    var dismissFlowAndStartEMOM = false
    var timerType: TimerType = .emom
    private (set) var rounds = -1
    var workSecs = -1
    var restSecs = -1
    
    init() {
        rounds = roundsDefault
        workSecs = workSecsDefault
        restSecs = restSecsDefault
    }
    
    func setRounds(rounds: Int) {
        self.rounds = rounds
    }
    
    func setTimertype(type: TimerType) {
        timerType = type
    }
    
    func backFromRoundsStepView() {
        rounds = roundsDefault
    }
    
    func backFromTimerPickerStepViewWork() {
        workSecs = workSecsDefault
    }
    
    func backFromTimerPickerStepViewRest() {
        restSecs = restSecsDefault
    }
    
    func getEmom() -> CustomTimer? {
        guard dismissFlowAndStartEMOM else { return nil }
        let rounds = timerType == .upTimer ? 1 : rounds
        return CustomTimer(timerType: timerType, rounds: rounds, workSecs: workSecs, restSecs: restSecs)
    }
    
    func getContinueButtonText() -> LocalizedStringKey {
        timerType == .upTimer ? "button_start_work" : "button_rest_next"
    }
    
    func getNavigationLink() -> String {
        timerType == .upTimer ? Screens.timerPickerStepViewWork.rawValue  : Screens.timerPickerStepViewRest.rawValue
    }
}
