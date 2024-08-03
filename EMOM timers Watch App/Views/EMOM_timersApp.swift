//
//  EMOM_timersApp.swift
//  EMOM timers Watch App
//
//  Created by Javier Calartrava on 10/4/24.
//
import HealthKit
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
            LocalLogger.log("EMOM_timers_Watch_AppApp.onChange: \($0)")
        }
    }
}


class AppDelegate: NSObject, WKApplicationDelegate {


    func handle(_ workoutConfiguration: HKWorkoutConfiguration) {
        Task {
            await HealthkitManager2.shared.startWorkout()
         //   logger.debug("Successfully started workout")
        }
    }
}

//extension HealthkitManager {
//    func startWorkout() async {
//
//
//        let configuration = HKWorkoutConfiguration()
//        configuration.activityType = .running
//        configuration.locationType = .outdoor
//
//        guard let store = healthStore else { return }
//
//        let session: HKWorkoutSession
//        do {
//            session = try HKWorkoutSession(healthStore: store,
//                                           configuration: configuration)
//        } catch {
//            // Handle failure here.
//            fatalError("*** An error occurred: \(error.localizedDescription) ***")
//        }
//
//
//        let builder = session.associatedWorkoutBuilder()
//
//
//        let source = HKLiveWorkoutDataSource(healthStore: store,
//                                             workoutConfiguration: configuration)
//
//
//        source.enableCollection(for: HKQuantityType(.stepCount), predicate: nil)
//        builder.dataSource = source
//
//
//        session.delegate = self
//        builder.delegate = self
//
//
//        self.session = session
//        self.builder = builder
//
//
//        let start = Date()
//
//
//        // Start the mirrored session on the companion iPhone.
//        do {
//            try await session.startMirroringToCompanionDevice()
//        }
//        catch {
//            fatalError("*** Unable to start the mirrored workout: \(error.localizedDescription) ***")
//        }
//
//
//        // Start the workout session.
//        session.startActivity(with: start)
//
//
//        do {
//            try await builder.beginCollection(at: start)
//        } catch {
//            // Handle the error here.
//            fatalError("*** An error occurred while starting the workout: \(error.localizedDescription) ***")
//        }
//
//
// //       logger.debug("*** Workout Session Started ***")
//    }
//}
