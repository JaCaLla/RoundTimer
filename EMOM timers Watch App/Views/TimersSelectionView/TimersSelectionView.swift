//
//  TimersSelectionView.swift
//  RoundTimer Watch App
//
//  Created by Javier Calartrava on 14/3/24.
//

import SwiftUI
import HealthKit

struct TimerSelectionItem {
    let systemName: String
    let text: String
}

struct TimersSelectionView: View {
    @State private var startCreateTimerFlow = false
    @State var customTimer: CustomTimer?
    @StateObject var selectEMOMViewModel: CreateCustomTimerViewModel = CreateCustomTimerViewModel()
    private let healthStore = HKHealthStore()

    // State variable to hold the heart rate
    @State private var heartRate: Double = 0
    var body: some View {
        VStack(spacing: 0) {
            Text("\(Int(heartRate)) BPM")
                .font(.title)
                .padding()
            if let customTimer = customTimer {
                switch customTimer.timerType {
                case .emom:
                    EMOMView(customTimer: $customTimer)
                case .upTimer:
                    UpTimerView(customTimer: $customTimer)
                }
            } else {
                VStack {
                    Button(action: {
                        selectEMOMViewModel.setTimertype(type: .emom)
                        startCreateTimerFlow.toggle()
                    }, label: {
                        TimersSelectionButtonView(systemName: "timer", text: "EMOM timer")
//                            HStack {
//                                Image(systemName: "timer")
//                                    .resizable()
//                                    .foregroundColor(.electricBlue)
//                                    .frame(width: 20.0, height: 20.0)
//                                Text("EMOM timer")
//                            }
                        })
                    Button(action: {
                        selectEMOMViewModel.setTimertype(type: .upTimer)
                        startCreateTimerFlow.toggle()
                    }, label: {
                        TimersSelectionButtonView(systemName: "timer", text: "Up timer")
//                            HStack {
//                                Image(systemName: "timer")
//                                    .resizable()
//                                    .foregroundColor(.electricBlue)
//                                    .frame(width: 20.0, height: 20.0)
//                                Text()
//                            }
                        })
                    SendMessageView()
                }
                    .fullScreenCover(isPresented: $startCreateTimerFlow) {
                    CreateCustomTimerView(customTimer: $customTimer)
                        .environmentObject(selectEMOMViewModel)
                }
            }
        }.onAppear {
            // Request authorization
            authorizeHealthKit()

            // Fetch heart rate data
            fetchHeartRateData()
        }
    }

    // Request HealthKit authorization
    private func authorizeHealthKit() {
        let typesToRead: Set = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!
        ]

        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            if !success {
                // Handle error
                if let error = error {
                    print("Error authorizing HealthKit: \(error.localizedDescription)")
                }
            }
        }
    }

    // Fetch heart rate data
    private func fetchHeartRateData() {
        // Define the type of data to fetch
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            print("Heart rate type not available")
            return
        }

        // Define the query
        let query = HKObserverQuery(sampleType: heartRateType, predicate: nil) { query, completionHandler, error in
            if let error = error {
                print("Error fetching heart rate data: \(error.localizedDescription)")
                return
            }

            // Fetch the most recent heart rate sample
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
            let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { query, samples, error in
                if let error = error {
                    print("Error fetching heart rate data: \(error.localizedDescription)")
                    return
                }

                guard let sample = samples?.first as? HKQuantitySample else {
                    print("No heart rate data available")
                    return
                }

                // Update the UI on the main thread
                DispatchQueue.main.async {
                    self.heartRate = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
                }
            }

            self.healthStore.execute(query)
        }

        healthStore.execute(query)
    }
}

struct TimersSelectionButtonView: View {
    var systemName: String
    var text: String
    var body: some View {
        HStack {
            Image(systemName: systemName)
                .resizable()
                .foregroundColor(.electricBlue)
                .frame(width: 20.0, height: 20.0)
            Text(text)
        }
    }
}

#Preview {
    TimersSelectionView()
}
