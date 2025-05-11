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
            #else
            TimersSelectionView()
            #endif
           
        }
    }
}
