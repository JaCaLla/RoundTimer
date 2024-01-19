//
//  NewRoundTimerView.swift
//  RoundTimer Watch App
//
//  Created by Javier Calartrava on 17/1/24.
//

import SwiftUI

struct NewRoundTimerView: View {
    @Environment(\.dismiss) var dismiss
    @State private var navPath: [String] = []
    var body: some View {
        NavigationStack(path: $navPath) {
            VStack {
                VStack {
                    Text("Round timer view")
                    NavigationLink(value: "RoundsStepView") {
                        Text("Next >")
                    }
                    
                }
            }
            .navigationTitle("Timers")
            .navigationDestination(for: String.self) { pathValue in
                if pathValue == "RoundsStepView" {
                    RoundsStepView(navPath: $navPath)
                } else if pathValue == "TimerPickerStepViewWork" {
                    TimerPickerStepView(navPath: $navPath, pickerViewType: .work)
                } else if pathValue == "TimerPickerStepViewRest" {
                    TimerPickerStepView(navPath: $navPath, pickerViewType: .rest)
                }
            }
        }
        .onChange(of: navPath) { oldValue, newValue in
            if !oldValue.isEmpty && newValue.isEmpty {
                dismiss()
            }
        }
    }
}

#Preview {
    NewRoundTimerView()
}

