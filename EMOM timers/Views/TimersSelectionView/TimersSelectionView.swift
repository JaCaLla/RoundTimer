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
    @State var isConnectedAW = false
    var body: some View {
            List {
                TimerSelectionView(systemName: "timer",
                    title: "title_emom_timer",
                    subtitle: "subtitle_emom_timer") {
                    Task {
                        let result = await HealthkitManager.shared.startWorkoutSession()
                        await MainActor.run {
                            LocalLogger.log("HealthkitManager.shared.startWorkoutSession:\(result ? "✅" : "❌")")
                            foregroundColor = result ? .green : .red
                            isConnectedAW = result
                            if result {
                                isPresentedCreateCustomTimerView.toggle()
                            }
                            }
                    }
//                                        HealthkitManager.shared.startWorkoutSession(completion: { result in
//                                            LocalLogger.log("HealthkitManager.shared.startWorkoutSession:\(result ? "✅" : "❌")")
//                                            foregroundColor = result ? .green : .red
//                                            isConnectedAW = result
//                                            if result {
//                                                isPresentedCreateCustomTimerView.toggle()
//                                            }
//                                        })

                }
            }.fullScreenCover(isPresented: $isPresentedCreateCustomTimerView) {
                CreateCustomTimerView(customTimer: $customTimer,
                                      isConnectedAW: $isConnectedAW)
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
