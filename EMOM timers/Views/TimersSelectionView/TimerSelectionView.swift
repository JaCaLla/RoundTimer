//
//  TimerSelectionView.swift
//  EMOM timers
//
//  Created by Javier Calartrava on 15/5/24.
//

import SwiftUI
import HealthKit
import os.log

struct TimersSelectionView: View {
    @Binding var customTimer: CustomTimer? 
    @State var isPresentedCreateCustomTimerView: Bool = false
    @State var foregroundColor: Color = .blue
    var body: some View {
            VStack {
                Button(action: {
                    HealthkitManager.shared.startWorkoutSession(completion: { result in
                        LocalLogger.log("HealthkitManager.shared.startWorkoutSession:\(result ? "✅" : "❌")")
                        foregroundColor = result ? .green : .red
                        if result {
                            isPresentedCreateCustomTimerView.toggle()
                        }
                    })
                }, label: {
                    TimersSelectionButtonView(systemName: "timer", text: "EMOM timer")
                    })
                Spacer()
                Button(action: {
                    foregroundColor = .white
                    HealthkitManager.shared.startWorkoutSession(completion: {
                        foregroundColor = $0 ? .green : .red
                    })
                }, label: {
                    Text("Start workout session")
                        .foregroundStyle(foregroundColor)
                    })
            }.fullScreenCover(isPresented: $isPresentedCreateCustomTimerView) {
                CreateCustomTimerView(customTimer: $customTimer)
            }.task {
                _ = HealthkitManager.shared
              }
            .onAppear(perform: {
                HealthkitManager.shared.authorizeHealthKit()
            })
    }
}

struct TimersSelectionButtonView: View {
    var systemName: String
    var text: String
    var body: some View {
        HStack {
            Image(systemName: systemName)
                .resizable()
                .foregroundColor(.electricBlue)
                .frame(width: 20.0, height: 20.0)
            Text(text)
        }
    }
}

#Preview {
    @State var customTimer: CustomTimer? = nil
    return TimersSelectionView(customTimer: $customTimer)
}
