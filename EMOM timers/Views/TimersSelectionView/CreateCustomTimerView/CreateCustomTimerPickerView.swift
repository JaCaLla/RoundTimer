//
//  CreateCustomTimerPickerView.swift
//  EMOM timers
//
//  Created by Javier Calartrava on 23/6/24.
//

import SwiftUI

struct CreateCustomTimerPickerView: View {
    let title: String
    let color: Color
    let min: Int
    let max: Int
    let format: String
    @Binding private var value: Int
    init(title: String, color: Color, min: Int = 0, max: Int = 60, format: String = "%0.2d", value: Binding<Int>) {
        self.title = title
        self.color = color
        self.min = min
        self.max = max
        self.format = format
        self._value = value
    }
    var body: some View {
        VStack(spacing: 0) {
            Text(title)
            Picker(title, selection: $value) { ForEach(min..<max) {
                Text("\(String(format: format, $0))")
                    .foregroundColor(color)
                    .font(.pickerSelectionFont)
            }
            }
            
        }                    .foregroundColor(color)
            .font(.pickerSelectionFont)

    }
}
