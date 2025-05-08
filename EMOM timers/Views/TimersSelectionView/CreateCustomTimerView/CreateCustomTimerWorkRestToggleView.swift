//
//  CreateCustomTimerWorkRestToggleView.swift
//  EMOM timers
//
//  Created by JAVIER CALATRAVA LLAVERIA on 5/5/25.
//

import SwiftUI

struct CreateCustomTimerWorkRestToggleView: View {
    @Binding var isRestOn: Bool
    var body: some View {
        HStack {
            Spacer()
            Text(isRestOn ? String(localized: "title_rest") : String(localized: "title_work"))
            Toggle("", isOn: $isRestOn)
                .toggleStyle(SwitchToggleStyle(tint: isRestOn ? .timerRestStartedColor : .timerStartedColor))
                .frame(width: 100)
        }.foregroundColor(isRestOn ? .timerRestStartedColor : .timerStartedColor)
            .font(.pickerSelectionFont)
    }
}
