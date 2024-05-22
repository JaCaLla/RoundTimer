//
//  TimerSelectionView.swift
//  EMOM timers
//
//  Created by Javier Calartrava on 15/5/24.
//

import SwiftUI
import HealthKit

struct TimersSelectionView: View {
    @Binding var customTimer: CustomTimer? 
    @State var startCreateTimerFlow: Bool = false
    @State var foregroundColor: Color = .blue
    var body: some View {
//        if let customTimer {
//            EMOMView(customTimer: $customTimer)
//        } else {
            VStack {
                Button(action: {
    //                selectEMOMViewModel.setTimertype(type: .emom)
                    startCreateTimerFlow.toggle()
                }, label: {
                    TimersSelectionButtonView(systemName: "timer", text: "EMOM timer")
                    })
                Button(action: {
    //                selectEMOMViewModel.setTimertype(type: .emom)
                    startCreateTimerFlow.toggle()
                }, label: {
                    TimersSelectionButtonView(systemName: "timer", text: "UP timer")
                    })
                Button(action: {
                    foregroundColor = .white
                    HealthkitManager.shared.startWorkoutSession(completion: {
                        foregroundColor = $0 ? .green : .red
                    })
                }, label: {
                    Text("Start workout session")
                        .foregroundStyle(foregroundColor)
                    })
            }.fullScreenCover(isPresented: $startCreateTimerFlow) {
                CreateCustomTimerView(customTimer: $customTimer)
            }.task {
                _ = HealthkitManager.shared
              }
            .onAppear(perform: {
                HealthkitManager.shared.authorizeHealthKit()
            })
      //  }
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
    @State var customTimer: CustomTimer? = nil
    return TimersSelectionView(customTimer: $customTimer)
}
