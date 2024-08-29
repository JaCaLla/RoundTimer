//
//  RoundsStepViewR.swift
//  EMOM timers Watch App
//
//  Created by Javier Calartrava on 20/7/24.
//

import SwiftUI

//enum AgeStepViewContext {
//    case timerCreation
//    case settings
//}

struct AgeStepView: View {
    
    @Binding var navPath: [String]
    
    @State private var selectedDate = Date.now
    // LOOK OUT! This is necessary because date picker is not initialized with the stored value
    @State private var isVisible = false
    
    @StateObject var viewModel: AgeStepViewModel = AgeStepViewModel()
    @StateObject private var healthkitManager = HealthkitManager.shared
    
    var body: some View {
        ScrollView {
            VStack {
                if healthkitManager.grantedPermissionForHeartRate {
                    if isVisible {
                        DatePicker(
                            String(localized: "setup_age_select_date"),
                            selection: $selectedDate,
                            in: viewModel.minimumDate...Date.now,
                            displayedComponents: [.date]
                        )
                        .frame(height: 60)
                        .datePickerStyle(WheelDatePickerStyle())
                    }
                    Text(String(localized: "\(viewModel.calculateAge(from: selectedDate)) years old"))
                    Divider()
                    Text(Image(systemName: "info.bubble")) + Text(" ") + Text(String(localized:"setup_age_info"))
                    Spacer()
                } else {
                    Text(Image(systemName: "heart.slash")) + Text(" ") + Text(String(localized:"setup_age_not_authorized"))
                    Divider()
                }
            }
            .navigationTitle(String(localized: "setup_age_title"))
            .onAppear {
              //  fousedfield = true
                selectedDate =  viewModel.getBirthDate()
                isVisible = true
                Task {
                    _ = await healthkitManager.authorizeHealthKit()
                }
            }
            .onDisappear() {
                viewModel.setBirthDate(date: selectedDate)
            }
        }
        
    }
}
