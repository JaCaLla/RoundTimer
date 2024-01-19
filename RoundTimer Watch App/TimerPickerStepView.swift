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
    @State private var selectedHours = 0
    @State private var selectedMins = 0
    @State private var selectedSecs = 30
    var body: some View {
        VStack {
            HStack {
                Picker("Hours", selection: $selectedHours) { ForEach(0..<23) { Text("\($0)") }
                }
                    .pickerStyle(.wheel)
                    .frame(width: 40, height: 80)
                Picker("Minutes", selection: $selectedMins) { ForEach(0..<59) { Text("\($0)") }
                }
                    .pickerStyle(.wheel)
                    .frame(width: 40, height: 80)
                Picker("Seconds", selection: $selectedSecs) { ForEach(0..<59) { Text("\($0)") }
                }
                    .pickerStyle(.wheel)
                    .frame(width: 40, height: 80)
            }
            Spacer()
            if pickerViewType == .work {
                NavigationLink(value: "TimerPickerStepViewRest") {
                    Text("Rest Time >")
                }
            } else {
                Button(action: {
                    // To do
                }, label: {
                        //Image(systemName: "checkmark.circle")
                        Text("Tone")
                    })
            }

        }.navigationTitle(pickerViewType.navigationTitle)
            .toolbar {
            if pickerViewType == .work {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        // To do
                    }, label: {
                            Image(systemName: "checkmark.circle")
                        })
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
        }
    }
}

#Preview("Work") {
    TimerPickerStepView(navPath: .constant(["RoundsStepView", "TimerPickerStepViewWork"]), pickerViewType: .work)
}

#Preview("Rest") {
    TimerPickerStepView(navPath: .constant([]), pickerViewType: .rest)
}
