//
//  NewRoundTimerView.swift
//  RoundTimer Watch App
//
//  Created by Javier Calartrava on 17/1/24.
//
import Combine
import SwiftUI

struct CreateCustomTimerView: View {
    @Environment(\.dismiss) var dismiss
    @State private var navPath: [String] = []
    @Binding var customTimer: CustomTimer?
    @EnvironmentObject var createCustomTimerViewModel: CreateCustomTimerViewModel
    var body: some View {
        NavigationStack(path: $navPath) {
            ScrollView {
                FirstViewInFlow(navPath: $navPath)
                .navigationTitle("EMOM")
                .navigationDestination(for: String.self) { pathValue in
                    if pathValue == CreateCustomTimerViewModel.Screens.ageStepView.rawValue {
                        AgeStepView(navPath: $navPath)
                    } else if pathValue == CreateCustomTimerViewModel.Screens.roundsStepView.rawValue {
                        RoundsStepView(navPath: $navPath)
                    } else if pathValue == CreateCustomTimerViewModel.Screens.timerPickerStepViewWork.rawValue {
                        TimerPickerStepView(navPath: $navPath, pickerViewType: .work)
                    } else if pathValue == CreateCustomTimerViewModel.Screens.timerPickerStepViewRest.rawValue {
                        TimerPickerStepView(navPath: $navPath, pickerViewType: .rest)
                    }
                }
            }
        }
        .onChange(of: navPath) { oldValue, newValue in
            if isDoneFromTimerPickerStepView(oldValue, newValue) {
                customTimer = createCustomTimerViewModel.getEmom()
                dismiss()
            } else if isBack(.roundsStepView, oldValue, newValue) {
                createCustomTimerViewModel.backFromRoundsStepView()
            } else if isBack(.timerPickerStepViewWork, oldValue, newValue) {
                createCustomTimerViewModel.backFromTimerPickerStepViewWork()
            } else if isBack(.timerPickerStepViewRest, oldValue, newValue) {
                createCustomTimerViewModel.backFromTimerPickerStepViewRest()
            }
        }
    }
    
    func isPopToRoot(_ oldValue: [String], _ newValue: [String], _ popToRoot: Bool) -> Bool {
        !oldValue.isEmpty && newValue.isEmpty && popToRoot
    }
    
    func isDoneFromTimerPickerStepView(_ oldValue: [String], _ newValue: [String]) -> Bool {
        if createCustomTimerViewModel.timerType == .emom,
           oldValue.count > 1,
            newValue.isEmpty {
            return oldValue[oldValue.count - 1] == CreateCustomTimerViewModel.Screens.timerPickerStepViewWork.rawValue ||
            oldValue[oldValue.count - 1] == CreateCustomTimerViewModel.Screens.timerPickerStepViewRest.rawValue
        } else if createCustomTimerViewModel.timerType == .upTimer,
                  newValue.count == 1,
                    oldValue.isEmpty {
            return  newValue[0] == CreateCustomTimerViewModel.Screens.timerPickerStepViewWork.rawValue
        }
        return false
    }
    
    func isBack(_ from: CreateCustomTimerViewModel.Screens, _ oldValue: [String], _ newValue: [String]) -> Bool {
        oldValue.count == newValue.count + 1 &&
        Array(oldValue.prefix(newValue.count)) == newValue &&
        oldValue.last == from.rawValue
    }
}

//#Preview {
//    CreateCustomTimerView(emom: .constant(CustomTimer.))
//}

