//
//  CreateCustomTimerView.swift
//  EMOM timers
//
//  Created by Javier Calartrava on 16/5/24.
//

import SwiftUI

struct CreateCustomTimerView: View {
    @Binding var customTimer: CustomTimer?
    @State private var selectedIndexRounds = 0
    @State private var selectedWorkMins = 0
    @State private var selectedWorkSecs = 30
    @State private var selectedRestMins = 0
    @State private var selectedRestSecs = 0
    let minRounds = 2
    let pickerHeight = 200.0
    var body: some View {
        VStack {
            Spacer()
            CreateCustomTimerPickerView(title: "Rounds", color: .roundColor,min: minRounds, max: 50, value: $selectedIndexRounds)
               // .foregroundColor(.roundColor)
            .frame(height: pickerHeight)
            Spacer()
            VStack(spacing: 0){
                Text("Work time:")
                    .foregroundColor(.timerStartedColor)
                HStack(spacing: 5) {
                    CreateCustomTimerPickerView(title: "Minutes", color: .timerStartedColor, value: $selectedWorkMins)
                        .frame(height: pickerHeight)
                    Text(":")
                    CreateCustomTimerPickerView(title: "Seconds",color: .timerStartedColor, value: $selectedWorkSecs)
                        .frame(height: pickerHeight)
                }
            }
            Spacer()
            VStack(spacing: 0){
                Text("Rest time:")
                    .foregroundColor(.timerRestStartedColor)
                HStack(spacing: 5) {
                    CreateCustomTimerPickerView(title: "Minutes", color: .timerRestStartedColor, value: $selectedRestMins)
                        .frame(height: pickerHeight)
                    Text(":")
                    CreateCustomTimerPickerView(title: "Seconds",color: .timerRestStartedColor, value: $selectedRestSecs)
                        .frame(height: pickerHeight)
                }
            }

              //  .foregroundColor(.timerStartedColor)
            Spacer()
            Button(LocalizedStringKey("Continue"), action: {
                let secs = selectedWorkMins * 60 + selectedWorkSecs
                let rounds = minRounds + selectedIndexRounds
                let timer = CustomTimer(timerType: .emom, rounds: rounds, workSecs: secs)
                customTimer = timer
            })
        }
        .pickerStyle(.wheel)
        .font(.pickerSelectionFont)
    }
}

struct CreateCustomTimerPickerView: View {
    let title: String
    let color: Color
    let min: Int
    let max: Int
    @Binding private var value: Int
    init(title: String, color: Color, min: Int = 0, max: Int = 60, value: Binding<Int>) {
        self.title = title
        self.color = color
        self.min = min
        self.max = max
        self._value = value
    }
    var body: some View {
        VStack {
            Text(title)
            Picker(title, selection: $value) { ForEach(min..<max) {
                Text("\(String(format: "%0.2d", $0))")
                    .foregroundColor(color)
                    .font(.pickerSelectionFont)
            }
            }
        }                    .foregroundColor(color)

    }
}


#Preview {
    CreateCustomTimerView(customTimer: .constant(CustomTimer.customTimerDefault))
}
