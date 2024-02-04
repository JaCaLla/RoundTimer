//
//  NewRoundTimerView.swift
//  RoundTimer Watch App
//
//  Created by Javier Calartrava on 17/1/24.
//
import Combine
import SwiftUI

final class SelectEMOMViewModel: ObservableObject {
    enum Screens: String {
        case roundsStepView = "RoundsStepView"
        case timerPickerStepViewWork = "TimerPickerStepViewWork"
        case timerPickerStepViewRest = "TimerPickerStepViewRest"
    }

    // TO REFACTOR: Replace this by an Emom
    let roundsDefault = 1
    let workSecsDefault = 20
    let restSecsDefault = 0

    var dismissFlowAndStartEMOM = false
    var rounds = -1
    var workSecs = -1
    var restSecs = -1

    init() {
        rounds = roundsDefault
        workSecs = workSecsDefault
        restSecs = restSecsDefault
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

    func getEmom() -> Emom? {
        guard dismissFlowAndStartEMOM else { return nil }
        return Emom(rounds: rounds, workSecs: workSecs, restSecs: restSecs)
    }
}

struct SelectEMOMView: View {
    @Environment(\.dismiss) var dismiss
    @State private var navPath: [String] = []
    @Binding var emom: Emom?
    @StateObject var selectEMOMViewModel: SelectEMOMViewModel = SelectEMOMViewModel()
    var body: some View {
        NavigationStack(path: $navPath) {
            ScrollView {
                VStack {
//                    VStack {
//                        NavigationLink(value: SelectEMOMViewModel.Screens.roundsStepView.rawValue) {
//                            Text("New >")
//                        }
//                        EMOMTimerListView(emoms: .sampleOddList)
//                    }
                    RoundsStepView(navPath: $navPath)
                }
                    .navigationTitle("EMOM")
                    .navigationDestination(for: String.self) { pathValue in
                    if pathValue == SelectEMOMViewModel.Screens.roundsStepView.rawValue {
                        RoundsStepView(navPath: $navPath)
                    } else if pathValue == SelectEMOMViewModel.Screens.timerPickerStepViewWork.rawValue {
                        TimerPickerStepView(navPath: $navPath, pickerViewType: .work)
                    } else if pathValue == SelectEMOMViewModel.Screens.timerPickerStepViewRest.rawValue {
                        TimerPickerStepView(navPath: $navPath, pickerViewType: .rest)
                    }
                }
            }
        }
            .onChange(of: navPath) { oldValue, newValue in
            if isDoneFromTimerPickerStepView(oldValue, newValue) {
                emom = selectEMOMViewModel.getEmom()
                dismiss()
            } else if isBack(.roundsStepView, oldValue, newValue) {
                selectEMOMViewModel.backFromRoundsStepView()
            } else if isBack(.timerPickerStepViewWork, oldValue, newValue) {
                selectEMOMViewModel.backFromTimerPickerStepViewWork()
            } else if isBack(.timerPickerStepViewRest, oldValue, newValue) {
                selectEMOMViewModel.backFromTimerPickerStepViewRest()
            }
        }
        .environmentObject(selectEMOMViewModel)
    }

    func isPopToRoot(_ oldValue: [String], _ newValue: [String], _ popToRoot: Bool) -> Bool {
        !oldValue.isEmpty && newValue.isEmpty && popToRoot
    }

    func isDoneFromTimerPickerStepView(_ oldValue: [String], _ newValue: [String]) -> Bool {
        guard oldValue.count > 1 && newValue.isEmpty else { return false }
        return oldValue[oldValue.count - 1] == SelectEMOMViewModel.Screens.timerPickerStepViewWork.rawValue ||
            oldValue[oldValue.count - 1] == SelectEMOMViewModel.Screens.timerPickerStepViewRest.rawValue
    }

    func isBack(_ from: SelectEMOMViewModel.Screens, _ oldValue: [String], _ newValue: [String]) -> Bool {
        oldValue.count == newValue.count + 1 &&
            Array(oldValue.prefix(newValue.count)) == newValue &&
        oldValue.last == from.rawValue
    }
}

#Preview {
    SelectEMOMView(emom: .constant(nil))
}

