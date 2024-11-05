//
//  RoundTimerApp.swift
//  RoundTimer Watch App
//
//  Created by Javier Calartrava on 17/1/24.
//

import SwiftUI

@main
struct RoundTimerWatchAppApp: App {
    @Environment(\.scenePhase) private var scenePhase
    var body: some Scene {
        WindowGroup {
            TimersSelectionView()
         //   ActiveTimerView()
//            CountdownView(onComplete: {
//                print("todo")
//            })
           // VibrationView()
        }
        .backgroundTask(.appRefresh("My_App_Updates")) { context in
            print("todo")
        }
        .onChange(of: scenePhase) {
          print("onChange: \($0)")
        }
    }
}
