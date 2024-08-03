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

enum TimersSelectionFlow {
    case settings
    case timerCreation
}

struct TimersSelectionView: View {
    @State private var isPresented = false
    @State private var isPresentedSettings = false
    @State private var isSettings: Bool = false
    
    @State private var startSettingsFlow = false
    @State var customTimer: CustomTimer?
    @State private var navPath: [String] = []
    @State private var mirroredTimer: MirroredTimer?
    @StateObject var viewModel: CreateCustomTimerViewModel = CreateCustomTimerViewModel()
    @StateObject private var timerStore = TimerStore.shared
    @State var closedFromCompation = false
    
    @StateObject private var healthkitManager = HealthkitManager2.shared
    var body: some View {
        VStack(spacing: 0) {
            if let customTimer {
                switch customTimer.timerType {
                case .emom:
                    EMOMView(customTimer: $customTimer, closedFromCompation: $isPresented)
                case .upTimer:
                    UpTimerView(customTimer: $customTimer)
                default:
                    EmptyView()
                }
            } else if let mirroredTimer {
                MirroredTimerView(mirroredTimer: $mirroredTimer, closedFromCompation: $isPresented)
            } else {
                List {
                    TimerSelectionView(action: {
                        viewModel.setTimertype(type: .emom)
                        isSettings = false
                        isPresented.toggle()
                        
                    }, label: {
                        TimersSelectionButtonView(systemName: "timer", text: "EMOM timer")
                    })
                    Button(action: {
                        viewModel.setTimertype(type: .upTimer)
                        isSettings = false
                        isPresented.toggle()
                    }, label: {
                        TimersSelectionButtonView(systemName: "timer", text: "Up timer")
                    })
                    Button(action: {
                        isSettings = true
                        isPresentedSettings.toggle()
                    }, label: {
                        TimersSelectionButtonView(systemName: "gear", text: "Settings")
                    })
                    .fullScreenCover(isPresented: $isPresentedSettings) {
                        AgeStepView(navPath: $navPath)
                    }
                }
                .fullScreenCover(isPresented: $isPresented) {
//                    if isSettings ||
//                        AppGroupStore.shared.getDate(forKey: .birthDate) == nil {
//                        AgeStepView(navPath: $navPath, context: .settings)
//                    } else {
                        CreateCustomTimerView(customTimer: $customTimer)
                            .environmentObject(viewModel)
//                    }
                }
            }
        }
        .onAppear() {
            guard  AppGroupStore.shared.getDate(forKey: .birthDate) == nil else { return }
            isPresentedSettings.toggle()
        }
//        .onAppear {
//            Task {
//                if await healthkitManager.authorizeHealthKit() {
//                    await MainActor.run {
//                        guard AppGroupStore.shared.getDate(forKey: .birthDate) == nil else { return }
//                        isPresented.toggle()
//                    }
//                }
//            }
//        }
        .onChange(of: timerStore.mirroredTimer) {
            guard let mirroredTimer = timerStore.mirroredTimer else { return }
            LocalLogger.log("TimerSelectionView.onChange \(mirroredTimer)")
            if mirroredTimer.mirroredTimerType == .removedFromCompanion {
                self.mirroredTimer = nil
            } else {
                self.mirroredTimer = timerStore.mirroredTimer
            }
        }
        .onChange(of: timerStore.customTimer) {
            LocalLogger.log("TimerSelectionView.onChange \(timerStore.customTimer?.description ?? "") closedFromCompation: \(timerStore.customTimer != nil)")
            self.customTimer = timerStore.customTimer
            closedFromCompation = self.customTimer == nil
            LocalLogger.log("TimerSelectionView.onChange closedFromCompation: \(self.customTimer != nil)")
        }
        .onChange(of: self.customTimer) {
            if customTimer == nil {
                Connectivity.shared.removeTimer()
            }
        }
    }
    
    @ViewBuilder func fullScreenCover(isSettings: Bool) -> some View {
        if isSettings {
            AgeStepView(navPath: $navPath)
        } else {
            CreateCustomTimerView(customTimer: $customTimer)
                .environmentObject(viewModel)
        }
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
