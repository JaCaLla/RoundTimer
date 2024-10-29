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
struct EMOM_timers_Watch_AppApp: App {
    var body: some Scene {
        WindowGroup {
         //   VibrationView()
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
