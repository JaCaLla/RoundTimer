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
    @State private var selectedHours = 0
    @State private var selectedMins = 0
    @State private var selectedSecs = 30
    @EnvironmentObject var selectEMOMViewModel: SelectEMOMViewModel
   // let pickerWidth = .0
    let pickerHeight = 100.0
    var body: some View {
        VStack {
            HStack(spacing: 5) {
                Picker("Hours", selection: $selectedHours) { ForEach(0..<23) { Text("\(String(format: "%0.2d",$0))") }
                }
                    //.pickerStyle(.wheel)
                    .frame(/*width: pickerWidth,*/ height: pickerHeight)
              //  Text(":")
                Picker("Minutes", selection: $selectedMins) { ForEach(0..<59) { Text("\(String(format: "%0.2d",$0))") }
                }
                .focused($fousedfield)
                   // .pickerStyle(.wheel)
                    .frame(/*width: pickerWidth,*/ height: pickerHeight)
                //Text(":")
                Picker("Seconds", selection: $selectedSecs) { ForEach(0..<59) { Text("\(String(format: "%0.2d",$0))") }
                }
                    
                    .frame(/*width: pickerWidth,*/ height: pickerHeight)
            }
            .pickerStyle(.wheel)
            .font(.system(size: 30,weight: .black))
            Spacer()
            if pickerViewType == .work {
                NavigationLink(value: "TimerPickerStepViewRest") {
                    Text("Rest Time ... >")
                     //   .font(.system(size: 30,weight: .black))
                }
                .simultaneousGesture(TapGesture().onEnded{
                    let secs = selectedHours * 3600 + selectedMins * 60 + selectedSecs
                    selectEMOMViewModel.workSecs = secs
                })
            } else {
                Button(action: {
                    dismissFlowAndStartEMOM()
                }, label: {
                        Text("Done!")
                        //.font(.system(size: 30,weight: .black))
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
            (selectedHours, selectedMins, selectedSecs ) = getHHMMSSIndexs(seconds: seconds)
        }
    }
    
    func getHHMMSSIndexs(seconds: Int) -> (Int, Int, Int) {
        (Emom.getHH(seconds: seconds),
         Emom.getMM(seconds: seconds),
         Emom.getSS(seconds: seconds))
    }
    
    private func dismissFlowAndStartEMOM() {
        navPath.removeAll()
        selectEMOMViewModel.dismissFlowAndStartEMOM = true
        // TO DO: Extract this calculation because will be performed in many places
        let secs = selectedHours * 3600 + selectedMins * 60 + selectedSecs
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
