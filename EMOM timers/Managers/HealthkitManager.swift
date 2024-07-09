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
   private var healthStore: HKHealthStore?

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

            let configuration = HKWorkoutConfiguration()
            configuration.activityType = .running
            configuration.locationType = .outdoor
            
            healthStore?.startWatchApp(with: configuration, completion: { result, error in
                completion(error==nil)

            })
    }
    
    func startWorkoutSession() async -> Bool {

            let configuration = HKWorkoutConfiguration()
            configuration.activityType = .running
            configuration.locationType = .outdoor
            
        return await withCheckedContinuation { continuation in
            healthStore?.startWatchApp(with: configuration, completion: { result, error in
                continuation.resume(returning: error == nil)
                //return error == nil
            })
        }
    }
}
