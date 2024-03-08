//
//  PickerView.swift
//  RoundTimer Watch App
//
//  Created by Javier Calartrava on 17/1/24.
//

import SwiftUI

enum TimerPickerStepViewType {
    case work, rest

    var navigationTitle: String {
        switch self {
        case .work: "Work"
        case .rest: "Rest"
        }
    }
}

struct TimerPickerStepView: View {

    @Binding var navPath: [String]
    var pickerViewType: TimerPickerStepViewType
    @FocusState private var fousedfield: Bool
    @State private var selectedMins = 0
    @State private var selectedSecs = 30
    @EnvironmentObject var selectEMOMViewModel: SelectEMOMViewModel
    let pickerHeight = 100.0
    var body: some View {
        VStack {
            HStack(spacing: 5) {
                    Picker("Minutes", selection: $selectedMins) { ForEach(0..<60) { Text("\(String(format: "%0.1d", $0))") }
                    }
                    .focused($fousedfield)
                    .frame(height: pickerHeight)
                Picker("Seconds", selection: $selectedSecs) { ForEach(0..<60) { Text("\(String(format: "%0.2d", $0))") }
                }
                    .frame(height: pickerHeight)
            }
                .pickerStyle(.wheel)
                .foregroundColor(.timerStartedColor)
                .font(.pickerSelectionFont)
            Spacer()
            if pickerViewType == .work,
                !(selectedMins == 0 && selectedSecs == 0) {
                NavigationLink(value: "TimerPickerStepViewRest") {
                    Text("Rest Time ... >")
                }
                    .simultaneousGesture(TapGesture().onEnded {
                        let secs = selectedMins * 60 + selectedSecs
                        selectEMOMViewModel.workSecs = secs
                    })
            } else if pickerViewType == .rest {
                Button(action: {
                    dismissFlowAndStartEMOM()
                }, label: {
                        Text("START WORK!")
                    })
            }

        }
            .navigationTitle(pickerViewType.navigationTitle)
            .toolbar {
            if pickerViewType == .work {
                // TO DO: NO SE PUEDE PONER EL BOTÓN POR QUE NO SE PUEDE DISTINGUIR
                ToolbarItem(placement: .topBarTrailing) {
//                    Button(action: {
//                        dismissFlowAndStartEMOM()
//                    }, label: {
//                            Image(systemName: "checkmark.circle")
//                        })
                }
            } else if pickerViewType == .rest {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        navPath.removeAll()
                    }, label: {
                            Image(systemName: "xmark.circle")
                        })
                }
            }
        }.onAppear {
            fousedfield = true
            let seconds = pickerViewType == .work ? selectEMOMViewModel.workSecs : selectEMOMViewModel.restSecs
            (selectedMins, selectedSecs) = getHHMMSSIndexs(seconds: seconds)
        }
    }

    func getHHMMSSIndexs(seconds: Int) -> ( Int, Int) {
        (Emom.getMM(seconds: seconds),
            Emom.getSS(seconds: seconds))
    }

    private func dismissFlowAndStartEMOM() {
        navPath.removeAll()
        selectEMOMViewModel.dismissFlowAndStartEMOM = true
        // TO DO: Extract this calculation because will be performed in many places
        let secs = selectedMins * 60 + selectedSecs
        if pickerViewType == .work {
            selectEMOMViewModel.workSecs = secs
        } else {
            selectEMOMViewModel.restSecs = secs
        }
    }
}

#Preview("Work") {
    TimerPickerStepView(navPath: .constant([SelectEMOMViewModel.Screens.roundsStepView.rawValue, SelectEMOMViewModel.Screens.timerPickerStepViewWork.rawValue]), pickerViewType: .work)
        .environmentObject(SelectEMOMViewModel())

}

//#Preview("Rest") {
//    TimerPickerStepView(navPath: .constant([]), pickerViewType: .rest)
//        .environmentObject(SelectEMOMViewModel())
//}
