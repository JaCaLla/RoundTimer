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
    @Environment(\.isLuminanceReduced) var isLuminanceReduced
    @State private var isPresented = false
    @State private var isPresentedSettings = false
    @State private var isSettings: Bool = false

    @State private var startSettingsFlow = false
    @State var customTimer: CustomTimer?
    @State private var navPath: [String] = []
    @StateObject var viewModel: CreateCustomTimerViewModel = CreateCustomTimerViewModel()
    @StateObject private var timerStore = TimerStore.shared
    
    let columns = [
        GridItem(.flexible())
    ]

    var body: some View {
        VStack(spacing: 0) {
            if let customTimer {
                switch customTimer.timerType {
                case .emom:
                    EMOMView(customTimer: $customTimer, viewModel: EMOMViewModel())
                case .upTimer:
                    EMOMView(customTimer: $customTimer, viewModel: UpTimerViewModel())
                }
            } else {
                ScrollView {
                    Spacer()
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(TimerType.allCases, content: timerSelectionCellView)
                        }
                    Spacer()
                }
                    .fullScreenCover(isPresented: $isPresented) {
                    CreateCustomTimerView(customTimer: $customTimer)
                        .environmentObject(viewModel)
                }
            }
        }
        .opacity(isLuminanceReduced ? AppUIConstants.opacityWhenLuminanceReduced : 1.0)
        .onAppear() {
            Task {
                guard await AppGroupStore.shared.getDate(forKey: .birthDate) == nil else { return }
                isPresentedSettings.toggle()
            }
        }
        .onChange(of: timerStore.customTimer) {
            LocalLogger.log("TimerSelectionView.onChange \(timerStore.customTimer?.description ?? "")")
            self.customTimer = timerStore.customTimer
        }
        .onChange(of: self.customTimer) {
            if customTimer == nil {
                Connectivity.shared.removeTimer()
            }
        }
    }
    
    private func timerSelectionCellView(_ type: TimerType) -> some View {
            TimerSelectionView(
                title: type == .emom ? "title_emom_timer" : "title_up_timer",
                subtitle: type == .emom ? "subtitle_emom_timer" : "subtitle_up_timer",
                action: {
                    viewModel.setTimertype(type: type)
                                            isSettings = false
                                            isPresented.toggle()
                }
            )
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

#Preview {
    TimersSelectionView()
}
