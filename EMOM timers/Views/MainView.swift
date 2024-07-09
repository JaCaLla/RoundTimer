//
//  MainView.swift
//  EMOM timers
//
//  Created by Javier Calartrava on 15/5/24.
//

import SwiftUI
import os.log
struct MainView: View {
    @State var customTimer: CustomTimer?
    @StateObject private var timerStore = TimerStore.shared
    var body: some View {
        ZStack {
            if customTimer != nil {
                EMOMView(customTimer: $customTimer)
                    .forceRotation(orientation: .landscape)
                    
            } else {
//                TabView {
                    TimersSelectionView(customTimer: $customTimer)
                        .tabItem {
                            Text("Timers")
                        }
//                    HelpView()
//                        .tabItem {
//                            Text("Help")
//                        }
//                }
            }
        }.onChange(of: customTimer) {
            if let customTimer {
                LocalLogger.log("MainView.onChange:\(customTimer.description)")
                timerStore.startTimerOnAW(customTimer: customTimer)
                //let customTimerTmp = customTimer
                //self.customTimer = nil
//                timerStore.ping {
//                    HealthkitManager.shared.startWorkoutSession(completion: { result in
//                        LocalLogger.log("MainView.onChange:\(customTimer.description)")
//                        LocalLogger.log("HealthkitManager.shared.startWorkoutSession(completion:\(result)")
//                        guard result else { return }
//                        timerStore.startTimerOnAW(customTimer: customTimer)
//                        self.customTimer = customTimer
//                    })
//                }
            } else {
                timerStore.removeTimerOnAW()
            }
            
        }
        .forceRotation(orientation: .landscape)
    }
}

#Preview {
    MainView()
}
