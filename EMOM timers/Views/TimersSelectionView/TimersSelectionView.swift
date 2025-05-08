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
    @EnvironmentObject var viewModel: CreateCustomTimerViewModel
    
    @State var isPresentedCreateCustomTimerView: Bool = false
    @State var foregroundColor: Color = .blue
    @State var isConnectedAW = false
    
    let columns = [
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack {
            Spacer()
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(TimerType.allCases, content: timerSelectionCellView)
                }
            Spacer()
        }
        .padding(.horizontal, 20)
        .fullScreenCover(isPresented: $isPresentedCreateCustomTimerView) {
            CreateCustomTimerView(timerType: viewModel.timerType,
                                  customTimer: $customTimer)
        }
    }
    
    private func timerSelectionCellView(_ type: TimerType) -> some View {
            TimerSelectionView(
                title: type == .emom ? "title_emom_timer" : "title_up_timer",
                subtitle: type == .emom ? "subtitle_emom_timer" : "subtitle_up_timer",
                action: {
                    viewModel.timerType = type
                    isPresentedCreateCustomTimerView.toggle()
                }
            )
        }
}
#Preview {
    @Previewable @State var customTimer: CustomTimer? = nil
    return TimersSelectionView(customTimer: $customTimer)
}
