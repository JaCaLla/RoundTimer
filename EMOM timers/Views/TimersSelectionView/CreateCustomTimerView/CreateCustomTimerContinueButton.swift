//
//  CreateCustomTimerContinueButton.swift
//  EMOM timers
//
//  Created by Javier Calartrava on 8/7/24.
//

import SwiftUI

struct CreateCustomTimerContinueButton: View {
    @Binding var isFetchingAW: Bool
    @Binding var customTimer: CustomTimer?
    @EnvironmentObject var viewModel: CreateCustomTimerViewModel
    var body: some View {
        ZStack {
            if isFetchingAW {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(2.0, anchor: .center)
            }
            Button(action: {
                isFetchingAW = true
                //TimerStore.shared.ping {
                    HealthkitManager.shared.startWorkoutSession(completion: { result in
                        LocalLogger.log("CreateCustomTimerView2.Button(action:)")
                        isFetchingAW = false
                        customTimer = viewModel.buildCustomTimer()
                    })
                //}
            }) {
                Text(String(localized: "continue"))
                    .modifier(ButtonStyle())
                // .buttonStyle()
            }
        }
    }
}

#Preview(traits: .fixedLayout(width: 300, height: 150)) {
    let viewModel: CreateCustomTimerViewModel = CreateCustomTimerViewModel()
   return CreateCustomTimerContinueButton(isFetchingAW: .constant(true), customTimer: .constant(.customTimerDefault))
        .environmentObject(viewModel)
}
