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
    var createChronoMirroredInAW: Bool
    @EnvironmentObject var viewModel: CreateCustomTimerViewModel

    var body: some View {
        ZStack {
            if isFetchingAW {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(2.0, anchor: .center)
            }
            Button(action: {
                Task {
                    customTimer = await viewModel.createCustomTimer()
                }
            }) {
                Text(String(localized: "button_continue"))
                    .buttonStyle()
            }
        }
    }
    

    
}

//#Preview(traits: .fixedLayout(width: 300, height: 150)) {
//    let viewModel: CreateCustomTimerViewModel = CreateCustomTimerViewModel()
//   return CreateCustomTimerContinueButton(isFetchingAW: .constant(true), customTimer: .constant(.customTimerDefault))
//        .environmentObject(viewModel)
//}
