//
//  TimerSelectionView.swift
//  EMOM timers
//
//  Created by Javier Calartrava on 15/5/24.
//

import SwiftUI
import HealthKit
import WatchConnectivity
import os.log

struct TimersSelectionView: View {
    @Binding var customTimer: CustomTimer?
    @State var isPresentedCreateCustomTimerView: Bool = false
    @State var foregroundColor: Color = .blue
    @State var isConnectedAW = false
    @State var wcSessionIsSuppported = false
    @EnvironmentObject var viewModel: CreateCustomTimerViewModel
    //@StateObject var viewModel = CreateCustomTimerViewModel()
    var body: some View {
        List {
            TimerSelectionView(systemName: "timer",
                title: "title_emom_timer",
                subtitle: "subtitle_emom_timer") {
                if wcSessionIsSuppported {
                    Task {
//                        let result = await HealthkitManager.shared.startWorkoutSession()
                        await MainActor.run {
//                            LocalLogger.log("HealthkitManager.shared.startWorkoutSession:\(result ? "✅" : "❌")")
//                            foregroundColor = result ? .green : .red
//                            isConnectedAW = result
                            isPresentedCreateCustomTimerView.toggle()
                        }
                    }
                } else {
                    isConnectedAW = false
                    isPresentedCreateCustomTimerView.toggle()
                }
  
            }
        }.fullScreenCover(isPresented: $isPresentedCreateCustomTimerView) {
            CreateCustomTimerView(customTimer: $customTimer,
                isConnectedAW: $isConnectedAW)
            //.environmentObject(viewModel)
        }
        .onAppear(perform: {
//            Task {
//                _ = await HealthkitManager.shared.authorizeHealthKit()
//                wcSessionIsSuppported = checkIfiPhoneIsConnectedToAppleWatch()
//            }
        })
    }
    
    func checkIfiPhoneIsConnectedToAppleWatch() -> Bool {
            if WCSession.isSupported() {
                let session = WCSession.default
                session.activate()
                if session.isPaired {
                    if session.isWatchAppInstalled {
                        return session.isReachable
                    }
                }
            }
            return false

    }
}
#Preview {
    @Previewable @State var customTimer: CustomTimer? = nil
    return TimersSelectionView(customTimer: $customTimer)
}
