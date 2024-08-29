//
//  HealthkitManager2.swift
//  EMOM timers
//
//  Created by Javier Calartrava on 15/7/24.
//

import Foundation
import HealthKit

final class HealthkitManager: NSObject, ObservableObject {
    // 2
    static let shared = HealthkitManager()

    var healthStore: HKHealthStore?
    var session: HKWorkoutSession?
    #if os(watchOS)
        var builder: HKLiveWorkoutBuilder?
    #endif

    @Published var heartRate: Double? {
        didSet {
            LocalLogger.log("HealthkitManager2.heartRate.didSet \(heartRate ?? -1.0)")
        }
    }
    
    @Published var grantedPermissionForHeartRate = false {
        didSet {
            LocalLogger.log("HealthkitManager2.grantedPermissionForHeartRate.didSet \(grantedPermissionForHeartRate)")
        }
    }
    
    private override init() {
        guard HKHealthStore.isHealthDataAvailable() else {
            return
        }
        healthStore = HKHealthStore()
    }

    func authorizeHealthKit() async -> Bool {
        let typesToRead: Set = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!
        ]
        LocalLogger.log("HealthkitManager2.authorizeHealthKit")
        return await withCheckedContinuation {[weak self] continuation in
            self?.healthStore?.requestAuthorization(toShare: nil, read: typesToRead) { userWasShownPermissionView, error in
                if (userWasShownPermissionView) {
                    let authorized = (self?.healthStore?.authorizationStatus(for: HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!) == .sharingAuthorized)
                    AppGroupStore.shared.setBool(value: authorized, forKey: .grantedPermissionForHeartRate)
                    self?.grantedPermissionForHeartRate = authorized
                    continuation.resume(returning: authorized)
                } else {
                    LocalLogger.log("User was not shown permission view")
                    if let e = error {
                        print(e)
                    }
                }
            }
        }
    }
    
    func fetchHeartRateData() {
        fetchHealthKitData(forIdentifier: .heartRate) { samples in
                            guard let sample = samples?.first as? HKQuantitySample else {
                                LocalLogger.log(type: .error, "No heart rate data available")
                               // print("No heart rate data available")
                                return
                            }
            
                            // Update the UI on the main thread
                            DispatchQueue.main.async {
                                self.heartRate = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
                                LocalLogger.log("HealthkitManager2.fetchHeartRateData: \(String(describing: self.heartRate)) ")
                            }
        }
    }
    
    // Fetch heart rate data
    private func fetchHealthKitData(forIdentifier: HKQuantityTypeIdentifier, completion: @escaping ([HKSample]?) -> Void) {
        // Define the type of data to fetch
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: forIdentifier) else {
            LocalLogger.log(type: .error, "Heart rate type not available")
           // print("Heart rate type not available")
            return
        }

        // Define the query
        let query = HKObserverQuery(sampleType: heartRateType, predicate: nil) { query, completionHandler, error in
            if let error = error {
                LocalLogger.log(type: .error, "Error fetching heart rate data: \(error.localizedDescription)")
            //    print("Error fetching heart rate data: \(error.localizedDescription)")
                return
            }

            // Fetch the most recent heart rate sample
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
            let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { query, samples, error in
                if let error = error {
                    LocalLogger.log(type: .error, "Error fetching heart rate data: \(error.localizedDescription)")
                  //  print("Error fetching heart rate data: \(error.localizedDescription)")
                    return
                }
                completion(samples)
//                guard let sample = samples?.first as? HKQuantitySample else {
//                    LocalLogger.log(type: .error, "No heart rate data available")
//                   // print("No heart rate data available")
//                    return
//                }
//
//                // Update the UI on the main thread
//                DispatchQueue.main.async {
//                    self.heartRate = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
//                    LocalLogger.log("HealthkitManager2.fetchHeartRateData: \(String(describing: self.heartRate)) ")
//                }
            }

            self.healthStore?.execute(query)
        }

        healthStore?.execute(query)
    }
    
    // MARK :- iOS
#if os(iOS)
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
    
    func authorizeHealthKit() {
        let typesToRead: Set = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
          //  HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
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
#endif
    
    
// MARK :- watchOS
    #if os(watchOS)
        func startWorkout() async {


            let configuration = HKWorkoutConfiguration()
            configuration.activityType = .running
            configuration.locationType = .outdoor

            guard let store = healthStore else { return }

            let session: HKWorkoutSession
            do {
                session = try HKWorkoutSession(healthStore: store,
                    configuration: configuration)
            } catch {
                // Handle failure here.
                fatalError("*** An error occurred: \(error.localizedDescription) ***")
            }


            let builder = session.associatedWorkoutBuilder()


            let source = HKLiveWorkoutDataSource(healthStore: store,
                workoutConfiguration: configuration)


            source.enableCollection(for: HKQuantityType(.stepCount), predicate: nil)
            builder.dataSource = source


            session.delegate = self
            builder.delegate = self


            self.session = session
            self.builder = builder


            let start = Date()


            // Start the mirrored session on the companion iPhone.
            do {
                try await session.startMirroringToCompanionDevice()
            }
            catch {
                fatalError("*** Unable to start the mirrored workout: \(error.localizedDescription) ***")
            }


            // Start the workout session.
            session.startActivity(with: start)


            do {
                try await builder.beginCollection(at: start)
            } catch {
                // Handle the error here.
                fatalError("*** An error occurred while starting the workout: \(error.localizedDescription) ***")
            }


            //       logger.debug("*** Workout Session Started ***")
        }
    #endif
}

extension HealthkitManager: HKWorkoutSessionDelegate {
    /**
     @method        workoutSession:didChangeToState:fromState:date:
     @abstract      This method is called when a workout session transitions to a new state.
     @discussion    The date is provided to indicate when the state change actually happened.  If your application is
                    suspended then the delegate will receive this call once the application resumes, which may be much later
                    than when the original state change ocurred.
     */
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        print("To Do")
    }


    /**
     @method        workoutSession:didFailWithError:
     @abstract      This method is called when an error occurs that stops a workout session.
     @discussion    When the state of the workout session changes due to an error occurring, this method is always called
                    before workoutSession:didChangeToState:fromState:date:.
     */
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: any Error) {
        print("To Do")
    }
}

#if os(watchOS)
    extension HealthkitManager: HKLiveWorkoutBuilderDelegate {

        /**
     @method        workoutBuilder:didCollectDataOfTypes:
     @abstract      Called every time new samples are added to the workout builder.
     @discussion    With new samples added, statistics for the collectedTypes may have changed and should be read again
     
     @param         workoutBuilder    The workout builder to which samples were added.
     @param         collectedTypes    The sample types that were added.
     */
        func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
            print("To Do")
        }


        /**
     @method        workoutBuilderDidCollectEvent:
     @abstract      Called every time a new event is added to the workout builder.
     
     @param         workoutBuilder    The workout builder to which an event was added.
     */
        func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
            print("To Do")
        }
    }
#endif
