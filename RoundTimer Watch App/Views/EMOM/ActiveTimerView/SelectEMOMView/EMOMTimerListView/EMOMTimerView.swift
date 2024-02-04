//
//  EMOMTimerView.swift
//  RoundTimer Watch App
//
//  Created by Javier Calartrava on 20/1/24.
//

import SwiftUI

struct EMOMTimerView: View {
    var emom: Emom
    var body: some View {
        VStack {
            HStack(spacing: 0) {
                Image(systemName: "figure.run")
                Text(emom.timeHHMMSS())
                    .fontWidth(.condensed)
            }
            Gauge(value: 0.75) {
                Text("\(emom.rounds)")
            }
            .gaugeStyle(.accessoryCircularCapacity)
            HStack(spacing: 0) {
                Image(systemName: "figure.rolling")
                Text(emom.timeHHMMSS(isWork: false))
                    .fontWidth(.condensed)
            }
        }
        .frame(width: 100)
    }
}


#Preview {
    EMOMTimerView(emom: .sample16rounds50Work10Rest)
}
