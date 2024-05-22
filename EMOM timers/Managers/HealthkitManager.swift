//
//  HealthkitManager.swift
//  EMOM timers
//
//  Created by Javier Calartrava on 19/5/24.
//

import Foundation
import HealthKit

final class HealthkitManager {
  // 2
  static let shared = HealthkitManager()

  // 3
   var healthStore: HKHealthStore?

  // 4
  private init() {
    // 5
    guard HKHealthStore.isHealthDataAvailable() else {
      return
    }

    healthStore = HKHealthStore()
  }
    
    func authorizeHealthKit() {
        let typesToRead: Set = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        ]

        healthStore?.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            if !success {
                // Handle error
                if let error = error {
                    print("Error authorizing HealthKit: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func startWorkoutSession(completion: @escaping (Bool) -> Void) {
        let semaphore = DispatchSemaphore(value: 0)

    //    Task {
            let configuration = HKWorkoutConfiguration()
            configuration.activityType = .running
            configuration.locationType = .outdoor

//            do {
//               try await healthStore?.startWatchApp(toHandle: configuration)
//            }
//            catch {
//                // Handle the error here.
//                fatalError("*** An error occurred while starting a workout on Apple Watch: \(error.localizedDescription) ***")
//            }
            
            healthStore?.startWatchApp(with: configuration, completion: { result, error in
                completion(error==nil)
//                if let error {
//                    fatalError("*** An error occurred while starting a workout on Apple Watch: \(error.localizedDescription) ***")
//                } else {
//                    print("*** Workout Session Started ***")
//                }
            })


           
     //       semaphore.signal()
   //     }

    //    semaphore.wait()
        
        
    }
}
