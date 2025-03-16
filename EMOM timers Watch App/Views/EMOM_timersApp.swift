//
//  EMOM_timersApp.swift
//  EMOM timers Watch App
//
//  Created by Javier Calartrava on 10/4/24.
//
import HealthKit
import SwiftUI
import AVFoundation

@main
struct EMOMTimersWatchApp: App {
    var body: some Scene {
        WindowGroup {
            #if false
            VibrationView()
            #endif
           TimersSelectionView()
        }
        .backgroundTask(.appRefresh("My_App_Updates")) { context in
            print("todo")
        }
    }
}


//class AppDelegate: NSObject, WKApplicationDelegate {
//
//    func handle(_ workoutConfiguration: HKWorkoutConfiguration) {
//        Task {
//            await HealthkitManager.shared.startWorkout()
//         //   logger.debug("Successfully started workout")
//        }
//    }
//}
