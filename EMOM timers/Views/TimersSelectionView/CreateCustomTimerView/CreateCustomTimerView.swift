//
//  CreateCustomTimerView2.swift
//  EMOM timers
//
//  Created by Javier Calartrava on 16/5/24.
//

import SwiftUI

struct CreateCustomTimerView: View {
    let timerType: TimerType
    @Binding var customTimer: CustomTimer?
    
    @EnvironmentObject var viewModel: CreateCustomTimerViewModel
    
    @State private var isRestOn = false
    @State private var isFetchingAW = false
    
    let pickerSize = 200.0
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                CreateCustomTimerWorkRestToggleView(isRestOn: $isRestOn)
                Spacer(minLength: 140)
                DismissButton()
            }
            HStack {
                if timerType == .emom {
                    CreateCustomTimerPickerView(title: String(localized: "picker_rounds"),
                                                color: .roundColor,
                                                min: viewModel.minRounds,
                                                max: viewModel.maxRounds,
                                                format: "%d",
                                                value: $viewModel.selectedIndexRounds)
                    .frame(width: pickerSize, height: pickerSize)
                    Spacer(minLength: 150)
                }
                if isRestOn && timerType == .emom {
                    CreateCustomTimerMMSSPickerView(selectedMins: $viewModel.selectedRestMins,
                                                    selectedSecs: $viewModel.selectedRestSecs,
                                                    isRestOn: isRestOn)
                } else {
                    CreateCustomTimerMMSSPickerView(selectedMins: $viewModel.selectedWorkMins,
                                                    selectedSecs: $viewModel.selectedWorkSecs,
                                                    isRestOn: isRestOn)
                }
            }
            Spacer()
            HStack() {
                Spacer()
                CreateCustomTimerContinueButton(/*isFetchingAW: $isFetchingAW,*/
                                                customTimer: $customTimer)
            }
        }
//        .task {
//            await viewModel.onAppearActions()
//        }
        .background(Color.defaultBackgroundColor)
    }
}

//#Preview {
//    CreateCustomTimerView(timerType: .emom,
//                          customTimer: .constant(CustomTimer.customTimerDefault))
//}
