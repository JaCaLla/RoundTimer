//
//  TimersSelectionView.swift
//  RoundTimer Watch App
//
//  Created by Javier Calartrava on 14/3/24.
//

import SwiftUI

struct TimerSelectionItem {
    let systemName: String
    let text: String
}

struct TimersSelectionView: View {
    @State private var startCreateTimerFlow = false
    @State var customTimer: CustomTimer?
    @StateObject var selectEMOMViewModel: CreateCustomTimerViewModel = CreateCustomTimerViewModel()
    var body: some View {
        VStack(spacing:0) {
            if let customTimer = customTimer{
                switch customTimer.timerType {
                case .emom:
                    EMOMView(customTimer: $customTimer)
                case .upTimer:
                    UpTimerView(customTimer: $customTimer)
                }
            } else {
                VStack {
                    Button(action: {
                        selectEMOMViewModel.setTimertype(type: .emom)
                        startCreateTimerFlow.toggle()
                    }, label: {
                        HStack {
                            Image(systemName: "timer")
                                .resizable()
                                .foregroundColor(.electricBlue)
                                .frame(width: 20.0, height: 20.0)
                            Text("EMOM timer")
                        }
                    })
                    Button(action: {
                        selectEMOMViewModel.setTimertype(type: .upTimer)
                        startCreateTimerFlow.toggle()
                    }, label: {
                        HStack {
                            Image(systemName: "timer")
                                .resizable()
                                .foregroundColor(.electricBlue)
                                .frame(width: 20.0, height: 20.0)
                            Text("Up timer")
                        }
                    })
                }
                .fullScreenCover(isPresented: $startCreateTimerFlow) {
                    CreateCustomTimerView(customTimer: $customTimer)
                        .environmentObject(selectEMOMViewModel)
                }
            }
        }
    }
}

#Preview {
    TimersSelectionView()
}
