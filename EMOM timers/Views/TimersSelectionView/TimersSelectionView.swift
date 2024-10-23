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
    var body: some View {
        List {
            TimerSelectionView(systemName: "timer",
                title: "title_emom_timer",
                subtitle: "subtitle_emom_timer") {
                if wcSessionIsSuppported {
                    Task {
                        let result = await HealthkitManager.shared.startWorkoutSession()
                        await MainActor.run {
                            LocalLogger.log("HealthkitManager.shared.startWorkoutSession:\(result ? "✅" : "❌")")
                            foregroundColor = result ? .green : .red
                            isConnectedAW = result
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
        }.task {
            _ = HealthkitManager.shared
        }
        .onAppear(perform: {
            Task {
                _ = await HealthkitManager.shared.authorizeHealthKit()
                wcSessionIsSuppported = checkIfiPhoneIsConnectedToAppleWatch()
            }
        })
    }
    
    func checkIfiPhoneIsConnectedToAppleWatch() -> Bool {
        // Check if the current device supports WatchConnectivity
//        do{
            if WCSession.isSupported() {
                let session = WCSession.default
                
                // Start the session
                session.activate()
                
                // Check if the iPhone is paired with an Apple Watch
                if session.isPaired {
                    // Check if the Apple Watch is reachable
                    if session.isWatchAppInstalled {
                        return session.isReachable
                    }
                }
            }
            return false
//        } catch {
//            return false
//        }
    }
}

//struct TimersSelectionButtonView: View {
//    var systemName: String
//    var text: String
//    var body: some View {
//        HStack {
//            Image(systemName: systemName)
//                .resizable()
//                .foregroundColor(.electricBlue)
//                .frame(width: 20.0, height: 20.0)
//            Text(text)
//        }
//    }
//}

#Preview {
    @Previewable @State var customTimer: CustomTimer? = nil
    return TimersSelectionView(customTimer: $customTimer)
}
