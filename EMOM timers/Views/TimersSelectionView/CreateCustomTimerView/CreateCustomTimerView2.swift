//
//  CreateCustomTimerView2.swift
//  EMOM timers
//
//  Created by Javier Calartrava on 16/5/24.
//

import SwiftUI

struct CreateCustomTimerView2: View {
    @Binding var customTimer: CustomTimer?
    @State private var selectedIndexRounds = 0
    @State private var selectedWorkMins = 0
    @State private var selectedWorkSecs = 3
    @State private var selectedRestMins = 0
    @State private var selectedRestSecs = 1
    let minRounds = 2
    let pickerHeight = 200.0
    @State private var isRestOn = false
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                HStack {
                    Spacer()
                    Text("Rest")
                    Toggle("", isOn: $isRestOn)
                        .toggleStyle(SwitchToggleStyle(tint: .timerRestStartedColor))
                        .frame(width: 100)
                }.foregroundColor(.timerRestStartedColor)
                    .font(.pickerSelectionFont)
            }
            HStack {
                CreateCustomTimerPickerView(title: "Rounds", color: .roundColor, min: minRounds, max: 50, format: "%d", value: $selectedIndexRounds)
                // .foregroundColor(.roundColor)
                .frame(width: 200, height: pickerHeight)
                Spacer(minLength: 150)

                HStack(spacing: 5) {
                    if isRestOn {
                        CreateCustomTimerPickerView(title: "Minutes", color: .timerRestStartedColor, value: $selectedRestMins)
                            .frame(height: pickerHeight)
                        Text(":")
                        CreateCustomTimerPickerView(title: "Seconds", color: .timerRestStartedColor, value: $selectedRestSecs)
                            .frame(height: pickerHeight)
                    } else {
                        CreateCustomTimerPickerView(title: "Minutes", color: .timerStartedColor, value: $selectedWorkMins)
                            .frame(height: pickerHeight)
                        Text(":")
                        CreateCustomTimerPickerView(title: "Seconds", color: .timerStartedColor, value: $selectedWorkSecs)
                            .frame(height: pickerHeight)
                    }
                }
            }

            Spacer()
            Button(action: {
                let workSecs = selectedWorkMins * 60 + selectedWorkSecs
                let restSecs = selectedRestMins * 60 + selectedRestSecs
                let rounds = minRounds + selectedIndexRounds
                let timer = CustomTimer(timerType: .emom, rounds: rounds, workSecs: workSecs, restSecs: restSecs)
                customTimer = timer
            }) {
                Text("Continue")
                    .font(.buttoniOSAppFont)
                    .padding() .foregroundStyle(Color.buttonTextColor) .background(Color.roundColor) .clipShape(RoundedRectangle(cornerRadius: 16))
            }
//            Button(LocalizedStringKey("Continue"), action: {
//                    let workSecs = selectedWorkMins * 60 + selectedWorkSecs
//                    let restSecs = selectedRestMins * 60 + selectedRestSecs
//                    let rounds = minRounds + selectedIndexRounds
//                    let timer = CustomTimer(timerType: .emom, rounds: rounds, workSecs: workSecs, restSecs: restSecs)
//                    customTimer = timer
//                })
        }
            .pickerStyle(.wheel)
        //  .font(.pickerSelectionFont)
    }
}



#Preview {
    CreateCustomTimerView2(customTimer: .constant(CustomTimer.customTimerDefault))
}
