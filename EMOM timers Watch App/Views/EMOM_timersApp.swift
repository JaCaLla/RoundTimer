//
//  EMOM_timersApp.swift
//  EMOM timers Watch App
//
//  Created by Javier Calartrava on 10/4/24.
//

import SwiftUI

@main
struct EMOM_timers_Watch_AppApp: App {
    @Environment(\.scenePhase) private var scenePhase
    var body: some Scene {
        WindowGroup {
            TimersSelectionView()
         //   ActiveTimerView()
//            CountdownView(onComplete: {
//                print("todo")
//            })
        //    VibrationView()
        }
        .backgroundTask(.appRefresh("My_App_Updates")) { context in
            print("todo")
        }
        .onChange(of: scenePhase) {
          print("onChange: \($0)")
        }
    }
}
