//
//  MainView.swift
//  EMOM timers
//
//  Created by Javier Calartrava on 15/5/24.
//

import SwiftUI

struct MainView: View {
    @State private var customTimer: CustomTimer?
    @StateObject private var viewModel = CreateCustomTimerViewModel()
    
    var body: some View {
        ZStack {
            Group {
                if let timer = customTimer {
                    timerView(for: timer)
                } else {
                    TimersSelectionView(customTimer: $customTimer)
                        .environmentObject(viewModel)
                }
            }
        }
    }
    
    @ViewBuilder
    private func timerView(for timer: CustomTimer) -> some View {
        switch timer.timerType {
        case .emom:
            EMOMView(customTimer: $customTimer)
        case .upTimer:
            UpTimerView(customTimer: $customTimer)
        }
    }
}

#Preview {
    MainView()
}
