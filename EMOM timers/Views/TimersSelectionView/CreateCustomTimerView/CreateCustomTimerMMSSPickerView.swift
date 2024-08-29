//
//  CreateCustomTimerMMSSPickerView.swift
//  EMOM timers
//
//  Created by Javier Calartrava on 5/7/24.
//

import SwiftUI

struct CreateCustomTimerMMSSPickerView: View {
    @Binding var selectedMins: Int
    @Binding var selectedSecs: Int
    let isRestOn: Bool
    var body: some View {
        HStack(spacing: 5) {
            CreateCustomTimerPickerView(title: String(localized: "picker_minutes"),
                                        color: color(isRestOn),
                                        value: $selectedMins)
            Text(":")
                .foregroundColor(color(isRestOn))
                .font(.pickerSelectionFont)
            CreateCustomTimerPickerView(title: String(localized: "picker_seconds"),
                                        color: color(isRestOn),
                                        value: $selectedSecs)
        }
    }
    
    private func color(_ isRestOn: Bool) -> Color {
        isRestOn ? .timerRestStartedColor : .timerStartedColor
    }
}

#Preview(traits: .fixedLayout(width: 420, height: 200)) {
    CreateCustomTimerMMSSPickerView(selectedMins: .constant(1),
                                    selectedSecs: .constant(20),
                                    isRestOn: false)
}

#Preview(traits: .fixedLayout(width: 420, height: 200)) {
    CreateCustomTimerMMSSPickerView(selectedMins: .constant(1),
                                    selectedSecs: .constant(20),
                                    isRestOn: true)
}
