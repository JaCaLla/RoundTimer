//
//  CreateCustomTimerViewModel.swift
//  RoundTimer Watch App
//
//  Created by Javier Calartrava on 19/3/24.
//

import Combine
import SwiftUI

protocol TimerPickerStepViewModelProtocol {
    func dismissFlowAndStartEMOM(pickerViewType: TimerPickerStepViewType, selected: (mins: Int, secs: Int))
    func getHHMMSSIndexs(pickerViewType: TimerPickerStepViewType) -> ( Int, Int)
}

final class CreateCustomTimerViewModel: ObservableObject {
    enum Screens: String {
        case ageStepView = "RoundsAgeView"
        case roundsStepView = "RoundsStepView"
        case timerPickerStepViewWork = "TimerPickerStepViewWork"
        case timerPickerStepViewRest = "TimerPickerStepViewRest"
    }
    
    private let defaulltCustomTimer = CustomTimer(timerType: .emom, rounds: 5, workSecs:  60, restSecs: 0)
    
    var dismissFlowAndStartEMOM = false
    @Published var timerType: TimerType = .emom
    private(set) var rounds = -1
    var workSecs = -1
    var restSecs = -1
    
    init() {
        rounds = defaulltCustomTimer.rounds
        workSecs = defaulltCustomTimer.workSecs
        restSecs = defaulltCustomTimer.restSecs
    }
    
    func setRounds(rounds: Int) {
        self.rounds = rounds
    }
    
    func setTimertype(type: TimerType) {
        timerType = type
    }
    
    func backFromRoundsStepView() {
        rounds = defaulltCustomTimer.rounds
    }
    
    func backFromTimerPickerStepViewWork() {
        workSecs = defaulltCustomTimer.workSecs
    }
    
    func backFromTimerPickerStepViewRest() {
        restSecs = defaulltCustomTimer.restSecs
    }
    
    func getEmom() -> CustomTimer? {
        guard dismissFlowAndStartEMOM else { return nil }
        let rounds = timerType == .upTimer ? 1 : rounds
        return CustomTimer(timerType: timerType, rounds: rounds, workSecs: workSecs /*+ 1*/, restSecs: restSecs /*== 0 ? 0 : restSecs + 1*/)
    }
    
    func getContinueButtonText() -> LocalizedStringKey {
        timerType == .upTimer ? "button_start_work" : "button_rest_next"
    }
    
    func getNavigationLink() -> String {
        timerType == .upTimer ? Screens.timerPickerStepViewWork.rawValue  : Screens.timerPickerStepViewRest.rawValue
    }
    
    func getButtonTitle() -> LocalizedStringKey {
        timerType == .upTimer ? "button_start_work" : "button_rest_next"
    }
}


// MARK: - TimerPickerStepViewModelProtocol
extension CreateCustomTimerViewModel: TimerPickerStepViewModelProtocol {
    func dismissFlowAndStartEMOM(pickerViewType: TimerPickerStepViewType,  selected: (mins: Int, secs: Int)) {
        dismissFlowAndStartEMOM = true
        // TO DO: Extract this calculation because will be performed in many places
        let secs = selected.mins * 60 + selected.secs
        if pickerViewType == .work {
            workSecs = secs
        } else {
            restSecs = secs
        }
    }
    
    func getHHMMSSIndexs( pickerViewType: TimerPickerStepViewType) -> ( Int, Int) {
    let seconds = pickerViewType == .work ? workSecs : restSecs
      return  (CustomTimer.getMM(seconds: seconds),
            CustomTimer.getSS(seconds: seconds))
    }
}
