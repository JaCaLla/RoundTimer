//
//  HeartZoneView.swift
//  EMOM timers
//
//  Created by Javier Calartrava on 16/7/24.
//

import SwiftUI
import Combine

struct HeartZoneView: View {
    @State var currentZone: Int = 0
    let colorZones: [Color] = [
            .heartRateZone1,
            .heartRateZone2,
            .heartRateZone3,
            .heartRateZone4,
            .heartRateZone5
    ]
    @State var heartRate: Double?//String = ""
    @StateObject private var healthkitManager = HealthkitManager2.shared

    var body: some View {
        VStack(alignment: .leading) {
            if heartRate != nil {
                HStack(spacing: 2) {
                    ForEach(0..<5) { index in
                        Text(zoneText(index, currentZone, heartRate))
                            .font(.heartRateZone)
                            .foregroundColor(.heartRateZoneText)
                            .multilineTextAlignment(.center)
                            .padding(5)
                            .frame(width: frameWidth(index, currentZone), height: 25)
                            .background(Rectangle()
                                .fill(colorZones[index])
                                .opacity(currentZone == index ? 1.0 : 0.2)
                                .cornerRadius(/*@START_MENU_TOKEN@*/3.0/*@END_MENU_TOKEN@*/)
                                .shadow(radius: 5))
                    }
                }
            }
        }.onAppear {
            Task {
                if await healthkitManager.authorizeHealthKit() {
                    healthkitManager.fetchHeartRateData()
                }
            }
        }.onChange(of: healthkitManager.heartRate) {
            self.heartRate = healthkitManager.heartRate
            if let birthDate = AppGroupStore.shared.getDate(forKey: .birthDate) {
                let age = HeartZoneCalculator.calculateAge(from: birthDate)
                self.currentZone = HeartZoneCalculator(age: age).zone(heartRate: heartRate)
            }
        }
    }

    func zoneText(_ index: Int, _ currentZone: Int, _ heartRate: Double?) -> String {
        guard let heartRate,
              index == currentZone else { return "" }
        return String("\(Int(heartRate)) ♥️")
    }

    func frameWidth(_ index: Int, _ currentZone: Int) -> Double {
        index == currentZone ? 80.0 : 20.2
    }
}

#Preview(traits: .fixedLayout(width: 200, height: 50)) {
    HeartZoneView(currentZone: 1)
        .previewDevice("Apple Watch Series 7 - 41mm")
}
