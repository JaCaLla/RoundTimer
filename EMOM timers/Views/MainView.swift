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
                    
            } else {
                    TimersSelectionView(customTimer: $customTimer)
            }
        }
        .onChange(of: customTimer) {
            if let customTimer {
                LocalLogger.log("MainView.onChange:\(customTimer.description)")
                timerStore.startTimerOnAW(customTimer: customTimer)
            } else {
                timerStore.removeTimerOnAW()
            }
            
        }
    }
}

#Preview {
    MainView()
}
