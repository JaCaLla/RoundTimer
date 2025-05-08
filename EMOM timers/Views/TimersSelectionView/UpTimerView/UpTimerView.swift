//
//  EMOMView.swift
//  EMOM timers
//
//  Created by Javier Calartrava on 17/5/24.
//

import SwiftUI

struct UpTimerView: View {
    let bottonSideSize = 50.0
    @Environment(\.scenePhase) private var scenePhase
    @Binding var customTimer: CustomTimer?
    @StateObject var emomViewModel = UpTimerViewModel()

    var body: some View {
        VStack {
            HStack {
                Spacer()
                closeButton()
            }
            Spacer()
            VStack {
                message()
                HStack {
                    rounds()
                    Spacer()
                    mmss()
                }
            }
            Spacer()
        }
        .onAppear {
            guard emomViewModel.state.value == .notStarted else { return }
            emomViewModel.setAndStart(emom: customTimer)
        }
        .contentShape(Rectangle())
    }
    
    private func closeButton() -> some View {
        Button(action: {
            emomViewModel.close()
            customTimer = nil
        }, label: {
                Image(systemName: "xmark")
            })
            .modifier(ButtonAW())
    }
    
    private func message() -> some View {
        Text("\(emomViewModel.getCurrentMessage())")
            .foregroundStyle(.white)
            .font(.messageiOSAppFont)
    }
    
    private func rounds() -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
                        Text((emomViewModel.getCurrentRound()))
                            .font(.timerAndRoundiOSAppFont)
        } .foregroundColor(.roundColor)
    }
    
    private func mmss() -> some View {
            Text(emomViewModel.mmss)
                .foregroundStyle(emomViewModel.getForegroundTextColor())
                .font(.timerAndRoundiOSAppFont)
    }
}


#Preview("Small Font") {
    let model = EMOMViewModel()
    let customTimer = CustomTimer(timerType: .emom, rounds: 2, workSecs: 1800, restSecs: 0)

    model.setAndStart(emom: customTimer)
    return EMOMView(customTimer: .constant(customTimer))
        .environmentObject(model)
}
