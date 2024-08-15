////
////  HealthkitManager.swift
////  EMOM timers Watch App
////
////  Created by Javier Calartrava on 20/5/24.
////
//
//import Foundation
//import HealthKit
//
//final class HealthkitManagerAW: NSObject {
//  // 2
//  static let shared = HealthkitManagerAW()
//
//  // 3
//   var healthStore: HKHealthStore?
//    var session: HKWorkoutSession?
//    var builder: HKLiveWorkoutBuilder?
//    
//  // 4
//    private override init() {
//    // 5
//        
//    guard HKHealthStore.isHealthDataAvailable() else {
//      return
//    }
//
//    healthStore = HKHealthStore()
//  }
//    
//    func authorizeHealthKit() {
//        let typesToRead: Set = [
//            HKObjectType.quantityType(forIdentifier: .heartRate)!,
//            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
//        ]
//
//        healthStore?.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
//            if !success {
//                // Handle error
//                if let error = error {
//                    print("Error authorizing HealthKit: \(error.localizedDescription)")
//                }
//            }
//        }
//    }
//}
//
//extension HealthkitManagerAW: HKWorkoutSessionDelegate {
//    /**
//     @method        workoutSession:didChangeToState:fromState:date:
//     @abstract      This method is called when a workout session transitions to a new state.
//     @discussion    The date is provided to indicate when the state change actually happened.  If your application is
//                    suspended then the delegate will receive this call once the application resumes, which may be much later
//                    than when the original state change ocurred.
//     */
//    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
//        print("To Do")
//    }
//
//    
//    /**
//     @method        workoutSession:didFailWithError:
//     @abstract      This method is called when an error occurs that stops a workout session.
//     @discussion    When the state of the workout session changes due to an error occurring, this method is always called
//                    before workoutSession:didChangeToState:fromState:date:.
//     */
//    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: any Error) {
//        print("To Do")
//    }
//}
//
//extension HealthkitManagerAW: HKLiveWorkoutBuilderDelegate {
//    
//    /**
//     @method        workoutBuilder:didCollectDataOfTypes:
//     @abstract      Called every time new samples are added to the workout builder.
//     @discussion    With new samples added, statistics for the collectedTypes may have changed and should be read again
//     
//     @param         workoutBuilder    The workout builder to which samples were added.
//     @param         collectedTypes    The sample types that were added.
//     */
//    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
//        print("To Do")
//    }
//
//    
//    /**
//     @method        workoutBuilderDidCollectEvent:
//     @abstract      Called every time a new event is added to the workout builder.
//     
//     @param         workoutBuilder    The workout builder to which an event was added.
//     */
//    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
//        print("To Do")
//    }
//}
